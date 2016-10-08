#!/usr/bin/env python3
#
# Copyright (c) 2016 Intel Corporation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or
# without modification, are permitted provided that the following
# conditions are met:
#
# 1. Redistributions of source code must retain the above
# copyright notice, this list of conditions and the following
# disclaimer.
#
# 2. Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided
# with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of
# its contributors may be used to endorse or promote products
# derived from this software without specific prior written
# permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import functools
import io
import itertools
import os
import os.path
import re
import subprocess
import tempfile
import xml.etree.ElementTree

VA_HEADERS = [
    'va_dec_hevc.h', 'va_dec_jpeg.h', 'va_dec_vp8.h', 'va_dec_vp9.h',
    'va_enc_h264.h', 'va_enc_hevc.h', 'va_enc_jpeg.h', 'va_enc_mpeg2.h',
    'va_enc_vp8.h', 'va_enc_vp9.h', 'va.h', 'va_version.h', 'va_vpp.h',
]
NS_GIR = 'http://www.gtk.org/introspection/core/1.0'
NS_C   = 'http://www.gtk.org/introspection/c/1.0'

C2S_RE1 = re.compile('([^_])([A-Z][a-z])')
C2S_RE2 = re.compile('([a-z][0-9]*)([A-Z])')
def camel_to_snake(s):
    return C2S_RE1.sub(r'\1_\2', C2S_RE2.sub(r'\1_\2', s))

def shared_prefix_len(strs):
    def alleq(chars):
        v = functools.reduce(lambda x,y: x if x == y else None, chars)
        return v is not None
    return len(list(itertools.takewhile(alleq, zip(*strs))))

VA_RE = re.compile('^va(?=[^.])(?!lue$)', re.IGNORECASE)
C_TYPE = '{' + NS_C + '}type'
C_IDENTIFIER = '{' + NS_C + '}identifier'
C_SYMBOL_PREFIXES = '{' + NS_C + '}symbol-prefixes'
MEMBER = '{' + NS_GIR + '}member'
PACKAGE = '{' + NS_GIR + '}package'
FUNCTION = '{' + NS_GIR + '}function'
NAMESPACE = '{' + NS_GIR + '}namespace'
PARAMETER = '{' + NS_GIR + '}parameter'
ENUMERATION = '{' + NS_GIR + '}enumeration'
def munge_gir(gir):
    for e in gir.findall('.//'):
        if e.tag != NAMESPACE and 'name' in e.attrib:
            e.attrib['name'] = VA_RE.sub('', e.attrib['name'])
        if e.tag == NAMESPACE and e.attrib[C_SYMBOL_PREFIXES] == 'workseverytime':
            e.attrib[C_SYMBOL_PREFIXES] = e.attrib['name'].lower()

    for fn in gir.findall('.//' + FUNCTION):
        fn.attrib['name'] = camel_to_snake(fn.attrib['name']).lower()
    for enum in gir.findall('.//' + ENUMERATION):
        for member in enum.findall(MEMBER):
            if member.attrib[C_IDENTIFIER].endswith('Max'):
                enum.remove(member)
    for enum in gir.findall('.//' + ENUMERATION):
        member_names = [i.attrib[C_IDENTIFIER] for i in enum.findall(MEMBER)]
        if len(member_names) == 1:
            member_names += [enum.attrib[C_TYPE]]
        prefix_len = shared_prefix_len(member_names)
        suffix_len = shared_prefix_len(list(x[::-1] for x in member_names))
        for member in enum.findall(MEMBER):
            name = member.attrib[C_IDENTIFIER][prefix_len:]
            if suffix_len != 0:
                name = name[:-suffix_len]
            member.attrib['name'] = camel_to_snake(name).lower()
    for p in gir.findall('.//' + PARAMETER):
        t = p.find('{' + NS_GIR + '}type')
        if t is not None and C_TYPE in t.attrib and '*' in t.attrib[C_TYPE]:
            if t.attrib[C_TYPE] not in ['void*', 'Display*']:
                p.attrib['direction'] = 'inout'
    for e in gir.findall('.//'):
        if 'name' in e.attrib and e.attrib['name'].startswith('1_'):
            e.attrib['name'] = e.attrib['name'][2:]

def add_include(gir, header):
    gir.getroot().insert(0, xml.etree.ElementTree.fromstring('<include xmlns="'
        + NS_C + '" name="' + header + '" />'))

def va2gir(includedir, verbose=False):
    os.environ['CFLAGS'] = '-Wl,--no-as-needed'
    output = None if verbose else subprocess.DEVNULL
    prepend_symbol = os.path.join(os.path.dirname(os.path.realpath(__file__)),
        'prepend_symbol.sh')
    tmp = tempfile.NamedTemporaryFile()
    ret = subprocess.call(['g-ir-scanner', '--warn-all', '--library', 'va',
        '--namespace', 'Va', '--nsversion', '1.0', '--accept-unprefixed',
        '--output', tmp.name, '--pkg', 'libva',]
        + [os.path.join(includedir, 'va', h) for h in VA_HEADERS],
        stdout=output, stderr=output)
    if ret != 0: return ret

    xml.etree.ElementTree.register_namespace('', NS_GIR)
    xml.etree.ElementTree.register_namespace('c', NS_C)
    gir = xml.etree.ElementTree.parse(tmp)
    munge_gir(gir)
    add_include(gir, 'va/va.h')
    gir.write(open('Va-1.0.gir', 'wb+'), xml_declaration=True)

    tmp = tempfile.NamedTemporaryFile()
    ret = subprocess.call(['g-ir-scanner', '--warn-all', '--library', 'va-x11',
        '--namespace', 'VaX11', '--nsversion', '1.0', '--output', tmp.name,
        '--pkg', 'libva-x11', '--symbol-prefix', 'workseverytime', '--include',
        'xlib-2.0', '--include-uninstalled', './Va-1.0.gir',
        '--symbol-filter-cmd', prepend_symbol,
        os.path.join(includedir, 'va/va_x11.h')],
        stdout=output, stderr=output)
    if ret != 0: return ret

    gir = xml.etree.ElementTree.parse(tmp)
    munge_gir(gir)
    add_include(gir, 'va/va_x11.h')
    gir.write(open('VaX11-1.0.gir', 'wb+'), xml_declaration=True)

    tmp = tempfile.NamedTemporaryFile()
    ret = subprocess.call(['g-ir-scanner', '--warn-all', '--library', 'va-drm',
        '--namespace', 'VaDrm', '--nsversion', '1.0', '--output', tmp.name,
        '--pkg', 'libva-drm', '--symbol-prefix', 'workseverytime',
        '--include-uninstalled', './Va-1.0.gir', '--symbol-filter-cmd',
        prepend_symbol, os.path.join(includedir, 'va/va_drm.h')],
        stdout=output, stderr=output)
    if ret != 0: return ret

    gir = xml.etree.ElementTree.parse(tmp)
    munge_gir(gir)
    add_include(gir, 'va/va_drm.h')
    gir.write(open('VaDrm-1.0.gir', 'wb+'), xml_declaration=True)
    return 0

if __name__ == '__main__':
    import sys
    args = sys.argv[1:]
    verbose = '-v' in args
    if verbose:
        args.remove('-v')
    sys.exit(va2gir(*args, verbose=verbose))
