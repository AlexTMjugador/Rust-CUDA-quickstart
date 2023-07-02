use cuda_builder::CudaBuilder;

fn main() {
    CudaBuilder::new("../cuda-kernel")
        .copy_to("../../target/release/kernel.ptx")
        .build()
        .unwrap();
}
