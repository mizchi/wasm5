// Cloudflare Worker for wasm5
// Executes WebAssembly modules using wasm5 runtime

import wasmModule from './wasm5-api.wasm';

let wasmInstance = null;
let outputBuffer = [];

// Initialize wasm5 runtime
async function initWasm5() {
  if (wasmInstance) return wasmInstance;

  const importObject = {
    spectest: {
      print_char: (char) => {
        outputBuffer.push(String.fromCharCode(char));
      },
      print: () => {},
      print_i32: (v) => { outputBuffer.push(v.toString()); },
      print_i64: (v) => { outputBuffer.push(v.toString()); },
      print_f32: (v) => { outputBuffer.push(v.toString()); },
      print_f64: (v) => { outputBuffer.push(v.toString()); },
      print_i32_f32: (i, f) => { outputBuffer.push(`${i} ${f}`); },
      print_f64_f64: (a, b) => { outputBuffer.push(`${a} ${b}`); },
    },
  };

  const instance = await WebAssembly.instantiate(wasmModule, importObject);
  wasmInstance = instance.exports;
  return wasmInstance;
}

// Execute wasm using wasm5
async function executeWasm(wasmBytes, funcName, args) {
  const wasm5 = await initWasm5();
  outputBuffer = [];

  // Allocate memory for wasm bytes
  const wasmSize = wasmBytes.length;
  const funcNameBytes = new TextEncoder().encode(funcName);
  const totalSize = wasmSize + funcNameBytes.length;

  wasm5.cabi_realloc(0, 0, 1, totalSize);

  // Copy wasm bytes to shared memory
  for (let i = 0; i < wasmSize; i++) {
    wasm5.set_byte(i, wasmBytes[i]);
  }

  // Copy function name after wasm bytes
  const funcNamePtr = wasmSize;
  for (let i = 0; i < funcNameBytes.length; i++) {
    wasm5.set_byte(funcNamePtr + i, funcNameBytes[i]);
  }

  // Execute
  const arg1 = args[0] ?? 0;
  const arg2 = args[1] ?? 0;
  const result = wasm5.execute_wasm(
    wasmSize,
    funcNamePtr,
    funcNameBytes.length,
    arg1,
    arg2
  );

  // Cleanup
  wasm5.cabi_free(0, totalSize);

  return {
    result,
    output: outputBuffer.join(''),
  };
}

// Simple test using embedded add.wasm
async function testAdd(a, b) {
  const wasm5 = await initWasm5();
  return wasm5.test_add(a, b);
}

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    // Health check
    if (url.pathname === '/health') {
      return new Response('OK');
    }

    // Test endpoint
    if (url.pathname === '/test') {
      try {
        const result = await testAdd(3, 5);
        return Response.json({
          success: true,
          test: 'add(3, 5)',
          result,
          expected: 8,
        });
      } catch (e) {
        return Response.json({ error: e.message }, { status: 500 });
      }
    }

    // Execute wasm endpoint
    if (url.pathname === '/execute' && request.method === 'POST') {
      try {
        const body = await request.json();
        const { wasm, func, args } = body;

        // wasm should be base64 encoded
        const wasmBytes = Uint8Array.from(atob(wasm), c => c.charCodeAt(0));

        const { result, output } = await executeWasm(wasmBytes, func, args || []);

        return Response.json({
          success: result >= 0,
          result,
          output,
        });
      } catch (e) {
        return Response.json({ error: e.message }, { status: 500 });
      }
    }

    // Usage info
    return Response.json({
      name: 'wasm5-worker',
      description: 'Execute WebAssembly using wasm5 runtime',
      endpoints: {
        '/health': 'Health check',
        '/test': 'Test add(3, 5) using embedded add.wasm',
        '/execute': {
          method: 'POST',
          body: {
            wasm: 'base64 encoded wasm bytes',
            func: 'function name to call',
            args: '[arg1, arg2] (optional i32 arguments)',
          },
        },
      },
    });
  },
};
