
#Author: Erik Kelemen

TARGET = IPA
LIBS = -lSDL2 -lGL -lGLU -lGLEW -lm
LDFLAGS=-nostartfiles

all: $(TARGET)

$(TARGET): xkelem01.asm rewrite.c Makefile
	gcc rewrite.c -c -O3 -o help.o
	nasm xkelem01.asm -f elf64 -o xkelem01.o
	gcc $(LDFLAGS) -no-pie xkelem01.o help.o -o $(TARGET) $(LIBS)