///|
/// Bootstrap test: wasm5 runtime compiled to wasm, executing another wasm
/// This proves recursive bootstrap capability

// Embedded add.wasm binary (exports "add" function)
fn get_add_wasm() -> Bytes {
  b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x60\x02\x7f\x7f\x01\x7f\x03\x02\x01\x00\x07\x07\x01\x03\x61\x64\x64\x00\x00\x0a\x09\x01\x07\x00\x20\x00\x20\x01\x6a\x0b"
}

// Embedded fib.wasm binary (exports "fib" function)
fn get_fib_wasm() -> Bytes {
  b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x03\x02\x01\x00\x07\x07\x01\x03\x66\x69\x62\x00\x00\x0a\x1f\x01\x1d\x00\x20\x00\x41\x01\x4c\x04\x7f\x20\x00\x05\x20\x00\x41\x01\x6b\x10\x00\x20\x00\x41\x02\x6b\x10\x00\x6a\x0b\x0b"
}

///|
/// Test add function - returns 0 on success, error code otherwise
pub fn test_add() -> Int {
  let add_wasm = get_add_wasm()
  let add_module = try { @parse.parse(add_wasm) } catch { _ => return 1 }
  let add_rt = try { @runtime.Runtime::load(add_module) } catch { _ => return 2 }
  let add_result = try {
    add_rt.call_compiled(
      b"add",
      [@runtime.Value::I32(3), @runtime.Value::I32(5)],
    )
  } catch { _ => return 3 }

  // Verify add(3, 5) == 8
  match add_result[0] {
    @runtime.Value::I32(8) => 0
    _ => 4
  }
}

///|
/// Test fib function - returns 0 on success, error code otherwise
pub fn test_fib() -> Int {
  let fib_wasm = get_fib_wasm()
  let fib_module = try { @parse.parse(fib_wasm) } catch { _ => return 1 }
  let fib_rt = try { @runtime.Runtime::load(fib_module) } catch { _ => return 2 }
  let fib_result = try {
    fib_rt.call_compiled(b"fib", [@runtime.Value::I32(10)])
  } catch { _ => return 3 }

  // Verify fib(10) == 55
  match fib_result[0] {
    @runtime.Value::I32(55) => 0
    _ => 4
  }
}

///|
/// Run all bootstrap tests
pub fn run_bootstrap() -> Int {
  let add_result = test_add()
  if add_result != 0 {
    return add_result
  }
  let fib_result = test_fib()
  if fib_result != 0 {
    return 10 + fib_result
  }
  0
}

///|
fn main {
  let result = run_bootstrap()
  if result == 0 {
    println("Bootstrap tests passed!")
  } else {
    println("Bootstrap test failed with code: " + result.to_string())
  }
}
