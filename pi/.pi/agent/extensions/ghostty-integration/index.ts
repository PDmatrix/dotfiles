import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { closeSync, constants, existsSync, openSync, readFileSync, writeSync } from "node:fs";
import { homedir } from "node:os";
import { basename, join } from "node:path";

const EXTENSION_ID = "ghostty-integration";
const CONFIG_PATH = join(homedir(), ".pi", "agent", "extensions", EXTENSION_ID, "config.json");
const OSC = "\x1b]";
const ST = "\x1b\\";

interface GhosttyConfig {
	enabled: boolean;
	progress: {
		enabled: boolean;
		keepAliveMs: number;
		completionFlashMs: number;
	};
	title: {
		enabled: boolean;
		idle: string;
		thinking: string;
		tool: string;
	};
	notification: {
		enabled: boolean;
		minimumRunMs: number;
		title: string;
		body: string;
		sound: {
			enabled: boolean;
			path: string;
			volume: number;
		};
	};
}

const DEFAULT_CONFIG: GhosttyConfig = {
	enabled: true,
	progress: {
		enabled: true,
		// Ghostty expires stale progress after about 15 seconds and recommends
		// refreshing at least once per second.
		keepAliveMs: 1000,
		completionFlashMs: 500,
	},
	title: {
		enabled: true,
		idle: "π {project}{session}{model}",
		thinking: "● π {project}{session} · Thinking",
		tool: "● π {project}{session} · {tool}",
	},
	notification: {
		enabled: true,
		minimumRunMs: 0,
		title: "Pi is ready",
		body: "{project}{session} · Settled after {elapsed}",
		sound: {
			enabled: true,
			path: "/usr/share/sounds/ocean/stereo/completion-success.oga",
			volume: 0.5,
		},
	},
};

function asObject(value: unknown): Record<string, unknown> | undefined {
	return value !== null && typeof value === "object" && !Array.isArray(value)
		? (value as Record<string, unknown>)
		: undefined;
}

function booleanValue(value: unknown, fallback: boolean): boolean {
	return typeof value === "boolean" ? value : fallback;
}

function stringValue(value: unknown, fallback: string): string {
	return typeof value === "string" ? value : fallback;
}

function numberValue(value: unknown, fallback: number, minimum: number, maximum: number): number {
	if (typeof value !== "number" || !Number.isFinite(value)) return fallback;
	return Math.min(maximum, Math.max(minimum, Math.round(value)));
}

function decimalValue(value: unknown, fallback: number, minimum: number, maximum: number): number {
	if (typeof value !== "number" || !Number.isFinite(value)) return fallback;
	return Math.min(maximum, Math.max(minimum, value));
}

function loadConfig(): { config: GhosttyConfig; error?: string } {
	if (!existsSync(CONFIG_PATH)) return { config: structuredClone(DEFAULT_CONFIG) };

	try {
		const root = asObject(JSON.parse(readFileSync(CONFIG_PATH, "utf8"))) ?? {};
		const progress = asObject(root.progress) ?? {};
		const title = asObject(root.title) ?? {};
		const notification = asObject(root.notification) ?? {};
		const sound = asObject(notification.sound) ?? {};

		return {
			config: {
				enabled: booleanValue(root.enabled, DEFAULT_CONFIG.enabled),
				progress: {
					enabled: booleanValue(progress.enabled, DEFAULT_CONFIG.progress.enabled),
					keepAliveMs: numberValue(progress.keepAliveMs, DEFAULT_CONFIG.progress.keepAliveMs, 250, 10_000),
					completionFlashMs: numberValue(
						progress.completionFlashMs,
						DEFAULT_CONFIG.progress.completionFlashMs,
						0,
						10_000,
					),
				},
				title: {
					enabled: booleanValue(title.enabled, DEFAULT_CONFIG.title.enabled),
					idle: stringValue(title.idle, DEFAULT_CONFIG.title.idle),
					thinking: stringValue(title.thinking, DEFAULT_CONFIG.title.thinking),
					tool: stringValue(title.tool, DEFAULT_CONFIG.title.tool),
				},
				notification: {
					enabled: booleanValue(notification.enabled, DEFAULT_CONFIG.notification.enabled),
					minimumRunMs: numberValue(
						notification.minimumRunMs,
						DEFAULT_CONFIG.notification.minimumRunMs,
						0,
						86_400_000,
					),
					title: stringValue(notification.title, DEFAULT_CONFIG.notification.title),
					body: stringValue(notification.body, DEFAULT_CONFIG.notification.body),
					sound: {
						enabled: booleanValue(sound.enabled, DEFAULT_CONFIG.notification.sound.enabled),
						path: stringValue(sound.path, DEFAULT_CONFIG.notification.sound.path),
						volume: decimalValue(sound.volume, DEFAULT_CONFIG.notification.sound.volume, 0, 1),
					},
				},
			},
		};
	} catch (error) {
		return {
			config: structuredClone(DEFAULT_CONFIG),
			error: error instanceof Error ? error.message : String(error),
		};
	}
}

function isGhostty(): boolean {
	return (
		process.env.TERM_PROGRAM?.toLowerCase() === "ghostty" ||
		process.env.TERM?.toLowerCase().includes("ghostty") === true ||
		Boolean(process.env.GHOSTTY_RESOURCES_DIR)
	);
}

function sanitizeOscText(value: string): string {
	return value
		.replace(/[\u0000-\u001f\u007f-\u009f]+/g, " ")
		.replace(/;/g, ":")
		.replace(/\s+/g, " ")
		.trim();
}

function formatElapsed(milliseconds: number): string {
	const totalSeconds = Math.max(0, Math.round(milliseconds / 1000));
	if (totalSeconds < 60) return `${totalSeconds}s`;
	const minutes = Math.floor(totalSeconds / 60);
	const seconds = totalSeconds % 60;
	if (minutes < 60) return seconds === 0 ? `${minutes}m` : `${minutes}m ${seconds}s`;
	const hours = Math.floor(minutes / 60);
	const remainingMinutes = minutes % 60;
	return remainingMinutes === 0 ? `${hours}h` : `${hours}h ${remainingMinutes}m`;
}

export default function ghosttyIntegration(pi: ExtensionAPI) {
	let config = structuredClone(DEFAULT_CONFIG);
	let runtimeEnabled = true;
	let ttyFd: number | undefined;
	let tuiSession = false;
	let working = false;
	let runStartedAt = 0;
	let currentCwd = process.cwd();
	let currentModel: string | undefined;
	let currentSession: string | undefined;
	const activeTools = new Map<string, string>();
	let keepAliveTimer: ReturnType<typeof setInterval> | undefined;
	let completionTimer: ReturnType<typeof setTimeout> | undefined;

	function openTerminal(): void {
		if (ttyFd !== undefined || !tuiSession || !isGhostty()) return;
		try {
			ttyFd = openSync("/dev/tty", constants.O_WRONLY | constants.O_NOCTTY);
		} catch {
			// A TTY-less child/session should remain a silent no-op.
		}
	}

	function closeTerminal(): void {
		if (ttyFd === undefined) return;
		try {
			closeSync(ttyFd);
		} catch {}
		ttyFd = undefined;
	}

	function writeTerminal(sequence: string): void {
		if (!tuiSession || !isGhostty()) return;
		openTerminal();
		if (ttyFd !== undefined) {
			try {
				writeSync(ttyFd, sequence);
				return;
			} catch {
				closeTerminal();
			}
		}
		if (process.stdout.isTTY) process.stdout.write(sequence);
	}

	function setProgress(state: 0 | 1 | 2 | 3 | 4, value?: number): void {
		const progress = value === undefined ? "" : `;${Math.min(100, Math.max(0, Math.round(value)))}`;
		writeTerminal(`${OSC}9;4;${state}${progress}${ST}`);
	}

	function stopTimers(): void {
		if (keepAliveTimer !== undefined) clearInterval(keepAliveTimer);
		if (completionTimer !== undefined) clearTimeout(completionTimer);
		keepAliveTimer = undefined;
		completionTimer = undefined;
	}

	function templateValues(elapsedMs = 0): Record<string, string> {
		return {
			project: basename(currentCwd) || currentCwd,
			session: currentSession ? ` · ${currentSession}` : "",
			model: currentModel ? ` · ${currentModel}` : "",
			tool: [...activeTools.values()].at(-1) ?? "Working",
			elapsed: formatElapsed(elapsedMs),
		};
	}

	function renderTemplate(template: string, elapsedMs = 0): string {
		const values = templateValues(elapsedMs);
		return template.replace(/\{(project|session|model|tool|elapsed)\}/g, (_match, key: string) => values[key] ?? "");
	}

	function updateTitle(ctx: ExtensionContext): void {
		if (!runtimeEnabled || !config.title.enabled || !tuiSession || !isGhostty()) return;
		const template = working
			? activeTools.size > 0
				? config.title.tool
				: config.title.thinking
			: config.title.idle;
		ctx.ui.setTitle(renderTemplate(template));
	}

	function startProgress(): void {
		if (!config.progress.enabled) return;
		setProgress(3);
		if (keepAliveTimer !== undefined) clearInterval(keepAliveTimer);
		keepAliveTimer = setInterval(() => {
			if (working && runtimeEnabled) setProgress(3);
		}, config.progress.keepAliveMs);
		keepAliveTimer.unref?.();
	}

	function clearProgress(showCompletion: boolean): void {
		if (keepAliveTimer !== undefined) clearInterval(keepAliveTimer);
		keepAliveTimer = undefined;
		if (completionTimer !== undefined) clearTimeout(completionTimer);
		completionTimer = undefined;

		if (!config.progress.enabled || !showCompletion || config.progress.completionFlashMs === 0) {
			setProgress(0);
			return;
		}

		setProgress(1, 100);
		completionTimer = setTimeout(() => {
			setProgress(0);
			completionTimer = undefined;
		}, config.progress.completionFlashMs);
		completionTimer.unref?.();
	}

	async function playNotificationSound(): Promise<void> {
		const sound = config.notification.sound;
		if (!sound.enabled || !sound.path) return;
		try {
			// Play directly through PipeWire rather than relying on notification
			// sound hints. Plasma mutes those hints while fullscreen DND is active.
			const result = await pi.exec("pw-play", ["--volume", String(sound.volume), sound.path], {
				timeout: 10_000,
			});
			if (result.code !== 0) {
				console.warn(`[${EXTENSION_ID}] Sound playback failed: ${result.stderr.trim() || `exit ${result.code}`}`);
			}
		} catch (error) {
			console.warn(
				`[${EXTENSION_ID}] Sound playback failed: ${error instanceof Error ? error.message : String(error)}`,
			);
		}
	}

	async function sendNotification(elapsedMs: number): Promise<void> {
		if (!config.notification.enabled || elapsedMs < config.notification.minimumRunMs) return;
		const title = sanitizeOscText(renderTemplate(config.notification.title, elapsedMs));
		const body = sanitizeOscText(renderTemplate(config.notification.body, elapsedMs));
		// OSC 777 is Ghostty's supported desktop-notification protocol.
		writeTerminal(`${OSC}777;notify;${title || "Pi"};${body || "Ready for input"}${ST}`);
		await playNotificationSound();
	}

	function applyLoadedConfig(ctx?: ExtensionContext): void {
		const loaded = loadConfig();
		config = loaded.config;
		runtimeEnabled = config.enabled;
		if (loaded.error && ctx?.hasUI) {
			ctx.ui.notify(`Ghostty config error; using defaults: ${loaded.error}`, "warning");
		}
	}

	async function settle(ctx: ExtensionContext, notify: boolean): Promise<void> {
		if (!working) return;
		const elapsedMs = Date.now() - runStartedAt;
		working = false;
		activeTools.clear();
		clearProgress(true);
		updateTitle(ctx);
		if (notify) await sendNotification(elapsedMs);
	}

	pi.on("session_start", async (_event, ctx) => {
		tuiSession = ctx.mode === "tui";
		currentCwd = ctx.cwd;
		currentModel = ctx.model?.id;
		currentSession = pi.getSessionName();
		working = false;
		activeTools.clear();
		stopTimers();
		applyLoadedConfig(ctx);
		openTerminal();
		if (runtimeEnabled) setProgress(0);
		updateTitle(ctx);
	});

	pi.on("session_info_changed", async (event, ctx) => {
		currentSession = event.name;
		updateTitle(ctx);
	});

	pi.on("model_select", async (event, ctx) => {
		currentModel = event.model.id;
		updateTitle(ctx);
	});

	pi.on("agent_start", async (_event, ctx) => {
		if (!tuiSession || !isGhostty() || !runtimeEnabled) return;
		if (!working) {
			working = true;
			runStartedAt = Date.now();
			activeTools.clear();
		}
		if (completionTimer !== undefined) clearTimeout(completionTimer);
		completionTimer = undefined;
		startProgress();
		updateTitle(ctx);
	});

	pi.on("tool_execution_start", async (event, ctx) => {
		if (!working) return;
		activeTools.set(event.toolCallId, event.toolName);
		updateTitle(ctx);
	});

	pi.on("tool_execution_end", async (event, ctx) => {
		activeTools.delete(event.toolCallId);
		updateTitle(ctx);
	});

	pi.on("agent_settled", async (_event, ctx) => {
		// Another extension can start a run from this hook. Do not announce idle
		// unless Pi is genuinely idle after all retries and queued follow-ups.
		if (!ctx.isIdle()) return;
		await settle(ctx, true);
	});

	pi.on("session_shutdown", async (_event, ctx) => {
		working = false;
		activeTools.clear();
		stopTimers();
		setProgress(0);
		if (config.title.enabled && tuiSession && isGhostty()) ctx.ui.setTitle(renderTemplate(config.title.idle));
		closeTerminal();
		tuiSession = false;
	});

	pi.registerCommand("ghostty", {
		description: "Control Ghostty integration: status, reload, on, off, progress, notify",
		handler: async (args, ctx) => {
			const action = args.trim().toLowerCase() || "status";
			if (action === "status") {
				ctx.ui.notify(
					`Ghostty: ${isGhostty() ? "detected" : "not detected"}; integration: ${
						runtimeEnabled ? "on" : "off"
					}; config: ${CONFIG_PATH}`,
					"info",
				);
				return;
			}
			if (action === "reload") {
				applyLoadedConfig(ctx);
				stopTimers();
				setProgress(0);
				if (runtimeEnabled && working) {
					startProgress();
					updateTitle(ctx);
				} else if (!runtimeEnabled) {
					working = false;
					activeTools.clear();
					if (tuiSession && isGhostty()) ctx.ui.setTitle(renderTemplate(config.title.idle));
				} else {
					updateTitle(ctx);
				}
				ctx.ui.notify(`Reloaded ${CONFIG_PATH}`, "info");
				return;
			}
			if (action === "on") {
				runtimeEnabled = true;
				if (working) startProgress();
				updateTitle(ctx);
				ctx.ui.notify("Ghostty integration enabled for this session", "info");
				return;
			}
			if (action === "off") {
				working = false;
				activeTools.clear();
				stopTimers();
				setProgress(0);
				if (config.title.enabled && tuiSession && isGhostty()) {
					ctx.ui.setTitle(renderTemplate(config.title.idle));
				}
				runtimeEnabled = false;
				ctx.ui.notify("Ghostty integration disabled for this session", "info");
				return;
			}
			if (action === "progress") {
				setProgress(3);
				if (completionTimer !== undefined) clearTimeout(completionTimer);
				completionTimer = setTimeout(() => {
					setProgress(0);
					completionTimer = undefined;
				}, 3000);
				completionTimer.unref?.();
				ctx.ui.notify("Showing Ghostty progress test for 3 seconds", "info");
				return;
			}
			if (action === "notify") {
				const title = sanitizeOscText(renderTemplate(config.notification.title));
				writeTerminal(`${OSC}777;notify;${title || "Pi"};Ghostty notification test${ST}`);
				await playNotificationSound();
				ctx.ui.notify("Sent Ghostty notification and sound test", "info");
				return;
			}
			ctx.ui.notify("Usage: /ghostty [status|reload|on|off|progress|notify]", "warning");
		},
	});
}
