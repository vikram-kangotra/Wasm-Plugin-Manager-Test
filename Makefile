EMCC = emcc
CC = gcc
LIBS = -lwasmer

plugin_manager: plugin_manager.c plugin.wasm
	$(CC) $< -o $@ $(LIBS)	

plugin.wasm: plugin.c
	$(EMCC) $< -o $@ -s SIDE_MODULE=1 -O3
	wasm2wat $@ -o plugin.wat

clean:
	rm plugin.wasm plugin.wat plugin_manager
