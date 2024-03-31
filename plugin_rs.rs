#[no_mangle]
extern fn add(left: usize, right: usize) -> usize {
    left + right
}

#[no_mangle]
extern fn activate() -> usize {
    add(10, 20)
}

#[no_mangle]
extern fn deactivate() -> usize {
    add(10, 10)
}
