.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash

SD ?= /Volumes/Flipper SD

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

##@ Submodules

.PHONY: submodules
submodules: ## Initialize and pull all submodules
	git submodule update --init --recursive --jobs 8

.PHONY: submodules-update
submodules-update: ## Update all submodules to upstream tip (review before commit!)
	git submodule update --remote --recursive --jobs 8

.PHONY: submodules-status
submodules-status: ## Show status of all submodules
	@git submodule status

##@ Firmware

.PHONY: build-momentum
build-momentum: ## Build Momentum firmware (no flash)
	cd forks/momentum && FBT_NO_SYNC=1 ./fbt updater_package

.PHONY: flash-momentum
flash-momentum: ## Build and flash Momentum firmware via USB CDC
	cd forks/momentum && FBT_NO_SYNC=1 ./fbt FORCE=1 flash_usb_full

.PHONY: build-stock
build-stock: ## Build stock OFW firmware (no flash)
	cd forks/upstream-firmware && FBT_NO_SYNC=1 ./fbt updater_package

.PHONY: flash-stock
flash-stock: ## Build and flash stock OFW via USB CDC
	cd forks/upstream-firmware && FBT_NO_SYNC=1 ./fbt FORCE=1 flash_usb_full

##@ Apps

.PHONY: build-apps
build-apps: ## Build all custom apps for Momentum
	./scripts/build-apps.sh momentum

.PHONY: build-apps-stock
build-apps-stock: ## Build all custom apps for stock OFW
	./scripts/build-apps.sh stock

##@ SD Card

.PHONY: sd-deploy
sd-deploy: ## Deploy full SD card init (Momentum DBs + UberGuidoZ + IRDB + bruteforce + keys)
	./scripts/sd-deploy.sh "$(SD)"

.PHONY: sd-clean
sd-clean: ## Strip macOS metadata from SD card
	./scripts/sd-clean.sh "$(SD)"

.PHONY: sd-backup
sd-backup: ## Backup user captures from SD card to ~/flipperzero-sd-backup/<date>/
	./scripts/sd-backup.sh "$(SD)"

.PHONY: sd-eject
sd-eject: ## Cleanly eject the SD card
	diskutil eject "$(SD)"

##@ Diagnostics

.PHONY: flipper-status
flipper-status: ## Detect connected Flipper devices
	@echo "USB serial devices:"; ls /dev/cu.usbmodemflip_* 2>/dev/null || echo "  (none — Flipper not connected or in DFU)"
	@echo "STMicroelectronics USB devices:"; system_profiler SPUSBDataType 2>/dev/null | grep -B1 -A4 "STMicroelectronics" | head -10 || echo "  (none)"

.PHONY: sd-status
sd-status: ## Show SD card mount and usage
	@if [[ -d "$(SD)" ]]; then df -h "$(SD)" | tail -2; else echo "SD not mounted at $(SD)"; fi
