///|
/// Run the start function if present.
pub fn Runtime::run_start(self : Runtime) -> Unit raise RuntimeError {
  // Execute the start function if present
  match self.ctx.module_.start {
    Some(start_idx) => {
      // Call the start function
      // Start function must have type [] -> []
      let func_idx = start_idx.reinterpret_as_int()
      let num_imported_funcs = count_imported_funcs(self.ctx.module_)

      // Only execute if it's a local function (not imported)
      // Imported start functions would require host environment support
      if func_idx >= num_imported_funcs {
        let local_idx = func_idx - num_imported_funcs
        let code = self.ctx.module_.codes[local_idx]
        guard code.compiled is Some(start_pc) else {
          raise RuntimeError::FunctionNotCompiled("Start function not compiled")
        }

        // Clear stack before setting up locals
        self.sp = 0
        self.status = Terminated

        // Initialize entry locals (start function has no parameters)
        let rt = initialize_entry_locals(self, [], code)
        if rt.status == Trap {
          raise RuntimeError::from_detail(rt.ctx.error_detail)
        }
        rt.pc = start_pc

        // Execute start function, ignoring runtime errors
        // (e.g., calls to unimplemented imported functions)
        let _ = execute(rt) catch { _ => rt }

        // Clear stack
        rt.sp = 0
      }
    }
    None => ()
  }
}

///|
fn execute(rt : Runtime) -> Runtime raise RuntimeError {
  let mut rt = rt
  rt.status = Running
  while rt.status is Running {
    let code = rt.ops.unsafe_get(rt.pc)
    // Hot path: inline frequently used opcodes to avoid dispatch overhead
    // OpCode numbers: LocalGet=23, LocalSet=24, I32Const=31, I32Add=35, Br=5, BrIf=6, I32GeU=66
    match code.to_int() {
      23 => {
        // LocalGet
        let idx = rt.ops.unsafe_get(rt.pc + 1).to_int()
        let value = rt.stack.unsafe_get(rt.bp + idx)
        rt.stack.unsafe_set(rt.sp, value)
        rt.sp = rt.sp + 1
        rt.pc = rt.pc + 2
      }
      24 => {
        // LocalSet
        let idx = rt.ops.unsafe_get(rt.pc + 1).to_int()
        let stack_top = rt.sp - 1
        let value = rt.stack.unsafe_get(stack_top)
        rt.stack.unsafe_set(rt.bp + idx, value)
        rt.sp = stack_top
        rt.pc = rt.pc + 2
      }
      31 => {
        // I32Const
        let value = rt.ops.unsafe_get(rt.pc + 1).to_uint()
        rt.stack.unsafe_set(rt.sp, value.to_uint64())
        rt.sp = rt.sp + 1
        rt.pc = rt.pc + 2
      }
      35 => {
        // I32Add
        let stack_top = rt.sp - 1
        let b = rt.stack.unsafe_get(stack_top).to_uint()
        let a = rt.stack.unsafe_get(stack_top - 1).to_uint()
        rt.stack.unsafe_set(stack_top - 1, (a + b).to_uint64())
        rt.sp = stack_top
        rt.pc = rt.pc + 1
      }
      5 => {
        // Br
        let target_pc = rt.ops.unsafe_get(rt.pc + 1).to_int()
        let arity = rt.ops.unsafe_get(rt.pc + 2).to_int()
        let drop_count = rt.ops.unsafe_get(rt.pc + 3).to_int()
        if drop_count > 0 && arity > 0 {
          let result_start = rt.sp - arity
          let target_start = result_start - drop_count
          for i = 0; i < arity; i = i + 1 {
            rt.stack.unsafe_set(
              target_start + i,
              rt.stack.unsafe_get(result_start + i),
            )
          }
        }
        rt.sp = rt.sp - drop_count
        rt.pc = target_pc
      }
      6 => {
        // BrIf
        let target_pc = rt.ops.unsafe_get(rt.pc + 1).to_int()
        let arity = rt.ops.unsafe_get(rt.pc + 2).to_int()
        let drop_count = rt.ops.unsafe_get(rt.pc + 3).to_int()
        let stack_top = rt.sp - 1
        let cond = rt.stack.unsafe_get(stack_top).to_uint()
        if cond != 0U {
          if drop_count > 0 && arity > 0 {
            let result_start = stack_top - arity
            let target_start = result_start - drop_count
            for i = 0; i < arity; i = i + 1 {
              rt.stack.unsafe_set(
                target_start + i,
                rt.stack.unsafe_get(result_start + i),
              )
            }
          }
          rt.sp = stack_top - drop_count
          rt.pc = target_pc
        } else {
          rt.sp = stack_top
          rt.pc = rt.pc + 4
        }
      }
      66 => {
        // I32GeU
        let stack_top = rt.sp - 1
        let b = rt.stack.unsafe_get(stack_top).to_uint()
        let a = rt.stack.unsafe_get(stack_top - 1).to_uint()
        rt.stack.unsafe_set(stack_top - 1, (if a >= b { 1UL } else { 0UL }))
        rt.sp = stack_top
        rt.pc = rt.pc + 1
      }
      36 => {
        // I32Sub
        let stack_top = rt.sp - 1
        let b = rt.stack.unsafe_get(stack_top).to_uint()
        let a = rt.stack.unsafe_get(stack_top - 1).to_uint()
        rt.stack.unsafe_set(stack_top - 1, (a - b).to_uint64())
        rt.sp = stack_top
        rt.pc = rt.pc + 1
      }
      37 => {
        // I32Mul
        let stack_top = rt.sp - 1
        let b = rt.stack.unsafe_get(stack_top).to_uint()
        let a = rt.stack.unsafe_get(stack_top - 1).to_uint()
        rt.stack.unsafe_set(stack_top - 1, (a * b).to_uint64())
        rt.sp = stack_top
        rt.pc = rt.pc + 1
      }
      42 => {
        // I32And
        let stack_top = rt.sp - 1
        let b = rt.stack.unsafe_get(stack_top).to_uint()
        let a = rt.stack.unsafe_get(stack_top - 1).to_uint()
        rt.stack.unsafe_set(stack_top - 1, (a & b).to_uint64())
        rt.sp = stack_top
        rt.pc = rt.pc + 1
      }
      4 => {
        // If
        let else_pc = rt.ops.unsafe_get(rt.pc + 1).to_int()
        let stack_top = rt.sp - 1
        let cond = rt.stack.unsafe_get(stack_top).to_uint()
        rt.sp = stack_top
        if cond != 0U {
          rt.pc = rt.pc + 2
        } else {
          rt.pc = else_pc
        }
      }
      26 => {
        // GlobalGet
        let idx = rt.ops.unsafe_get(rt.pc + 1).to_int()
        rt.stack.unsafe_set(rt.sp, value_to_stack(rt.ctx.globals[idx]))
        rt.sp = rt.sp + 1
        rt.pc = rt.pc + 2
      }
      27 => {
        // GlobalSet
        let idx = rt.ops.unsafe_get(rt.pc + 1).to_int()
        let stack_top = rt.sp - 1
        let raw = rt.stack.unsafe_get(stack_top)
        let val_type : @core.ValType = match rt.ctx.globals[idx] {
          I32(_) => I32
          I64(_) => I64
          F32(_) => F32
          F64(_) => F64
          Ref(_) | Funcref(_) | Externref(_) => FuncRef
        }
        rt.ctx.globals[idx] = stack_to_value(raw, val_type)
        rt.sp = stack_top
        rt.pc = rt.pc + 2
      }
      171 => {
        // I32Load
        let offset = rt.ops.unsafe_get(rt.pc + 1).to_int().reinterpret_as_uint().to_uint64()
        let stack_top = rt.sp - 1
        let base = rt.stack.unsafe_get(stack_top)
        let effective_addr = base + offset
        if effective_addr + 4UL > rt.ctx.memory.length().reinterpret_as_uint().to_uint64() {
          rt.ctx.error_detail = "out of bounds memory access"
          rt.status = Trap
        } else {
          let addr = effective_addr.to_int()
          rt.stack.unsafe_set(stack_top, read_u32_le(rt.ctx.memory, addr).to_uint64())
          rt.pc = rt.pc + 2
        }
      }
      185 => {
        // I32Store
        let offset = rt.ops.unsafe_get(rt.pc + 1).to_int().reinterpret_as_uint().to_uint64()
        let stack_top = rt.sp - 2
        let value = rt.stack.unsafe_get(rt.sp - 1).to_uint()
        let base = rt.stack.unsafe_get(stack_top)
        let effective_addr = base + offset
        if effective_addr + 4UL > rt.ctx.memory.length().reinterpret_as_uint().to_uint64() {
          rt.ctx.error_detail = "out of bounds memory access"
          rt.sp = stack_top
          rt.status = Trap
        } else {
          let addr = effective_addr.to_int()
          write_u32_le(rt.ctx.memory, addr, value)
          rt.sp = stack_top
          rt.pc = rt.pc + 2
        }
      }
      12 => {
        // Return
        let num_return_values = rt.ops.unsafe_get(rt.pc + 1).reinterpret_as_int64().to_int()
        let return_start = rt.sp - num_return_values
        for i = 0; i < num_return_values; i = i + 1 {
          rt.stack.unsafe_set(rt.bp + i, rt.stack.unsafe_get(return_start + i))
        }
        let stack_top = rt.bp + num_return_values
        rt.sp = stack_top
        if rt.bp == 0 {
          rt.status = Terminated
        } else {
          rt.status = Returned
        }
      }
      56 => {
        // I32Eqz
        let stack_top = rt.sp - 1
        let a = rt.stack.unsafe_get(stack_top).to_uint()
        rt.stack.unsafe_set(stack_top, (if a == 0U { 1UL } else { 0UL }))
        rt.pc = rt.pc + 1
      }
      63 => {
        // I32LeS
        let stack_top = rt.sp - 1
        let b = rt.stack.unsafe_get(stack_top).to_uint().reinterpret_as_int()
        let a = rt.stack.unsafe_get(stack_top - 1).to_uint().reinterpret_as_int()
        rt.stack.unsafe_set(stack_top - 1, (if a <= b { 1UL } else { 0UL }))
        rt.sp = stack_top
        rt.pc = rt.pc + 1
      }
      // Fused instructions (peephole optimized)
      242 => {
        // LocalGetLocalGet idx1 idx2
        let idx1 = rt.ops.unsafe_get(rt.pc + 1).to_int()
        let idx2 = rt.ops.unsafe_get(rt.pc + 2).to_int()
        rt.stack.unsafe_set(rt.sp, rt.stack.unsafe_get(rt.bp + idx1))
        rt.stack.unsafe_set(rt.sp + 1, rt.stack.unsafe_get(rt.bp + idx2))
        rt.sp = rt.sp + 2
        rt.pc = rt.pc + 3
      }
      243 => {
        // I32AddLocals idx1 idx2
        let idx1 = rt.ops.unsafe_get(rt.pc + 1).to_int()
        let idx2 = rt.ops.unsafe_get(rt.pc + 2).to_int()
        let a = rt.stack.unsafe_get(rt.bp + idx1).to_uint()
        let b = rt.stack.unsafe_get(rt.bp + idx2).to_uint()
        rt.stack.unsafe_set(rt.sp, (a + b).to_uint64())
        rt.sp = rt.sp + 1
        rt.pc = rt.pc + 3
      }
      244 => {
        // I32GeULocals idx1 idx2
        let idx1 = rt.ops.unsafe_get(rt.pc + 1).to_int()
        let idx2 = rt.ops.unsafe_get(rt.pc + 2).to_int()
        let a = rt.stack.unsafe_get(rt.bp + idx1).to_uint()
        let b = rt.stack.unsafe_get(rt.bp + idx2).to_uint()
        rt.stack.unsafe_set(rt.sp, (if a >= b { 1UL } else { 0UL }))
        rt.sp = rt.sp + 1
        rt.pc = rt.pc + 3
      }
      245 => {
        // LocalInc idx
        let idx = rt.ops.unsafe_get(rt.pc + 1).to_int()
        let value = rt.stack.unsafe_get(rt.bp + idx).to_uint()
        rt.stack.unsafe_set(rt.bp + idx, (value + 1U).to_uint64())
        rt.pc = rt.pc + 2
      }
      _ => {
        // Cold path: use dispatch table for other opcodes
        let opcode = uint64_to_opcode(code)
        rt = dispatch_op(opcode, rt)
      }
    }
  }
  if rt.status is Trap {
    raise RuntimeError::from_detail(rt.ctx.error_detail)
  }
  // Returned and Terminated both exit normally
  rt
}

///|
/// Execute a local function call using native stack.
/// Caller state is preserved on the MoonBit stack frame.
/// Returns the runtime with results on the stack after callee returns.
fn execute_call(
  rt : Runtime,
  callee_pc : Int,
  caller_bp : Int,
  caller_num_locals : Int,
  return_pc : Int,
) -> Runtime raise RuntimeError {
  // Execute callee
  rt.pc = callee_pc
  let rt = execute(rt)

  // Callee has returned - results are at stack[rt.bp .. rt.sp)
  // Return values are already copied to bp by op_return
  // Restore caller's state
  rt.bp = caller_bp
  rt.num_locals = caller_num_locals
  rt.pc = return_pc
  rt.status = Running
  rt
}

///|
/// Call a compiled function by name with the given arguments.
pub fn Runtime::call_compiled(
  self : Runtime,
  func_name : Bytes,
  args : Array[Value],
) -> Array[Value] raise RuntimeError {
  let mut func_idx : Int? = None
  for exp in self.ctx.module_.exports {
    if exp.name == func_name {
      match exp.desc {
        Func(idx) => {
          func_idx = Some(idx.reinterpret_as_int())
          break
        }
        _ => continue
      }
    }
  }
  guard func_idx is Some(idx) else {
    raise RuntimeError::FunctionNotFound("Function not found: \{func_name}")
  }
  let num_imported_funcs = count_imported_funcs(self.ctx.module_)

  // Check if it's an imported function - call it directly via import resolver
  if idx < num_imported_funcs {
    let imported_func = self.ctx.imported_funcs[idx]
    return (imported_func.func)(args)
  }

  // Adjust to local function index
  let local_idx = idx - num_imported_funcs
  let type_idx = self.ctx.module_.funcs[local_idx].reinterpret_as_int()
  let func_type = require_func_type(self.ctx.module_, type_idx, "call_compiled")
  let code = self.ctx.module_.codes[local_idx]
  guard code.compiled is Some(start_pc) else {
    raise RuntimeError::FunctionNotCompiled(
      "Function not compiled: \{func_name}",
    )
  }

  // Clear stack before setting up entry frame
  self.sp = 0
  self.status = Terminated

  // Initialize entry locals (pushes args and locals onto stack, sets sp/num_locals)
  let rt = initialize_entry_locals(self, args, code)
  if rt.status == Trap {
    raise RuntimeError::from_detail(rt.ctx.error_detail)
  }
  rt.pc = start_pc
  let rt = execute(rt)

  // Extract results from unified stack
  // After function returns, results are at stack[0..num_results)
  let results : Array[Value] = []
  let result_types = func_type.results
  for i in 0..<result_types.length() {
    if i < rt.sp {
      results.push(stack_to_value(rt.stack.unsafe_get(i), result_types[i]))
    }
  }
  results
}

///|
/// Call a function by its index (used for funcref handling).
/// This allows calling functions that may not be exported by name.
pub fn Runtime::call_by_index(
  self : Runtime,
  func_idx : Int,
  args : Array[Value],
) -> Array[Value] raise RuntimeError {
  let num_imported_funcs = count_imported_funcs(self.ctx.module_)

  // Check if it's an imported function - call it directly via import resolver
  if func_idx < num_imported_funcs {
    if func_idx < 0 || func_idx >= self.ctx.imported_funcs.length() {
      raise RuntimeError::FunctionNotFound(
        "Invalid imported function index: \{func_idx}",
      )
    }
    let imported_func = self.ctx.imported_funcs[func_idx]
    return (imported_func.func)(args)
  }

  // Adjust to local function index
  let local_idx = func_idx - num_imported_funcs
  if local_idx < 0 || local_idx >= self.ctx.module_.codes.length() {
    raise RuntimeError::FunctionNotFound(
      "Invalid local function index: \{func_idx}",
    )
  }
  let type_idx = self.ctx.module_.funcs[local_idx].reinterpret_as_int()
  let func_type = require_func_type(self.ctx.module_, type_idx, "call_by_index")
  let code = self.ctx.module_.codes[local_idx]
  guard code.compiled is Some(start_pc) else {
    raise RuntimeError::FunctionNotCompiled(
      "Function not compiled: index \{func_idx}",
    )
  }

  // Clear stack before setting up entry frame
  let rt : Runtime = { ..self, sp: 0, status: Terminated }

  // Initialize entry locals (pushes args and locals onto stack, sets sp/num_locals)
  let rt = initialize_entry_locals(rt, args, code)
  if rt.status == Trap {
    raise RuntimeError::from_detail(rt.ctx.error_detail)
  }
  let rt = { ..rt, pc: start_pc }
  let rt = execute(rt)

  // Extract results from unified stack
  let results : Array[Value] = []
  let result_types = func_type.results
  for i in 0..<result_types.length() {
    if i < rt.sp {
      results.push(stack_to_value(rt.stack.unsafe_get(i), result_types[i]))
    }
  }
  results
}
