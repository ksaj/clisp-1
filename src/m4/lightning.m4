dnl -*- Autoconf -*-
dnl Copyright (C) 2008 Sam Steingold
dnl Copyright (C) 2017 Bruno Haible
dnl This is free software, distributed under the GNU GPL v2+

AC_DEFUN([CL_LIGHTNING],
[
  AC_ARG_WITH([lightning-prefix],
    [AS_HELP_STRING([[--with-lightning-prefix]],
       [additional place to look for the lightning headers])],
    [if test -f $withval/include/lightning.h; then
       AC_LIB_APPENDTOVAR([CPPFLAGS], [-I$withval/include])
     fi
    ],
    [])
  AC_CHECK_HEADERS([lightning.h])
])
