#!/bin/bash

usage() { echo "Syno Docker Kernel Entrypoint: $0 [-a <PackageArch>][-v <version>" 1>&2; exit 1; }

while getopts "a:" o; do
    case "${o}" in
        a)
            PACKAGEARCH=${OPTARG}
            ;;
        v)
            VERSION=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${PACKAGEARCH}" ]; then
    usage
fi

PACKAGEARCH=$(echo "${PACKAGEARCH}" | tr 'A-Z' 'a-z')
VERSION=$(echo "${VERSION}" | tr -cd '\.0-9-')


echo "Package Arch = ${PACKAGEARCH}"
echo "Version      = ${VERSION}"



#RUN curl -o /tarballs/linux.txz https://global.synologydownload.com/download/ToolChain/Synology%20NAS%20GPL%20Source/7.2-64570/denverton/linux-4.4.x.txz
#RUN curl -o /tarballs/gcc.txz https://global.synologydownload.com/download/ToolChain/toolchain/7.2-63134/Intel%20x86%20Linux%204.4.302%20%28Denverton%29/denverton-gcc1220_glibc236_x86_64-GPL.txz
#RUN curl -o /tarballs/base.txz https://global.synologydownload.com/download/ToolChain/toolkit/7.2/base/base_env-7.2.txz
#RUN curl -o /tarballs/dev.txz https://global.synologydownload.com/download/ToolChain/toolkit/7.2/denverton/ds.denverton-7.2.dev.txz
#RUN curl -o /tarballs/env.txz https://global.synologydownload.com/download/ToolChain/toolkit/7.2/denverton/ds.denverton-7.2.env.txz
#

