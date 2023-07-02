#!/bin/sh -e

for vendor_patch_dir in vendor/patches/*; do
    vendor_name="${vendor_patch_dir#vendor/patches/}"

    for patch in "$vendor_patch_dir"/*.patch; do
        echo "> Applying patch $patch..."

        if git -C "vendor/$vendor_name" apply --check "../../$patch" 2>/dev/null; then
            git -C "vendor/$vendor_name" apply "../../$patch"
        fi
    done
done

docker build -t rust-cuda .

# Bind-mounting /etc/resolv.conf works around /etc/resolv.conf having
# too restrictive (i.e., root-only) read permissions in some environments.
# Bind-mounting /etc/passwd allows the container to see proper host user information
docker run \
	-v /etc/passwd:/etc/passwd -v /etc/resolv.conf:/etc/resolv.conf \
	-v "$HOME":"$HOME" \
	-v "$PWD":/rust-cuda \
	--gpus all -u "$(id -u)":"$(id -g)" --hostname "$(hostname)" \
	-it --rm rust-cuda
