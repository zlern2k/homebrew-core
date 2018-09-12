class Protobuf < Formula
  desc "Protocol buffers (Google's data interchange format)"
  homepage "https://github.com/protocolbuffers/protobuf/"
  url "https://github.com/protocolbuffers/protobuf.git",
      :tag => "v3.6.1",
      :revision => "48cb18e5c419ddd23d9badcfe4e9df7bde1979b2"
  head "https://github.com/protocolbuffers/protobuf.git"

  bottle do
    sha256 "47bfed73e275684cd1b74d0817239661bdeab555744ac7345467abba4fa58216" => :mojave
    sha256 "0f5f2cf5d166e083f7456e08f3dca248625b1c385e91fd1fd7c8bf9f46162092" => :high_sierra
    sha256 "a667c98b9cf7d81bd81436d50bc8ad4dea8e8e063ab1ed1be7f95625cddf4eb2" => :sierra
    sha256 "ef87974beb704c499ee6233211358e900372c89b09c3438d8933f18af70b1750" => :el_capitan
  end

  option "without-python@2", "Build without python2 support"

  deprecated_option "without-python" => "with-python@2"
  deprecated_option "with-python3" => "with-python"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "python@2" => :recommended
  depends_on "python" => :optional

  resource "six" do
    url "https://files.pythonhosted.org/packages/16/d8/bc6316cf98419719bd59c91742194c111b6f2e85abac88e496adefaf7afe/six-1.11.0.tar.gz"
    sha256 "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9"
  end

  needs :cxx11

  # Upstream PR from 3 Jul 2018 "Add Python 3.7 compatibility"
  patch do
    url "https://github.com/protocolbuffers/protobuf/pull/4862.patch?full_index=1"
    sha256 "4b1fe1893c40cdcef531c31746ddd18759c9ce3564c89ddcc0ec934ea5dbf377"
  end

  def install
    # Don't build in debug mode. See:
    # https://github.com/Homebrew/homebrew/issues/9279
    # https://github.com/protocolbuffers/protobuf/blob/5c24564811c08772d090305be36fae82d8f12bbe/configure.ac#L61
    ENV.prepend "CXXFLAGS", "-DNDEBUG"
    ENV.cxx11

    system "./autogen.sh"
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}", "--with-zlib"
    system "make"
    system "make", "check" if build.bottle?
    system "make", "install"

    # Install editor support and examples
    doc.install "editors", "examples"

    Language::Python.each_python(build) do |python, version|
      resource("six").stage do
        system python, *Language::Python.setup_install_args(libexec)
      end
      chdir "python" do
        ENV.append_to_cflags "-I#{include}"
        ENV.append_to_cflags "-L#{lib}"
        args = Language::Python.setup_install_args libexec
        args << "--cpp_implementation"
        system python, *args
      end
      site_packages = "lib/python#{version}/site-packages"
      pth_contents = "import site; site.addsitedir('#{libexec/site_packages}')\n"
      (prefix/site_packages/"homebrew-protobuf.pth").write pth_contents
    end
  end

  def caveats; <<~EOS
    Editor support and examples have been installed to:
      #{doc}
  EOS
  end

  test do
    testdata = <<~EOS
      syntax = "proto3";
      package test;
      message TestCase {
        string name = 4;
      }
      message Test {
        repeated TestCase case = 1;
      }
    EOS
    (testpath/"test.proto").write testdata
    system bin/"protoc", "test.proto", "--cpp_out=."
    system "python2.7", "-c", "import google.protobuf" if build.with? "python@2"
    system "python3", "-c", "import google.protobuf" if build.with? "python"
  end
end
