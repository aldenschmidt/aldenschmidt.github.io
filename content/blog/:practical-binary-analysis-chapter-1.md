---
title: "Practical Binary Analysis: Chapter 1 Notes"
date: 2021-03-14T23:29:48-04:00
slug: ""
description: "These are my notes from Practical Binary Analysis and the answers to the exercises."
keywords: [reverse engineering]
draft: false
tags: []
math: false
toc: true 
---

## The C compilation Process

The phases are preprocessing → compilation → assembly → linking 

![/img/Screen_Shot_2021-03-14_at_1.03.34_AM.png](/img/Screen_Shot_2021-03-14_at_1.03.34_AM.png)

### The Preprocessing Phase (Step 1)

Process starts with source files (`filename.c`)

C source files contain *macros* (denoted by `#define`) and `#include` directives. You can use these directives to include header files which get expanded during the preprocessing phase leaving C code behind.

```c
#include <stdio.h>

#define FORMAT_STRING  "%s"
#define MESSAGE        "Hello, world!\n"

int main(int argc, char *argv[]) {
	printf(FORMAT_STRING, MESSAGE);
	return 0; 
}
```

### The Compilation Phase (Step 2)

This phase occurs after the preprocessing phase, converts the c code into assembly language (to view this step use `gcc -S -masm=intel {filename}`)

- Why does it compile into assembly code and not machine code?

    Writing a compiler that will translate directly into machine code would be really difficult. It is much easier to have the compiler write out ASM and then write a separate assembler that can translate into machine code

### The Assembly Phase (Step 3)

Takes in input from **Step 2** and generates actual machine code (in the format of .o files or *object files/modules*)

**Relocatable files:** means that the file can be moved around and not break - you know you're dealing with an object file and not an executable (there are also position-independent executables as well - you can tell them apart because they have an entry point address) 

### The Linking Phase (Step 4)

Final phase of compilation. Links all of the object files into a single binary executable file (sometimes modern computers use an optimization *link-time optimization* or LTO)

Object files may reference functions or variables in other object files or libraries external to the program. Hence, the addresses at which the referenced code and variables aren't known so the object files only contain *relocation symbols (*which specify how functions/variables should be resolved). References that rely on a relocation symbol are called *symbolic references*. 

Linkers job is to take all the object files and convert them to a single executable typically designed to be run at one particular location. References to libraries may be resolved depending on the type of library. 

**Static libraries:** (which typically have the extension .a) are merged into the executable (think how preprocessing works). 

**Dynamic (shared) libraries:** are not copied into the file as they are referred to by multiple executables. 

The `interpreter` line tells you which *dynamic linker* will be used to resolve the final dependencies on the **dynamic libraries.** 

## Symbols and Stripped Binaries

Compilers emit *symbols* which keep track of such symbolic names and record which binary code and data correspond to each symbol (e.g function symbols provide a mapping from symbolic, high-level function names to the first address and the size of each function)

### Viewing Symbolic Information

`readelf` can be used to view the symbols of a binary. Symbolic info can be emitted as part of the binary or in the form of a separate symbol file.

Debugging symbols go as far as providing a full mapping between source lines and binary-level instructions

**ELF Binaries:** debugging symbols are typically generated in the DWARF format

**PE Binaries:** are generated with the Microsoft Portable Debugging (PDB)

### Stripping a Binary

Default behavior of `gcc` is to not strip binaries. Using the command `strip` is how you remove the debugging symbols from a binary. After this, the only symbols that remain are the ones which are used to resolve dynamic libraries.


## Disassembling a Binary

### Looking Inside an Object File

Using `objdump` you can examine the assembly of an object file. `.rodata` stands for "read-only data" and its where all the constants in the binary are stored (like strings or whatever).


## Loading and Executing a Binary

This section covers HOW a binary is executed once it is created. 

The binaries representation in memory does not necessarily correspond one-to-one with its on-disk representation (e.g large regions of zero-initialized data may be collapsed in the on-disk binary to save space but they'll be expanded in memory.) 

When you run a binary - OS starts by setting up a new process for program to run in - including a virtual address space 

The OS then maps an *interpreter* into the process's virtual memory (a user space program that knows how to load the bin and perform relocations). 

**Linux Interpreter: `ld-linux.so`**

**Windows Interpreter: `ntdll.dll`**

![/img/Screen_Shot_2021-03-14_at_10.44.09_PM.png](/img/Screen_Shot_2021-03-14_at_10.44.09_PM.png)

This diagram represents loading an ELF binary on a Linux system

ELF binaries come with a special section called `.interp` that specifies the path to the interpreter that is to be used to load the binary 

Then the OS parses the binary to find out which dynamic libraries the binary uses.