# Synology Docker Kernel Action

This kernel action encapsulates a deployment of a synology toolchain and a kernel build with the given replacement kernelconfig
A kernel-build silo for the 3-tarball-plus-linux Synology toolchain setup

## Inputs

### `dsm-version`

**defaults to 7.2**

This is the DSM version of the Syno we're targeting, major/minor only.  For example, "7.2", "7.1"

### `package-arch`

**defaults to Denverton**

This is the target architecture, which Synology calls the "Package Arch": Purley, Grantley, v1000,
Broadwell, Denverton.  case-insensitive, this value will be sanitized as needed so

Denverton = denverton = DeNvErToN

## Outputs

### `time`

The time the kernel was built (expecting other things to follow)

## Example usage

uses: chickenandpork/synology-docker-kernel-action@v1
with:
  dsm-version: '7.2'
  package-arch: 'denverton'

