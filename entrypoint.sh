#!/bin/bash
echo "Entrypoint running ($0) with ${*}" 1>&2

usage() { echo "Syno Docker Kernel Entrypoint: $0 [-a <PackageArch>][-v <version>]" 1>&2; exit 1; }

localconfig=/tmp/localconfig

while getopts "a:m:n:t:v:" o; do
    case "${o}" in
        a)
            PACKAGEARCH=${OPTARG}
            ;;
        t)
            ARTIFACTS=${OPTARG}
            ;;
        m)  # make it a module
            for M in ${OPTARG}; do
                test "${M}" == "@" || echo "${M}=m" >> ${localconfig}
            done
            ;;
        n)  # deactivate
            for M in ${OPTARG}; do
                test "${M}" == "@" || echo "${M}=n" >> ${localconfig}
            done
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

touch ${localconfig}  # avoid missing file if no options are altered and merge_config may not handle non-existent file

if [ -z "${PACKAGEARCH}" ]; then
    usage
fi

PACKAGEARCH=$(echo "${PACKAGEARCH}" | tr 'A-Z' 'a-z')
VERSION=$(echo "${VERSION}" | tr -cd '\.0-9-')


echo "Package Arch = ${PACKAGEARCH}"
echo "Version      = ${VERSION}"
echo "Local Config ====="
test -f ${localconfig} && sort ${localconfig} || true
echo "Local Config ^^^^^"

stubbed_version_resolver() {
    # $1 == Arch
    # $2 == Version
    # $3 == Victim array to be populated
    local -n res=$3

    DL_BASE="https://global.synologydownload.com/download/ToolChain"
    case ${1} in
        denverton) ;;
        *) echo "Package Architecture ${1} not supported" 1>&2; return 1;;
    esac

    case ${2} in
        7.2*)
            KERNEL_BASE="${DL_BASE}/Synology%20NAS%20GPL%20Source/7.2-64570/${1}/linux-4.4.x.txz"
            BASE="${DL_BASE}/toolkit/${2}/base/base_env-${2}.txz"
            DEV="${DL_BASE}/toolkit/${2}/${1}/ds.denverton-${2}.dev.txz"
            ENV="${DL_BASE}/toolkit/${2}/${1}/ds.denverton-${2}.env.txz"
            KSUBDIR="linux-4.4.x"
            ;;
        *) echo "Kernel version ${2} not supported" 1>&2; return 1;;
    esac

    res=("${KERNEL_BASE}" "${BASE}" "${ENV}" "${DEV}" "${KSUBDIR}")
    declare -p res
}

fetch() {
    echo "::group::Fetch Resources"
    # $1 == tarballs array
    local -n t=$1

    mkdir /tarballs
    #RUN curl -o /tarballs/linux.txz https://global.synologydownload.com/download/ToolChain/Synology%20NAS%20GPL%20Source/7.2-64570/denverton/linux-4.4.x.txz
    curl -kLo /tarballs/linux.txz "${t[0]}"
    #RUN curl -o /tarballs/gcc.txz https://global.synologydownload.com/download/ToolChain/toolchain/7.2-63134/Intel%20x86%20Linux%204.4.302%20%28Denverton%29/denverton-gcc1220_glibc236_x86_64-GPL.txz
    #RUN curl -o /tarballs/base.txz https://global.synologydownload.com/download/ToolChain/toolkit/7.2/base/base_env-7.2.txz
    curl -kLo /tarballs/base.txz "${t[1]}"
    #RUN curl -o /tarballs/dev.txz https://global.synologydownload.com/download/ToolChain/toolkit/7.2/denverton/ds.denverton-7.2.dev.txz
    curl -kLo /tarballs/dev.txz "${t[2]}"
    #RUN curl -o /tarballs/env.txz https://global.synologydownload.com/download/ToolChain/toolkit/7.2/denverton/ds.denverton-7.2.env.txz
    curl -kLo /tarballs/env.txz "${t[3]}"

    # t[4] is kernel subdir (ie "linux-4.4.x")

    ls -al /tarballs/
    echo "::endgroup::"
}

unpack() {
    echo "::group::Unpack Resources"
    local -n t=$1

    mkdir -p /synobuild/usr/local

    echo "unpacking base"
    tar Jxf /tarballs/base.txz -C /synobuild/

    echo "unpacking dev"
    tar Jxf /tarballs/dev.txz -C /synobuild/

    echo "unpacking env"
    tar Jxf /tarballs/env.txz -C /synobuild/

    echo "unpacking linux"
    tar Jxf /tarballs/linux.txz -C /synobuild/usr/local

    echo "checking"
    test -d /synobuild/usr/local/${t[4]}  # t[4] is kernel subdir (ie "linux-4.4.x")
    ls -al /synobuild/usr/local/${t[4]}/scripts/kconfig/
    echo "::endgroup::"
}

merge() {
    echo "::group::Merging Config and Building"
    local -n t=$1

    ls -al /synobuild/usr/local/${t[4]}/scripts/kconfig/

    cat ${localconfig} >>/synobuild/localconfig
    # https://stackoverflow.com/a/39440863 <== merge_config

    # not setting (yet): KBUILD_BUILD_HOST
    # not setting (yet): KBUILD_BUILD_USER
    # not setting (yet): SOURCE_DATE_EPOCH

    chroot /synobuild bash -c 'cd /usr/local/linux-* && ./scripts/kconfig/merge_config.sh synoconfigs/denverton /localconfig && make modules'
    echo "::endgroup::"
}

pack_modules() {
    echo "::group::Packing Modules"
    local -n t=$1

    ls -al /synobuild/usr/local/${t[4]}/scripts/kconfig/

    chroot /synobuild bash -c 'cd /usr/local/linux-* && ./scripts/kconfig/merge_config.sh synoconfigs/denverton /localconfig && make modules'
    echo "::endgroup::"
}

manifest() {
    echo "::group::Determining Manifest"
    local -n t=$1
    case "${2}" in
        @) chroot "/synobuild/usr/local/${t[4]}/" bash -c 'find / -name \*.ko -print' > /manifest ;;
        *) for f in ${ARTIFACTS}; do echo ${f} >> /manifest ; done ;;
    esac
    echo "::endgroup::"
}

archive() {
    echo "::group::Archiving Artifacts"
    local -n t=$1

    ls -al ${2}
    head ${2}
    tar -cJf "${3}" -C "/synobuild/usr/local/${tarballs[4]}/" --files-from=${2}
    echo "::endgroup::"
}




tarballs=()
stubbed_version_resolver "${PACKAGEARCH}" "${VERSION}" tarballs
declare -p tarballs
fetch tarballs
unpack tarballs
merge tarballs
manifest tarballs "${ARTIFACTS}"
archive tarballs "/manifest" /github/workspace/${PACKAGEARCH}-${VERSION}.txz
echo "archive=${PACKAGEARCH}-${VERSION}.txz" >> ${GITHUB_OUTPUT}
ls -al /github/workspace/
