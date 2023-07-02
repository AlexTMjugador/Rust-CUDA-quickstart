use cust::prelude::*;
use nanorand::{Rng, WyRand};
use std::error::Error;

const NUMBERS_LEN: usize = 100_000;

static KERNEL_PTX: &str = include_str!("../../../target/release/kernel.ptx");

fn main() -> Result<(), Box<dyn Error>> {
    let mut wyrand = WyRand::new();
    let mut lhs = vec![2.0f32; NUMBERS_LEN];
    wyrand.fill(&mut lhs);
    let mut rhs = vec![0.0f32; NUMBERS_LEN];
    wyrand.fill(&mut rhs);

    let _ctx = cust::quick_init()?;
    let module = Module::from_ptx(KERNEL_PTX, &[])?;
    let stream = Stream::new(StreamFlags::NON_BLOCKING, None)?;

    let lhs_gpu = lhs.as_slice().as_dbuf()?;
    let rhs_gpu = rhs.as_slice().as_dbuf()?;

    let mut out = vec![0.0f32; NUMBERS_LEN];
    let out_buf = out.as_slice().as_dbuf()?;

    let func = module.get_function("add")?;

    // Use the CUDA occupancy API to find an optimal launch configuration for the grid and block size.
    // This will try to maximize how much of the GPU is used by finding the best launch configuration for the
    // current CUDA device/architecture
    let (_, block_size) = func.suggested_launch_configuration(0, 0.into())?;

    let grid_size = (NUMBERS_LEN as u32 + block_size - 1) / block_size;

    println!(
        "using {} blocks and {} threads per block",
        grid_size, block_size
    );

    unsafe {
        launch!(
            // Slices are fat pointers composed of a raw pointer and a length
            func<<<grid_size, block_size, 0, stream>>>(
                lhs_gpu.as_device_ptr(),
                lhs_gpu.len(),
                rhs_gpu.as_device_ptr(),
                rhs_gpu.len(),
                out_buf.as_device_ptr(),
            )
        )?;
    }

    stream.synchronize()?;

    // Copy back the data from the GPU
    out_buf.copy_to(&mut out)?;

    println!("{} + {} = {}", lhs[0], rhs[0], out[0]);

    Ok(())
}
