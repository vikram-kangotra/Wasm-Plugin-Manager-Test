EMCC = emcc
CC = gcc
LIBS = -lwasmer

PLUGIN_DIR = plugins

.PHONY: all clean

all: plugin_manager

plugin_manager: plugin_manager.c $(PLUGIN_DIR) $(PLUGIN_DIR)/plugin.wasm $(PLUGIN_DIR)/plugin_rs.wasm
	$(CC) $< -o $@ $(LIBS)	

$(PLUGIN_DIR):
	@mkdir -p $@

$(PLUGIN_DIR)/plugin.wasm: plugin.c
	$(EMCC) $< -o $@ -s SIDE_MODULE=1 -O3
	wasm2wat $@ -o $(PLUGIN_DIR)/plugin.wat

$(PLUGIN_DIR)/plugin_rs.wasm: plugin_rs.rs
	rustc --target=wasm32-unknown-unknown $< -o $@ --crate-type=cdylib -C opt-level=3
	wasm2wat $@ -o $(PLUGIN_DIR)/plugin_rs.wat

clean:
	rm -rf $(PLUGIN_DIR) plugin.wasm plugin.wat plugin_manager plugin_rs.wasm plugin_rs.wat
