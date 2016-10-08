#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([GVa], [0.1], [BUG-REPORT-ADDRESS])
AC_CONFIG_MACRO_DIRS([m4])
AM_INIT_AUTOMAKE([foreign subdir-objects])
AM_SILENT_RULES([yes])
LT_INIT

# Checks for programs.

AM_PROG_VALAC
AC_PATH_PROG([VAPIGEN], [vapigen], [vapigen])
GOBJECT_INTROSPECTION_REQUIRE([1.46])

# Checks for libraries.

AM_PATH_GLIB_2_0([], [], [], [gobject])
PKG_CHECK_MODULES([LIBVA], [libva])
PKG_CHECK_VAR([LIBVA_INCLUDEDIR], [libva], [includedir])

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AX_CREATE_PKGCONFIG_INFO([gva-0.1.pc])
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
