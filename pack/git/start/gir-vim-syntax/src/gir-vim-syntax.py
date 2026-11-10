#!/usr/bin/python3
# vim: set columns=120 sw=4 ts=4 et :
# Writen by Yeti. Public domain.
# $Id: gir-vim-syntax.py 15886 2025-07-09 17:41:21Z yeti $
import xml.etree.ElementTree as ET
import sys, re, time, argparse

nsmap = {
    'gir': 'http://www.gtk.org/introspection/core/1.0',
    'c': 'http://www.gtk.org/introspection/c/1.0',
    'glib': 'http://www.gtk.org/introspection/glib/1.0',
}

# Keep this global; we also use it as means to keep the output deterministic.
symbol_priority = 'Class Interface Struct Union Flags Enum UserFunction Typedef Constant Variable Function Macro'.split()

def die(msg, e=None):
    sys.stderr.write(msg)
    if e:
        sys.stderr.write(': ' + str(e))
    sys.stderr.write('\n')
    sys.exit(1)

def shorten_ns(s):
    if not s.startswith('{'):
        return s
    for name, ns in nsmap.items():
        pfx = '{' + ns + '}'
        if s.startswith(pfx):
            return name + ':' + s[len(pfx):]
    return s

def shorten_attributes(elem):
    return dict((shorten_ns(k), v) for k, v in elem.attrib.items())

def gimme_some_name(attrib):
    for k in 'name', 'glib:name', 'gir:name':
        if k in attrib:
            return attrib[k]
    return '???'

def add_if_exists(attrib, name, syntax, kind, where=None):
    if name in attrib:
        if attrib[name].startswith('_'):
            return None
        if kind not in syntax:
            syntax[kind] = set()
        syntax[kind].add(attrib[name])
        return attrib[name]

    if 'name' in attrib and attrib['name'].startswith('_'):
        return None

    if where is not None:
        tag = shorten_ns(where.tag)
        for attr in ('c:type', 'c:identifier', 'gir:name', 'glib:type-name', 'glib:type-struct'):
            if attr in attrib:
                where = attrib[attr]
                break
        if type(where) is not str:
            where = '???'
        sys.stderr.write('Missing %s attribute in %s of type %s.\n' % (name, where, tag))
    return None

def add_methods(symbol, syntax):
    for ftype in 'function', 'method', 'constructor':
        for method in symbol.findall('gir:' + ftype, nsmap):
            add_if_exists(shorten_attributes(method), 'c:identifier', syntax, 'Function', where=symbol)

def add_gtype(symbol, attrib, syntax, warn_if_missing=False):
    # The LIBRARY_TYPE_CLASS_NAME macro is not in GIR at all. We can semi-reliably derive its name only if we have the
    # get-type function (in particular when there are uppercase letter clusters in ClassName).
    where = None
    if warn_if_missing:
        where = symbol

    get_type_func = add_if_exists(attrib, 'glib:get-type', syntax, 'Function', where=where)
    if not get_type_func:
        return

    # Marks some internal GLib nonsense.
    if get_type_func == 'intern':
        return

    m = re.search(r'^(?P<prefix>[^_]+)_(?P<typename>\w+)_get_g?type$', get_type_func)
    if not m:
        sys.stderr.write('Class %s has get-type function with strange name %s.\n'
                         % (gimme_some_name(attrib), get_type_func))
        return
    syntax.setdefault('Constant', set()).add((m.group('prefix') + '_type_' + m.group('typename')).upper())

def handle_docsection(symbol, attrib, syntax):
    pass

def handle_alias(symbol, attrib, syntax):
    add_if_exists(attrib, 'c:type', syntax, 'Typedef', where=symbol)

def handle_function(symbol, attrib, syntax):
    add_if_exists(attrib, 'c:identifier', syntax, 'Function', where=symbol)

def handle_function_macro(symbol, attrib, syntax):
    add_if_exists(attrib, 'c:identifier', syntax, 'Macro', where=symbol)

def handle_callback(symbol, attrib, syntax):
    add_if_exists(attrib, 'c:type', syntax, 'UserFunction', where=symbol)

def handle_constant(symbol, attrib, syntax):
    add_if_exists(attrib, 'c:type', syntax, 'Constant', where=symbol)

def handle_record(symbol, attrib, syntax):
    if not add_if_exists(attrib, 'c:type', syntax, 'Struct', where=symbol):
        return
    add_gtype(symbol, attrib, syntax)
    add_methods(symbol, syntax)

def handle_union(symbol, attrib, syntax):
    add_if_exists(attrib, 'c:type', syntax, 'Union', where=symbol)

def handle_glib_boxed(symbol, attrib, syntax):
    if not add_if_exists(attrib, 'glib:type-name', syntax, 'Typedef', where=symbol):
        return
    add_gtype(symbol, attrib, syntax)
    add_methods(symbol, syntax)

def handle_class(symbol, attrib, syntax):
    # Some symbols, like GtkEntryIconAccessible, mysteriously lack the C type. Try also glib type-name and only
    # make noise when both fail.
    if (not add_if_exists(attrib, 'c:type', syntax, 'Class')
        and not add_if_exists(attrib, 'glib:type-name', syntax, 'Class')):
        add_if_exists(attrib, 'c:type', syntax, 'Class', where=symbol)
        return
    add_gtype(symbol, attrib, syntax, True)
    add_methods(symbol, syntax)

def handle_interface(symbol, attrib, syntax):
    if not add_if_exists(attrib, 'c:type', syntax, 'Interface', where=symbol):
        return
    add_gtype(symbol, attrib, syntax, True)
    add_methods(symbol, syntax)

def handle_enumeration(symbol, attrib, syntax):
    if not add_if_exists(attrib, 'c:type', syntax, 'Enum', where=symbol):
        return
    add_gtype(symbol, attrib, syntax)
    for member in symbol.findall('gir:member', nsmap):
        add_if_exists(shorten_attributes(member), 'c:identifier', syntax, 'Constant', where=symbol)
    if 'glib:error-domain' in attrib:
        symbol = attrib['glib:error-domain']
        m = re.search('^(?P<name>[a-z-]+-error)-quark$', symbol)
        if m:
            syntax.setdefault('Constant', set()).add(m.group('name').replace('-', '_').upper())

def handle_bitfield(symbol, attrib, syntax):
    if not add_if_exists(attrib, 'c:type', syntax, 'Flags', where=symbol):
        return
    add_gtype(symbol, attrib, syntax)
    for member in symbol.findall('gir:member', nsmap):
        add_if_exists(shorten_attributes(member), 'c:identifier', syntax, 'Constant', where=symbol)

handlers = {
    'gir:docsection': handle_docsection,
    'gir:alias': handle_alias,
    'gir:function': handle_function,
    'gir:function-inline': handle_function,
    'gir:function-macro': handle_function_macro,
    'gir:callback': handle_callback,
    'gir:constant': handle_constant,
    'gir:record': handle_record,
    'gir:union': handle_union,
    'glib:boxed': handle_glib_boxed,
    'gir:class': handle_class,
    'gir:interface': handle_interface,
    'gir:enumeration': handle_enumeration,
    'gir:bitfield': handle_bitfield,
}

def remove_fluff(syntax, prefixes):
    for symbols in syntax.values():
        toremove = set()
        for p in prefixes:
            is_fluff = re.compile(r'^' + p.upper() + r'_DEPRECATED_(([A-Z]+_)?(IN_[0-9]+_[0-9]+_)?)?FOR$').search
            toremove.update(s for s in symbols if is_fluff(s))
        symbols.difference_update(toremove)

def expand_standard_gobject(syntax, typename, prefix, symbol):
    macro_patterns = '_%s', '_%s_CLASS', 'IS_%s', 'IS_%s_CLASS', '%s_GET_CLASS'
    syntax.setdefault('Class', set()).add(typename)
    syntax.setdefault('Struct', set()).add(typename + 'Class')
    syntax.setdefault('Constant', set()).add((prefix + '_TYPE_' + symbol).upper())
    syntax.setdefault('Macro', set()).update([(prefix + '_' + p % symbol).upper() for p in macro_patterns])
    syntax.setdefault('Function', set()).add((prefix + '_' + symbol + '_get_type').lower())

def process_gir_file(girfile, syntax, keepall):
    try:
        text = open(girfile).read()
    except (IOError, OSError) as e:
        die('Error reading file %s' % girfile, e)

    try:
        root = ET.fromstring(text)
    except ET.ParseError as e:
        die('Error parsing GIR file %s as XML' % girfile, e)

    namespace = list(root.findall('gir:namespace', nsmap))
    if len(namespace) != 1:
        die('GIR file %s has multiple namespaces' % girfile)

    namespace = namespace[0]
    attrib = shorten_attributes(namespace)
    prefixes = attrib.get('c:symbol-prefixes', '').split(',')
    newsyntax = {}
    for symbol in namespace:
        kind = shorten_ns(symbol.tag)
        if kind in handlers:
            handlers[kind](symbol, shorten_attributes(symbol), newsyntax)
        else:
            name = gimme_some_name(symbol)
            sys.stderr.write('Unhandled symbol %s of type %s.\n' % (name, kind))

    if not keepall:
        remove_fluff(newsyntax, prefixes)

    # Merge after removing fluff which is library-specific.
    for kind, symbols in newsyntax.items():
        syntax.setdefault(kind, set()).update(symbols)

def resolve_multiple_occurences(syntax):
    keys = list(syntax.keys())
    conflicts = set()
    for i, k1 in enumerate(keys):
        for k2 in keys[i+1:]:
            conflicts.update(syntax[k1].intersection(syntax[k2]))

    for symbol in conflicts:
        where = [k for k, s in syntax.items() if symbol in s]
        keep_this_one = min((i, k) for i, k in enumerate(symbol_priority) if k in where)[1]
        for k in where:
            if k != keep_this_one:
                syntax[k].remove(symbol)

argparser = argparse.ArgumentParser(prog='gir-vim-syntax',
                                    description='Process GIR files into a Vim syntax file, '
                                                'written to the standard output.')
argparser.add_argument('GIRFILE', nargs='*')
argparser.add_argument('--name', dest='name', metavar='LIBFOO', help='prefix of the generated syntax (mandatory)')
argparser.add_argument('--extra', dest='extra', metavar='FILENAME', help='file with additional syntax items')
argparser.add_argument('--linelen', dest='linelen', metavar='CHARS', help='maximum output line length', type=int, default=4095)
argparser.add_argument('--keep-all', dest='keepall', action='store_true', help='do not filter out administrative macros')
argparser.add_argument('--maintainer', dest='maintainer', help='syntax maintainer (informative for the syntax file)')
args = argparser.parse_args()

syntax_name = args.name
if syntax_name is None:
    die('Syntax file prefix must be given using --name.')

if not args.GIRFILE and args.extra is None:
    die('No GIR file and no extras given. Nothing to process.')

syntax = {}
for girfile in args.GIRFILE:
    process_gir_file(girfile, syntax, args.keepall)

resolve_multiple_occurences(syntax)

# The extra file should list symbols like this:
# Typedef gint gint16 gint64
# Macro GINT16_FROM_BE CLAMP
# Skip g_macro__has_attribute___noreturn__
# etc.
if args.extra is not None:
    for line in open(args.extra):
        line = line.strip()
        if line:
            line = line.split()
            kind = line[0]
            items = line[1:]
            if kind == 'Skip':
                for k, v in syntax.items():
                    v.difference_update(items)
            elif kind == 'GObject':
                if len(items) != 3:
                    die('GObject extra line must have two items: CamelType, prefix and under_score_name')
                expand_standard_gobject(syntax, *items)
            elif kind not in symbol_priority:
                die('Symbol kind %s is unknown' % kind)
            else:
                syntax.setdefault(kind, set()).update(items)

resolve_multiple_occurences(syntax)

highlighting_def = '''
Class Interface Struct Union Flags Enum UserFunction Typedef -> Type
Function -> Function
Variable -> Identifier
Constant -> Constant
Macro -> Macro
'''
h = [line.strip() for line in highlighting_def.split('\n')]
h = [line.split('->') for line in h if line]
highlighting = {}
for line in h:
    for kind in line[0].strip().split():
        highlighting[kind] = line[1].strip()

template = '''\
" Vim syntax file
" Language: C %(library)s library extension
" Maintainer: %(maintainer)s
" Last Change: %(date)s
" This is not a standalone vim syntax file and does not behave like one.
" Include it in addition to c.vim to highlight the library symbols.
'''

maintainer = args.maintainer
if maintainer is None:
    maintainer = 'David Nečas (Yeti) <yeti@physics.muni.cz>'
header = template % {
    'library': syntax_name,
    'maintainer': maintainer,
    'date': time.strftime('%Y-%m-%d'),
}

print(header)

# Dump symbols
linelen = args.linelen
kinds = [k for k in symbol_priority if k in syntax]
for kind in kinds:
    symbols = list(reversed(sorted(syntax[kind])))
    while symbols:
        # Output at least one symbol per line. But otherwise try to keep the maximum length.
        line = 'syn keyword %s%s %s' % (syntax_name, kind, symbols.pop())
        while symbols and len(line) + 1 + len(symbols[-1]) <= linelen:
            line += ' ' + symbols.pop()
        print(line)
print()

# Default highlighting
for kind in kinds:
    print('hi def link %s%s %s' % (syntax_name, kind, highlighting[kind]))
