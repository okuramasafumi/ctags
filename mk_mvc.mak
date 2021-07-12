#
# Makefile for Win32 using Microsoft Visual Studio 2013
#
# To use from the command line:
# 1. From the Start Menu "Visual Studio 2013" -> "Visual Studio Tools" -> "VS2013 x86 Native Tools Command Prompt"
# 2. In the command prompt that opens goto the directory containing the sources
# 3. Execute: nmake -f mk_mvc.mak
#

OBJEXT = obj
include source.mak

GNULIB_HEADS = gnulib/regex.h
GNULIB_SRCS = gnulib/regex.c gnulib/nl_langinfo.c gnulib/setlocale_null.c gnulib/malloc/dynarray_resize.c

COMMON_DEFINES =
DEFINES = -DWIN32 $(COMMON_DEFINES) -DHAVE_REPOINFO_H -DHAVE_PACKCC -DREADTAGS_DSL
INCLUDES = -I. -Ignulib -Imain -Ifnmatch -Iparsers -Ilibreadtags -Idsl
OPT = /O2 /WX
PACKCC = packcc.exe
GNULIB_OBJS = $(GNULIB_SRCS:.c=.obj)
FNMATCH_OBJS = $(FNMATCH_SRCS:.c=.obj)
WIN32_OBJS = $(WIN32_SRCS:.c=.obj)
PEG_OBJS = $(PEG_SRCS:.c=.obj)
PACKCC_OBJS = $(PACKCC_SRCS:.c=.obj)
RES_OBJ = win32/ctags.res
EXTRA_OBJS = $(GNULIB_OBJS) $(FNMATCH_OBJS) $(WIN32_OBJS) $(PEG_OBJS) $(RES_OBJ)
ALL_OBJS = $(ALL_SRCS:.c=.obj) $(EXTRA_OBJS)
ALL_LIB_OBJS = $(ALL_LIB_SRCS:.c=.obj) $(EXTRA_OBJS)
READTAGS_OBJS = $(READTAGS_SRCS:.c=.obj)
READTAGS_DSL_OBJS = $(READTAGS_DSL_SRCS:.c=.obj)
OPTSCRIPT_OBJS = $(OPTSCRIPT_SRCS:.c=.obj)

!if "$(WITH_ICONV)" == "yes"
DEFINES = $(DEFINES) -DHAVE_ICONV
LIBS = $(LIBS) /libpath:$(ICONV_DIR)/lib iconv.lib
INCLUDES = $(INCLUDES) -I$(ICONV_DIR)/include
!endif

!ifdef DEBUG
DEFINES = $(DEFINES) -DDEBUG
PDB = yes
!endif

!ifdef PDB
OPT = $(OPT) /Zi
PDBFLAG = /debug
!else
PDBFLAG =
!endif

# Generate repoinfo.h.
!if [win32\gen-repoinfo.bat $(REPOINFO_HEADS)]
!endif

.SUFFIXES: .peg

{main}.c{main}.obj::
	$(CC) $(OPT) $(DEFINES) $(INCLUDES) /Fomain\ /c $<
{optlib}.c{optlib}.obj::
	$(CC) $(OPT) $(DEFINES) $(INCLUDES) /Fooptlib\ /c $<
{parsers}.c{parsers}.obj::
	$(CC) $(OPT) $(DEFINES) $(INCLUDES) /Foparsers\ /c $<
{parsers\cxx}.c{parsers\cxx}.obj::
	$(CC) $(OPT) $(DEFINES) $(INCLUDES) /Foparsers\cxx\ /c $<
{extra-cmds}.c{extra-cmds}.obj::
	$(CC) $(OPT) $(DEFINES) $(INCLUDES) /Foextra-cmds\ /c $<
{libreadtags}.c{libreadtags}.obj::
	$(CC) $(OPT) $(DEFINES) $(INCLUDES) /Folibreadtags\ /c $<
{dsl}.c{dsl}.obj::
	$(CC) $(OPT) $(DEFINES) $(INCLUDES) /Fodsl\ /c $<
{win32\mkstemp}.c{win32\mkstemp}.obj::
	$(CC) $(OPT) $(DEFINES) $(INCLUDES) /Fowin32\mkstemp\ /c $<
{peg}.peg{peg}.c::
	$(PACKCC) $<
{peg}.c{peg}.obj::
	$(CC) $(OPT) $(DEFINES) $(INCLUDES) /Fopeg\ /c $<
{gnulib}.c{gnulib}.obj::
	$(CC) $(OPT) $(DEFINES) $(INCLUDES) /Fognulib\ /c $<
{gnulib\malloc}.c{gnulib\malloc}.obj::
	$(CC) $(OPT) $(DEFINES) $(INCLUDES) /Fognulib\malloc\ /c $<

all: copy_gnulib_heads $(PACKCC) ctags.exe readtags.exe optscript.exe

ctags: ctags.exe

ctags.exe: $(ALL_OBJS) $(ALL_HEADS) $(PEG_HEADS) $(PEG_EXTRA_HEADS) $(GNULIB_HEADS) $(FNMATCH_HEADS) $(WIN32_HEADS) $(REPOINFO_HEADS)
	$(CC) $(OPT) /Fe$@ $(ALL_OBJS) /link setargv.obj $(LIBS) $(PDBFLAG)

readtags.exe: $(READTAGS_OBJS) $(READTAGS_HEADS) $(READTAGS_DSL_OBJS) $(READTAGS_DSL_HEADS) $(GNULIB_OBJS) $(GNULIB_HEADS)
	$(CC) $(OPT) /Fe$@ $(READTAGS_OBJS) $(READTAGS_DSL_OBJS) $(GNULIB_OBJS) /link setargv.obj $(PDBFLAG)

optscript.exe: $(ALL_LIB_OBJS) $(OPTSCRIPT_OBJS) $(ALL_LIB_HEADS) $(OPTSCRIPT_DSL_HEADS) $(WIN32_HEADS)
	$(CC) $(OPT) /Fe$@ $(ALL_LIB_OBJS) $(OPTSCRIPT_OBJS) /link setargv.obj $(LIBS)

$(FNMATCH_OBJS): $(FNMATCH_SRCS)
	$(CC) /c $(OPT) /Fo$@ $(INCLUDES) $(DEFINES) $(FNMATCH_SRCS)

$(PACKCC_OBJS): $(PACKCC_SRCS)
	$(CC) /c $(OPT) /Fo$@ $(INCLUDES) $(COMMON_DEFINES) $(PACKCC_SRCS)

$(PACKCC): $(PACKCC_OBJS)
	$(CC) $(OPT) /Fe$@ $(PACKCC_OBJS) /link setargv.obj $(PDBFLAG)

main\repoinfo.obj: main\repoinfo.c main\repoinfo.h

peg\varlink.c peg\varlink.h: peg\varlink.peg $(PACKCC)
peg\kotlin.c peg\kotlin.h: peg\kotlin.peg $(PACKCC)

$(RES_OBJ): win32/ctags.rc win32/ctags.exe.manifest win32/resource.h
	$(RC) /nologo /l 0x409 /Fo$@ $*.rc

copy_gnulib_heads:
	copy win32\config_mvc.h config.h
	copy win32\gnulib_h\langinfo.h gnulib

clean:
	- del *.obj main\*.obj optlib\*.obj parsers\*.obj parsers\cxx\*.obj gnulib\*.obj fnmatch\*.obj misc\packcc\*.obj peg\*.obj extra-cmds\*.obj libreadtags\*.obj dsl/*.o win32\mkstemp\*.obj win32\*.res main\repoinfo.h
	- del ctags.exe readtags.exe optscript.exe $(PACKCC)
	- del tags
	- del config.h gnulib\langinfo.h gnulib\*.obj gnulib\malloc\*.obj
