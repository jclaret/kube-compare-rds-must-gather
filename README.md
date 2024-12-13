kube-compare must-gather
=========================

`kube-compare-rds-must-gather` is a tool built on top of [OpenShift must-gather](https://github.com/openshift/must-gather)
that expands its capabilities to gather LVM Operator information.

### Getting the plugin
```
podman create --name kca
podman create --name kca registry.redhat.io/openshift4/kube-compare-artifacts-rhel9:latest
podman cp kca:/usr/share/openshift/linux_amd64/kube-compare.rhel9 /usr/local/bin/kubectl-cluster_compare
```

### Getting the Reference for RAN

4.18: registry.redhat.io/openshift4/ztp-site-generate-rhel8:v4.18 
4.16: registry.redhat.io/openshift4/ztp-site-generate-rhel8:v4.16
4.14: registry.redhat.io/openshift4/ztp-site-generate-rhel8:v4.14

To extract from container:
```
podman run --rm --log-driver=none ${pullspec} extract /home/ztp --tar | tar x -C ./out
```

### Getting the Reference for Core

4.17: registry.redhat.io/openshift4/openshift-telco-core-rds-rhel9:v4.17

To extract from container:
```
podman run -it ${pullspec} | base64 -d | tar xv -C out
```

### Run the tool
Live cluster
```
oc cluster-compare -r https://raw.githubusercontent.com/openshift-kni/cnf-features-deploy/master/ztp/kube-compare-reference/metadata.yaml
```

Must gather
```
oc cluster-compare -r https://raw.githubusercontent.com/openshift-kni/cnf-features-deploy/master/ztp/kube-compare-reference/metadata.yaml -f "must-gather*/*/cluster-scoped-resources","must-gather*/*/namespaces" -R
```

NOTE:
Each CR with a diff is displayed. 
 * The “-” indicates expected content that is missing
 * The “+” indicates content that is in the CR but not in the reference
Summary output
* Number of CRs found with diffs
* Listing of required CRs which are missing
* Listing of CRs which had no corresponding reference CR
* More common when run against must-gather
* Metadata Hash → Identifies the reference
* Patched CRs → Advanced function (see slides at end)



### Usage
```sh
oc adm must-gather --image=quay.io/kube-compare-rds/must-gather:latest
```

The command above will create a local directory with a dump of the lvm state.

You will get a dump of:

#### Building the image locally
The `Dockerfile.mustgather` can be used to build a local local-storage must-gather image. This file is referenced in the `Makefile`, and can be built using the following command:

```sh
make clean
make must-gather REGISTRY=quay.io/jclaret REPO=kube-compare-rds VERSION=0.1
make test-help
make test-online
make test-offline

podman run --rm -it quay.io/jclaret/kube-compare-rds:mustgather-0.1 --help
podman run --rm -it --entrypoint /bin/bash quay.io/jclaret/kube-compare-rds:mustgather-0.1
podman run --rm -it quay.io/jclaret/kube-compare-rds:mustgather-0.1 (online by default)
podman run --rm -it -v must-gather-dir:/must-gather-data:Z quay.io/jclaret/kube-compare-rds:mustgather-0.1 --offline --must-gather-dir <directory>
```
