#!/bin/sh -e

# Regenerate Cargo.lock by resolving minimal versions and
# then updating some too-old transitive dependencies.
# Modify as needed 
cargo update -Z minimal-versions
cargo update -p libc:0.1.1
cargo update -p filetime:0.1.0
cargo update -p rand:0.3.0
cargo update -p lzma-sys
