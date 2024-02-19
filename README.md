# Synology Docker Kernel Action

This kernel action encapsulates a deployment of a synology toolchain and a kernel build with the given replacement kernelconfig
A kernel-build silo for the 3-tarball-plus-linux Synology toolchain setup

## Inputs

### `artifacts`

This is the relative paths of modules to include in the artifact.  Although an array or list would
be logical, currently this is a single string, space-separated.  For example,
"net/ipv4/netfilter/ipt_REJECT.ko net/ipv4/netfilter/nf_reject_ipv4.ko"

### `dsm-version`

**defaults to 7.2**

This is the DSM version of the Syno we're targeting, major/minor only.  For example, "7.2", "7.1"

### `package-arch`

**defaults to Denverton**

This is the target architecture, which Synology calls the "Package Arch": Purley, Grantley, v1000,
Broadwell, Denverton.  case-insensitive, this value will be sanitized as needed so

Denverton = denverton = DeNvErToN

### `module-deactivate`

This is a list of kernel symbols that should be deactivated in the build.  This is unusual for
modules, but can be used to circumvent build failures unrelated to the modules you're packing up.
Although an array or list would be logical, currently this is a single string, space-separated, all
uppercase.  For example, "CONFIG_NFSD CONFIG_NFS_FS"

### `module-modularize`

This is a list of kernel symbols that should be activated as modules in the build.  Although an
array or list would be logical, currently this is a single string, space-separated, all uppercase.
For example, "CONFIG_IP_NF_TARGET_REJECT CONFIG_NETFILTER_XT_MATCH_COMMENT"

## Outputs

### `time`

The time the kernel was built (expecting other things to follow)

## Example usage

uses: chickenandpork/synology-docker-kernel-action@v1
with:
  artifacts: net/ipv4/netfilter/ipt_REJECT.ko net/ipv4/netfilter/nf_reject_ipv4.ko net/netfilter/xt_comment.ko
  dsm-version: '7.2'
  module-deactivate: CONFIG_NFSD CONFIG_NFS_FS
  module-modularize: CONFIG_IP_NF_TARGET_REJECT CONFIG_NETFILTER_XT_MATCH_COMMENT
  package-arch: 'denverton'

