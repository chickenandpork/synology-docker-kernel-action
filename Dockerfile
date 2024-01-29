ARG  VER_UBUNTU=22
FROM ubuntu:${VER_UBUNTU}.04

RUN apt-get update && apt-get install -y --no-install-recommends curl xz-utils && apt-get clean && rm -rf /var/lib/apt/lists/*

# All the work is done in the entrypoint; entrypoint takes parameters that define the versiond of
# the DSM and thw architecture of the toolchain, then unpack it in an acceptable order, then do the
# work of a kernel build.  This is just a wrapper.

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
