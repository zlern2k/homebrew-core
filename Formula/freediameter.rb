class Freediameter < Formula
  desc "Open source Diameter (Authentication) protocol implementation"
  homepage "http://www.freediameter.net"
  url "http://www.freediameter.net/hg/freeDiameter/archive/1.2.1.tar.gz"
  sha256 "bd7f105542e9903e776aa006c6931c1f5d3d477cb59af33a9162422efa477097"
  revision 1
  head "http://www.freediameter.net/hg/freeDiameter", :using => :hg

  bottle do
    sha256 "312ad5669b92df173d95b51326ae8b21c9860202ad4b2dd3215f16714b851676" => :mojave
    sha256 "c57d61c9ddb1a1cef706b043d3be28ad4ab94eb7e9bbd0c9952f392074fafc31" => :high_sierra
    sha256 "0b444785c639b55365e67092f5ff4997c2cba3ad72f37aaaaf7cf4a2eb88b758" => :sierra
    sha256 "ae4a0a662111c28c542ba2b15f2ff5f0d6955dd62c474b7216f12bda8a54041c" => :el_capitan
  end

  option "with-all-extensions", "Enable all extensions"

  depends_on "cmake" => :build
  depends_on "gnutls"
  depends_on "libgcrypt"
  depends_on "libidn"

  if build.with? "all-extensions"
    depends_on "swig" => :build
    depends_on "postgresql"
    depends_on "mysql"
  end

  def install
    args = std_cmake_args + %W[
      -DDEFAULT_CONF_PATH=#{etc}
      -DDISABLE_SCTP=ON
    ]
    args << "-DALL_EXTENSIONS=ON" if build.with? "all-extensions"

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end

    doc.install Dir["doc/*"]
    pkgshare.install "contrib"
  end

  def post_install
    return if File.exist?(etc/"freeDiameter.conf")

    cp doc/"freediameter.conf.sample", etc/"freeDiameter.conf"
  end

  def caveats; <<~EOS
    To configure freeDiameter, edit #{etc}/freeDiameter.conf to taste.

    Sample configuration files can be found in #{doc}.

    For more information about freeDiameter configuration options, read:
      http://www.freediameter.net/trac/wiki/Configuration

    Other potentially useful files can be found in #{opt_pkgshare}/contrib.
  EOS
  end

  plist_options :startup => true

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/freeDiameterd</string>
        </array>
        <key>KeepAlive</key>
        <dict>
          <key>NetworkState</key>
          <true/>
        </dict>
      </dict>
    </plist>
  EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/freeDiameterd --version")
  end
end
