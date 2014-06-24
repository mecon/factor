CC = gcc
AR = ar
LD = ld

EXECUTABLE = factor
VERSION = 0.91

IMAGE = factor.image
BUNDLE = Factor.app
LIBPATH = -L/usr/X11R6/lib
CFLAGS = -Wall

ifdef DEBUG
	CFLAGS += -g
else
	CFLAGS += -O3 $(SITE_CFLAGS)
endif

ifdef CONFIG
	include $(CONFIG)
endif

ENGINE = $(DLL_PREFIX)factor$(DLL_SUFFIX)$(DLL_EXTENSION)

DLL_OBJS = $(PLAF_DLL_OBJS) \
	vm/alien.o \
	vm/bignum.o \
	vm/code_heap.o \
	vm/debug.o \
	vm/factor.o \
	vm/ffi_test.o \
	vm/image.o \
	vm/io.o \
	vm/math.o \
	vm/data_gc.o \
	vm/code_gc.o \
	vm/primitives.o \
	vm/run.o \
	vm/callstack.o \
	vm/types.o \
	vm/quotations.o \
	vm/utilities.o \
	vm/errors.o \
	vm/profiler.o

EXE_OBJS = $(PLAF_EXE_OBJS)

default:
	$(MAKE) `./build-support/factor.sh make-target`

help:
	@echo "Run '$(MAKE)' with one of the following parameters:"
	@echo ""
	@echo "freebsd-x86-32"
	@echo "freebsd-x86-64"
	@echo "linux-x86-32"
	@echo "linux-x86-64"
	@echo "linux-ppc"
	@echo "linux-arm"
	@echo "openbsd-x86-32"
	@echo "openbsd-x86-64"
	@echo "netbsd-x86-32"
	@echo "netbsd-x86-64"
	@echo "macosx-x86-32"
	@echo "macosx-x86-64"
	@echo "macosx-ppc"
	@echo "solaris-x86-32"
	@echo "solaris-x86-64"
	@echo "wince-arm"
	@echo "winnt-x86-32"
	@echo "winnt-x86-64"
	@echo ""
	@echo "Additional modifiers:"
	@echo ""
	@echo "DEBUG=1  compile VM with debugging information"
	@echo "SITE_CFLAGS=...  additional optimization flags"
	@echo "NO_UI=1  don't link with X11 libraries (ignored on Mac OS X)"
	@echo "X11=1  force link with X11 libraries instead of Cocoa (only on Mac OS X)"

openbsd-x86-32:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.openbsd.x86.32

openbsd-x86-64:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.openbsd.x86.64

freebsd-x86-32:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.freebsd.x86.32

freebsd-x86-64:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.freebsd.x86.64

netbsd-x86-32:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.netbsd.x86.32

netbsd-x86-64:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.netbsd.x86.64

macosx-freetype:
	ln -sf libfreetype.6.dylib \
		Factor.app/Contents/Frameworks/libfreetype.dylib

macosx-ppc: macosx-freetype
	$(MAKE) $(EXECUTABLE) macosx.app CONFIG=vm/Config.macosx.ppc

macosx-x86-32: macosx-freetype
	$(MAKE) $(EXECUTABLE) macosx.app CONFIG=vm/Config.macosx.x86.32

macosx-x86-64: macosx-freetype
	$(MAKE) $(EXECUTABLE) macosx.app CONFIG=vm/Config.macosx.x86.64

linux-x86-32:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.linux.x86.32

linux-x86-64:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.linux.x86.64

linux-ppc:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.linux.ppc

linux-arm:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.linux.arm

solaris-x86-32:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.solaris.x86.32

solaris-x86-64:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.solaris.x86.64

freetype6.dll:
	wget http://factorcode.org/dlls/freetype6.dll
	chmod 755 freetype6.dll

zlib1.dll:
	wget http://factorcode.org/dlls/zlib1.dll
	chmod 755 zlib1.dll

winnt-x86-32: freetype6.dll zlib1.dll
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.windows.nt.x86.32

winnt-x86-64:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.windows.nt.x86.64

wince-arm:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.windows.ce.arm

macosx.app: factor
	mkdir -p $(BUNDLE)/Contents/MacOS
	mv $(EXECUTABLE) $(BUNDLE)/Contents/MacOS/factor
	ln -s Factor.app/Contents/MacOS/factor ./factor
	cp $(ENGINE) $(BUNDLE)/Contents/Frameworks

	install_name_tool \
		-id @executable_path/../Frameworks/libfreetype.6.dylib \
		Factor.app/Contents/Frameworks/libfreetype.6.dylib
	install_name_tool \
		-change libfactor.dylib \
		@executable_path/../Frameworks/libfactor.dylib \
		Factor.app/Contents/MacOS/factor

factor: $(DLL_OBJS) $(EXE_OBJS)
	$(LINKER) $(ENGINE) $(DLL_OBJS)
	$(CC) $(LIBS) $(LIBPATH) -L. $(LINK_WITH_ENGINE) \
		$(CFLAGS) -o $@$(EXE_SUFFIX)$(EXE_EXTENSION) $(EXE_OBJS)

clean:
	rm -f vm/*.o
	rm -f factor*.dll libfactor*.*

vm/resources.o:
	$(WINDRES) vm/factor.rs vm/resources.o

.c.o:
	$(CC) -c $(CFLAGS) -o $@ $<

.S.o:
	$(CC) -c $(CFLAGS) -o $@ $<

.m.o:
	$(CC) -c $(CFLAGS) -o $@ $<

.PHONY: factor
