// ============================================================================
// Compilation
// ============================================================================

///|
fn Compiler::compile_wasm_instr(
  self : Compiler,
  ctx : CompileCtx,
  instr : @core.Instr,
) -> Unit raise RuntimeError {
  match instr {
    // Constants
    I32Const(value) => {
      self.emit_op(I32Const)
      ctx.push_type(I32)
      self.emit_i32(value)
    }
    // Arithmetic (binary: pop 2, push 1)
    I32Add => {
      ctx.pop_type()
      self.emit_op(I32Add)
    }
    I32Sub => {
      ctx.pop_type()
      self.emit_op(I32Sub)
    }
    I32Mul => {
      ctx.pop_type()
      self.emit_op(I32Mul)
    }
    I32DivS => {
      ctx.pop_type()
      self.emit_op(I32DivS)
    }
    I32DivU => {
      ctx.pop_type()
      self.emit_op(I32DivU)
    }
    I32RemS => {
      ctx.pop_type()
      self.emit_op(I32RemS)
    }
    I32RemU => {
      ctx.pop_type()
      self.emit_op(I32RemU)
    }
    // Bitwise (binary: pop 2, push 1)
    I32And => {
      ctx.pop_type()
      self.emit_op(I32And)
    }
    I32Or => {
      ctx.pop_type()
      self.emit_op(I32Or)
    }
    I32Xor => {
      ctx.pop_type()
      self.emit_op(I32Xor)
    }
    I32Shl => {
      ctx.pop_type()
      self.emit_op(I32Shl)
    }
    I32ShrS => {
      ctx.pop_type()
      self.emit_op(I32ShrS)
    }
    I32ShrU => {
      ctx.pop_type()
      self.emit_op(I32ShrU)
    }
    I32Rotl => {
      ctx.pop_type()
      self.emit_op(I32Rotl)
    }
    I32Rotr => {
      ctx.pop_type()
      self.emit_op(I32Rotr)
    }
    // Comparison (binary: pop 2, push 1 i32)
    I32Eq => {
      ctx.pop_type()
      self.emit_op(I32Eq)
    }
    I32Ne => {
      ctx.pop_type()
      self.emit_op(I32Ne)
    }
    I32LtS => {
      ctx.pop_type()
      self.emit_op(I32LtS)
    }
    I32LtU => {
      ctx.pop_type()
      self.emit_op(I32LtU)
    }
    I32GtS => {
      ctx.pop_type()
      self.emit_op(I32GtS)
    }
    I32GtU => {
      ctx.pop_type()
      self.emit_op(I32GtU)
    }
    I32LeS => {
      ctx.pop_type()
      self.emit_op(I32LeS)
    }
    I32LeU => {
      ctx.pop_type()
      self.emit_op(I32LeU)
    }
    I32GeS => {
      ctx.pop_type()
      self.emit_op(I32GeS)
    }
    I32GeU => {
      ctx.pop_type()
      self.emit_op(I32GeU)
    }
    // Unary (pop 1, push 1)
    I32Eqz => self.emit_op(I32Eqz) // i32 -> i32
    I32Clz => self.emit_op(I32Clz) // i32 -> i32
    I32Ctz => self.emit_op(I32Ctz) // i32 -> i32
    I32Popcnt => self.emit_op(I32Popcnt) // i32 -> i32
    I32Extend8S => self.emit_op(I32Extend8S) // i32 -> i32
    I32Extend16S => self.emit_op(I32Extend16S) // i32 -> i32
    I32WrapI64 => {
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(I32WrapI64)
    } // i64 -> i32
    // i64 Constants
    I64Const(value) => {
      self.emit_op(I64Const)
      // Split i64 into two i32 immediates
      self.emit_i32((value & 0xFFFFFFFFUL).to_uint())
      self.emit_i32((value >> 32).to_uint())
      ctx.push_type(I64)
    }
    // f32/f64 Constants
    F32Const(value) => {
      self.emit_op(F32Const)
      self.emit_i32(value.reinterpret_as_uint())
      ctx.push_type(F32)
    }
    F64Const(value) => {
      self.emit_op(F64Const)
      let bits = value.reinterpret_as_uint64()
      self.emit_i32((bits & 0xFFFFFFFFUL).to_uint())
      self.emit_i32((bits >> 32).to_uint())
      ctx.push_type(F64)
    }
    // i64 Arithmetic (binary: pop 2, push 1)
    I64Add => {
      ctx.pop_type()
      self.emit_op(I64Add)
    }
    I64Sub => {
      ctx.pop_type()
      self.emit_op(I64Sub)
    }
    I64Mul => {
      ctx.pop_type()
      self.emit_op(I64Mul)
    }
    I64DivS => {
      ctx.pop_type()
      self.emit_op(I64DivS)
    }
    I64DivU => {
      ctx.pop_type()
      self.emit_op(I64DivU)
    }
    I64RemS => {
      ctx.pop_type()
      self.emit_op(I64RemS)
    }
    I64RemU => {
      ctx.pop_type()
      self.emit_op(I64RemU)
    }
    // i64 Bitwise (binary: pop 2, push 1)
    I64And => {
      ctx.pop_type()
      self.emit_op(I64And)
    }
    I64Or => {
      ctx.pop_type()
      self.emit_op(I64Or)
    }
    I64Xor => {
      ctx.pop_type()
      self.emit_op(I64Xor)
    }
    I64Shl => {
      ctx.pop_type()
      self.emit_op(I64Shl)
    }
    I64ShrS => {
      ctx.pop_type()
      self.emit_op(I64ShrS)
    }
    I64ShrU => {
      ctx.pop_type()
      self.emit_op(I64ShrU)
    }
    I64Rotl => {
      ctx.pop_type()
      self.emit_op(I64Rotl)
    }
    I64Rotr => {
      ctx.pop_type()
      self.emit_op(I64Rotr)
    }
    // i64 Comparison (pop 2 i64, push 1 i32)
    I64Eq => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(I64Eq)
    }
    I64Ne => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(I64Ne)
    }
    I64LtS => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(I64LtS)
    }
    I64LtU => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(I64LtU)
    }
    I64GtS => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(I64GtS)
    }
    I64GtU => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(I64GtU)
    }
    I64LeS => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(I64LeS)
    }
    I64LeU => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(I64LeU)
    }
    I64GeS => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(I64GeS)
    }
    I64GeU => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(I64GeU)
    }
    // i64 Unary
    I64Eqz => {
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(I64Eqz)
    } // i64 -> i32
    I64Clz => self.emit_op(I64Clz) // i64 -> i64
    I64Ctz => self.emit_op(I64Ctz) // i64 -> i64
    I64Popcnt => self.emit_op(I64Popcnt) // i64 -> i64
    I64Extend8S => self.emit_op(I64Extend8S) // i64 -> i64
    I64Extend16S => self.emit_op(I64Extend16S) // i64 -> i64
    I64Extend32S => self.emit_op(I64Extend32S) // i64 -> i64
    I64ExtendI32S => {
      ctx.pop_type()
      ctx.push_type(I64)
      self.emit_op(I64ExtendI32S)
    } // i32 -> i64
    I64ExtendI32U => {
      ctx.pop_type()
      ctx.push_type(I64)
      self.emit_op(I64ExtendI32U)
    } // i32 -> i64
    // Float comparisons (pop 2, push i32)
    F32Eq => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(F32Eq)
    }
    F32Ne => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(F32Ne)
    }
    F32Lt => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(F32Lt)
    }
    F32Gt => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(F32Gt)
    }
    F32Le => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(F32Le)
    }
    F32Ge => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(F32Ge)
    }
    F64Eq => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(F64Eq)
    }
    F64Ne => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(F64Ne)
    }
    F64Lt => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(F64Lt)
    }
    F64Gt => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(F64Gt)
    }
    F64Le => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(F64Le)
    }
    F64Ge => {
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(F64Ge)
    }
    // Float unary (same type in/out)
    F32Neg => self.emit_op(F32Neg)
    F32Abs => self.emit_op(F32Abs)
    F32Sqrt => self.emit_op(F32Sqrt)
    F32Ceil => self.emit_op(F32Ceil)
    F32Floor => self.emit_op(F32Floor)
    F32Trunc => self.emit_op(F32Trunc)
    F32Nearest => self.emit_op(F32Nearest)
    F64Neg => self.emit_op(F64Neg)
    F64Abs => self.emit_op(F64Abs)
    F64Sqrt => self.emit_op(F64Sqrt)
    F64Ceil => self.emit_op(F64Ceil)
    F64Floor => self.emit_op(F64Floor)
    F64Trunc => self.emit_op(F64Trunc)
    F64Nearest => self.emit_op(F64Nearest)
    // Float binary (pop 2, push 1)
    F32Add => {
      ctx.pop_type()
      self.emit_op(F32Add)
    }
    F32Sub => {
      ctx.pop_type()
      self.emit_op(F32Sub)
    }
    F32Mul => {
      ctx.pop_type()
      self.emit_op(F32Mul)
    }
    F32Div => {
      ctx.pop_type()
      self.emit_op(F32Div)
    }
    F32Min => {
      ctx.pop_type()
      self.emit_op(F32Min)
    }
    F32Max => {
      ctx.pop_type()
      self.emit_op(F32Max)
    }
    F32Copysign => {
      ctx.pop_type()
      self.emit_op(F32Copysign)
    }
    F64Add => {
      ctx.pop_type()
      self.emit_op(F64Add)
    }
    F64Sub => {
      ctx.pop_type()
      self.emit_op(F64Sub)
    }
    F64Mul => {
      ctx.pop_type()
      self.emit_op(F64Mul)
    }
    F64Div => {
      ctx.pop_type()
      self.emit_op(F64Div)
    }
    F64Min => {
      ctx.pop_type()
      self.emit_op(F64Min)
    }
    F64Max => {
      ctx.pop_type()
      self.emit_op(F64Max)
    }
    F64Copysign => {
      ctx.pop_type()
      self.emit_op(F64Copysign)
    }
    // Float conversions
    F64ConvertI64U => {
      ctx.pop_type()
      ctx.push_type(F64)
      self.emit_op(F64ConvertI64U)
    }
    F64ConvertI64S => {
      ctx.pop_type()
      ctx.push_type(F64)
      self.emit_op(F64ConvertI64S)
    }
    F64ConvertI32U => {
      ctx.pop_type()
      ctx.push_type(F64)
      self.emit_op(F64ConvertI32U)
    }
    F64ConvertI32S => {
      ctx.pop_type()
      ctx.push_type(F64)
      self.emit_op(F64ConvertI32S)
    }
    F64PromoteF32 => {
      ctx.pop_type()
      ctx.push_type(F64)
      self.emit_op(F64PromoteF32)
    }
    F32DemoteF64 => {
      ctx.pop_type()
      ctx.push_type(F32)
      self.emit_op(F32DemoteF64)
    }
    F32ConvertI32S => {
      ctx.pop_type()
      ctx.push_type(F32)
      self.emit_op(F32ConvertI32S)
    }
    F32ConvertI32U => {
      ctx.pop_type()
      ctx.push_type(F32)
      self.emit_op(F32ConvertI32U)
    }
    F32ConvertI64S => {
      ctx.pop_type()
      ctx.push_type(F32)
      self.emit_op(F32ConvertI64S)
    }
    F32ConvertI64U => {
      ctx.pop_type()
      ctx.push_type(F32)
      self.emit_op(F32ConvertI64U)
    }
    // Truncations
    I64TruncF64S => {
      ctx.pop_type()
      ctx.push_type(I64)
      self.emit_op(I64TruncF64S)
    }
    I64TruncF64U => {
      ctx.pop_type()
      ctx.push_type(I64)
      self.emit_op(I64TruncF64U)
    }
    I32TruncF32S => {
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(I32TruncF32S)
    }
    I32TruncF32U => {
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(I32TruncF32U)
    }
    I32TruncF64S => {
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(I32TruncF64S)
    }
    I32TruncF64U => {
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(I32TruncF64U)
    }
    I64TruncF32S => {
      ctx.pop_type()
      ctx.push_type(I64)
      self.emit_op(I64TruncF32S)
    }
    I64TruncF32U => {
      ctx.pop_type()
      ctx.push_type(I64)
      self.emit_op(I64TruncF32U)
    }
    // Saturating truncations
    I32TruncSatF32S => {
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(I32TruncSatF32S)
    }
    I32TruncSatF32U => {
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(I32TruncSatF32U)
    }
    I32TruncSatF64S => {
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(I32TruncSatF64S)
    }
    I32TruncSatF64U => {
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(I32TruncSatF64U)
    }
    I64TruncSatF32S => {
      ctx.pop_type()
      ctx.push_type(I64)
      self.emit_op(I64TruncSatF32S)
    }
    I64TruncSatF32U => {
      ctx.pop_type()
      ctx.push_type(I64)
      self.emit_op(I64TruncSatF32U)
    }
    I64TruncSatF64S => {
      ctx.pop_type()
      ctx.push_type(I64)
      self.emit_op(I64TruncSatF64S)
    }
    I64TruncSatF64U => {
      ctx.pop_type()
      ctx.push_type(I64)
      self.emit_op(I64TruncSatF64U)
    }
    // Reinterpret (same size, different type)
    I32ReinterpretF32 => {
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(I32ReinterpretF32)
    }
    I64ReinterpretF64 => {
      ctx.pop_type()
      ctx.push_type(I64)
      self.emit_op(I64ReinterpretF64)
    }
    F32ReinterpretI32 => {
      ctx.pop_type()
      ctx.push_type(F32)
      self.emit_op(F32ReinterpretI32)
    }
    F64ReinterpretI64 => {
      ctx.pop_type()
      ctx.push_type(F64)
      self.emit_op(F64ReinterpretI64)
    }
    // Locals - we don't track local types here, just use a placeholder
    LocalGet(_idx) => {
      self.emit_op(LocalGet)
      self.emit_idx(_idx.reinterpret_as_int())
      // We need to push the local's type, but we don't have access to it here
      // For simplicity, push I32 as placeholder (the exact type doesn't matter for branch arity)
      ctx.push_type(I32)
    }
    LocalSet(_idx) => {
      ctx.pop_type()
      self.emit_op(LocalSet)
      self.emit_idx(_idx.reinterpret_as_int())
    }
    LocalTee(_idx) => {
      // Tee keeps the value on stack
      self.emit_op(LocalTee)
      self.emit_idx(_idx.reinterpret_as_int())
    }
    // Stack
    Drop => {
      ctx.pop_type()
      self.emit_op(Drop)
    }
    Select => {
      ctx.pop_types(2)
      self.emit_op(Select)
    } // pop 3, push 1 => net -2
    SelectTyped(_types) => {
      // Runtime behavior is identical to untyped select
      ctx.pop_types(2)
      self.emit_op(Select)
    } // pop 3, push 1 => net -2
    Nop => self.emit_op(Nop)
    Unreachable => self.emit_op(Unreachable)
    Throw(tag_idx) => {
      let tag_idx_int = tag_idx.reinterpret_as_int()
      let num_imported = count_imported_tags(self.module_)
      let type_idx = get_tag_type_idx(self.module_, tag_idx_int, num_imported)
      if type_idx >= 0 {
        let tag_type = require_func_type(self.module_, type_idx, "throw")
        ctx.pop_types(tag_type.params.length())
      }
      self.emit_op(Throw)
      self.emit_idx(tag_idx_int)
    }
    Rethrow(label_idx) => {
      self.emit_op(Rethrow)
      self.emit_idx(label_idx.reinterpret_as_int())
    }
    Simd(simd) => {
      match @core.simd_spec_by_opcode(simd.opcode) {
        Some(spec) =>
          match @core.simd_stack_effect(spec.name) {
            Const => ctx.push_type(V128)
            Load => {
              ctx.pop_type()
              ctx.push_type(V128)
            }
            Store => ctx.pop_types(2)
            LoadLane => {
              ctx.pop_types(2)
              ctx.push_type(V128)
            }
            StoreLane => ctx.pop_types(2)
            Unary => {
              ctx.pop_type()
              ctx.push_type(V128)
            }
            Binary => {
              ctx.pop_types(2)
              ctx.push_type(V128)
            }
            Ternary => {
              ctx.pop_types(3)
              ctx.push_type(V128)
            }
            Shift => {
              ctx.pop_types(2)
              ctx.push_type(V128)
            }
            ToI32 => {
              ctx.pop_type()
              ctx.push_type(I32)
            }
            Splat(_t) => {
              ctx.pop_type()
              ctx.push_type(V128)
            }
            Extract(t) => {
              ctx.pop_type()
              ctx.push_type(t)
            }
            Replace(_t) => {
              ctx.pop_types(2)
              ctx.push_type(V128)
            }
          }
        None => ()
      }
      self.emit_op(SimdUnimplemented)
    }
    Atomic(atomic_instr) => {
      match @core.atomic_spec_by_opcode(atomic_instr.opcode) {
        Some(spec) =>
          match @core.atomic_stack_effect(spec.name) {
            Fence => ()
            Notify => {
              ctx.pop_types(2)
              ctx.push_type(I32)
            }
            Wait32 => {
              ctx.pop_types(3)
              ctx.push_type(I32)
            }
            Wait64 => {
              ctx.pop_types(3)
              ctx.push_type(I32)
            }
            Load(t, _size) => {
              ctx.pop_type()
              ctx.push_type(t)
            }
            Store(_t, _size) => ctx.pop_types(2)
            Rmw(t, _size) => {
              ctx.pop_types(2)
              ctx.push_type(t)
            }
            Cmpxchg(t, _size) => {
              ctx.pop_types(3)
              ctx.push_type(t)
            }
          }
        None => ()
      }
      self.emit_op(AtomicUnimplemented)
    }
    // Control flow
    Block(block_type, instrs) => {
      let (params, results) = get_compile_block_type(self.module_, block_type)
      // Push control frame - target_pc is 0 (placeholder), will be patched at block end
      ctx.push_control(BlockKind, params, results, 0)
      // Compile block body
      for instr in instrs {
        self.compile_wasm_instr(ctx, instr)
      }
      // Now we know the end PC - it's the current position
      let end_pc = self.ops.length()
      // Pop control frame and patch all pending branches
      let block = ctx.pop_control()
      for slot in block.pending_br_patches {
        self.ops[slot] = end_pc.to_int64().reinterpret_as_uint64()
      }
      // Reset type stack
      ctx.truncate_stack(block.stack_height_at_entry)
      ctx.push_types(block.results)
    }
    Loop(block_type, instrs) => {
      let (params, results) = get_compile_block_type(self.module_, block_type)
      // For loops, target_pc is the start (where br jumps back to)
      let loop_start = self.ops.length()
      ctx.push_control(LoopKind, params, results, loop_start)
      // Compile loop body
      for instr in instrs {
        self.compile_wasm_instr(ctx, instr)
      }
      // Pop control frame (no patches needed for loops - target was known at start)
      let block = ctx.pop_control()
      ctx.truncate_stack(block.stack_height_at_entry)
      ctx.push_types(block.results)
    }
    Br(label) => {
      let label_int = label.reinterpret_as_int()
      let arity = ctx.get_branch_arity(label_int)
      let drop_count = ctx.calc_drop_count(label_int, arity)
      self.emit_op(Br)
      // Emit target PC slot - for loops it's known, for blocks we need to patch
      let target_pc_slot = self.ops.length()
      if ctx.is_loop_target(label_int) {
        // Loop target is known
        self.emit_idx(ctx.get_target_pc(label_int))
      } else {
        // Block/if target - emit placeholder and register for patching
        self.emit_idx(0)
        ctx.add_br_patch(label_int, target_pc_slot)
      }
      self.emit_idx(arity)
      self.emit_idx(drop_count)
    }
    BrIf(label) => {
      ctx.pop_type() // Pop condition
      let label_int = label.reinterpret_as_int()
      let arity = ctx.get_branch_arity(label_int)
      let drop_count = ctx.calc_drop_count(label_int, arity)
      self.emit_op(BrIf)
      // Emit target PC slot
      let target_pc_slot = self.ops.length()
      if ctx.is_loop_target(label_int) {
        self.emit_idx(ctx.get_target_pc(label_int))
      } else {
        self.emit_idx(0)
        ctx.add_br_patch(label_int, target_pc_slot)
      }
      self.emit_idx(arity)
      self.emit_idx(drop_count)
    }
    BrTable(labels, default_label) => {
      ctx.pop_type() // Pop index
      // Use default label for arity calculation (all must have same arity per validation)
      let default_int = default_label.reinterpret_as_int()
      let arity = ctx.get_branch_arity(default_int)
      self.emit_op(BrTable)
      self.emit_idx(labels.length())
      self.emit_idx(arity)
      // For each label, emit target_pc + drop_count
      for label in labels {
        let label_int = label.reinterpret_as_int()
        let drop_count = ctx.calc_drop_count(label_int, arity)
        let target_pc_slot = self.ops.length()
        if ctx.is_loop_target(label_int) {
          self.emit_idx(ctx.get_target_pc(label_int))
        } else {
          self.emit_idx(0)
          ctx.add_br_patch(label_int, target_pc_slot)
        }
        self.emit_idx(drop_count)
      }
      // Default label
      let default_drop = ctx.calc_drop_count(default_int, arity)
      let default_pc_slot = self.ops.length()
      if ctx.is_loop_target(default_int) {
        self.emit_idx(ctx.get_target_pc(default_int))
      } else {
        self.emit_idx(0)
        ctx.add_br_patch(default_int, default_pc_slot)
      }
      self.emit_idx(default_drop)
    }
    BrOnNull(label) => {
      // br_on_null: branch if ref is null, leaving ref on stack if not null
      ctx.pop_type() // Pop the reference type
      let label_int = label.reinterpret_as_int()
      let arity = ctx.get_branch_arity(label_int)
      let drop_count = ctx.calc_drop_count(label_int, arity)
      self.emit_op(BrOnNull)
      let target_pc_slot = self.ops.length()
      if ctx.is_loop_target(label_int) {
        self.emit_idx(ctx.get_target_pc(label_int))
      } else {
        self.emit_idx(0)
        ctx.add_br_patch(label_int, target_pc_slot)
      }
      self.emit_idx(arity)
      self.emit_idx(drop_count)
      // In fallthrough case, ref is pushed back
      ctx.push_type(FuncRef)
    }
    BrOnNonNull(label) => {
      // br_on_non_null: branch if ref is not null
      // Calculate arity and drop_count BEFORE popping the ref type,
      // because at runtime the ref will be pushed back before the shuffle
      let label_int = label.reinterpret_as_int()
      let arity = ctx.get_branch_arity(label_int)
      let drop_count = ctx.calc_drop_count(label_int, arity)
      ctx.pop_type() // Pop the reference type
      self.emit_op(BrOnNonNull)
      let target_pc_slot = self.ops.length()
      if ctx.is_loop_target(label_int) {
        self.emit_idx(ctx.get_target_pc(label_int))
      } else {
        self.emit_idx(0)
        ctx.add_br_patch(label_int, target_pc_slot)
      }
      self.emit_idx(arity)
      self.emit_idx(drop_count)
      // In fallthrough case (null), ref is discarded
    }
    If(block_type, then_instrs, else_instrs) => {
      ctx.pop_type() // Pop condition
      let (params, results) = get_compile_block_type(self.module_, block_type)
      // Push control frame - target_pc is 0 (placeholder), will be patched at if end
      ctx.push_control(IfKind, params, results, 0)
      let entry_height = ctx.control_stack[ctx.control_stack.length() - 1].stack_height_at_entry
      // Emit if instruction with placeholder for else branch
      self.emit_op(If)
      let else_pc_slot = self.ops.length()
      self.emit_idx(0)
      // Compile then branch
      for instr in then_instrs {
        self.compile_wasm_instr(ctx, instr)
      }
      // Emit jump over else branch (unconditional)
      self.emit_op(Br)
      let end_jump_slot = self.ops.length()
      self.emit_idx(0) // Will be patched to end
      self.emit_idx(results.length()) // arity = results
      self.emit_idx(0) // drop_count = 0 (then branch should have correct stack)
      // Patch else_pc to point here
      let else_start = self.ops.length()
      self.ops[else_pc_slot] = else_start.to_int64().reinterpret_as_uint64()
      // Reset stack for else branch
      ctx.truncate_stack(entry_height)
      ctx.push_types(params)
      // Compile else branch
      for instr in else_instrs {
        self.compile_wasm_instr(ctx, instr)
      }
      // Now we know the end PC
      let end_pc = self.ops.length()
      // Patch the jump at end of then branch
      self.ops[end_jump_slot] = end_pc.to_int64().reinterpret_as_uint64()
      // Pop control frame and patch all pending branches from inside the if
      let block = ctx.pop_control()
      for slot in block.pending_br_patches {
        self.ops[slot] = end_pc.to_int64().reinterpret_as_uint64()
      }
      ctx.truncate_stack(block.stack_height_at_entry)
      ctx.push_types(block.results)
    }
    TryTable(block_type, _catches, instrs) => {
      let (params, results) = get_compile_block_type(self.module_, block_type)
      ctx.push_control(BlockKind, params, results, 0)
      for instr in instrs {
        self.compile_wasm_instr(ctx, instr)
      }
      let end_pc = self.ops.length()
      let block = ctx.pop_control()
      for slot in block.pending_br_patches {
        self.ops[slot] = end_pc.to_int64().reinterpret_as_uint64()
      }
      ctx.truncate_stack(block.stack_height_at_entry)
      ctx.push_types(block.results)
    }
    Call(func_idx) => {
      // Look up function signature to properly track types
      let func_idx_int = func_idx.reinterpret_as_int()
      let num_imported = count_imported_funcs(self.module_)
      let type_idx = get_func_type_idx(self.module_, func_idx_int, num_imported)

      // Get the function type and update type stack
      if type_idx >= 0 {
        let func_type = require_func_type(self.module_, type_idx, "call")
        // Pop params from type stack
        ctx.pop_types(func_type.params.length())
        // Push results to type stack
        for result_type in func_type.results {
          ctx.push_type(result_type)
        }
      }

      // Emit appropriate op based on whether function is imported or local
      if func_idx_int < num_imported {
        self.emit_op(CallImport)
        self.emit_idx(func_idx_int)
      } else {
        // Emit op_call_local with all immediates computed at compile time:
        // - callee_pc (or placeholder for forward ref)
        // - num_params
        // - num_locals
        // - max_stack_height
        let local_func_idx = func_idx_int - num_imported
        let code = self.module_.codes[local_func_idx]
        let func_type = require_func_type(self.module_, type_idx, "call")
        let num_params = func_type.params.length()
        let num_locals = num_params + code.locals.length()
        self.emit_op(CallLocal)
        let callee_pc_slot = self.ops.length()
        match code.compiled {
          Some(callee_pc) => self.emit_idx(callee_pc)
          None => {
            // Forward reference - emit placeholder and record for patching
            self.emit_idx(0)
            self.pending_call_patches.push({
              local_func_idx,
              slot: callee_pc_slot,
            })
          }
        }
        self.emit_idx(num_params)
        self.emit_idx(num_locals)
        self.emit_idx(code.max_stack_height)
      }
    }
    Return => {
      self.emit_op(Return)
      self.emit_idx(ctx.func_result_count)
    }
    // Memory instructions (load: pop addr, push value; store: pop addr+value)
    I32Load(_align, offset, _mem_idx) => {
      // pop i32 addr, push i32 value
      self.emit_op(I32Load)
      self.emit_idx(offset.reinterpret_as_int())
    }
    I32Store(_align, offset, _mem_idx) => {
      ctx.pop_types(2) // pop addr and value
      self.emit_op(I32Store)
      self.emit_idx(offset.reinterpret_as_int())
    }
    I32Load8S(_align, offset, _mem_idx) => {
      self.emit_op(I32Load8S)
      self.emit_idx(offset.reinterpret_as_int())
    }
    I32Load8U(_align, offset, _mem_idx) => {
      self.emit_op(I32Load8U)
      self.emit_idx(offset.reinterpret_as_int())
    }
    I32Load16S(_align, offset, _mem_idx) => {
      self.emit_op(I32Load16S)
      self.emit_idx(offset.reinterpret_as_int())
    }
    I32Load16U(_align, offset, _mem_idx) => {
      self.emit_op(I32Load16U)
      self.emit_idx(offset.reinterpret_as_int())
    }
    I32Store8(_align, offset, _mem_idx) => {
      ctx.pop_types(2)
      self.emit_op(I32Store8)
      self.emit_idx(offset.reinterpret_as_int())
    }
    I32Store16(_align, offset, _mem_idx) => {
      ctx.pop_types(2)
      self.emit_op(I32Store16)
      self.emit_idx(offset.reinterpret_as_int())
    }
    I64Load(_align, offset, _mem_idx) => {
      ctx.pop_type()
      ctx.push_type(I64)
      self.emit_op(I64Load)
      self.emit_idx(offset.reinterpret_as_int())
    }
    I64Store(_align, offset, _mem_idx) => {
      ctx.pop_types(2)
      self.emit_op(I64Store)
      self.emit_idx(offset.reinterpret_as_int())
    }
    I64Load8S(_align, offset, _mem_idx) => {
      ctx.pop_type()
      ctx.push_type(I64)
      self.emit_op(I64Load8S)
      self.emit_idx(offset.reinterpret_as_int())
    }
    I64Load8U(_align, offset, _mem_idx) => {
      ctx.pop_type()
      ctx.push_type(I64)
      self.emit_op(I64Load8U)
      self.emit_idx(offset.reinterpret_as_int())
    }
    I64Load16S(_align, offset, _mem_idx) => {
      ctx.pop_type()
      ctx.push_type(I64)
      self.emit_op(I64Load16S)
      self.emit_idx(offset.reinterpret_as_int())
    }
    I64Load16U(_align, offset, _mem_idx) => {
      ctx.pop_type()
      ctx.push_type(I64)
      self.emit_op(I64Load16U)
      self.emit_idx(offset.reinterpret_as_int())
    }
    I64Load32S(_align, offset, _mem_idx) => {
      ctx.pop_type()
      ctx.push_type(I64)
      self.emit_op(I64Load32S)
      self.emit_idx(offset.reinterpret_as_int())
    }
    I64Load32U(_align, offset, _mem_idx) => {
      ctx.pop_type()
      ctx.push_type(I64)
      self.emit_op(I64Load32U)
      self.emit_idx(offset.reinterpret_as_int())
    }
    I64Store8(_align, offset, _mem_idx) => {
      ctx.pop_types(2)
      self.emit_op(I64Store8)
      self.emit_idx(offset.reinterpret_as_int())
    }
    I64Store16(_align, offset, _mem_idx) => {
      ctx.pop_types(2)
      self.emit_op(I64Store16)
      self.emit_idx(offset.reinterpret_as_int())
    }
    I64Store32(_align, offset, _mem_idx) => {
      ctx.pop_types(2)
      self.emit_op(I64Store32)
      self.emit_idx(offset.reinterpret_as_int())
    }
    F32Load(_align, offset, _mem_idx) => {
      ctx.pop_type()
      ctx.push_type(F32)
      self.emit_op(F32Load)
      self.emit_idx(offset.reinterpret_as_int())
    }
    F32Store(_align, offset, _mem_idx) => {
      ctx.pop_types(2)
      self.emit_op(F32Store)
      self.emit_idx(offset.reinterpret_as_int())
    }
    F64Load(_align, offset, _mem_idx) => {
      ctx.pop_type()
      ctx.push_type(F64)
      self.emit_op(F64Load)
      self.emit_idx(offset.reinterpret_as_int())
    }
    F64Store(_align, offset, _mem_idx) => {
      ctx.pop_types(2)
      self.emit_op(F64Store)
      self.emit_idx(offset.reinterpret_as_int())
    }
    // Global instructions
    GlobalGet(_idx) => {
      ctx.push_type(I32) // Placeholder type
      self.emit_op(GlobalGet)
      self.emit_idx(_idx.reinterpret_as_int())
    }
    GlobalSet(_idx) => {
      ctx.pop_type()
      self.emit_op(GlobalSet)
      self.emit_idx(_idx.reinterpret_as_int())
    }
    // Memory size and grow
    MemorySize(_mem_idx) => {
      ctx.push_type(I32)
      self.emit_op(MemorySize)
    }
    MemoryGrow(_mem_idx) => self.emit_op(MemoryGrow) // i32 -> i32

    // Bulk memory instructions
    MemoryCopy(_dst_idx, _src_idx) => {
      ctx.pop_types(3) // pop dest, src, n
      self.emit_op(MemoryCopy)
    }
    MemoryFill(_mem_idx) => {
      ctx.pop_types(3) // pop dest, val, n
      self.emit_op(MemoryFill)
    }
    MemoryInit(data_idx, _mem_idx) => {
      ctx.pop_types(3) // pop dest, src, n
      self.emit_op(MemoryInit)
      self.emit_idx(data_idx.reinterpret_as_int())
    }
    DataDrop(data_idx) => {
      self.emit_op(DataDrop)
      self.emit_idx(data_idx.reinterpret_as_int())
    }

    // Table bulk operations
    TableInit(table_idx, elem_idx) => {
      ctx.pop_types(3) // pop dest, src, n
      self.emit_op(TableInit)
      self.emit_idx(table_idx.reinterpret_as_int())
      self.emit_idx(elem_idx.reinterpret_as_int())
    }
    TableCopy(dst_table_idx, src_table_idx) => {
      ctx.pop_types(3) // pop dest, src, n
      self.emit_op(TableCopy)
      self.emit_idx(dst_table_idx.reinterpret_as_int())
      self.emit_idx(src_table_idx.reinterpret_as_int())
    }
    TableFill(table_idx) => {
      ctx.pop_types(3) // pop dest, val, n
      self.emit_op(TableFill)
      self.emit_idx(table_idx.reinterpret_as_int())
    }
    ElemDrop(elem_idx) => {
      self.emit_op(ElemDrop)
      self.emit_idx(elem_idx.reinterpret_as_int())
    }

    // Table instructions
    TableSize(table_idx) => {
      ctx.push_type(I32)
      self.emit_op(TableSize)
      self.emit_idx(table_idx.reinterpret_as_int())
    }
    TableGet(table_idx) => {
      // pop i32 index, push ref
      self.emit_op(TableGet)
      self.emit_idx(table_idx.reinterpret_as_int())
    }
    TableSet(table_idx) => {
      ctx.pop_types(2) // pop index and ref
      self.emit_op(TableSet)
      self.emit_idx(table_idx.reinterpret_as_int())
    }
    TableGrow(table_idx) => {
      ctx.pop_type() // pop count, keep delta -> result
      self.emit_op(TableGrow)
      self.emit_idx(table_idx.reinterpret_as_int())
    }
    // Reference instructions
    RefNull(_ref_type) => {
      ctx.push_type(reftype_to_valtype(_ref_type))
      self.emit_op(RefNull)
      // Encode the ref type as an immediate
      let type_idx = match _ref_type {
        Func => 0
        Extern => 1
        Any => 2
        Eq => 3
        I31 => 4
        Struct => 5
        Array => 6
        Exn => 7
        None => 8
        NoFunc => 9
        NoExtern => 10
        NoExn => 11
        TypeIndex(idx) => idx
      }
      self.emit_idx(type_idx)
    }
    RefFunc(func_idx) => {
      let func_idx_int = func_idx.reinterpret_as_int()
      let num_imported = count_imported_funcs(self.module_)
      let type_idx = get_func_type_idx(self.module_, func_idx_int, num_imported)
      if type_idx >= 0 {
        ctx.push_type(Ref(TypeIndex(type_idx), false))
      } else {
        ctx.push_type(FuncRef)
      }
      self.emit_op(RefFunc)
      self.emit_idx(func_idx.reinterpret_as_int())
    }
    RefIsNull => {
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(RefIsNull)
    }
    RefEq => {
      ctx.pop_type()
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(RefEq)
    }
    RefAsNonNull => {
      let popped = ctx.pop_type_value()
      match popped {
        Some(val_type) => ctx.push_type(non_null_ref_type(val_type))
        None => ctx.push_type(Ref(Any, false))
      }
      self.emit_op(RefAsNonNull)
    }
    RefTest(ref_type, nullable) => {
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(RefTest)
      // Emit target type code (negative for abstract types, positive for TypeIndex)
      let target_type = match ref_type {
        Func => -7
        Extern => -8
        Any => -2
        Eq => -3
        I31 => -4
        Struct => -5
        Array => -6
        Exn => -9
        None => -10
        NoFunc => -11
        NoExtern => -12
        NoExn => -13
        TypeIndex(idx) => idx
      }
      self.emit_idx(target_type)
      self.emit_idx(if nullable { 1 } else { 0 })
    }
    RefCast(ref_type, nullable) => {
      let target = reftype_to_valtype(ref_type)
      let result_type = if nullable {
        target
      } else {
        non_null_ref_type(target)
      }
      ctx.pop_type()
      ctx.push_type(result_type)
      self.emit_op(RefCast)
      // Emit target type code
      let target_type = match ref_type {
        Func => -7
        Extern => -8
        Any => -2
        Eq => -3
        I31 => -4
        Struct => -5
        Array => -6
        Exn => -9
        None => -10
        NoFunc => -11
        NoExtern => -12
        NoExn => -13
        TypeIndex(idx) => idx
      }
      self.emit_idx(target_type)
      self.emit_idx(if nullable { 1 } else { 0 })
    }
    StructNew(type_idx) => {
      let type_idx_int = type_idx.reinterpret_as_int()
      let struct_type = require_struct_type(
        self.module_,
        type_idx_int,
        "struct.new",
      )
      let num_fields = struct_type.fields.length()
      ctx.pop_types(num_fields)
      ctx.push_type(Ref(TypeIndex(type_idx_int), false))
      self.emit_op(StructNew)
      self.emit_idx(type_idx_int)
      self.emit_idx(num_fields)
    }
    StructNewDefault(type_idx) => {
      let type_idx_int = type_idx.reinterpret_as_int()
      let struct_type = require_struct_type(
        self.module_,
        type_idx_int,
        "struct.new_default",
      )
      let num_fields = struct_type.fields.length()
      ctx.push_type(Ref(TypeIndex(type_idx_int), false))
      self.emit_op(StructNewDefault)
      self.emit_idx(type_idx_int)
      self.emit_idx(num_fields)
    }
    StructGet(type_idx, field_idx) => {
      let type_idx_int = type_idx.reinterpret_as_int()
      let field_idx_int = field_idx.reinterpret_as_int()
      let struct_type = require_struct_type(
        self.module_,
        type_idx_int,
        "struct.get",
      )
      if field_idx_int < 0 || field_idx_int >= struct_type.fields.length() {
        raise RuntimeError::InvalidType("struct.get: invalid field index")
      }
      let field = struct_type.fields[field_idx_int]
      ctx.pop_type()
      ctx.push_type(storage_value_type(field.storage))
      self.emit_op(StructGet)
      self.emit_idx(field_idx_int)
    }
    StructGetS(type_idx, field_idx) => {
      let type_idx_int = type_idx.reinterpret_as_int()
      let field_idx_int = field_idx.reinterpret_as_int()
      let struct_type = require_struct_type(
        self.module_,
        type_idx_int,
        "struct.get_s",
      )
      if field_idx_int < 0 || field_idx_int >= struct_type.fields.length() {
        raise RuntimeError::InvalidType("struct.get_s: invalid field index")
      }
      let field = struct_type.fields[field_idx_int]
      let storage_type_code = match field.storage {
        I8 => 0
        I16 => 1
        _ => 0
      }
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(StructGetS)
      self.emit_idx(field_idx_int)
      self.emit_idx(storage_type_code)
    }
    StructGetU(type_idx, field_idx) => {
      let type_idx_int = type_idx.reinterpret_as_int()
      let field_idx_int = field_idx.reinterpret_as_int()
      let struct_type = require_struct_type(
        self.module_,
        type_idx_int,
        "struct.get_u",
      )
      if field_idx_int < 0 || field_idx_int >= struct_type.fields.length() {
        raise RuntimeError::InvalidType("struct.get_u: invalid field index")
      }
      let field = struct_type.fields[field_idx_int]
      let storage_type_code = match field.storage {
        I8 => 0
        I16 => 1
        _ => 0
      }
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(StructGetU)
      self.emit_idx(field_idx_int)
      self.emit_idx(storage_type_code)
    }
    StructSet(type_idx, field_idx) => {
      let type_idx_int = type_idx.reinterpret_as_int()
      let field_idx_int = field_idx.reinterpret_as_int()
      let struct_type = require_struct_type(
        self.module_,
        type_idx_int,
        "struct.set",
      )
      if field_idx_int < 0 || field_idx_int >= struct_type.fields.length() {
        raise RuntimeError::InvalidType("struct.set: invalid field index")
      }
      ctx.pop_types(2)
      self.emit_op(StructSet)
      self.emit_idx(field_idx_int)
    }
    ArrayNew(type_idx) => {
      let type_idx_int = type_idx.reinterpret_as_int()
      let _ = require_array_type(self.module_, type_idx_int, "array.new")
      ctx.pop_types(2)
      ctx.push_type(Ref(TypeIndex(type_idx_int), false))
      self.emit_op(ArrayNew)
      self.emit_idx(type_idx_int)
    }
    ArrayNewDefault(type_idx) => {
      let type_idx_int = type_idx.reinterpret_as_int()
      let _ = require_array_type(
        self.module_,
        type_idx_int,
        "array.new_default",
      )
      ctx.pop_type()
      ctx.push_type(Ref(TypeIndex(type_idx_int), false))
      self.emit_op(ArrayNewDefault)
      self.emit_idx(type_idx_int)
    }
    ArrayNewFixed(type_idx, len) => {
      let type_idx_int = type_idx.reinterpret_as_int()
      let len_int = len.reinterpret_as_int()
      let _ = require_array_type(self.module_, type_idx_int, "array.new_fixed")
      ctx.pop_types(len_int)
      ctx.push_type(Ref(TypeIndex(type_idx_int), false))
      self.emit_op(ArrayNewFixed)
      self.emit_idx(type_idx_int)
      self.emit_idx(len_int)
    }
    ArrayNewData(type_idx, data_idx) => {
      let type_idx_int = type_idx.reinterpret_as_int()
      let data_idx_int = data_idx.reinterpret_as_int()
      let array_type = require_array_type(
        self.module_,
        type_idx_int,
        "array.new_data",
      )
      let elem_size = storage_byte_size(array_type.element.storage)
      ctx.pop_types(2)
      ctx.push_type(Ref(TypeIndex(type_idx_int), false))
      self.emit_op(ArrayNewData)
      self.emit_idx(type_idx_int)
      self.emit_idx(data_idx_int)
      self.emit_idx(elem_size)
    }
    ArrayNewElem(type_idx, elem_idx) => {
      let type_idx_int = type_idx.reinterpret_as_int()
      let elem_idx_int = elem_idx.reinterpret_as_int()
      let _ = require_array_type(self.module_, type_idx_int, "array.new_elem")
      ctx.pop_types(2)
      ctx.push_type(Ref(TypeIndex(type_idx_int), false))
      self.emit_op(ArrayNewElem)
      self.emit_idx(type_idx_int)
      self.emit_idx(elem_idx_int)
    }
    ArrayGet(type_idx) => {
      let type_idx_int = type_idx.reinterpret_as_int()
      let array_type = require_array_type(
        self.module_,
        type_idx_int,
        "array.get",
      )
      ctx.pop_types(2)
      ctx.push_type(storage_value_type(array_type.element.storage))
      self.emit_op(ArrayGet)
    }
    ArrayGetS(type_idx) => {
      let type_idx_int = type_idx.reinterpret_as_int()
      let array_type = require_array_type(
        self.module_,
        type_idx_int,
        "array.get_s",
      )
      let storage_type_code = match array_type.element.storage {
        I8 => 0
        I16 => 1
        _ => 0
      }
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(ArrayGetS)
      self.emit_idx(storage_type_code)
    }
    ArrayGetU(type_idx) => {
      let type_idx_int = type_idx.reinterpret_as_int()
      let array_type = require_array_type(
        self.module_,
        type_idx_int,
        "array.get_u",
      )
      let storage_type_code = match array_type.element.storage {
        I8 => 0
        I16 => 1
        _ => 0
      }
      ctx.pop_types(2)
      ctx.push_type(I32)
      self.emit_op(ArrayGetU)
      self.emit_idx(storage_type_code)
    }
    ArraySet(type_idx) => {
      let type_idx_int = type_idx.reinterpret_as_int()
      let _ = require_array_type(self.module_, type_idx_int, "array.set")
      ctx.pop_types(3)
      self.emit_op(ArraySet)
      ignore(type_idx_int)
    }
    ArrayLen => {
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(ArrayLen)
    }
    ArrayFill(type_idx) => {
      let type_idx_int = type_idx.reinterpret_as_int()
      let _ = require_array_type(self.module_, type_idx_int, "array.fill")
      ctx.pop_types(4)
      self.emit_op(ArrayFill)
      ignore(type_idx_int)
    }
    ArrayCopy(dst_type, src_type) => {
      let dst_int = dst_type.reinterpret_as_int()
      let src_int = src_type.reinterpret_as_int()
      let _ = require_array_type(self.module_, dst_int, "array.copy")
      let _ = require_array_type(self.module_, src_int, "array.copy")
      ctx.pop_types(5)
      self.emit_op(ArrayCopy)
    }
    ArrayInitData(type_idx, data_idx) => {
      let type_idx_int = type_idx.reinterpret_as_int()
      let data_idx_int = data_idx.reinterpret_as_int()
      let array_type = require_array_type(
        self.module_,
        type_idx_int,
        "array.init_data",
      )
      let elem_size = storage_byte_size(array_type.element.storage)
      ctx.pop_types(4)
      self.emit_op(ArrayInitData)
      self.emit_idx(type_idx_int)
      self.emit_idx(data_idx_int)
      self.emit_idx(elem_size)
    }
    ArrayInitElem(type_idx, elem_idx) => {
      let type_idx_int = type_idx.reinterpret_as_int()
      let elem_idx_int = elem_idx.reinterpret_as_int()
      let _ = require_array_type(self.module_, type_idx_int, "array.init_elem")
      ctx.pop_types(4)
      self.emit_op(ArrayInitElem)
      self.emit_idx(type_idx_int)
      self.emit_idx(elem_idx_int)
    }
    BrOnCast(label, target_ref, target_nullable, _sref, _snull) => {
      let label_int = label.reinterpret_as_int()
      let arity = ctx.get_branch_arity(label_int)
      let drop_count = ctx.calc_drop_count(label_int, arity)
      ctx.pop_type()
      ctx.push_type(Ref(Any, true))
      self.emit_op(BrOnCast)
      let target_pc_slot = self.ops.length()
      if ctx.is_loop_target(label_int) {
        self.emit_idx(ctx.get_target_pc(label_int))
      } else {
        self.emit_idx(0) // Placeholder
        ctx.add_br_patch(label_int, target_pc_slot)
      }
      self.emit_idx(arity)
      self.emit_idx(drop_count)
      // Emit target type code
      let target_type = match target_ref {
        Func => -7
        Extern => -8
        Any => -2
        Eq => -3
        I31 => -4
        Struct => -5
        Array => -6
        Exn => -9
        None => -10
        NoFunc => -11
        NoExtern => -12
        NoExn => -13
        TypeIndex(idx) => idx
      }
      self.emit_idx(target_type)
      self.emit_idx(if target_nullable { 1 } else { 0 })
    }
    BrOnCastFail(label, target_ref, target_nullable, _sref, _snull) => {
      let label_int = label.reinterpret_as_int()
      let arity = ctx.get_branch_arity(label_int)
      let drop_count = ctx.calc_drop_count(label_int, arity)
      ctx.pop_type()
      ctx.push_type(Ref(Any, true))
      self.emit_op(BrOnCastFail)
      let target_pc_slot = self.ops.length()
      if ctx.is_loop_target(label_int) {
        self.emit_idx(ctx.get_target_pc(label_int))
      } else {
        self.emit_idx(0) // Placeholder
        ctx.add_br_patch(label_int, target_pc_slot)
      }
      self.emit_idx(arity)
      self.emit_idx(drop_count)
      // Emit target type code
      let target_type = match target_ref {
        Func => -7
        Extern => -8
        Any => -2
        Eq => -3
        I31 => -4
        Struct => -5
        Array => -6
        Exn => -9
        None => -10
        NoFunc => -11
        NoExtern => -12
        NoExn => -13
        TypeIndex(idx) => idx
      }
      self.emit_idx(target_type)
      self.emit_idx(if target_nullable { 1 } else { 0 })
    }
    AnyConvertExtern => {
      ctx.pop_type()
      ctx.push_type(AnyRef)
      self.emit_op(AnyConvertExtern)
    }
    ExternConvertAny => {
      ctx.pop_type()
      ctx.push_type(ExternRef)
      self.emit_op(ExternConvertAny)
    }
    RefI31 => {
      ctx.pop_type()
      ctx.push_type(Ref(I31, false))
      self.emit_op(RefI31)
    }
    I31GetS => {
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(I31GetS)
    }
    I31GetU => {
      ctx.pop_type()
      ctx.push_type(I32)
      self.emit_op(I31GetU)
    }
    // Indirect call
    CallIndirect(type_idx, table_idx) => {
      // Pop table index (i32)
      ctx.pop_type()
      // Get function type to properly track types
      let type_idx_int = type_idx.reinterpret_as_int()
      let func_type = require_func_type(
        self.module_,
        type_idx_int,
        "call_indirect",
      )
      // Pop params from type stack
      ctx.pop_types(func_type.params.length())
      // Push results to type stack
      for result_type in func_type.results {
        ctx.push_type(result_type)
      }
      self.emit_op(CallIndirect)
      self.emit_idx(type_idx_int)
      self.emit_idx(table_idx.reinterpret_as_int())
    }
    // Tail calls
    ReturnCall(func_idx) => {
      // Look up function signature to properly track types (same as Call)
      let func_idx_int = func_idx.reinterpret_as_int()
      let num_imported = count_imported_funcs(self.module_)
      let type_idx = get_func_type_idx(self.module_, func_idx_int, num_imported)

      // Get the function type and update type stack
      // For tail calls, only pop params (results go to caller, not us)
      if type_idx >= 0 {
        let func_type = require_func_type(self.module_, type_idx, "return_call")
        ctx.pop_types(func_type.params.length())
      }

      // Emit appropriate op based on whether function is imported or local
      if func_idx_int < num_imported {
        self.emit_op(ReturnCallImport)
        self.emit_idx(func_idx_int)
      } else {
        // Emit op_return_call_local with all immediates computed at compile time
        let local_func_idx = func_idx_int - num_imported
        let code = self.module_.codes[local_func_idx]
        let func_type = require_func_type(self.module_, type_idx, "return_call")
        let num_params = func_type.params.length()
        let num_locals = num_params + code.locals.length()
        self.emit_op(ReturnCallLocal)
        let callee_pc_slot = self.ops.length()
        match code.compiled {
          Some(callee_pc) => self.emit_idx(callee_pc)
          None => {
            // Forward reference - emit placeholder and record for patching
            self.emit_idx(0)
            self.pending_call_patches.push({
              local_func_idx,
              slot: callee_pc_slot,
            })
          }
        }
        self.emit_idx(num_params)
        self.emit_idx(num_locals)
      }
    }
    ReturnCallIndirect(type_idx, table_idx) => {
      // Pop table index (i32)
      ctx.pop_type()
      // Get function type to properly track types
      let type_idx_int = type_idx.reinterpret_as_int()
      let func_type = require_func_type(
        self.module_,
        type_idx_int,
        "return_call_indirect",
      )
      // Pop params from type stack (no results - tail call)
      ctx.pop_types(func_type.params.length())
      self.emit_op(ReturnCallIndirect)
      self.emit_idx(type_idx_int)
      self.emit_idx(table_idx.reinterpret_as_int())
    }
    // Typed function references
    CallRef(type_idx) => {
      // Pop the function reference
      ctx.pop_type()
      // Get function type to properly track types
      let type_idx_int = type_idx.reinterpret_as_int()
      let func_type = require_func_type(self.module_, type_idx_int, "call_ref")
      // Pop params from type stack
      ctx.pop_types(func_type.params.length())
      // Push results to type stack
      for result_type in func_type.results {
        ctx.push_type(result_type)
      }
      self.emit_op(CallRef)
      self.emit_idx(type_idx_int)
    }
    ReturnCallRef(type_idx) => {
      // Pop the function reference
      ctx.pop_type()
      // Get function type to properly track types
      let type_idx_int = type_idx.reinterpret_as_int()
      let func_type = require_func_type(
        self.module_,
        type_idx_int,
        "return_call_ref",
      )
      // Pop params from type stack (no results - tail call)
      ctx.pop_types(func_type.params.length())
      self.emit_op(ReturnCallRef)
      self.emit_idx(type_idx_int)
    }
  }
}

///|
fn reftype_to_valtype(ref_type : @core.RefType) -> @core.ValType {
  match ref_type {
    Func => FuncRef
    Extern => ExternRef
    Any => AnyRef
    Eq => EqRef
    I31 => I31Ref
    Struct => StructRef
    Array => ArrayRef
    Exn => ExnRef
    None => NullRef
    NoFunc => NullFuncRef
    NoExtern => NullExternRef
    NoExn => NullExnRef
    TypeIndex(_) => Ref(ref_type, true)
  }
}

///|
fn non_null_ref_type(val_type : @core.ValType) -> @core.ValType {
  match val_type {
    Ref(heap_type, true) => Ref(heap_type, false)
    Ref(heap_type, false) => Ref(heap_type, false)
    FuncRef => Ref(Func, false)
    ExternRef => Ref(Extern, false)
    AnyRef => Ref(Any, false)
    EqRef => Ref(Eq, false)
    I31Ref => Ref(I31, false)
    StructRef => Ref(Struct, false)
    ArrayRef => Ref(Array, false)
    ExnRef => Ref(Exn, false)
    NullRef => Ref(Any, false)
    NullFuncRef => Ref(Func, false)
    NullExternRef => Ref(Extern, false)
    NullExnRef => Ref(Exn, false)
    _ => val_type
  }
}
