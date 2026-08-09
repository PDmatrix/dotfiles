# Local Ghostty integration for Pi

A private, dependency-free Pi extension. It is installed globally from this directory, so Pi auto-discovers it and `/reload` reloads it.

## Behavior

- `agent_start`: changes the terminal title and starts Ghostty's native indeterminate progress bar.
- Tool execution: puts the active tool name in the title.
- `agent_settled`: flashes 100%, clears progress, restores the idle title, and sends a desktop notification.
- `session_shutdown`: clears timers, the native progress state, and `/dev/tty` resources.

The extension deliberately uses `agent_settled`, not `agent_end`, so retries, automatic compaction, and queued follow-ups do not produce premature notifications.

## Ghostty protocols

- Progress: `OSC 9;4` (state `3` is indeterminate, `1;100` is complete, `0` clears it).
- Notification: `OSC 777;notify;title;body`.
- Terminal title: Pi's `ctx.ui.setTitle()` API.

Ghostty expires progress after roughly 15 seconds, so the extension sends a keep-alive every second as recommended by Ghostty.

This machine has Ghostty 1.3.1, which supports the native progress protocol. Its defaults already enable both required settings:

```ini
desktop-notifications = true
progress-style = true
```

### KDE Plasma fullscreen notifications

Plasma 6.4+ automatically enables Do Not Disturb while a fullscreen application is focused. Ghostty sends normal-priority `GNotification` notifications, so Plasma suppresses their popups unless Ghostty is allowed through DND.

This machine has a per-application exception in `~/.config/plasmanotifyrc`:

```ini
[Applications][com.mitchellh.ghostty]
ShowPopupsInDndMode=true
```

This keeps fullscreen DND for other applications while allowing Pi notifications delivered by Ghostty.

OSC 777 contains only notification text; it has no sound field. Ghostty creates a normal GTK `GNotification` and does not request a sound, while Plasma's fullscreen DND also mutes notification sounds. Therefore this extension plays its completion sound directly with PipeWire's `pw-play`, independently of Plasma's notification-sound policy.

## Configuration

Edit [`config.json`](./config.json), then run `/ghostty reload` (or Pi's `/reload`).

Available template variables:

- `{project}` — current directory basename
- `{session}` — ` · session-name`, or empty
- `{model}` — ` · model-id`, or empty
- `{tool}` — current tool name
- `{elapsed}` — settled run duration

`notification.minimumRunMs` can suppress notifications for very short runs. It is `0` by default, so every settled run notifies.

The `notification.sound` object controls the independent completion sound:

```json
{
  "enabled": true,
  "path": "/usr/share/sounds/ocean/stereo/completion-success.oga",
  "volume": 0.5
}
```

Use a volume from `0.0` to `1.0`, or set `enabled` to `false`. The default avoids Ghostty's terminal audio-bell mechanism and plays directly through the system's current PipeWire output.

## Commands

- `/ghostty` or `/ghostty status`
- `/ghostty reload`
- `/ghostty on` / `/ghostty off` — session-only override
- `/ghostty progress` — three-second native progress test
- `/ghostty notify` — desktop notification test

## Research and inspiration

- Ghostty OSC 9;4 documentation: <https://ghostty.org/docs/vt/osc/conemu>
- Ghostty OSC 9 notification documentation: <https://ghostty.org/docs/vt/osc/9>
- Ghostty 1.2 native progress release notes: <https://ghostty.org/docs/install/release-notes/1-2-0#graphical-progress-bars>
- Pi extension lifecycle documentation: `docs/extensions.md`
- Pi examples: `titlebar-spinner.ts`, `notify.ts`, and `working-indicator.ts`
- Compared with `pi-terminal-signals`, `pi-ghostty`, and `pi-ghostty-notifier`; this implementation remains local so every behavior is under your control.
