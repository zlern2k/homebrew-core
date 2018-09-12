class Handbrake < Formula
  desc "Open-source video transcoder available for Linux, Mac, and Windows"
  homepage "https://handbrake.fr/"
  url "https://download.handbrake.fr/releases/1.1.2/HandBrake-1.1.2-source.tar.bz2"
  sha256 "ba9a4a90a7657720f04e4ba0a2880ed055be3bd855e99c0c13af944c3904de2e"
  head "https://github.com/HandBrake/HandBrake.git"

  bottle do
    sha256 "ec78b6794e70d906a4814ad3622ae2ee4d8d65961ec0c70b979dd316303b043a" => :mojave
    sha256 "2e3ddd3d1b7a0df8b0ef9f2cab5f51f9994008c3a543578a6795db3d1ffd4f89" => :high_sierra
    sha256 "97484268f8fc9f9996634f916d72a7b348c6dba83b37beb1a032f3b614b1cd3e" => :sierra
    sha256 "8c758733f241bf05a42ce06ad752bbba16b36ef520a0b9df239539af9863c356" => :el_capitan
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "cmake" => :build
  depends_on "libtool" => :build
  depends_on "nasm" => :build
  depends_on "pkg-config" => :build
  depends_on "python@2" => :build
  depends_on "yasm" => :build

  def install
    # Upstream issue 8 Jun 2018 "libvpx fails to build"
    # See https://github.com/HandBrake/HandBrake/issues/1401
    if MacOS.version <= :el_capitan
      inreplace "contrib/libvpx/module.defs", /--disable-unit-tests/,
                                              "\\0 --disable-avx512"
    end

    if MacOS.version >= :mojave
      # Upstream issue 8 Sep 2018 "HandBrake 1.1.2: libvpx failed to be configured on macOS 10.14 Mojave"
      # See https://github.com/HandBrake/HandBrake/issues/1578
      inreplace "contrib/libvpx/module.defs", "--target=x86_64-darwin11-gcc", "--target=x86_64-darwin14-gcc"
    end

    system "./configure", "--prefix=#{prefix}",
                          "--disable-xcode",
                          "--disable-gtk"
    system "make", "-C", "build"
    system "make", "-C", "build", "install"
  end

  test do
    system bin/"HandBrakeCLI", "--help"
  end
end
