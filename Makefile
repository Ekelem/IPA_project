
TARGET = IPA
LIBS = -lSDL2 -lGL -lGLU -lGLEW -lm
#LIBS = -lGLEW -lGL -lSDL2 -lSDL2_mixer -lSDL2_image -lGLU -lglut
LDFLAGS=-nostartfiles

all: $(TARGET)

$(TARGET): xkelem01.asm rewrite.c Makefile
	gcc rewrite.c -c -O3 -o help.o
	nasm xkelem01.asm -f elf64 -o xkelem01.o
	gcc $(LDFLAGS) xkelem01.o help.o -o $(TARGET) $(LIBS)