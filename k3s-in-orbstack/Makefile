# Variables
NODES ?= 3
WORKERS = $(shell expr $(NODES) - 1)

USER := $(shell whoami)
SSH_KEY := ~/.orbstack/ssh/id_ed25519
CONTROL_PLANE := control-plane
DOMAIN := orb.local
KUBECONFIG_FILE := kubeconfig
STATE_FILE := .cluster_state

.PHONY: all vms install teardown test

# The default target that builds everything
all: vms install

# Step 1: Spin up the bare Ubuntu VMs and save state
vms:
	@echo "Initializing cluster state..."
	@> $(STATE_FILE) # Clear or create the state file
	@echo "Creating $(CONTROL_PLANE) in OrbStack..."
	orb create ubuntu $(CONTROL_PLANE)
	@echo $(CONTROL_PLANE) >> $(STATE_FILE)
	@if [ $(WORKERS) -gt 0 ]; then \
		for i in $$(seq 1 $(WORKERS)); do \
			echo "Creating worker-$$i..."; \
			orb create ubuntu worker-$$i; \
			echo worker-$$i >> $(STATE_FILE); \
		done; \
	fi
	@echo "VMs created. Waiting a few seconds for SSH daemons to initialize..."
	sleep 5

# Step 2: Install k3s via k3sup and output kubeconfig locally
install:
	@echo "Bootstrapping K3s control plane..."
	k3sup install \
		--host $(CONTROL_PLANE).$(DOMAIN) \
		--user $(USER) \
		--ssh-key $(SSH_KEY) \
		--local-path $(KUBECONFIG_FILE) \
		--cluster
	
	@if [ $(WORKERS) -gt 0 ]; then \
		for i in $$(seq 1 $(WORKERS)); do \
			echo "Joining worker-$$i to the cluster..."; \
			k3sup join \
				--host worker-$$i.$(DOMAIN) \
				--server-host $(CONTROL_PLANE).$(DOMAIN) \
				--user $(USER) \
				--ssh-key $(SSH_KEY); \
		done; \
	fi
	@echo "✅ Cluster is ready!"
	@echo "👉 To use kubectl locally, run: export KUBECONFIG=\$$(pwd)/$(KUBECONFIG_FILE)"

# Step 3: Nuke the VMs using the state file and clean up
teardown:
	@if [ -f $(STATE_FILE) ]; then \
		echo "Found state file. Destroying tracked VMs..."; \
		for vm in $$(cat $(STATE_FILE)); do \
			echo "Destroying $$vm..."; \
			orb delete $$vm || true; \
		done; \
		echo "Removing state file..."; \
		rm -f $(STATE_FILE); \
	else \
		echo "No state file found. Attempting default cleanup for $(CONTROL_PLANE)..."; \
		orb delete $(CONTROL_PLANE) || true; \
	fi
	@echo "Removing local $(KUBECONFIG_FILE)..."
	rm -f $(KUBECONFIG_FILE)
	@echo "✅ Teardown complete. Bare metal environment and config destroyed."

# Helper target to verify the cluster using the local config
test:
	@KUBECONFIG=$(KUBECONFIG_FILE) kubectl get nodes
