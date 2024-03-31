#include <stdio.h>
#include <stdlib.h>
#include <wasmer.h>

wasm_byte_vec_t read_wasm_file(const char* filename) {
    FILE* file = fopen(filename, "rb");
    if (file == NULL) {
        fprintf(stderr, "failed to open file\n");
        exit(1);
    }
    fseek(file, 0, SEEK_END);
    long len = ftell(file);
    wasm_byte_vec_t wasm;
    wasm_byte_vec_new_uninitialized(&wasm, len);

    fseek(file, 0, SEEK_SET);
    if (fread(wasm.data, 1, len, file) != len) {
        fprintf(stderr, "failed to read file\n");
        exit(1);
    }
    fclose(file);
    return wasm;
}

int main() {

    wasm_engine_t* engine = wasm_engine_new();
    wasm_store_t* store = wasm_store_new(engine);

    // Can use WAT or WASM format.
    wasm_byte_vec_t wat = read_wasm_file("add.wasm");
    wasm_byte_vec_t wasm;

    // Parses in-memory bytes as either the WAT format, or a binary Wasm module. This is wasmer-specific.
    wat2wasm(&wat, &wasm);

    wasm_module_t* module = wasm_module_new(store, &wasm);

    if (module == NULL) {
        printf("Failed to compile module!\n");
        return 1;
    }

    wasm_extern_vec_t imports = WASM_EMPTY_VEC;

    wasm_instance_t* instance = wasm_instance_new(store, module, &imports, NULL);

    if (instance == NULL) {
        printf("Failed to instantiate module!\n");
        return 1;
    }

    wasm_extern_vec_t exports;
    wasm_instance_exports(instance, &exports);
    
    wasm_func_t* add_func = wasm_extern_as_func(exports.data[1]);

    if (add_func == NULL) {
        printf("Failed to find function!\n");
        return 1;
    }

    wasm_val_t args_val[2] = { WASM_I32_VAL(21), WASM_I32_VAL(21) };
    wasm_val_t results_val[1] = { WASM_INIT_VAL };
    wasm_val_vec_t args = WASM_ARRAY_VEC(args_val);
    wasm_val_vec_t results = WASM_ARRAY_VEC(results_val);

    if (wasm_func_call(add_func, &args, &results)) {
        printf("Call failed!\n");
        return 1;
    }

    printf("Result: %d\n", results_val[0].of.i32);

    wasm_extern_vec_delete(&exports);
    wasm_instance_delete(instance);
    wasm_module_delete(module);
    wasm_byte_vec_delete(&wasm);
    wasm_store_delete(store);
    wasm_engine_delete(engine);

    return 0;
}
