#!/bin/sh -e

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

. ~/.cargo/env

export LLVM_CONFIG=/opt/llvm/bin/llvm-config
export CUDA_ROOT=/usr/local/cuda
export CUDA_PATH="$CUDA_ROOT"
export LLVM_LINK_STATIC=1
export PATH="$CUDA_ROOT/nvvm/lib64:$PATH"

exec bash -i
