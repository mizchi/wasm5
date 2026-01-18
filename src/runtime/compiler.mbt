// ============================================================================
// Compiler - compile-time context for building instruction arrays
// ============================================================================

///|
/// Pending call patch for forward references
priv struct PendingCallPatch {
  local_func_idx : Int // Which function is being called
  slot : Int // Which slot in ops needs the callee_pc
}

///|
/// Compiler holds the instruction array during compilation.
/// After compilation, the ops array is converted to FixedArray for runtime.
priv struct Compiler {
  module_ : @core.Module
  ops : Array[UInt64]
  pending_call_patches : Array[PendingCallPatch] // Forward call references to patch
}

///|
/// Create a new compiler for a module
fn Compiler::new(module_ : @core.Module) -> Compiler {
  { module_, ops: [], pending_call_patches: [] }
}

///|
/// Emit an opcode
fn Compiler::emit_op(self : Compiler, opcode : OpCode) -> Unit {
  self.ops.push(opcode_to_uint64(opcode))
}

///|
/// Emit an immediate i32 value as UInt64
fn Compiler::emit_i32(self : Compiler, value : UInt) -> Unit {
  self.ops.push(value.to_uint64())
}

///|
/// Emit an immediate index value as UInt64
fn Compiler::emit_idx(self : Compiler, value : Int) -> Unit {
  self.ops.push(value.to_int64().reinterpret_as_uint64())
}

///|
/// Finish compilation and return the FixedArray of instructions
fn Compiler::finish(self : Compiler) -> FixedArray[UInt64] {
  // Apply peephole optimization with PC remapping
  let result = peephole_optimize(self.ops)

  // Check if any optimization was applied (if lengths differ)
  if result.ops.length() == self.ops.length() {
    // No optimization applied, return original (faster)
    return FixedArray::from_array(self.ops)
  }

  // PC remapping needed
  remap_all_pcs(result.ops, result.index_map)

  // Remap code.compiled start_pc values for each function
  for code in self.module_.codes {
    guard code.compiled is Some(old_pc) else { continue }
    let new_pc = remap_pc(result.index_map, old_pc)
    code.compiled = Some(new_pc)
  }

  FixedArray::from_array(result.ops)
}

///|
/// Get instruction size (opcode + immediates) for a given opcode value.
/// Returns -1 for variable-length instructions (BrTable).
fn opcode_size(op : UInt64) -> Int {
  match op.to_int() {
    // Size 1: No immediates
    0 | // Nop
    1 | // Unreachable
    2 | // Drop
    3 | // Select
    30 | // LocalInitUnsupported
    35 | 36 | 37 | 38 | 39 | 40 | 41 | 42 | 43 | 44 | // I32 arithmetic
    45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 | 53 | 54 | 55 | 56 | // I32 unary + wrap
    57 | 58 | 59 | 60 | 61 | 62 | 63 | 64 | 65 | 66 | // I32 comparison
    67 | 68 | 69 | 70 | 71 | 72 | 73 | 74 | 75 | 76 | // I64 arithmetic
    77 | 78 | 79 | 80 | 81 | 82 | 83 | 84 | 85 | 86 | 87 | 88 | 89 | 90 | // I64 unary + extend
    91 | 92 | 93 | 94 | 95 | 96 | 97 | 98 | 99 | 100 | // I64 comparison
    101 | 102 | 103 | 104 | 105 | 106 | 107 | // F32 unary
    108 | 109 | 110 | 111 | 112 | 113 | 114 | // F32 binary
    115 | 116 | 117 | 118 | 119 | 120 | // F32 comparison
    121 | 122 | 123 | 124 | 125 | 126 | 127 | // F64 unary
    128 | 129 | 130 | 131 | 132 | 133 | 134 | // F64 binary
    135 | 136 | 137 | 138 | 139 | 140 | // F64 comparison
    141 | 142 | 143 | 144 | 145 | 146 | 147 | 148 | // Truncations
    149 | 150 | 151 | 152 | 153 | 154 | 155 | 156 | // TruncSat
    157 | 158 | 159 | 160 | 161 | 162 | 163 | 164 | // Conversions
    165 | 166 | 167 | 168 | 169 | 170 | // Demote/Promote/Reinterpret
    194 | 195 | // MemorySize, MemoryGrow
    210 | 211 | 212 | 213 | 214 | 215 | // RefIsNull, RefEq, RefAsNonNull, RefI31, I31GetS/U
    218 | 219 | // AnyConvertExtern, ExternConvertAny
    235 | // ArrayLen
    240 | 241 => 1 // SimdUnimplemented, AtomicUnimplemented

    // Size 2: One immediate
    4 | // If (else_pc)
    12 | // Return (result_count)
    21 | // Throw (tag_idx)
    22 | // Rethrow (relative_depth)
    23 | 24 | 25 | // LocalGet, LocalSet, LocalTee (idx)
    26 | 27 | // GlobalGet, GlobalSet (idx)
    28 | 29 | // InitZeros, InitNullRefs (count)
    31 | 32 | 33 | 34 | // I32Const, I64Const, F32Const, F64Const (value)
    199 | // DataDrop (data_idx)
    200 | 201 | 202 | 203 | // TableGet, TableSet, TableSize, TableGrow (table_idx)
    207 | // ElemDrop (elem_idx)
    208 | // RefNull (type)
    209 | // RefFunc (func_idx)
    221 | 227 => 2 // StructNewDefault, ArrayNewDefault (type_idx)

    // Size 4: Three immediates
    5 | // Br (target_pc, arity, drop_count)
    6 => 4 // BrIf (target_pc, arity, drop_count)

    // Size 2: One immediate
    14 | // CallImport (import_idx)
    18 | // ReturnCallImport (import_idx)
    16 | // CallRef (type_idx)
    20 | // ReturnCallRef (type_idx)
    171 | 172 | 173 | 174 | // Loads (offset only)
    175 | 176 | 177 | 178 | // I32Load8/16
    179 | 180 | 181 | 182 | 183 | 184 | // I64Load8/16/32
    185 | 186 | 187 | 188 | // Stores (offset only)
    189 | 190 | 191 | 192 | 193 => 2 // Store8/16/32

    // Size 3: Two immediates
    196 | 197 | 198 | // MemoryCopy, MemoryFill, MemoryInit
    204 | 205 | 206 | // TableFill, TableCopy, TableInit
    216 | 217 | // RefTest, RefCast
    220 | // StructNew
    222 | 223 | 224 | 225 | // StructGet, StructGetS/U, StructSet
    226 | // ArrayNew
    228 | // ArrayNewFixed (type_idx, count)
    229 | 230 | // ArrayNewData, ArrayNewElem
    231 | 232 | 233 | 234 | // ArrayGet, ArrayGetS/U, ArraySet
    15 | 19 | // CallIndirect, ReturnCallIndirect (type_idx, table_idx)
    242 | 243 | 244 => 3 // Fused: LocalGetLocalGet, I32AddLocals, I32GeULocals (idx1, idx2)
    245 => 2 // LocalInc (idx)

    // Size 4: Three immediates
    8 | 9 => 4 // BrOnNull, BrOnNonNull (target_pc, arity, drop_count)

    // Size 5: Four immediates
    13 | // CallLocal (callee_pc, num_params, num_locals, max_stack_height)
    17 => 5 // ReturnCallLocal (callee_pc, num_params, num_locals, max_stack_height)

    // Size 6: Five immediates
    10 | 11 => 6 // BrOnCast, BrOnCastFail (target_pc, arity, drop_count, target_type, nullable)

    // ArrayFill, ArrayCopy have no immediates
    236 | 237 => 1 // ArrayFill, ArrayCopy (no immediates)
    // ArrayInitData has 3 immediates (type_idx, data_idx, elem_size)
    238 => 4 // ArrayInitData
    // ArrayInitElem has 2 immediates (type_idx, elem_idx)
    239 => 3 // ArrayInitElem

    // Variable length: BrTable
    7 => -1 // BrTable - variable length, cannot skip

    // Default: assume 1 (should not happen)
    _ => 1
  }
}

///|
/// Result of peephole optimization with index mapping
priv struct PeepholeResult {
  ops : Array[UInt64]
  // Dense mapping: index_map[old_idx] = new_idx
  index_map : FixedArray[Int]
}

///|
/// Peephole optimization pass - fuse common instruction sequences
/// Returns optimized ops and index mapping for PC remapping
fn peephole_optimize(ops : Array[UInt64]) -> PeepholeResult {
  // OpCode constants
  let local_get : UInt64 = 23
  let local_set : UInt64 = 24
  let i32_const : UInt64 = 31
  let i32_add : UInt64 = 35
  let i32_geu : UInt64 = 66
  let local_get_local_get : UInt64 = 242
  let i32_add_locals : UInt64 = 243
  let i32_geu_locals : UInt64 = 244
  let local_inc : UInt64 = 245

  let result : Array[UInt64] = []
  // index_map[old_idx] = new_idx, for every position in original array
  let index_map : FixedArray[Int] = FixedArray::make(ops.length() + 1, 0)
  let mut i = 0
  let len = ops.length()

  while i < len {
    let op = ops[i]
    let size = opcode_size(op)
    let new_idx = result.length()

    // Skip variable-length instructions (BrTable)
    if size < 0 {
      // BrTable format: opcode, label_count, arity, [target_pc, drop_count]..., default_target, default_drop
      let label_count = ops[i + 1].to_int()
      let total_size = 3 + label_count * 2 + 2 // opcode + label_count + arity + (target, drop)*labels + default_target + default_drop
      // Record mapping for all positions
      for j in 0..<total_size {
        index_map[i + j] = new_idx + j
      }
      // Copy BrTable as-is (PC remapping done later)
      for j in 0..<total_size {
        result.push(ops[i + j])
      }
      i = i + total_size
      continue
    }

    // Pattern: LocalGet idx1; LocalGet idx2; I32GeU → I32GeULocals idx1 idx2
    if op == local_get && i + 4 < len {
      let idx1 = ops[i + 1]
      let op2 = ops[i + 2]
      if op2 == local_get {
        let idx2 = ops[i + 3]
        let op3 = ops[i + 4]
        if op3 == i32_geu {
          // Record mapping: all 5 old positions map to new fused instruction
          for j in 0..<5 {
            index_map[i + j] = new_idx
          }
          result.push(i32_geu_locals)
          result.push(idx1)
          result.push(idx2)
          i = i + 5
          continue
        }
        // Pattern: LocalGet idx1; LocalGet idx2; I32Add → I32AddLocals idx1 idx2
        if op3 == i32_add {
          for j in 0..<5 {
            index_map[i + j] = new_idx
          }
          result.push(i32_add_locals)
          result.push(idx1)
          result.push(idx2)
          i = i + 5
          continue
        }
        // Pattern: LocalGet idx1; LocalGet idx2 → LocalGetLocalGet idx1 idx2
        for j in 0..<4 {
          index_map[i + j] = new_idx
        }
        result.push(local_get_local_get)
        result.push(idx1)
        result.push(idx2)
        i = i + 4
        continue
      }
    }

    // Pattern: LocalGet idx; I32Const 1; I32Add; LocalSet idx → LocalInc idx
    if op == local_get && i + 6 < len {
      let idx = ops[i + 1]
      let op2 = ops[i + 2]
      if op2 == i32_const {
        let const_val = ops[i + 3]
        let op3 = ops[i + 4]
        if const_val == 1UL && op3 == i32_add {
          let op4 = ops[i + 5]
          if op4 == local_set {
            let idx2 = ops[i + 6]
            if idx == idx2 {
              // Record mapping: all 7 old positions map to new fused instruction
              for j in 0..<7 {
                index_map[i + j] = new_idx
              }
              result.push(local_inc)
              result.push(idx)
              i = i + 7
              continue
            }
          }
        }
      }
    }

    // No pattern matched, copy instruction with all its immediates
    for j in 0..<size {
      index_map[i + j] = new_idx + j
      result.push(ops[i + j])
    }
    i = i + size
  }

  // Add sentinel for end of array
  index_map[len] = result.length()

  { ops: result, index_map }
}

///|
/// Remap a PC value using the dense index map
fn remap_pc(index_map : FixedArray[Int], old_pc : Int) -> Int {
  index_map[old_pc]
}

///|
/// Check if an opcode contains a PC value in its immediate(s)
/// Returns the offset(s) of PC values relative to opcode position
fn opcode_pc_offsets(op : UInt64) -> Array[Int] {
  match op.to_int() {
    4 => [1] // If (else_pc)
    5 => [1] // Br (target_pc, arity, drop_count) - only target_pc is a PC
    6 => [1] // BrIf (target_pc, arity, drop_count) - only target_pc is a PC
    8 | 9 => [1] // BrOnNull, BrOnNonNull (target_pc, arity, drop_count)
    10 | 11 => [1] // BrOnCast, BrOnCastFail (target_pc, ...)
    13 => [1] // CallLocal (callee_pc, num_params, num_locals, max_stack_height)
    17 => [1] // ReturnCallLocal (callee_pc, ...)
    _ => []
  }
}

///|
/// Remap all PC values in the optimized ops array
fn remap_all_pcs(ops : Array[UInt64], index_map : FixedArray[Int]) -> Unit {
  let mut i = 0
  let len = ops.length()
  while i < len {
    let op = ops[i]
    let size = opcode_size(op)

    // Handle variable-length BrTable specially
    if size < 0 {
      // BrTable format: opcode, label_count, arity, [target_pc, drop_count]..., default_target, default_drop
      let label_count = ops[i + 1].to_int()
      // Remap each label's target_pc (at offset 3 + j*2)
      for j in 0..<label_count {
        let offset = 3 + j * 2 // target_pc position for label j
        let old_pc = ops[i + offset].to_int()
        ops[i + offset] = remap_pc(index_map, old_pc)
          .to_int64()
          .reinterpret_as_uint64()
      }
      // Remap default_target (at offset 3 + label_count*2)
      let default_offset = 3 + label_count * 2
      let default_old_pc = ops[i + default_offset].to_int()
      ops[i + default_offset] = remap_pc(index_map, default_old_pc)
        .to_int64()
        .reinterpret_as_uint64()
      let total_size = 3 + label_count * 2 + 2
      i = i + total_size
      continue
    }

    // Remap PC values based on opcode
    let pc_offsets = opcode_pc_offsets(op)
    for offset in pc_offsets {
      let old_pc = ops[i + offset].to_int()
      ops[i + offset] = remap_pc(index_map, old_pc)
        .to_int64()
        .reinterpret_as_uint64()
    }

    i = i + size
  }
}

///|
/// Get the initialization category for a local type.
/// Returns: 0 = zero (i32/i64/f32/f64), 1 = null ref, -1 = unsupported
fn local_init_category(t : @core.ValType) -> Int {
  match t {
    I32 | I64 | F32 | F64 => 0 // zero
    FuncRef
    | ExternRef
    | AnyRef
    | ExnRef
    | NullRef
    | NullFuncRef
    | NullExnRef
    | NullExternRef
    | EqRef
    | I31Ref
    | StructRef
    | ArrayRef
    | Ref(_, _) => 1 // null ref
    _ => -1 // unsupported (V128, etc.)
  }
}

///|
/// Emit batch initialization ops for declared locals.
/// Groups consecutive locals by type (zero vs null ref) for efficiency.
/// Unsupported types (V128) cause a trap instruction to be emitted.
fn Compiler::emit_locals_init(
  self : Compiler,
  locals : Array[@core.ValType],
) -> Unit {
  if locals.length() == 0 {
    return
  }
  let mut i = 0
  while i < locals.length() {
    let category = local_init_category(locals[i])
    if category < 0 {
      // Unsupported local type - emit trap
      self.emit_op(LocalInitUnsupported)
      return
    }
    let mut count = 1
    // Count consecutive locals of same category
    while i + count < locals.length() &&
          local_init_category(locals[i + count]) == category {
      count += 1
    }
    // Emit batch init op
    if category == 1 {
      self.emit_op(InitNullRefs)
    } else {
      self.emit_op(InitZeros)
    }
    self.emit_idx(count)
    i += count
  }
}

///|
fn Compiler::compile_func(
  self : Compiler,
  func_idx : Int, // Index into module_.funcs (excludes imports)
  code : @core.Code,
) -> Unit raise RuntimeError {
  // Get function type
  let type_idx = self.module_.funcs[func_idx].reinterpret_as_int()
  let func_type = require_func_type(self.module_, type_idx, "compile_func")

  // Create compile-time context with function result count
  let ctx = CompileCtx::new(func_type.results.length())

  // Push function parameters onto type stack (they become locals)
  // Parameters are already in locals, but we need them on the type stack
  // for the implicit function block
  for param in func_type.params {
    ctx.push_type(param)
  }

  // Push implicit function-level control frame
  // The function body acts like a block with params=[] and results=func_type.results
  // But parameters are already popped into locals, so we model it as empty params
  // target_pc is 0 placeholder - will be patched at end
  ctx.push_control(BlockKind, [], func_type.results, 0)
  let start_pc = self.ops.length()

  // Emit batch initialization for declared locals (params are already on stack)
  self.emit_locals_init(code.locals)

  // Compile function body
  for instr in code.body.instrs {
    self.compile_wasm_instr(ctx, instr)
  }
  // Emit implicit return at function end
  self.emit_op(Return)
  let end_pc = self.ops.length() - 1 // Points to op_return (before immediate)
  self.emit_idx(ctx.func_result_count)
  let func_block = ctx.pop_control()
  for slot in func_block.pending_br_patches {
    self.ops[slot] = end_pc.to_int64().reinterpret_as_uint64()
  }
  code.compiled = Some(start_pc)
  // Store max stack height: num_locals + max_operand_depth
  let num_locals = func_type.params.length() + code.locals.length()
  code.max_stack_height = num_locals + ctx.max_stack_depth
}

///|
fn Compiler::compile(self : Compiler) -> Unit raise RuntimeError {
  for i, code in self.module_.codes {
    self.compile_func(i, code)
  }
  // Patch forward call references now that all functions are compiled
  for patch in self.pending_call_patches {
    let code = self.module_.codes[patch.local_func_idx]
    guard code.compiled is Some(callee_pc) else {
      raise RuntimeError::FunctionNotCompiled(
        "Forward call to uncompiled function: \{patch.local_func_idx}",
      )
    }
    self.ops[patch.slot] = callee_pc.to_int64().reinterpret_as_uint64()
  }
}
