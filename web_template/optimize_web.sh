#!/bin/bash
CDDD="../exports/web"
cd $CDDD &&
wasm-opt index.wasm -o tmp_index.wasm -all --post-emscripten -Oz &&
rm index.wasm &&
mv tmp_index.wasm index.wasm
