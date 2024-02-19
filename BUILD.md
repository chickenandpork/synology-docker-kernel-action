# Building

## Build and Test

In order to repro the build-and-test I do, consider this:

```
mkdir -p $(pwd)/dist && \
  docker build -t synology-docker-kernel-action:latest -f Dockerfile . && \
  docker run -it --rm -v $(pwd)/dist:/github/workspace --entrypoint=/bin/bash synology-docker-kernel-action:latest \
    -a denverton \
    -v 7.2 \
    -m "CONFIG_IP_NF_TARGET_REJECT CONFIG_NETFILTER_XT_MATCH_COMMENT" \
    -n "CONFIG_NFSD CONFIG_NFS_FS" \
    -t "net/ipv4/netfilter/ipt_REJECT.ko net/netfilter/xt_comment.ko"
```

