PACKAGES := atuin ghostty pi starship zsh
STOW := stow --dir=$(CURDIR) --target=$(HOME) --no-folding

.PHONY: bootstrap stow restow unstow check

bootstrap:
	./bootstrap

stow:
	$(STOW) --stow $(PACKAGES)

restow:
	$(STOW) --restow $(PACKAGES)

unstow:
	$(STOW) --delete $(PACKAGES)

check:
	$(STOW) --simulate --verbose=2 --stow $(PACKAGES)
