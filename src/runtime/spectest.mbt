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

///|
fn spectest_print_char(args : Array[Value]) -> Array[Value] {
  guard args.length() == 1
  guard args is [I32(v)]
  // Print character - in pure MoonBit we just ignore it for now
  // as there's no print without newline in standard library
  ignore(v)
  []
}
