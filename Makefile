VERSION := $(shell grep '^version =' Cargo.toml | head -1 | sed 's/.*"\(.*\)".*/\1/')
BINARY_NAME := my
DIST_DIR := dist

TARGETS := \
	aarch64-apple-darwin \
	aarch64-unknown-linux-gnu \
	armv7-unknown-linux-gnueabihf \
	x86_64-unknown-linux-gnu \
	x86_64-pc-windows-msvc

.PHONY: all clean install-targets $(TARGETS)

all: $(TARGETS)

$(TARGETS):
	cargo build --release --target $@
	@mkdir -p $(DIST_DIR)
	@if echo "$@" | grep -q "windows"; then \
		cp target/$@/release/$(BINARY_NAME).exe $(DIST_DIR)/$(BINARY_NAME)-$(VERSION)-$@.exe; \
	else \
		cp target/$@/release/$(BINARY_NAME) $(DIST_DIR)/$(BINARY_NAME)-$(VERSION)-$@; \
	fi
	@echo "Built $@ -> $(DIST_DIR)/"

install-targets:
	@for target in $(TARGETS); do \
		rustup target add $$target 2>/dev/null || true; \
	done

clean:
	cargo clean
	rm -rf $(DIST_DIR)
