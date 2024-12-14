# kube-compare must-gather

`kube-compare-rds-must-gather` is a tool based on [OpenShift must-gather](https://github.com/openshift/must-gather). It enables enhanced functionality to run [kube-compare](https://github.com/openshift/kube-compare) against CORE and RAN reference guides to identify configuration differences in live clusters or must-gather data.

## Overview

`kube-compare-rds-must-gather` helps validate OpenShift cluster configurations by comparing live cluster state or must-gather dumps against predefined reference configurations. This tool supports CORE and RAN references, enabling streamlined troubleshooting and validation workflows in Telco environments.

## Using the kube-compare must-gather Image

### Help Command

```sh
podman run --rm -it quay.io/jclaret/kube-compare-rds:mustgather-0.1 --help
```

### Interactive Shell

```sh
podman run --rm -it --entrypoint /bin/bash quay.io/jclaret/kube-compare-rds:mustgather-0.1
```

### Online Mode (Default)

```sh
podman run --rm -it quay.io/jclaret/kube-compare-rds:mustgather-0.1
```

### Offline Mode

```sh
podman run --rm -it -v must-gather-dir:/must-gather-data:Z \
  quay.io/jclaret/kube-compare-rds:mustgather-0.1 --offline --must-gather-dir /must-gather-data
```

## Building and Testing the kube-compare must-gather Image Locally

You can build the kube-compare must-gather image locally using the provided `Containerfile.mustgather`. The `Makefile` simplifies the build and testing process with pre-defined commands.

### Build the Image

To clean up any existing images and build a new one, run:

```sh
make clean
make must-gather REGISTRY=quay.io/jclaret REPO=kube-compare-rds VERSION=0.1
```
### Test the Image

Verify that the image responds correctly to the --help flag:

```sh
make test-help
```

Test the image in online mode against a live cluster:

```sh
make test-online
```

Test the image in offline mode with a local must-gather directory:

```sh
make test-offline
```

NOTE: Before running test-offline, ensure you have a valid must-gather directory in the same path. You can generate one with the following command:

```sh
oc adm must-gather --dest-dir must-gather-offline
```

This will create a directory called must-gather-offline that can be used for the offline test.

## Reference Guides

### RAN Reference

The RAN reference for different OpenShift versions can be obtained from the following containers:

[version]: registry.redhat.io/openshift4/ztp-site-generate-rhel[version]:v[version]

Extracting the Reference:
```sh
podman run --rm --log-driver=none ${pullspec} extract /home/ztp --tar | tar x -C ./out
```

### CORE Reference

The CORE reference for OpenShift versions can be obtained from the following container:

[version]: registry.redhat.io/openshift4/openshift-telco-core-rds-rhel[version]:v[version]

Extracting the Reference:
```sh
podman run --rm ${pullspec} | base64 -d | tar xv -C out
```
