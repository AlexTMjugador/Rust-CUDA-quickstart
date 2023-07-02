<div align="center">
<h1>Rust-CUDA quickstart</h1>

<i>Bring the <a href="https://github.com/Rust-GPU/Rust-CUDA">Rust-CUDA</a>
project back to life under modern Linux environments.</i>

</div>

# 💡 Background

`rustc` has an official [Tier 2
`nvptx64-nvidia-cuda`](https://doc.rust-lang.org/rustc/platform-support.html#tier-2)
target that leverages the corresponding [LLVM
backend](https://llvm.org/docs/NVPTXUsage.html) to generate portable PTX
assembly that can be translated to GPU-specific machine code by the CUDA driver
at runtime.

But there are several pitfalls with the idea of running CUDA kernels by
simply telling `rustc` to build for `nvptx64-nvidia-cuda`:

- LLVM's PTX code generation [is said to be
  buggy](https://rust-gpu.github.io/Rust-CUDA/faq.html#why-not-use-rustc-with-the-llvm-ptx-backend),
  sometimes producing completely invalid code.
- Generating PTX code is only part of the story: the built kernels must somehow
  be loaded and executed on the GPU. This task requires Rust bindings to parts
  of the CUDA API.

The amazing [Rust-CUDA](https://github.com/Rust-GPU/Rust-CUDA) project addresses
these pitfalls by introducing a custom `rustc` target that uses NVVM, NVIDIA's
proprietary PTX code generation backend included with the CUDA SDK, and offering
a set of crates with ergonomic Rust APIs for CUDA kernel development.

However, Rust-CUDA has been unmaintained for more than two years at the time of
this writing, and there is no indication of that changing soon. This is a great
problem, because Rust-CUDA is coupled with specific CUDA and nightly Rust
versions that date back to 2021 and are starting to show their age in the form
of increased incompatibilities with updated execution environments. Currently,
it's not possible to use Rust-CUDA as-is because it depends on an outdated major
CUDA version and most of the Rust ecosystem is pushing towards higher Rust
version requirements.

Several users have submitted pull requests to Rust-CUDA to update the versions
it's coupled to, but these update attempts have caused code generation
regressions that are seemingly difficult to pinpoint and fix.

# ✨ Purpose

As an easier and less risky solution to updating Rust-CUDA, this repository
defines a quickstart project and a controlled Docker environment capable of
executing Rust-CUDA as it was possible years ago. This is achieved by:

- Defining a Docker container with the latest supported CUDA and Ubuntu
  userspace component versions, so that the Rust-CUDA system dependencies work
  with the versions they were meant to work with, even if the host system is
  much more up-to-date.
- Carefully selecting Rust dependency versions, so that no crate in the
  dependency graph has an MSRV greater than `nightly-2021-12-04`.
- Patching Rust dependencies as needed to get them to build and work on more
  environments.

# 🔨 Usage

First off, remember to check out the submodules containing vendor code (`git
submodule update --init --recursive`). After that, execute `run.sh`, and if
everything goes fine you'll eventually find yourself at a shell where you can
execute `cargo run --release` to build and launch a CUDA kernel.

Your Docker installation must be set up to use the NVIDIA Container Toolkit, as
otherwise CUDA won't work in Docker containers.

When changing Cargo dependencies, remember to run `pin-deps.sh` to ensure that
the `Cargo.lock` file is not updated with too new crates. It may be necessary to
update that file as dependencies are modified.

The Rust side of this project is very similar to the simple add Rust-CUDA
example. A few bits of code have been copied from it.

In its current state, this repository will only work on Linux-like environments.
