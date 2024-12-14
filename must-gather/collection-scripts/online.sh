#!/bin/bash -x

# Load common functions
source "$(dirname "$0")/common.sh"

run_online() {
  section_title "Running must-gather in online mode"

  # Fetch cluster version (single call)
  if [[ -z "$CLUSTER_VERSION" ]]; then
    action "Fetching OpenShift cluster version"
    if get_cluster_version; then
      success "Cluster version detected: $CLUSTER_VERSION"
    else
      error "Failed to fetch cluster version. Ensure the cluster is accessible."
      exit 1
    fi
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
  if oc cluster-compare -r cnf-features-deploy/ztp/kube-compare-reference/metadata.yaml; then
    success "RAN comparison completed successfully"
  else
    warning "RAN comparison failed"
  fi

  section_title "Running CORE Comparison"
  action "Running CORE comparison"
  echo "   Reference: telco-reference/telco-core/configuration/reference-crs-kube-compare/metadata.yaml"
  if oc cluster-compare -r telco-reference/telco-core/configuration/reference-crs-kube-compare/metadata.yaml; then
    success "CORE comparison completed successfully"
  else
    warning "CORE comparison failed"
  fi
}
