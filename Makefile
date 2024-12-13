# This Makefile builds, cleans, and tests a Must-Gather image using Podman or Docker.

# Define default values for variables if not set.
REGISTRY ?= quay.io/jclaret
REPO ?= kube-compare-rds
VERSION ?= latest

# Detect container tool (Podman or Docker). Error out if neither is available.
TOOL_BIN ?= $(shell which podman 2>/dev/null || which docker 2>/dev/null)
ifeq ($(TOOL_BIN),)
$(error "No container tool found (podman or docker). Please install one and try again.")
endif

# Define the image name based on inputs.
MUSTGATHER_IMAGE = $(REGISTRY)/$(REPO):mustgather-$(VERSION)
MUSTGATHER_DIR = must-gather-offline

# Define the current working directory.
CURPATH = $(PWD)

# Build the Must-Gather image.
.PHONY: must-gather
must-gather:
	@echo "Building Must-Gather image: $(MUSTGATHER_IMAGE)"
	$(TOOL_BIN) build -t $(MUSTGATHER_IMAGE) -f $(CURPATH)/Containerfile.mustgather .

# Clean the local image.
.PHONY: clean
clean:
	@echo "Cleaning up local image: $(MUSTGATHER_IMAGE)"
	$(TOOL_BIN) rmi -f $(MUSTGATHER_IMAGE) || true

# Test the Must-Gather image by running --help.
.PHONY: test-help
test-help: must-gather
	@echo "Testing Must-Gather image (--help)"
	$(TOOL_BIN) run --rm -it $(MUSTGATHER_IMAGE) --help

# Test the Must-Gather image online (by default)
.PHONY: test-online
test-online: must-gather
	@echo "Testing Must-Gather image (online)"
	$(TOOL_BIN) run --rm -it -v /root/.kcli/clusters/hub/auth/kubeconfig:/root/.kube/config:Z $(MUSTGATHER_IMAGE)

# Test the Must-Gather image offline
.PHONY: test-offline
test-offline: must-gather
	@echo "Testing Must-Gather image (online)"
	$(TOOL_BIN) run --rm -it -v /root/.kcli/clusters/hub/auth/kubeconfig:/root/.kube/config:Z -v $(MUSTGATHER_DIR):/must-gather:Z $(MUSTGATHER_IMAGE)

# Display usage if the user runs "make help".
.PHONY: help
help:
	@echo "Usage:"
	@echo "  make must-gather [REGISTRY=<registry>] [REPO=<repository>] [VERSION=<version>]"
	@echo "  make clean"
	@echo "  make test-help"
	@echo "Defaults:"
	@echo "  REGISTRY=$(REGISTRY)"
	@echo "  REPO=$(REPO)"
	@echo "  VERSION=$(VERSION)"

