#!/bin/bash -x

# Load common functions
source "$(dirname "$0")/common.sh"

run_offline() {
  section_title "Running must-gather in offline mode"

  # Validate input directory
  if [[ -z "$MUST_GATHER_DIR" || ! -d "$MUST_GATHER_DIR" ]]; then
    error "Invalid must-gather directory: $MUST_GATHER_DIR. Ensure the directory exists and is accessible."
    exit 1
  fi

  # Fetch cluster version from must-gather directory
  action "Fetching OpenShift cluster version from must-gather data"
  if get_cluster_version_offline; then
    success "Cluster version detected from must-gather data: $CLUSTER_VERSION"
  else
    error "Failed to fetch cluster version from must-gather data."
    exit 1
  fi

  # Clone Repositories
  section_title "Cloning Repositories"

  action "Cloning RAN repository: https://github.com/openshift-kni/cnf-features-deploy.git"
  if git clone --quiet https://github.com/openshift-kni/cnf-features-deploy.git; then
    success "RAN repository cloned successfully"
  else
    warning "Failed to clone RAN repository. Proceeding with existing data if available."
  fi

  action "Cloning CORE repository: https://github.com/openshift-kni/telco-reference.git"
  if git clone --quiet https://github.com/openshift-kni/telco-reference.git; then
    success "CORE repository cloned successfully"
  else
    warning "Failed to clone CORE repository. Proceeding with existing data if available."
  fi

  # Run Comparisons
  section_title "Running RAN Comparison"
  action "Running RAN comparison"
  echo "   Reference: cnf-features-deploy/ztp/kube-compare-reference/metadata.yaml"
  if oc cluster-compare -r cnf-features-deploy/ztp/kube-compare-reference/metadata.yaml \
    -f "$MUST_GATHER_DIR/*/cluster-scoped-resources,$MUST_GATHER_DIR/*/namespaces" -R; then
    success "RAN comparison completed successfully"
  else
    warning "RAN comparison failed"
  fi

  section_title "Running CORE Comparison"
  action "Running CORE comparison"
  echo "   Reference: telco-reference/telco-core/configuration/reference-crs-kube-compare/metadata.yaml"
  if oc cluster-compare -r telco-reference/telco-core/configuration/reference-crs-kube-compare/metadata.yaml \
    -f "$MUST_GATHER_DIR/*/cluster-scoped-resources,$MUST_GATHER_DIR/*/namespaces" -R; then
    success "CORE comparison completed successfully"
  else
    warning "CORE comparison failed"
  fi
}

