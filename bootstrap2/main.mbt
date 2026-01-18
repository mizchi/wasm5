///|
/// Pure bootstrap test - no I/O, just returns result code
/// For recursive bootstrap testing with wasm5

// Embedded add.wasm binary (exports "add" function)
fn get_add_wasm() -> Bytes {
  b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x60\x02\x7f\x7f\x01\x7f\x03\x02\x01\x00\x07\x07\x01\x03\x61\x64\x64\x00\x00\x0a\x09\x01\x07\x00\x20\x00\x20\x01\x6a\x0b"
}

///|
/// Run bootstrap test and return result (0 = success)
pub fn run() -> Int {
  let wasm = get_add_wasm()
  let mod_ = try { @parse.parse(wasm) } catch { _ => return 1 }
  let rt = try { @runtime.Runtime::load(mod_) } catch { _ => return 2 }
  let result = try {
    rt.call_compiled(b"add", [@runtime.Value::I32(3), @runtime.Value::I32(5)])
  } catch { _ => return 3 }
  match result[0] {
    @runtime.Value::I32(8) => 0  // add(3, 5) = 8 ✓
    @runtime.Value::I32(n) => 100 + n.reinterpret_as_int()  // Wrong result
    _ => 4
  }
}

///|
fn main {
  let code = run()
  if code == 0 {
    println("Level 2 bootstrap: SUCCESS (wasm5 in wasm executed add.wasm)")
  } else {
    println("Level 2 bootstrap: FAILED with code " + code.to_string())
  }
}
