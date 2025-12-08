#!/bin/ksh
export PREFIX="$HOME/opt/cross"
export TARGET=x86_64-elf-cpp
export PATH="$PREFIX/bin:$PATH"
make all
