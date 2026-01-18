///|
fn spectest_print(args : Array[Value]) -> Array[Value] {
  guard args is []
  []
}

///|
fn spectest_print_i32(args : Array[Value]) -> Array[Value] {
  guard args.length() == 1
  guard args is [I32(_)]
  []
}

///|
fn spectest_print_i64(args : Array[Value]) -> Array[Value] {
  guard args.length() == 1
  guard args is [I64(_)]
  []
}

///|
fn spectest_print_f32(args : Array[Value]) -> Array[Value] {
  guard args.length() == 1
  guard args is [F32(_)]
  []
}

///|
fn spectest_print_f64(args : Array[Value]) -> Array[Value] {
  guard args.length() == 1
  guard args is [F64(_)]
  []
}

///|
fn spectest_print_i32_f32(args : Array[Value]) -> Array[Value] {
  guard args.length() == 2
  guard args is [I32(_), F32(_)]
  []
}

///|
fn spectest_print_f64_f64(args : Array[Value]) -> Array[Value] {
  guard args.length() == 2
  guard args is [F64(_), F64(_)]
  []
}

///| Global buffer for spectest output
let spectest_output_buffer : Array[Char] = []

///|
fn spectest_print_char(args : Array[Value]) -> Array[Value] {
  guard args.length() == 1
  guard args is [I32(v)]
  // Buffer character for later output
  let c = v.reinterpret_as_int().unsafe_to_char()
  spectest_output_buffer.push(c)
  // Flush on newline
  if c == '\n' {
    let s = String::from_array(spectest_output_buffer)
    spectest_output_buffer.clear()
    println(s.substring(end=s.length() - 1)) // Remove the trailing newline since println adds one
  }
  []
}
