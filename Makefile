EMCC = emcc
CC = gcc
LIBS = -lwasmer

plugin_manager: plugin_manager.c add.wasm
	$(CC) $< -o $@ $(LIBS)	

add.wasm: add.c
	$(EMCC) $< -o $@ -s SIDE_MODULE=1 -O3
	wasm2wat $@ -o add.wat

clean:
	rm add.wasm add.wat plugin_manager
