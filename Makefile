EMCC = emcc
CC = gcc
LIBS = -lwasmer

PLUGIN_DIR = plugins

plugin_manager: plugin_manager.c $(PLUGIN_DIR)/plugin.wasm $(PLUGIN_DIR)/plugin_rs.wasm
	cp $(PLUGIN_DIR)/*.wasm .
	$(CC) $< -o $@ $(LIBS)	

$(PLUGIN_DIR)/plugin.wasm: plugin.c
	@mkdir -p $(PLUGIN_DIR)
	$(EMCC) $< -o $@ -s SIDE_MODULE=1 -O3
	wasm2wat $@ -o plugin.wat

$(PLUGIN_DIR)/plugin_rs.wasm: plugin_rs.rs
	@mkdir -p $(PLUGIN_DIR)
	rustc --target=wasm32-unknown-unknown $< -o $@ --crate-type=cdylib -C opt-level=3
	wasm2wat $@ -o plugin_rs.wat

clean:
	rm plugins -rf
	rm plugin.wasm plugin.wat plugin_manager plugin_rs.wasm plugin_rs.wat
