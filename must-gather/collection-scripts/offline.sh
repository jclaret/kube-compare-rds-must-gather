#!/bin/bash

run_offline() {
  local must_gather_dir=$1
  info "Running must-gather in offline mode with directory: $must_gather_dir"
  
  validate_oc_cli
  get_cluster_version

  RAN_REPO="https://github.com/openshift-kni/cnf-features-deploy.git"
  CORE_REPO="https://github.com/openshift-kni/telco-reference.git"

  info "Cloning RAN repository..."
  git clone $RAN_REPO
  success "Cloned RAN repository."

  info "Running RAN comparison..."
  oc cluster-compare -r cnf-features-deploy/ztp/kube-compare-reference/metadata.yaml \
    -f "$must_gather_dir/*/cluster-scoped-resources,$must_gather_dir/*/namespaces" -R || warning "RAN comparison failed."

  info "Cloning CORE repository..."
  git clone $CORE_REPO
  success "Cloned CORE repository."

  info "Running CORE comparison..."
  oc cluster-compare -r telco-reference/telco-core/configuration/reference-crs-kube-compare/metadata.yaml \
    -f "$must_gather_dir/*/cluster-scoped-resources,$must_gather_dir/*/namespaces" -R || warning "CORE comparison failed."
}
