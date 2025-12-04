#/bin/bash
export PREFIX="$HOME/opt/cross"
export TARGET=x86_64-elf
#try:
#export TARGET=x86_64-elf-cpp
export PATH="$PREFIX/bin:$PATH"
make all