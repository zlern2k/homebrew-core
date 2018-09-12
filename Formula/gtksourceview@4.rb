class GtksourceviewAT4 < Formula
  desc "Text view with syntax, undo/redo, and text marks"
  homepage "https://projects.gnome.org/gtksourceview/"
  url "https://download.gnome.org/sources/gtksourceview/4.0/gtksourceview-4.0.3.tar.xz"
  sha256 "3d55a7b82841d96bf414ced2e1e912d4881c9ba2f7b74f0ff8aad636087f9d73"

  bottle do
    sha256 "0b0689afbc8e159aff559126e960da8cec73ad566eda8a70e7e87e2ac51a7a7f" => :mojave
    sha256 "af5f47c301643829fb12bf23daed42981e6881ee5c713237aa1b51fa8c6e1d1a" => :high_sierra
    sha256 "393b576d9b2f86978f4d9d4b21518887cb6eacd770b71cf679a994561da71a6d" => :sierra
    sha256 "9f47547c03530d5fcaba7ae636b2d52adaef645c624dc3c0fde3c22988326046" => :el_capitan
  end

  depends_on "intltool" => :build
  depends_on "pkg-config" => :build
  depends_on "vala" => :build
  depends_on "gobject-introspection" => :build
  depends_on "gettext"
  depends_on "gtk+3"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-vala=yes",
                          "--enable-gobject-introspection=yes"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <gtksourceview/gtksource.h>

      int main(int argc, char *argv[]) {
        gchar *text = gtk_source_utils_unescape_search_text("hello world");
        return 0;
      }
    EOS
    ENV.libxml2
    atk = Formula["atk"]
    cairo = Formula["cairo"]
    fontconfig = Formula["fontconfig"]
    freetype = Formula["freetype"]
    gdk_pixbuf = Formula["gdk-pixbuf"]
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    gtkx3 = Formula["gtk+3"]
    libepoxy = Formula["libepoxy"]
    libpng = Formula["libpng"]
    pango = Formula["pango"]
    pixman = Formula["pixman"]
    flags = %W[
      -I#{atk.opt_include}/atk-1.0
      -I#{cairo.opt_include}/cairo
      -I#{fontconfig.opt_include}
      -I#{freetype.opt_include}/freetype2
      -I#{gdk_pixbuf.opt_include}/gdk-pixbuf-2.0
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/gio-unix-2.0/
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{gtkx3.opt_include}/gtk-3.0
      -I#{include}/gtksourceview-4
      -I#{libepoxy.opt_include}
      -I#{libpng.opt_include}/libpng16
      -I#{pango.opt_include}/pango-1.0
      -I#{pixman.opt_include}/pixman-1
      -D_REENTRANT
      -L#{atk.opt_lib}
      -L#{cairo.opt_lib}
      -L#{gdk_pixbuf.opt_lib}
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{gtkx3.opt_lib}
      -L#{lib}
      -L#{pango.opt_lib}
      -latk-1.0
      -lcairo
      -lcairo-gobject
      -lgdk-3
      -lgdk_pixbuf-2.0
      -lgio-2.0
      -lglib-2.0
      -lgobject-2.0
      -lgtk-3
      -lgtksourceview-4.0
      -lintl
      -lpango-1.0
      -lpangocairo-1.0
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
