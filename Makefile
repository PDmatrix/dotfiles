STATE_HOME := $(if $(XDG_STATE_HOME),$(XDG_STATE_HOME),$(HOME)/.local/state)
PROFILE_FILE := $(STATE_HOME)/dotfiles/profile
PROFILE ?= $(shell if test -r "$(PROFILE_FILE)"; then head -n 1 "$(PROFILE_FILE)"; else printf '%s' desktop; fi)

PACKAGES.desktop := atuin ghostty herdr pi starship zsh
PACKAGES.server := atuin herdr pi starship zsh
PACKAGES := $(PACKAGES.$(PROFILE))

ifeq ($(strip $(PACKAGES)),)
$(error Unknown PROFILE '$(PROFILE)'; expected desktop or server)
endif

STOW := stow --dir=$(CURDIR) --target=$(HOME) --no-folding

.PHONY: bootstrap stow restow unstow check

bootstrap:
	./bootstrap --profile $(PROFILE)

stow:
	$(STOW) --stow $(PACKAGES)

restow:
	$(STOW) --restow $(PACKAGES)

unstow:
	$(STOW) --delete $(PACKAGES)

check:
	$(STOW) --simulate --verbose=2 --stow $(PACKAGES)
