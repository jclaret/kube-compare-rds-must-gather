#!/bin/bash

# Text formatting
bold=$(tput bold)
normal=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
cyan=$(tput setaf 6)
reset=$(tput sgr0)

# Styled messages
action() {
  echo -e "${green}${bold}→${reset} $1"
}

info() {
  echo -e "${blue}[INFO]${reset} $1"
}

success() {
  echo -e "${green}[SUCCESS]${reset} $1"
}

warning() {
  echo -e "${yellow}[WARNING]${reset} $1"
}

error() {
  echo -e "${red}[ERROR]${reset} $1" >&2
}

separator() {
  echo -e "${cyan}───────────────────────────────────────────────────────${reset}"
}

section_title() {
  echo -e "${bold}${cyan}$1${reset}"
  separator
}

# Function to fetch the OpenShift cluster version (Online Mode)
get_cluster_version() {
  FULL_CLUSTER_VERSION=$(oc get clusterversion -o jsonpath='{.items[0].status.desired.version}')
  if [[ -z "$FULL_CLUSTER_VERSION" ]]; then
    error "Unable to determine the OpenShift cluster version."
    return 1
  fi
  CLUSTER_VERSION=$(echo "$FULL_CLUSTER_VERSION" | awk -F. '{print $1 "." $2}')
}

# Function to fetch cluster version from must-gather (Offline Mode)
get_cluster_version_offline() {
  local must_gather_dir=$1

  omc use /must-gather > /dev/null

  FULL_CLUSTER_VERSION=$(omc get clusterversion -o jsonpath='{.items[0].status.desired.version}')
  if [[ -z "$FULL_CLUSTER_VERSION" ]]; then
    error "Unable to determine the OpenShift cluster version from must-gather."
    return 1
  fi
  CLUSTER_VERSION=$(echo "$FULL_CLUSTER_VERSION" | awk -F. '{print $1 "." $2}')
}
