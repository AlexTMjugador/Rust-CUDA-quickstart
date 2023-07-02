#![allow(improper_ctypes_definitions)]
#![no_std]
#![cfg_attr(
    target_os = "cuda",
    feature(register_attr),
    register_attr(nvvm_internal)
)]

use cuda_std::*;

extern crate alloc;

#[kernel]
pub unsafe fn add(a: &[f32], b: &[f32], c: *mut f32) {
    let idx = thread::index_1d() as usize;
    if idx < a.len() {
        let elem = &mut *c.add(idx);
        *elem = a[idx] + b[idx];
    }
}
