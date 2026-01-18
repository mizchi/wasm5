///|
/// Group failures by test type for better reporting
fn group_failures_by_type(
  failures : Array[TestFailure],
) -> Map[String, Array[TestFailure]] {
  let grouped : Map[String, Array[TestFailure]] = {}
  for failure in failures {
    match grouped.get(failure.test_type) {
      Some(arr) => arr.push(failure)
      None => grouped[failure.test_type] = [failure]
    }
  }
  grouped
}

///|
/// Format a single failure with additional context
fn format_failure_detail(failure : TestFailure) -> String {
  let location = if failure.line >= 0 {
    "\{failure.source_file}:\{failure.line}"
  } else {
    failure.source_file
  }
  "  [\{failure.test_type}] \{location}\n    → \{failure.message}"
}

///|
async fn run_test_harness(subdir : String, filename : String) -> Unit {
  let path = "test/reference_tests/\{subdir}"
  let display_name = if subdir.length() > 0 {
    "\{subdir}\{filename}"
  } else {
    filename
  }
  let (file_failures, file_skipped) = process_wast_file(path, filename)
  if file_failures.length() > 0 {
    let grouped = group_failures_by_type(file_failures)
    println(
      "\n╔══════════════════════════════════════════════════════════════════╗",
    )
    println("║ TEST FAILURES: \{display_name}")
    println(
      "╚══════════════════════════════════════════════════════════════════╝",
    )
    for test_type, failures in grouped {
      println(
        "\n┌─ \{test_type} (\{failures.length()} failures) ─────────────────────",
      )
      for failure in failures {
        println(format_failure_detail(failure))
      }
      println(
        "└────────────────────────────────────────────────────────────────",
      )
    }
    println(
      "\n╔══════════════════════════════════════════════════════════════════╗",
    )
    println(
      "║ SUMMARY: \{file_failures.length()} failure(s), \{file_skipped} skipped",
    )
    println(
      "╚══════════════════════════════════════════════════════════════════╝\n",
    )
    fail("\{file_failures.length()} failure(s) in \{display_name}")
  }
  if file_skipped > 0 {
    println("Skipped \{file_skipped} tests in \{display_name}")
  }
}

// =============================================================================
// WebAssembly Spec Tests
// =============================================================================

///|
async test "address.wast" {
  run_test_harness("", "address.wast")
}

///|
async test "align.wast" {
  run_test_harness("", "align.wast")
}

// Blacklisted: WAT text format test
// async test "annotations.wast" {
//   run_test_harness("","annotations.wast")
// }

///|
async test "binary-leb128.wast" {
  run_test_harness("", "binary-leb128.wast")
}

///|
async test "binary.wast" {
  run_test_harness("", "binary.wast")
}

///|
async test "block.wast" {
  run_test_harness("", "block.wast")
}

///|
async test "br.wast" {
  run_test_harness("", "br.wast")
}

///|
async test "br_if.wast" {
  run_test_harness("", "br_if.wast")
}

///|
async test "br_on_non_null.wast" {
  run_test_harness("", "br_on_non_null.wast")
}

///|
async test "br_on_null.wast" {
  run_test_harness("", "br_on_null.wast")
}

///|
async test "br_table.wast" {
  run_test_harness("", "br_table.wast")
}

///|
async test "call.wast" {
  run_test_harness("", "call.wast")
}

///|
async test "call_indirect.wast" {
  run_test_harness("", "call_indirect.wast")
}

///|
async test "call_ref.wast" {
  run_test_harness("", "call_ref.wast")
}

// Blacklisted: WAT text format test
// async test "comments.wast" {
//   run_test_harness("","comments.wast")
// }

///|
async test "const.wast" {
  run_test_harness("", "const.wast")
}

///|
async test "conversions.wast" {
  run_test_harness("", "conversions.wast")
}

///|
async test "custom.wast" {
  run_test_harness("", "custom.wast")
}

///|
async test "data.wast" {
  run_test_harness("", "data.wast")
}

///|
async test "elem.wast" {
  run_test_harness("", "elem.wast")
}

///|
async test "endianness.wast" {
  run_test_harness("", "endianness.wast")
}

///|
async test "exports.wast" {
  run_test_harness("", "exports.wast")
}

///|
async test "f32.wast" {
  run_test_harness("", "f32.wast")
}

///|
async test "f32_bitwise.wast" {
  run_test_harness("", "f32_bitwise.wast")
}

///|
async test "f32_cmp.wast" {
  run_test_harness("", "f32_cmp.wast")
}

///|
async test "f64.wast" {
  run_test_harness("", "f64.wast")
}

///|
async test "f64_bitwise.wast" {
  run_test_harness("", "f64_bitwise.wast")
}

///|
async test "f64_cmp.wast" {
  run_test_harness("", "f64_cmp.wast")
}

///|
async test "fac.wast" {
  run_test_harness("", "fac.wast")
}

///|
async test "float_exprs.wast" {
  run_test_harness("", "float_exprs.wast")
}

///|
async test "float_literals.wast" {
  run_test_harness("", "float_literals.wast")
}

///|
async test "float_memory.wast" {
  run_test_harness("", "float_memory.wast")
}

///|
async test "float_misc.wast" {
  run_test_harness("", "float_misc.wast")
}

///|
async test "forward.wast" {
  run_test_harness("", "forward.wast")
}

///|
async test "func.wast" {
  run_test_harness("", "func.wast")
}

///|
async test "func_ptrs.wast" {
  run_test_harness("", "func_ptrs.wast")
}

///|
async test "global.wast" {
  run_test_harness("", "global.wast")
}

///|
async test "i32.wast" {
  run_test_harness("", "i32.wast")
}

///|
async test "i64.wast" {
  run_test_harness("", "i64.wast")
}

///|
async test "id.wast" {
  run_test_harness("", "id.wast")
}

///|
async test "if.wast" {
  run_test_harness("", "if.wast")
}

///|
async test "imports.wast" {
  run_test_harness("", "imports.wast")
}

///|
async test "inline-module.wast" {
  run_test_harness("", "inline-module.wast")
}

// Blacklisted: Requires module instances (linking)
// async test "instance.wast" {
//   run_test_harness("","instance.wast")
// }

///|
async test "int_exprs.wast" {
  run_test_harness("", "int_exprs.wast")
}

///|
async test "int_literals.wast" {
  run_test_harness("", "int_literals.wast")
}

///|
async test "labels.wast" {
  run_test_harness("", "labels.wast")
}

///|
async test "left-to-right.wast" {
  run_test_harness("", "left-to-right.wast")
}

// Blacklisted: Requires cross-module imports/exports
// async test "linking.wast" {
//   run_test_harness("","linking.wast")
// }

///|
async test "load.wast" {
  run_test_harness("", "load.wast")
}

///|
async test "local_get.wast" {
  run_test_harness("", "local_get.wast")
}

///|
async test "local_init.wast" {
  run_test_harness("", "local_init.wast")
}

///|
async test "local_set.wast" {
  run_test_harness("", "local_set.wast")
}

///|
async test "local_tee.wast" {
  run_test_harness("", "local_tee.wast")
}

///|
async test "loop.wast" {
  run_test_harness("", "loop.wast")
}

///|
async test "memory.wast" {
  run_test_harness("", "memory.wast")
}

///|
async test "memory_grow.wast" {
  run_test_harness("", "memory_grow.wast")
}

///|
async test "memory_redundancy.wast" {
  run_test_harness("", "memory_redundancy.wast")
}

///|
async test "memory_size.wast" {
  run_test_harness("", "memory_size.wast")
}

///|
async test "memory_trap.wast" {
  run_test_harness("", "memory_trap.wast")
}

///|
async test "names.wast" {
  run_test_harness("", "names.wast")
}

///|
async test "nop.wast" {
  run_test_harness("", "nop.wast")
}

///|
async test "obsolete-keywords.wast" {
  run_test_harness("", "obsolete-keywords.wast")
}

///|
async test "ref.wast" {
  run_test_harness("", "ref.wast")
}

///|
async test "ref_as_non_null.wast" {
  run_test_harness("", "ref_as_non_null.wast")
}

///|
async test "ref_func.wast" {
  run_test_harness("", "ref_func.wast")
}

///|
async test "ref_is_null.wast" {
  run_test_harness("", "ref_is_null.wast")
}

///|
async test "ref_null.wast" {
  run_test_harness("", "ref_null.wast")
}

///|
async test "return.wast" {
  run_test_harness("", "return.wast")
}

///|
async test "return_call.wast" {
  run_test_harness("", "return_call.wast")
}

///|
async test "return_call_indirect.wast" {
  run_test_harness("", "return_call_indirect.wast")
}

///|
async test "return_call_ref.wast" {
  run_test_harness("", "return_call_ref.wast")
}

///|
async test "select.wast" {
  run_test_harness("", "select.wast")
}

///|
async test "skip-stack-guard-page.wast" {
  run_test_harness("", "skip-stack-guard-page.wast")
}

///|
async test "stack.wast" {
  run_test_harness("", "stack.wast")
}

///|
async test "start.wast" {
  run_test_harness("", "start.wast")
}

///|
async test "store.wast" {
  run_test_harness("", "store.wast")
}

///|
async test "switch.wast" {
  run_test_harness("", "switch.wast")
}

///|
async test "table.wast" {
  run_test_harness("", "table.wast")
}

///|
async test "table_get.wast" {
  run_test_harness("", "table_get.wast")
}

///|
async test "table_grow.wast" {
  run_test_harness("", "table_grow.wast")
}

///|
async test "table_set.wast" {
  run_test_harness("", "table_set.wast")
}

///|
async test "table_size.wast" {
  run_test_harness("", "table_size.wast")
}

///|
async test "token.wast" {
  run_test_harness("", "token.wast")
}

///|
async test "traps.wast" {
  run_test_harness("", "traps.wast")
}

// Blacklisted: Requires exception handling
// async test "try_table.wast" {
//   run_test_harness("","try_table.wast")
// }

///|
async test "type-canon.wast" {
  run_test_harness("", "type-canon.wast")
}

///|
async test "type-equivalence.wast" {
  run_test_harness("", "type-equivalence.wast")
}

///|
async test "type-rec.wast" {
  run_test_harness("", "type-rec.wast")
}

///|
async test "type.wast" {
  run_test_harness("", "type.wast")
}

///|
async test "unreachable.wast" {
  run_test_harness("", "unreachable.wast")
}

///|
async test "unreached-invalid.wast" {
  run_test_harness("", "unreached-invalid.wast")
}

///|
async test "unreached-valid.wast" {
  run_test_harness("", "unreached-valid.wast")
}

///|
async test "unwind.wast" {
  run_test_harness("", "unwind.wast")
}

///|
async test "utf8-custom-section-id.wast" {
  run_test_harness("", "utf8-custom-section-id.wast")
}

///|
async test "utf8-import-field.wast" {
  run_test_harness("", "utf8-import-field.wast")
}

///|
async test "utf8-import-module.wast" {
  run_test_harness("", "utf8-import-module.wast")
}

///|
async test "utf8-invalid-encoding.wast" {
  run_test_harness("", "utf8-invalid-encoding.wast")
}

// =============================================================================
// WebAssembly GC Spec Tests
// =============================================================================

///|
async test "gc/array.wast" {
  run_test_harness("gc/", "array.wast")
}

///|
async test "gc/array_copy.wast" {
  run_test_harness("gc/", "array_copy.wast")
}

///|
async test "gc/array_fill.wast" {
  run_test_harness("gc/", "array_fill.wast")
}

///|
async test "gc/array_init_data.wast" {
  run_test_harness("gc/", "array_init_data.wast")
}

///|
async test "gc/array_init_elem.wast" {
  run_test_harness("gc/", "array_init_elem.wast")
}

///|
async test "gc/array_new_data.wast" {
  run_test_harness("gc/", "array_new_data.wast")
}

///|
async test "gc/array_new_elem.wast" {
  run_test_harness("gc/", "array_new_elem.wast")
}

///|
async test "gc/binary-gc.wast" {
  run_test_harness("gc/", "binary-gc.wast")
}

///|
async test "gc/br_on_cast.wast" {
  run_test_harness("gc/", "br_on_cast.wast")
}

///|
async test "gc/br_on_cast_fail.wast" {
  run_test_harness("gc/", "br_on_cast_fail.wast")
}

///|
async test "gc/extern.wast" {
  run_test_harness("gc/", "extern.wast")
}

///|
async test "gc/i31.wast" {
  run_test_harness("gc/", "i31.wast")
}

///|
async test "gc/ref_cast.wast" {
  run_test_harness("gc/", "ref_cast.wast")
}

///|
async test "gc/ref_eq.wast" {
  run_test_harness("gc/", "ref_eq.wast")
}

///|
async test "gc/ref_test.wast" {
  run_test_harness("gc/", "ref_test.wast")
}

///|
async test "gc/struct.wast" {
  run_test_harness("gc/", "struct.wast")
}

///|
async test "gc/type-subtyping.wast" {
  run_test_harness("gc/", "type-subtyping.wast")
}

// =============================================================================
// WebAssembly Bulk Memory Spec Tests
// =============================================================================

///|
async test "bulk-memory/bulk.wast" {
  run_test_harness("bulk-memory/", "bulk.wast")
}

///|
async test "bulk-memory/memory_copy.wast" {
  run_test_harness("bulk-memory/", "memory_copy.wast")
}

///|
async test "bulk-memory/memory_fill.wast" {
  run_test_harness("bulk-memory/", "memory_fill.wast")
}

///|
async test "bulk-memory/memory_init.wast" {
  run_test_harness("bulk-memory/", "memory_init.wast")
}

///|
async test "bulk-memory/table-sub.wast" {
  run_test_harness("bulk-memory/", "table-sub.wast")
}

///|
async test "bulk-memory/table_copy.wast" {
  run_test_harness("bulk-memory/", "table_copy.wast")
}

///|
async test "bulk-memory/table_fill.wast" {
  run_test_harness("bulk-memory/", "table_fill.wast")
}

///|
async test "bulk-memory/table_init.wast" {
  run_test_harness("bulk-memory/", "table_init.wast")
}

// Component Model Reference Tests
// =============================================================================

///|
async fn run_component_harness(filename : String) -> Unit {
  let (file_failures, file_skipped) = process_component_wast_file(
    "test/reference_tests/component/", filename,
  )
  if file_failures.length() > 0 {
    let grouped = group_failures_by_type(file_failures)
    println(
      "\n╔══════════════════════════════════════════════════════════════════╗",
    )
    println("║ COMPONENT TEST FAILURES: \{filename}")
    println(
      "╚══════════════════════════════════════════════════════════════════╝",
    )
    for test_type, failures in grouped {
      println(
        "\n┌─ \{test_type} (\{failures.length()} failures) ─────────────────────",
      )
      for failure in failures {
        println(format_failure_detail(failure))
      }
      println(
        "└────────────────────────────────────────────────────────────────",
      )
    }
    println(
      "\n╔══════════════════════════════════════════════════════════════════╗",
    )
    println(
      "║ SUMMARY: \{file_failures.length()} failure(s), \{file_skipped} skipped",
    )
    println(
      "╚══════════════════════════════════════════════════════════════════╝\n",
    )
    fail("\{file_failures.length()} failure(s) in \{filename}")
  }
  if file_skipped > 0 {
    println("Skipped \{file_skipped} tests in \{filename}")
  }
}

///|
async test "component/adapt.wast" {
  run_component_harness("adapt.wast")
}

///|
async test "component/alias.wast" {
  run_component_harness("alias.wast")
}

///|
async test "component/big.wast" {
  run_component_harness("big.wast")
}

///|
async test "component/definedtypes.wast" {
  run_component_harness("definedtypes.wast")
}

///|
async test "component/empty.wast" {
  run_component_harness("empty.wast")
}

///|
async test "component/example.wast" {
  run_component_harness("example.wast")
}

///|
async test "component/export-ascription.wast" {
  run_component_harness("export-ascription.wast")
}

///|
async test "component/export-introduces-alias.wast" {
  run_component_harness("export-introduces-alias.wast")
}

///|
async test "component/export.wast" {
  run_component_harness("export.wast")
}

///|
async test "component/func.wast" {
  run_component_harness("func.wast")
}

///|
async test "component/import.wast" {
  run_component_harness("import.wast")
}

///|
async test "component/imports-exports.wast" {
  run_component_harness("imports-exports.wast")
}

///|
async test "component/inline-exports.wast" {
  run_component_harness("inline-exports.wast")
}

///|
async test "component/instance-type.wast" {
  run_component_harness("instance-type.wast")
}

// ///|

///|
async test "component/instantiate.wast" {
  run_component_harness("instantiate.wast")
}

///|
async test "component/invalid.wast" {
  run_component_harness("invalid.wast")
}

///|
async test "component/link.wast" {
  run_component_harness("link.wast")
}

///|
async test "component/lots-of-aliases.wast" {
  run_component_harness("lots-of-aliases.wast")
}

///|
async test "component/lower.wast" {
  run_component_harness("lower.wast")
}

///|
async test "component/memory64.wast" {
  run_component_harness("memory64.wast")
}

///|
async test "component/module-link.wast" {
  run_component_harness("module-link.wast")
}

///|
async test "component/more-flags.wast" {
  run_component_harness("more-flags.wast")
}

///|
async test "component/naming.wast" {
  run_component_harness("naming.wast")
}

///|
async test "component/nested-modules.wast" {
  run_component_harness("nested-modules.wast")
}

///|
async test "component/resources.wast" {
  run_component_harness("resources.wast")
}

///|
async test "component/tags.wast" {
  run_component_harness("tags.wast")
}

///|
async test "component/type-export-restrictions.wast" {
  run_component_harness("type-export-restrictions.wast")
}

///|
async test "component/types.wast" {
  run_component_harness("types.wast")
}

///|
async test "component/very-nested.wast" {
  run_component_harness("very-nested.wast")
}

///|
async test "component/virtualize.wast" {
  run_component_harness("virtualize.wast")
}

///|
async test "component/wrong-order.wast" {
  run_component_harness("wrong-order.wast")
}

// ============================================================================
// Wasmtime Component Runtime Tests
// ============================================================================

///|
async fn run_wasmtime_harness(filename : String) -> Unit {
  let (file_failures, file_skipped) = process_component_wast_file(
    "test/reference_tests/wasmtime/", filename,
  )
  if file_failures.length() > 0 {
    let grouped = group_failures_by_type(file_failures)
    println(
      "\n╔══════════════════════════════════════════════════════════════════╗",
    )
    println("║ WASMTIME TEST FAILURES: \{filename}")
    println(
      "╚══════════════════════════════════════════════════════════════════╝",
    )
    for test_type, failures in grouped {
      println(
        "\n┌─ \{test_type} (\{failures.length()} failures) ─────────────────────",
      )
      for failure in failures {
        println(format_failure_detail(failure))
      }
      println(
        "└────────────────────────────────────────────────────────────────",
      )
    }
    println(
      "\n╔══════════════════════════════════════════════════════════════════╗",
    )
    println(
      "║ SUMMARY: \{file_failures.length()} failure(s), \{file_skipped} skipped",
    )
    println(
      "╚══════════════════════════════════════════════════════════════════╝\n",
    )
    fail("\{file_failures.length()} failure(s) in \{filename}")
  }
  if file_skipped > 0 {
    println("Skipped \{file_skipped} tests in \{filename}")
  }
}

///|
async test "wasmtime/adapter.wast" {
  run_wasmtime_harness("adapter.wast")
}

///|
async test "wasmtime/aliasing.wast" {
  run_wasmtime_harness("aliasing.wast")
}

///|
async test "wasmtime/fused.wast" {
  run_wasmtime_harness("fused.wast")
}

///|
async test "wasmtime/import.wast" {
  run_wasmtime_harness("import.wast")
}

///|
async test "wasmtime/instance.wast" {
  run_wasmtime_harness("instance.wast")
}

///|
async test "wasmtime/linking.wast" {
  run_wasmtime_harness("linking.wast")
}

///|
async test "wasmtime/modules.wast" {
  run_wasmtime_harness("modules.wast")
}

///|
async test "wasmtime/nested.wast" {
  run_wasmtime_harness("nested.wast")
}

///|
async test "wasmtime/resources.wast" {
  run_wasmtime_harness("resources.wast")
}

///|
async test "wasmtime/restrictions.wast" {
  run_wasmtime_harness("restrictions.wast")
}

///|
async test "wasmtime/simple.wast" {
  run_wasmtime_harness("simple.wast")
}

///|
async test "wasmtime/strings.wast" {
  run_wasmtime_harness("strings.wast")
}

///|
async test "wasmtime/tags.wast" {
  run_wasmtime_harness("tags.wast")
}

///|
async test "wasmtime/types.wast" {
  run_wasmtime_harness("types.wast")
}
