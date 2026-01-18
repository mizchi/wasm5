///|
/// wasm5 API for Cloudflare Workers
/// Provides functions to parse and execute WebAssembly modules

/// Memory for passing data between JS and wasm
let shared_memory : Array[Byte] = []

///|
/// Allocate memory for passing wasm bytes
pub fn cabi_realloc(
  _old_ptr : Int,
  _old_size : Int,
  _align : Int,
  new_size : Int,
) -> Int {
  shared_memory.resize(new_size, b'\x00')
  0 // Return pointer (we use index 0)
}

///|
/// Free allocated memory
pub fn cabi_free(_ptr : Int, _size : Int) -> Unit {
  shared_memory.clear()
}

///|
/// Get a byte from shared memory
pub fn get_byte(idx : Int) -> Int {
  if idx < shared_memory.length() {
    shared_memory[idx].to_int()
  } else {
    0
  }
}

///|
/// Set a byte in shared memory
pub fn set_byte(idx : Int, val : Int) -> Unit {
  if idx < shared_memory.length() {
    shared_memory[idx] = val.to_byte()
  }
}

///|
/// Execute a wasm module from shared memory
/// Args: wasm_size, func_name_ptr, func_name_len, arg1, arg2
/// Returns: result value (i32) or -1 on error
pub fn execute_wasm(
  wasm_size : Int,
  func_name_ptr : Int,
  func_name_len : Int,
  arg1 : Int,
  arg2 : Int,
) -> Int {
  // Extract wasm bytes
  let wasm_arr : Array[Byte] = []
  for i in 0..<wasm_size {
    wasm_arr.push(shared_memory[i])
  }
  let wasm_bytes = Bytes::from_array(wasm_arr)

  // Extract function name
  let name_arr : Array[Byte] = []
  for i in 0..<func_name_len {
    name_arr.push(shared_memory[func_name_ptr + i])
  }
  let func_name = Bytes::from_array(name_arr)

  // Parse module
  let module_ = try {
    @parse.parse(wasm_bytes)
  } catch {
    _ => return -1
  }

  // Load runtime
  let rt = try {
    @runtime.Runtime::load(module_)
  } catch {
    _ => return -2
  }

  // Call function with two i32 arguments
  let args = [@runtime.Value::I32(arg1.reinterpret_as_uint()), @runtime.Value::I32(arg2.reinterpret_as_uint())]
  let results = try {
    rt.call_compiled(func_name, args)
  } catch {
    _ => return -3
  }

  // Return first result
  match results.get(0) {
    Some(@runtime.Value::I32(v)) => v.reinterpret_as_int()
    Some(@runtime.Value::I64(v)) => v.reinterpret_as_int64().to_int()
    _ => -4
  }
}

///|
/// Simple test: add two numbers using embedded add.wasm
pub fn test_add(a : Int, b : Int) -> Int {
  let add_wasm : Bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x60\x02\x7f\x7f\x01\x7f\x03\x02\x01\x00\x07\x07\x01\x03\x61\x64\x64\x00\x00\x0a\x09\x01\x07\x00\x20\x00\x20\x01\x6a\x0b"
  let module_ = try { @parse.parse(add_wasm) } catch { _ => return -1 }
  let rt = try { @runtime.Runtime::load(module_) } catch { _ => return -2 }
  let args = [@runtime.Value::I32(a.reinterpret_as_uint()), @runtime.Value::I32(b.reinterpret_as_uint())]
  let results = try { rt.call_compiled(b"add", args) } catch { _ => return -3 }
  match results.get(0) {
    Some(@runtime.Value::I32(v)) => v.reinterpret_as_int()
    _ => -4
  }
}

///|
fn main {
  // Test the API
  let result = test_add(3, 5)
  println("test_add(3, 5) = " + result.to_string())
}
