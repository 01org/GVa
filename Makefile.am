ACLOCAL_AMFLAGS = -I m4
lib_LTLIBRARIES = libgva-0.1.la
libgva_0_1_la_SOURCES = src/buffer.vala src/config.vala src/context.vala \
	src/display.vala src/image.vala src/surface.vala interface/libva.vapi
include_HEADERS = gva-0.1.h
libgva_0_1_la_CFLAGS = $(GLIB_CFLAGS) $(LIBVA_CFLAGS)
libgva_0_1_la_LDFLAGS = $(GLIB_LIBS) $(LIBVA_LIBS)
libgva_0_1_la_VALAFLAGS = --header gva-0.1.h --vapi interface/gva-0.1.vapi
vapi_DATA = $(srcdir)/interface/libva.vapi $(srcdir)/interface/libva-x11.vapi \
	$(srcdir)/interface/libva-drm.vapi $(srcdir)/interface/gva-0.1.vapi
gir_DATA = $(srcdir)/interface/Va-1.0.gir $(srcdir)/interface/VaX11-1.0.gir \
	$(srcdir)/interface/VaDrm-1.0.gir $(srcdir)/interface/GVa-0.1.gir
typelib_DATA = interface/Va-1.0.typelib interface/VaX11-1.0.typelib \
	interface/VaDrm-1.0.typelib interface/GVa-0.1.typelib
pkgconfig_DATA = gva-0.1.pc
vapidir = $(datarootdir)/vala/vapi
girdir = $(datarootdir)/gir-1.0
typelibdir = $(libdir)/girepository-1.0
pkgconfigdir = $(libdir)/pkgconfig

EXTRA_DIST = scripts/va2gir.py scripts/prepend_symbol.sh
EXTRA_DIST += interface/gva-0.1.deps interface/libva-drm.deps
EXTRA_DIST += interface/libva-x11.deps
EXTRA_DIST += $(vapi_DATA) $(gir_DATA) libgva_0_1_la_gir.stamp
EXTRA_DIST += $(srcdir)/interface/4vapi/Va-1.0.gir \
	$(srcdir)/interface/4vapi/VaX11-1.0.gir \
	$(srcdir)/interface/4vapi/VaDrm-1.0.gir

CLEANFILES = $(typelib_DATA)

VA2GIR_VERBOSE_0 :=
VA2GIR_VERBOSE_1 := -v
VA2GIR_VERBOSE := $(VA2GIR_VERBOSE_$(V))

$(srcdir)/interface/libva.vapi: $(srcdir)/interface/4vapi/Va-1.0.gir
$(srcdir)/interface/libva-x11.vapi: $(srcdir)/interface/4vapi/VaX11-1.0.gir $(srcdir)/interface/libva.vapi
$(srcdir)/interface/libva-drm.vapi: $(srcdir)/interface/4vapi/VaDrm-1.0.gir $(srcdir)/interface/libva.vapi

$(srcdir)/interface/4vapi/%.gir: $(srcdir)/interface/%.gir
	$(AM_V_at)$(MKDIR_P) $(dir $@)
	$(AM_V_at)$(AM_V_GEN)$(abs_top_srcdir)/scripts/gir4vapi.py < $^ > $@-t
	$(AM_V_at)mv -f $@-t $@

%.vapi:
	$(AM_V_at)$(AM_V_GEN)$(VAPIGEN) -q $< --vapidir=$(srcdir)/interface \
	--girdir=$(srcdir)/interface/4vapi --library $(@:.vapi=)
	$(AM_V_at)touch $@

$(srcdir)/libgva_0_1_la_gir.stamp:
	$(AM_V_at)rm -f $@; echo stamp > $@-t
	$(AM_V_at)$(AM_V_GEN)$(MKDIR_P) $(abs_top_srcdir)/interface; \
	cd $(abs_top_srcdir)/interface; \
	$(abs_top_srcdir)/scripts/va2gir.py $(VA2GIR_VERBOSE) $(LIBVA_INCLUDEDIR)
	$(AM_V_at)mv -f $@-t $@

$(srcdir)/interface/Va-1.0.gir $(srcdir)/interface/VaX11-1.0.gir $(srcdir)/interface/VaDrm-1.0.gir: $(srcdir)/libgva_0_1_la_gir.stamp
	@if test -f $@; then :; else rm $^; $(MAKE) $(AM_MAKEFLAGS) $^; fi

interface/%.typelib: $(srcdir)/interface/%.gir
	$(AM_V_at)$(MKDIR_P) $(dir $@)
	$(AM_V_at)$(AM_V_GEN)$(INTROSPECTION_COMPILER) $^ \
	--includedir $(dir $^) > $@

$(srcdir)/interface/GVa-0.1.gir: $(libgva_0_1_la_SOURCES)
	$(AM_V_at)$(AM_V_GEN)$(VALAC) $^ --gir $@ --library gva-0.1 \
	--header gva-0.1.h --vapi ignore-me-gva-0.1.vapi \
	--vapidir $(srcdir)/interface --shared-library libgva-0.1.so \
	-X "$(strip $(LIBVA_CFLAGS))" -X -fPIC -X -shared -o /dev/null
