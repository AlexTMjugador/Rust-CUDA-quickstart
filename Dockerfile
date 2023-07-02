# Based on
# https://github.com/Rust-GPU/Rust-CUDA/blob/8a6cb734d21d5582052fa5b38089d1aa0f4d582f/Dockerfile,
# but updated, slightly fixed to never ask for interactive input during APT
# operations, and with an entrypoint for proper Rust setup as a host user

FROM nvidia/cuda:11.4.3-cudnn8-devel-ubuntu20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -yq \
    build-essential \
    curl xz-utils pkg-config libssl-dev zlib1g-dev libtinfo-dev libxml2-dev

# get prebuilt llvm
RUN curl -O https://releases.llvm.org/7.0.1/clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-18.04.tar.xz && \
    xz -d /clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-18.04.tar.xz && \
    tar xf /clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-18.04.tar && \
    rm /clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-18.04.tar && \
    mv /clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-18.04 /opt/llvm

# make ld aware of necessary *.so libraries
RUN echo /usr/local/cuda/lib64 >> /etc/ld.so.conf &&\
    echo /usr/local/cuda/compat >> /etc/ld.so.conf &&\
    echo /usr/local/cuda/nvvm/lib64 >> /etc/ld.so.conf &&\
    ldconfig

WORKDIR /rust-cuda
ENTRYPOINT ["/rust-cuda/entrypoint.sh"]
