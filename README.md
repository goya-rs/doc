# What is it?

Goya is an eBPF framework which uses [Aya Framework](https://github.com/aya-rs/aya) for kernel space (In Rust) and [Cilium library](https://github.com/cilium/ebpf) (In Go) for user space.

# How to use it?

You need an [Aya environment](https://aya-rs.dev/book/start/development/) and go lang installed.

## Quick Start

If you want to test with docker, you can type:

```Bash
docker run --rm -it --name aya \
                    --privileged \
                    --network host \
                    -w /host/root/ \
                    -v /:/host \
                    -v /sys/kernel/debug:/sys/kernel/debug \
                    littlejo/aya:goya bash
```

* More info in [Dockerfile](./Dockerfile)

Now generate a new XDP project:

```Bash
cargo generate --name goya-xdp \
               -d program_type=xdp \
               -d default_iface=veth0 \
               https://github.com/goya-rs/goya-template
```

Compile and install the eBPF "hello world" program:

```Bash
cd goya-xdp/
task
```

If you need to attach the program to another interface, you can run:

```Bash
task IFACE=veth1
```

## Limitation

* Currently works only with:
  * **XDP** Programs
  * **classifier** programs
  * **kprobe** programs
  * **tracepoint** programs
* **Aya logs** are limited to plain text (No macros like `:mac` and `:ip` are not supported)
