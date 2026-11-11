#!/bin/bash
# Writen by Yeti. Public domain.

set -e
rm -rf syntax
mkdir syntax

make_syntax() {
    name=$1
    shift

    girs_found=
    girs_not_found=
    for girfile in "$@"; do
        if test -f "$girfile"; then
            girs_found="$girs_found $girfile"
        else
            girs_not_found="$girs_not_found $(basename $girfile)"
        fi
    done
    if test -z "$girs_found" && test -n "$girs_not_found"; then
        echo "** Skipping $name.vim, no source GIR file found." 1>&2
        return
    fi
    if test -n "$girs_not_found"; then
        echo "** Generating $name.vim without$girs_not_found" 1>&2
    fi
    girs_found=${girs_found# }

    xtra=
    extra=
    if test -f extra/$name.extra; then
        xtra="extra/$name.extra"
        extra="--extra $xtra"
    fi
    echo -n "$girs_found" | sed -e 's,^[^ ]*/,,' -e 's, [^ ]*/, ,g'
    if test -n "$*"; then
        echo -n ' '
    fi
    if test -n "$xtra"; then
        echo -n "$xtra "
    fi
    synfile="syntax/$name.vim"
    echo "-> $synfile"
    ./src/gir-vim-syntax.py --name $name $extra $girs_found >"$synfile"
}

GIR_PATH=/usr/share/gir-1.0
echo "Generating from GIR files in $GIR_PATH..."
make_syntax glib $GIR_PATH/{GLib,GLibUnix,GModule,GObject,Gio,GioUnix}-2.0.gir
make_syntax gtk2 $GIR_PATH/{Gtk,Gdk,GdkX11}-2.0.gir
make_syntax gtk3 $GIR_PATH/{Gtk,Gdk,GdkX11}-3.0.gir
make_syntax gtk4 $GIR_PATH/{Gtk,Gdk,Gsk,GdkX11,GdkWayland,GdkAndroid,GdkWin32}-4.0.gir
make_syntax gdkpixbuf $GIR_PATH/GdkPixbuf-2.0.gir
make_syntax graphene $GIR_PATH/Graphene-1.0.gir
make_syntax gtksourceview2 $GIR_PATH/GtkSource-2.0.gir
make_syntax gtksourceview3 $GIR_PATH/GtkSource-3.0.gir
make_syntax gtksourceview4 $GIR_PATH/GtkSource-4.gir
make_syntax cairo $GIR_PATH/cairo-1.0.gir
make_syntax pango $GIR_PATH/Pango{,Cairo,Fc,FT2,OT,Xft}-1.0.gir
make_syntax atk $GIR_PATH/Atk-1.0.gir
make_syntax librsvg $GIR_PATH/Rsvg-2.0.gir
make_syntax jsonglib $GIR_PATH/Json-1.0.gir
make_syntax gegl $GIR_PATH/Gegl-0.4.gir
make_syntax babl $GIR_PATH/Babl-0.1.gir
# No GIRs, separately generates extras file. Process to vim syntax files.
# Vulkan has some keywords longer than 80 characters, which is currently the Vim maximum so they do not get highlighted.
make_syntax hdf5
make_syntax vulkan
make_syntax gsl
make_syntax gmp
make_syntax mpfr
make_syntax openmp

# xlib, GL, libxml2 and similar GIRs are completely useless.
#
# We have adopted existing hand-crafted xlib.vim.
# A somewhat useful libxml2.vim was created, probably far from perfect.

echo 'Copying hand-crafted...'
cp -v hand-crafted/*.vim syntax
