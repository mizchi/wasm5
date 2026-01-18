// ============================================================================
// Op Table - Function dispatch table for wasm-compatible execution
// ============================================================================
// This table allows the interpreter to work without function pointers,
// making it compatible with the wasm target.

///|
/// Operation codes for the interpreter
pub(all) enum OpCode {
  // Control flow
  Nop
  Unreachable
  Drop
  Select
  If
  Br
  BrIf
  BrTable
  BrOnNull
  BrOnNonNull
  BrOnCast
  BrOnCastFail
  Return
  CallLocal
  CallImport
  CallIndirect
  CallRef
  ReturnCallLocal
  ReturnCallImport
  ReturnCallIndirect
  ReturnCallRef
  Throw
  Rethrow
  // Local/Global
  LocalGet
  LocalSet
  LocalTee
  GlobalGet
  GlobalSet
  InitZeros
  InitNullRefs
  LocalInitUnsupported
  // Constants
  I32Const
  I64Const
  F32Const
  F64Const
  // i32 arithmetic
  I32Add
  I32Sub
  I32Mul
  I32DivS
  I32DivU
  I32RemS
  I32RemU
  I32And
  I32Or
  I32Xor
  I32Shl
  I32ShrS
  I32ShrU
  I32Rotl
  I32Rotr
  I32Clz
  I32Ctz
  I32Popcnt
  I32Extend8S
  I32Extend16S
  I32WrapI64
  I32Eqz
  // i32 comparison
  I32Eq
  I32Ne
  I32LtS
  I32LtU
  I32GtS
  I32GtU
  I32LeS
  I32LeU
  I32GeS
  I32GeU
  // i64 arithmetic
  I64Add
  I64Sub
  I64Mul
  I64DivS
  I64DivU
  I64RemS
  I64RemU
  I64And
  I64Or
  I64Xor
  I64Shl
  I64ShrS
  I64ShrU
  I64Rotl
  I64Rotr
  I64Clz
  I64Ctz
  I64Popcnt
  I64Extend8S
  I64Extend16S
  I64Extend32S
  I64ExtendI32S
  I64ExtendI32U
  I64Eqz
  // i64 comparison
  I64Eq
  I64Ne
  I64LtS
  I64LtU
  I64GtS
  I64GtU
  I64LeS
  I64LeU
  I64GeS
  I64GeU
  // f32 arithmetic
  F32Neg
  F32Abs
  F32Sqrt
  F32Ceil
  F32Floor
  F32Trunc
  F32Nearest
  F32Add
  F32Sub
  F32Mul
  F32Div
  F32Min
  F32Max
  F32Copysign
  // f32 comparison
  F32Eq
  F32Ne
  F32Lt
  F32Gt
  F32Le
  F32Ge
  // f64 arithmetic
  F64Neg
  F64Abs
  F64Sqrt
  F64Ceil
  F64Floor
  F64Trunc
  F64Nearest
  F64Add
  F64Sub
  F64Mul
  F64Div
  F64Min
  F64Max
  F64Copysign
  // f64 comparison
  F64Eq
  F64Ne
  F64Lt
  F64Gt
  F64Le
  F64Ge
  // Conversions
  I32TruncF32S
  I32TruncF32U
  I32TruncF64S
  I32TruncF64U
  I64TruncF32S
  I64TruncF32U
  I64TruncF64S
  I64TruncF64U
  I32TruncSatF32S
  I32TruncSatF32U
  I32TruncSatF64S
  I32TruncSatF64U
  I64TruncSatF32S
  I64TruncSatF32U
  I64TruncSatF64S
  I64TruncSatF64U
  F32ConvertI32S
  F32ConvertI32U
  F32ConvertI64S
  F32ConvertI64U
  F64ConvertI32S
  F64ConvertI32U
  F64ConvertI64S
  F64ConvertI64U
  F32DemoteF64
  F64PromoteF32
  I32ReinterpretF32
  I64ReinterpretF64
  F32ReinterpretI32
  F64ReinterpretI64
  // Memory
  I32Load
  I64Load
  F32Load
  F64Load
  I32Load8S
  I32Load8U
  I32Load16S
  I32Load16U
  I64Load8S
  I64Load8U
  I64Load16S
  I64Load16U
  I64Load32S
  I64Load32U
  I32Store
  I64Store
  F32Store
  F64Store
  I32Store8
  I32Store16
  I64Store8
  I64Store16
  I64Store32
  MemorySize
  MemoryGrow
  MemoryCopy
  MemoryFill
  MemoryInit
  DataDrop
  // Table
  TableGet
  TableSet
  TableSize
  TableGrow
  TableFill
  TableCopy
  TableInit
  ElemDrop
  // Reference
  RefNull
  RefFunc
  RefIsNull
  RefEq
  RefAsNonNull
  RefI31
  I31GetS
  I31GetU
  RefTest
  RefCast
  AnyConvertExtern
  ExternConvertAny
  // GC - Struct
  StructNew
  StructNewDefault
  StructGet
  StructGetS
  StructGetU
  StructSet
  // GC - Array
  ArrayNew
  ArrayNewDefault
  ArrayNewFixed
  ArrayNewData
  ArrayNewElem
  ArrayGet
  ArrayGetS
  ArrayGetU
  ArraySet
  ArrayLen
  ArrayFill
  ArrayCopy
  ArrayInitData
  ArrayInitElem
  // Unimplemented
  SimdUnimplemented
  AtomicUnimplemented
  // Fused instructions (peephole optimization)
  // LocalGetLocalGet idx1 idx2 - push two locals
  LocalGetLocalGet
  // I32AddLocals idx1 idx2 - add two locals, push result
  I32AddLocals
  // I32GeULocals idx1 idx2 - compare two locals (unsigned), push result
  I32GeULocals
  // LocalInc idx - increment local by 1 (local.get idx; i32.const 1; i32.add; local.set idx)
  LocalInc
}

///|
/// Dispatch an operation by opcode
fn dispatch_op(opcode : OpCode, rt : Runtime) -> Runtime {
  match opcode {
    // Control flow
    Nop => op_nop(rt)
    Unreachable => op_unreachable(rt)
    Drop => op_drop(rt)
    Select => op_select(rt)
    If => op_if(rt)
    Br => op_br(rt)
    BrIf => op_br_if(rt)
    BrTable => op_br_table(rt)
    BrOnNull => op_br_on_null(rt)
    BrOnNonNull => op_br_on_non_null(rt)
    BrOnCast => op_br_on_cast(rt)
    BrOnCastFail => op_br_on_cast_fail(rt)
    Return => op_return(rt)
    CallLocal => op_call_local(rt)
    CallImport => op_call_import(rt)
    CallIndirect => op_call_indirect(rt)
    CallRef => op_call_ref(rt)
    ReturnCallLocal => op_return_call_local(rt)
    ReturnCallImport => op_return_call_import(rt)
    ReturnCallIndirect => op_return_call_indirect(rt)
    ReturnCallRef => op_return_call_ref(rt)
    Throw => op_throw(rt)
    Rethrow => op_rethrow(rt)
    // Local/Global
    LocalGet => op_local_get(rt)
    LocalSet => op_local_set(rt)
    LocalTee => op_local_tee(rt)
    GlobalGet => op_global_get(rt)
    GlobalSet => op_global_set(rt)
    InitZeros => op_init_zeros(rt)
    InitNullRefs => op_init_null_refs(rt)
    LocalInitUnsupported => op_local_init_unsupported(rt)
    // Constants
    I32Const => op_i32_const(rt)
    I64Const => op_i64_const(rt)
    F32Const => op_f32_const(rt)
    F64Const => op_f64_const(rt)
    // i32 arithmetic
    I32Add => op_i32_add(rt)
    I32Sub => op_i32_sub(rt)
    I32Mul => op_i32_mul(rt)
    I32DivS => op_i32_div_s(rt)
    I32DivU => op_i32_div_u(rt)
    I32RemS => op_i32_rem_s(rt)
    I32RemU => op_i32_rem_u(rt)
    I32And => op_i32_and(rt)
    I32Or => op_i32_or(rt)
    I32Xor => op_i32_xor(rt)
    I32Shl => op_i32_shl(rt)
    I32ShrS => op_i32_shr_s(rt)
    I32ShrU => op_i32_shr_u(rt)
    I32Rotl => op_i32_rotl(rt)
    I32Rotr => op_i32_rotr(rt)
    I32Clz => op_i32_clz(rt)
    I32Ctz => op_i32_ctz(rt)
    I32Popcnt => op_i32_popcnt(rt)
    I32Extend8S => op_i32_extend8_s(rt)
    I32Extend16S => op_i32_extend16_s(rt)
    I32WrapI64 => op_i32_wrap_i64(rt)
    I32Eqz => op_i32_eqz(rt)
    // i32 comparison
    I32Eq => op_i32_eq(rt)
    I32Ne => op_i32_ne(rt)
    I32LtS => op_i32_lt_s(rt)
    I32LtU => op_i32_lt_u(rt)
    I32GtS => op_i32_gt_s(rt)
    I32GtU => op_i32_gt_u(rt)
    I32LeS => op_i32_le_s(rt)
    I32LeU => op_i32_le_u(rt)
    I32GeS => op_i32_ge_s(rt)
    I32GeU => op_i32_ge_u(rt)
    // i64 arithmetic
    I64Add => op_i64_add(rt)
    I64Sub => op_i64_sub(rt)
    I64Mul => op_i64_mul(rt)
    I64DivS => op_i64_div_s(rt)
    I64DivU => op_i64_div_u(rt)
    I64RemS => op_i64_rem_s(rt)
    I64RemU => op_i64_rem_u(rt)
    I64And => op_i64_and(rt)
    I64Or => op_i64_or(rt)
    I64Xor => op_i64_xor(rt)
    I64Shl => op_i64_shl(rt)
    I64ShrS => op_i64_shr_s(rt)
    I64ShrU => op_i64_shr_u(rt)
    I64Rotl => op_i64_rotl(rt)
    I64Rotr => op_i64_rotr(rt)
    I64Clz => op_i64_clz(rt)
    I64Ctz => op_i64_ctz(rt)
    I64Popcnt => op_i64_popcnt(rt)
    I64Extend8S => op_i64_extend8_s(rt)
    I64Extend16S => op_i64_extend16_s(rt)
    I64Extend32S => op_i64_extend32_s(rt)
    I64ExtendI32S => op_i64_extend_i32_s(rt)
    I64ExtendI32U => op_i64_extend_i32_u(rt)
    I64Eqz => op_i64_eqz(rt)
    // i64 comparison
    I64Eq => op_i64_eq(rt)
    I64Ne => op_i64_ne(rt)
    I64LtS => op_i64_lt_s(rt)
    I64LtU => op_i64_lt_u(rt)
    I64GtS => op_i64_gt_s(rt)
    I64GtU => op_i64_gt_u(rt)
    I64LeS => op_i64_le_s(rt)
    I64LeU => op_i64_le_u(rt)
    I64GeS => op_i64_ge_s(rt)
    I64GeU => op_i64_ge_u(rt)
    // f32 arithmetic
    F32Neg => op_f32_neg(rt)
    F32Abs => op_f32_abs(rt)
    F32Sqrt => op_f32_sqrt(rt)
    F32Ceil => op_f32_ceil(rt)
    F32Floor => op_f32_floor(rt)
    F32Trunc => op_f32_trunc(rt)
    F32Nearest => op_f32_nearest(rt)
    F32Add => op_f32_add(rt)
    F32Sub => op_f32_sub(rt)
    F32Mul => op_f32_mul(rt)
    F32Div => op_f32_div(rt)
    F32Min => op_f32_min(rt)
    F32Max => op_f32_max(rt)
    F32Copysign => op_f32_copysign(rt)
    // f32 comparison
    F32Eq => op_f32_eq(rt)
    F32Ne => op_f32_ne(rt)
    F32Lt => op_f32_lt(rt)
    F32Gt => op_f32_gt(rt)
    F32Le => op_f32_le(rt)
    F32Ge => op_f32_ge(rt)
    // f64 arithmetic
    F64Neg => op_f64_neg(rt)
    F64Abs => op_f64_abs(rt)
    F64Sqrt => op_f64_sqrt(rt)
    F64Ceil => op_f64_ceil(rt)
    F64Floor => op_f64_floor(rt)
    F64Trunc => op_f64_trunc(rt)
    F64Nearest => op_f64_nearest(rt)
    F64Add => op_f64_add(rt)
    F64Sub => op_f64_sub(rt)
    F64Mul => op_f64_mul(rt)
    F64Div => op_f64_div(rt)
    F64Min => op_f64_min(rt)
    F64Max => op_f64_max(rt)
    F64Copysign => op_f64_copysign(rt)
    // f64 comparison
    F64Eq => op_f64_eq(rt)
    F64Ne => op_f64_ne(rt)
    F64Lt => op_f64_lt(rt)
    F64Gt => op_f64_gt(rt)
    F64Le => op_f64_le(rt)
    F64Ge => op_f64_ge(rt)
    // Conversions
    I32TruncF32S => op_i32_trunc_f32_s(rt)
    I32TruncF32U => op_i32_trunc_f32_u(rt)
    I32TruncF64S => op_i32_trunc_f64_s(rt)
    I32TruncF64U => op_i32_trunc_f64_u(rt)
    I64TruncF32S => op_i64_trunc_f32_s(rt)
    I64TruncF32U => op_i64_trunc_f32_u(rt)
    I64TruncF64S => op_i64_trunc_f64_s(rt)
    I64TruncF64U => op_i64_trunc_f64_u(rt)
    I32TruncSatF32S => op_i32_trunc_sat_f32_s(rt)
    I32TruncSatF32U => op_i32_trunc_sat_f32_u(rt)
    I32TruncSatF64S => op_i32_trunc_sat_f64_s(rt)
    I32TruncSatF64U => op_i32_trunc_sat_f64_u(rt)
    I64TruncSatF32S => op_i64_trunc_sat_f32_s(rt)
    I64TruncSatF32U => op_i64_trunc_sat_f32_u(rt)
    I64TruncSatF64S => op_i64_trunc_sat_f64_s(rt)
    I64TruncSatF64U => op_i64_trunc_sat_f64_u(rt)
    F32ConvertI32S => op_f32_convert_i32_s(rt)
    F32ConvertI32U => op_f32_convert_i32_u(rt)
    F32ConvertI64S => op_f32_convert_i64_s(rt)
    F32ConvertI64U => op_f32_convert_i64_u(rt)
    F64ConvertI32S => op_f64_convert_i32_s(rt)
    F64ConvertI32U => op_f64_convert_i32_u(rt)
    F64ConvertI64S => op_f64_convert_i64_s(rt)
    F64ConvertI64U => op_f64_convert_i64_u(rt)
    F32DemoteF64 => op_f32_demote_f64(rt)
    F64PromoteF32 => op_f64_promote_f32(rt)
    I32ReinterpretF32 => op_i32_reinterpret_f32(rt)
    I64ReinterpretF64 => op_i64_reinterpret_f64(rt)
    F32ReinterpretI32 => op_f32_reinterpret_i32(rt)
    F64ReinterpretI64 => op_f64_reinterpret_i64(rt)
    // Memory
    I32Load => op_i32_load(rt)
    I64Load => op_i64_load(rt)
    F32Load => op_f32_load(rt)
    F64Load => op_f64_load(rt)
    I32Load8S => op_i32_load8_s(rt)
    I32Load8U => op_i32_load8_u(rt)
    I32Load16S => op_i32_load16_s(rt)
    I32Load16U => op_i32_load16_u(rt)
    I64Load8S => op_i64_load8_s(rt)
    I64Load8U => op_i64_load8_u(rt)
    I64Load16S => op_i64_load16_s(rt)
    I64Load16U => op_i64_load16_u(rt)
    I64Load32S => op_i64_load32_s(rt)
    I64Load32U => op_i64_load32_u(rt)
    I32Store => op_i32_store(rt)
    I64Store => op_i64_store(rt)
    F32Store => op_f32_store(rt)
    F64Store => op_f64_store(rt)
    I32Store8 => op_i32_store8(rt)
    I32Store16 => op_i32_store16(rt)
    I64Store8 => op_i64_store8(rt)
    I64Store16 => op_i64_store16(rt)
    I64Store32 => op_i64_store32(rt)
    MemorySize => op_memory_size(rt)
    MemoryGrow => op_memory_grow(rt)
    MemoryCopy => op_memory_copy(rt)
    MemoryFill => op_memory_fill(rt)
    MemoryInit => op_memory_init(rt)
    DataDrop => op_data_drop(rt)
    // Table
    TableGet => op_table_get(rt)
    TableSet => op_table_set(rt)
    TableSize => op_table_size(rt)
    TableGrow => op_table_grow(rt)
    TableFill => op_table_fill(rt)
    TableCopy => op_table_copy(rt)
    TableInit => op_table_init(rt)
    ElemDrop => op_elem_drop(rt)
    // Reference
    RefNull => op_ref_null(rt)
    RefFunc => op_ref_func(rt)
    RefIsNull => op_ref_is_null(rt)
    RefEq => op_ref_eq(rt)
    RefAsNonNull => op_ref_as_non_null(rt)
    RefI31 => op_ref_i31(rt)
    I31GetS => op_i31_get_s(rt)
    I31GetU => op_i31_get_u(rt)
    RefTest => op_ref_test(rt)
    RefCast => op_ref_cast(rt)
    AnyConvertExtern => op_any_convert_extern(rt)
    ExternConvertAny => op_extern_convert_any(rt)
    // GC - Struct
    StructNew => op_struct_new(rt)
    StructNewDefault => op_struct_new_default(rt)
    StructGet => op_struct_get(rt)
    StructGetS => op_struct_get_s(rt)
    StructGetU => op_struct_get_u(rt)
    StructSet => op_struct_set(rt)
    // GC - Array
    ArrayNew => op_array_new(rt)
    ArrayNewDefault => op_array_new_default(rt)
    ArrayNewFixed => op_array_new_fixed(rt)
    ArrayNewData => op_array_new_data(rt)
    ArrayNewElem => op_array_new_elem(rt)
    ArrayGet => op_array_get(rt)
    ArrayGetS => op_array_get_s(rt)
    ArrayGetU => op_array_get_u(rt)
    ArraySet => op_array_set(rt)
    ArrayLen => op_array_len(rt)
    ArrayFill => op_array_fill(rt)
    ArrayCopy => op_array_copy(rt)
    ArrayInitData => op_array_init_data(rt)
    ArrayInitElem => op_array_init_elem(rt)
    // Unimplemented
    SimdUnimplemented => op_simd_unimplemented(rt)
    AtomicUnimplemented => op_atomic_unimplemented(rt)
    // Fused (handled inline in execute loop, fallback here)
    LocalGetLocalGet => op_local_get_local_get(rt)
    I32AddLocals => op_i32_add_locals(rt)
    I32GeULocals => op_i32_geu_locals(rt)
    LocalInc => op_local_inc(rt)
  }
}

///|
/// Convert OpCode to UInt64 for storage in ops array
fn opcode_to_uint64(opcode : OpCode) -> UInt64 {
  match opcode {
    Nop => 0
    Unreachable => 1
    Drop => 2
    Select => 3
    If => 4
    Br => 5
    BrIf => 6
    BrTable => 7
    BrOnNull => 8
    BrOnNonNull => 9
    BrOnCast => 10
    BrOnCastFail => 11
    Return => 12
    CallLocal => 13
    CallImport => 14
    CallIndirect => 15
    CallRef => 16
    ReturnCallLocal => 17
    ReturnCallImport => 18
    ReturnCallIndirect => 19
    ReturnCallRef => 20
    Throw => 21
    Rethrow => 22
    LocalGet => 23
    LocalSet => 24
    LocalTee => 25
    GlobalGet => 26
    GlobalSet => 27
    InitZeros => 28
    InitNullRefs => 29
    LocalInitUnsupported => 30
    I32Const => 31
    I64Const => 32
    F32Const => 33
    F64Const => 34
    I32Add => 35
    I32Sub => 36
    I32Mul => 37
    I32DivS => 38
    I32DivU => 39
    I32RemS => 40
    I32RemU => 41
    I32And => 42
    I32Or => 43
    I32Xor => 44
    I32Shl => 45
    I32ShrS => 46
    I32ShrU => 47
    I32Rotl => 48
    I32Rotr => 49
    I32Clz => 50
    I32Ctz => 51
    I32Popcnt => 52
    I32Extend8S => 53
    I32Extend16S => 54
    I32WrapI64 => 55
    I32Eqz => 56
    I32Eq => 57
    I32Ne => 58
    I32LtS => 59
    I32LtU => 60
    I32GtS => 61
    I32GtU => 62
    I32LeS => 63
    I32LeU => 64
    I32GeS => 65
    I32GeU => 66
    I64Add => 67
    I64Sub => 68
    I64Mul => 69
    I64DivS => 70
    I64DivU => 71
    I64RemS => 72
    I64RemU => 73
    I64And => 74
    I64Or => 75
    I64Xor => 76
    I64Shl => 77
    I64ShrS => 78
    I64ShrU => 79
    I64Rotl => 80
    I64Rotr => 81
    I64Clz => 82
    I64Ctz => 83
    I64Popcnt => 84
    I64Extend8S => 85
    I64Extend16S => 86
    I64Extend32S => 87
    I64ExtendI32S => 88
    I64ExtendI32U => 89
    I64Eqz => 90
    I64Eq => 91
    I64Ne => 92
    I64LtS => 93
    I64LtU => 94
    I64GtS => 95
    I64GtU => 96
    I64LeS => 97
    I64LeU => 98
    I64GeS => 99
    I64GeU => 100
    F32Neg => 101
    F32Abs => 102
    F32Sqrt => 103
    F32Ceil => 104
    F32Floor => 105
    F32Trunc => 106
    F32Nearest => 107
    F32Add => 108
    F32Sub => 109
    F32Mul => 110
    F32Div => 111
    F32Min => 112
    F32Max => 113
    F32Copysign => 114
    F32Eq => 115
    F32Ne => 116
    F32Lt => 117
    F32Gt => 118
    F32Le => 119
    F32Ge => 120
    F64Neg => 121
    F64Abs => 122
    F64Sqrt => 123
    F64Ceil => 124
    F64Floor => 125
    F64Trunc => 126
    F64Nearest => 127
    F64Add => 128
    F64Sub => 129
    F64Mul => 130
    F64Div => 131
    F64Min => 132
    F64Max => 133
    F64Copysign => 134
    F64Eq => 135
    F64Ne => 136
    F64Lt => 137
    F64Gt => 138
    F64Le => 139
    F64Ge => 140
    I32TruncF32S => 141
    I32TruncF32U => 142
    I32TruncF64S => 143
    I32TruncF64U => 144
    I64TruncF32S => 145
    I64TruncF32U => 146
    I64TruncF64S => 147
    I64TruncF64U => 148
    I32TruncSatF32S => 149
    I32TruncSatF32U => 150
    I32TruncSatF64S => 151
    I32TruncSatF64U => 152
    I64TruncSatF32S => 153
    I64TruncSatF32U => 154
    I64TruncSatF64S => 155
    I64TruncSatF64U => 156
    F32ConvertI32S => 157
    F32ConvertI32U => 158
    F32ConvertI64S => 159
    F32ConvertI64U => 160
    F64ConvertI32S => 161
    F64ConvertI32U => 162
    F64ConvertI64S => 163
    F64ConvertI64U => 164
    F32DemoteF64 => 165
    F64PromoteF32 => 166
    I32ReinterpretF32 => 167
    I64ReinterpretF64 => 168
    F32ReinterpretI32 => 169
    F64ReinterpretI64 => 170
    I32Load => 171
    I64Load => 172
    F32Load => 173
    F64Load => 174
    I32Load8S => 175
    I32Load8U => 176
    I32Load16S => 177
    I32Load16U => 178
    I64Load8S => 179
    I64Load8U => 180
    I64Load16S => 181
    I64Load16U => 182
    I64Load32S => 183
    I64Load32U => 184
    I32Store => 185
    I64Store => 186
    F32Store => 187
    F64Store => 188
    I32Store8 => 189
    I32Store16 => 190
    I64Store8 => 191
    I64Store16 => 192
    I64Store32 => 193
    MemorySize => 194
    MemoryGrow => 195
    MemoryCopy => 196
    MemoryFill => 197
    MemoryInit => 198
    DataDrop => 199
    TableGet => 200
    TableSet => 201
    TableSize => 202
    TableGrow => 203
    TableFill => 204
    TableCopy => 205
    TableInit => 206
    ElemDrop => 207
    RefNull => 208
    RefFunc => 209
    RefIsNull => 210
    RefEq => 211
    RefAsNonNull => 212
    RefI31 => 213
    I31GetS => 214
    I31GetU => 215
    RefTest => 216
    RefCast => 217
    AnyConvertExtern => 218
    ExternConvertAny => 219
    StructNew => 220
    StructNewDefault => 221
    StructGet => 222
    StructGetS => 223
    StructGetU => 224
    StructSet => 225
    ArrayNew => 226
    ArrayNewDefault => 227
    ArrayNewFixed => 228
    ArrayNewData => 229
    ArrayNewElem => 230
    ArrayGet => 231
    ArrayGetS => 232
    ArrayGetU => 233
    ArraySet => 234
    ArrayLen => 235
    ArrayFill => 236
    ArrayCopy => 237
    ArrayInitData => 238
    ArrayInitElem => 239
    SimdUnimplemented => 240
    AtomicUnimplemented => 241
    LocalGetLocalGet => 242
    I32AddLocals => 243
    I32GeULocals => 244
    LocalInc => 245
  }
}

///|
/// Convert UInt64 to OpCode
fn uint64_to_opcode(code : UInt64) -> OpCode {
  match code.to_int() {
    0 => Nop
    1 => Unreachable
    2 => Drop
    3 => Select
    4 => If
    5 => Br
    6 => BrIf
    7 => BrTable
    8 => BrOnNull
    9 => BrOnNonNull
    10 => BrOnCast
    11 => BrOnCastFail
    12 => Return
    13 => CallLocal
    14 => CallImport
    15 => CallIndirect
    16 => CallRef
    17 => ReturnCallLocal
    18 => ReturnCallImport
    19 => ReturnCallIndirect
    20 => ReturnCallRef
    21 => Throw
    22 => Rethrow
    23 => LocalGet
    24 => LocalSet
    25 => LocalTee
    26 => GlobalGet
    27 => GlobalSet
    28 => InitZeros
    29 => InitNullRefs
    30 => LocalInitUnsupported
    31 => I32Const
    32 => I64Const
    33 => F32Const
    34 => F64Const
    35 => I32Add
    36 => I32Sub
    37 => I32Mul
    38 => I32DivS
    39 => I32DivU
    40 => I32RemS
    41 => I32RemU
    42 => I32And
    43 => I32Or
    44 => I32Xor
    45 => I32Shl
    46 => I32ShrS
    47 => I32ShrU
    48 => I32Rotl
    49 => I32Rotr
    50 => I32Clz
    51 => I32Ctz
    52 => I32Popcnt
    53 => I32Extend8S
    54 => I32Extend16S
    55 => I32WrapI64
    56 => I32Eqz
    57 => I32Eq
    58 => I32Ne
    59 => I32LtS
    60 => I32LtU
    61 => I32GtS
    62 => I32GtU
    63 => I32LeS
    64 => I32LeU
    65 => I32GeS
    66 => I32GeU
    67 => I64Add
    68 => I64Sub
    69 => I64Mul
    70 => I64DivS
    71 => I64DivU
    72 => I64RemS
    73 => I64RemU
    74 => I64And
    75 => I64Or
    76 => I64Xor
    77 => I64Shl
    78 => I64ShrS
    79 => I64ShrU
    80 => I64Rotl
    81 => I64Rotr
    82 => I64Clz
    83 => I64Ctz
    84 => I64Popcnt
    85 => I64Extend8S
    86 => I64Extend16S
    87 => I64Extend32S
    88 => I64ExtendI32S
    89 => I64ExtendI32U
    90 => I64Eqz
    91 => I64Eq
    92 => I64Ne
    93 => I64LtS
    94 => I64LtU
    95 => I64GtS
    96 => I64GtU
    97 => I64LeS
    98 => I64LeU
    99 => I64GeS
    100 => I64GeU
    101 => F32Neg
    102 => F32Abs
    103 => F32Sqrt
    104 => F32Ceil
    105 => F32Floor
    106 => F32Trunc
    107 => F32Nearest
    108 => F32Add
    109 => F32Sub
    110 => F32Mul
    111 => F32Div
    112 => F32Min
    113 => F32Max
    114 => F32Copysign
    115 => F32Eq
    116 => F32Ne
    117 => F32Lt
    118 => F32Gt
    119 => F32Le
    120 => F32Ge
    121 => F64Neg
    122 => F64Abs
    123 => F64Sqrt
    124 => F64Ceil
    125 => F64Floor
    126 => F64Trunc
    127 => F64Nearest
    128 => F64Add
    129 => F64Sub
    130 => F64Mul
    131 => F64Div
    132 => F64Min
    133 => F64Max
    134 => F64Copysign
    135 => F64Eq
    136 => F64Ne
    137 => F64Lt
    138 => F64Gt
    139 => F64Le
    140 => F64Ge
    141 => I32TruncF32S
    142 => I32TruncF32U
    143 => I32TruncF64S
    144 => I32TruncF64U
    145 => I64TruncF32S
    146 => I64TruncF32U
    147 => I64TruncF64S
    148 => I64TruncF64U
    149 => I32TruncSatF32S
    150 => I32TruncSatF32U
    151 => I32TruncSatF64S
    152 => I32TruncSatF64U
    153 => I64TruncSatF32S
    154 => I64TruncSatF32U
    155 => I64TruncSatF64S
    156 => I64TruncSatF64U
    157 => F32ConvertI32S
    158 => F32ConvertI32U
    159 => F32ConvertI64S
    160 => F32ConvertI64U
    161 => F64ConvertI32S
    162 => F64ConvertI32U
    163 => F64ConvertI64S
    164 => F64ConvertI64U
    165 => F32DemoteF64
    166 => F64PromoteF32
    167 => I32ReinterpretF32
    168 => I64ReinterpretF64
    169 => F32ReinterpretI32
    170 => F64ReinterpretI64
    171 => I32Load
    172 => I64Load
    173 => F32Load
    174 => F64Load
    175 => I32Load8S
    176 => I32Load8U
    177 => I32Load16S
    178 => I32Load16U
    179 => I64Load8S
    180 => I64Load8U
    181 => I64Load16S
    182 => I64Load16U
    183 => I64Load32S
    184 => I64Load32U
    185 => I32Store
    186 => I64Store
    187 => F32Store
    188 => F64Store
    189 => I32Store8
    190 => I32Store16
    191 => I64Store8
    192 => I64Store16
    193 => I64Store32
    194 => MemorySize
    195 => MemoryGrow
    196 => MemoryCopy
    197 => MemoryFill
    198 => MemoryInit
    199 => DataDrop
    200 => TableGet
    201 => TableSet
    202 => TableSize
    203 => TableGrow
    204 => TableFill
    205 => TableCopy
    206 => TableInit
    207 => ElemDrop
    208 => RefNull
    209 => RefFunc
    210 => RefIsNull
    211 => RefEq
    212 => RefAsNonNull
    213 => RefI31
    214 => I31GetS
    215 => I31GetU
    216 => RefTest
    217 => RefCast
    218 => AnyConvertExtern
    219 => ExternConvertAny
    220 => StructNew
    221 => StructNewDefault
    222 => StructGet
    223 => StructGetS
    224 => StructGetU
    225 => StructSet
    226 => ArrayNew
    227 => ArrayNewDefault
    228 => ArrayNewFixed
    229 => ArrayNewData
    230 => ArrayNewElem
    231 => ArrayGet
    232 => ArrayGetS
    233 => ArrayGetU
    234 => ArraySet
    235 => ArrayLen
    236 => ArrayFill
    237 => ArrayCopy
    238 => ArrayInitData
    239 => ArrayInitElem
    240 => SimdUnimplemented
    241 => AtomicUnimplemented
    242 => LocalGetLocalGet
    243 => I32AddLocals
    244 => I32GeULocals
    245 => LocalInc
    _ => Nop // Default fallback
  }
}
