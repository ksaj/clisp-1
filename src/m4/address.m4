dnl -*- Autoconf -*-
dnl Copyright (C) 1993-2003 Free Software Foundation, Inc.
dnl This file is free software, distributed under the terms of the GNU
dnl General Public License.  As a special exception to the GNU General
dnl Public License, this file may be distributed as part of a program
dnl that contains a configuration script generated by Autoconf, under
dnl the same distribution terms as the rest of that program.

dnl From Bruno Haible, Marcus Daniels, Sam Steingold.

AC_PREREQ(2.57)

AC_DEFUN([CL_ADDRESS_RANGE],
[AC_REQUIRE([AC_PROG_CC])dnl
address_range_prog='
#include <stdio.h>
#ifdef __cplusplus
extern "C" void exit(int);
#endif
#if defined(__STDC__) || defined(__cplusplus)
void printf_address (unsigned long addr)
#else
printf_address (addr)
  unsigned long addr;
#endif
{ if (sizeof(unsigned long) <= 4)
    printf ("0x%08X", (unsigned int)addr);
  else
    printf ("0x%08X%08X",(unsigned int)(addr>>32),(unsigned int)(addr&0xFFFFFFFF));
}
#define chop_address(addr) ((unsigned long)(char*)(addr) & ~0x00FFFFFFL)
'
AC_CACHE_CHECK(for the code address range, cl_cv_address_code, [
if test $cross_compiling = no; then
cat > conftest.c <<EOF
#include "confdefs.h"
$address_range_prog
dnl printf_address(chop_address(&main)); doesn't work in C++.
int main() { printf_address(chop_address(&printf_address)); exit(0); }
EOF
AC_TRY_EVAL(ac_link)
cl_cv_address_code=`./conftest`
rm -f conftest*
else
cl_cv_address_code='guessing 0'
fi
])
x=`echo $cl_cv_address_code | sed -e 's,^guessing ,,'`"UL"
AC_DEFINE_UNQUOTED(CODE_ADDRESS_RANGE,$x,[address range of program code (text+data+bss)])
AC_CACHE_CHECK(for the malloc address range, cl_cv_address_malloc, [
if test $cross_compiling = no; then
cat > conftest.c <<EOF
#include "confdefs.h"
#include <sys/types.h>
/* declare malloc() */
#include <stdlib.h>
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif
#ifndef malloc
]AC_LANG_EXTERN[
#if defined(__STDC__) || defined(__cplusplus)
RETMALLOCTYPE malloc (MALLOC_SIZE_T size);
#else
RETMALLOCTYPE malloc();
#endif
#endif
$address_range_prog
int main() { printf_address(chop_address(malloc(10000))); exit(0); }
EOF
AC_TRY_EVAL(ac_link)
cl_cv_address_malloc=`./conftest`
rm -f conftest*
else
cl_cv_address_malloc='guessing 0'
fi
])
x=`echo $cl_cv_address_malloc | sed -e 's,^guessing ,,'`"UL"
AC_DEFINE_UNQUOTED(MALLOC_ADDRESS_RANGE,$x,[address range of malloc() memory])
AC_CACHE_CHECK(for the shared library address range, cl_cv_address_shlib, [
if test $cross_compiling = no; then
cat > conftest.c <<EOF
#include "confdefs.h"
$address_range_prog
/* Declare printf(). */
#if defined(sun) /* for SunOS 4, but not for IRIX 6 */
#ifdef __cplusplus
extern "C" int printf (const char *, ...);
#else
extern int printf ();
#endif
#endif
/* Declare tmpnam(). */
#ifdef __cplusplus
extern "C" char* tmpnam (char*);
#else
extern char* tmpnam ();
#endif
/* With normal simple DLLs, &printf is in the shared library. Fine.
   But with ELF, &printf is a trampoline function allocated near the
   program's code range. errno and other global variables - such as
   &stdout - are allocated near the program's code and bss as well.
   However, the return value of tmpnam(NULL) is a pointer to a static
   buffer in the shared library. (This buffer is unlikely to be named
   by a global symbol.) */
int main() {
  char* addr;
  addr = (char*) tmpnam((char*)0);
  if (!addr) addr = (char*) &printf;
  printf_address(chop_address(addr));
  exit(0);
}
EOF
AC_TRY_EVAL(ac_link)
cl_cv_address_shlib=`./conftest`
rm -f conftest*
else
cl_cv_address_shlib='guessing 0'
fi
])
x=`echo $cl_cv_address_shlib | sed -e 's,^guessing ,,'`"UL"
AC_DEFINE_UNQUOTED(SHLIB_ADDRESS_RANGE,$x,[address range of shared library code])
AC_CACHE_CHECK(for the stack address range, cl_cv_address_stack, [
if test $cross_compiling = no; then
cat > conftest.c <<EOF
#include "confdefs.h"
$address_range_prog
int main() { int dummy; printf_address(chop_address(&dummy)); exit(0); }
EOF
AC_TRY_EVAL(ac_link)
cl_cv_address_stack=`./conftest`
rm -f conftest*
else
cl_cv_address_stack='guessing ~0'
fi
])
x=`echo "$cl_cv_address_stack" | sed -e 's,^guessing ,,'`"UL"
AC_DEFINE_UNQUOTED(STACK_ADDRESS_RANGE,$x,[address range of the C stack])
])
