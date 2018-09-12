class Gjstest < Formula
  desc "Fast JavaScript unit testing framework that runs on the V8 engine"
  homepage "https://github.com/google/gjstest"
  revision 15
  head "https://github.com/google/gjstest.git"

  stable do
    url "https://github.com/google/gjstest/archive/v1.0.2.tar.gz"
    sha256 "7bf0de1c4b880b771a733c9a5ce07c71b93f073e6acda09bec7e400c91c2057c"

    # Patches for compatability with more recent v8 versions
    patch do
      url "https://github.com/google/gjstest/commit/141f35d1fcb5c5fb0dc13421d74555255d98bed8.patch?full_index=1"
      sha256 "66208476d389295f8913513f893626891cdd562e205ec6616f90b3dc5af88d5a"
    end

    patch do
      url "https://github.com/google/gjstest/commit/b4cacaac8505f84e2341a39cffc047474d57b6a1.patch?full_index=1"
      sha256 "598d15f600ecd09392f014822a0756904f7ba825ba92de1ca107092513a93a0e"
    end

    patch do
      url "https://github.com/google/gjstest/commit/8218472140582e2efd1a9dfb2d7b969610a02d75.patch?full_index=1"
      sha256 "736a9ac4e963801730ac8d482ed4817ebc5c57d5395b7a05236b7841423218dd"
    end
  end

  bottle do
    sha256 "0cbe3cecc85f801ce129cf4f158ce24b479c4a948fbc2759a9f11e908891b6bd" => :mojave
    sha256 "609f48aea6da4a1dc6cb02400af96965a50e9eb89edcfb3527a3d09b1e20a98c" => :high_sierra
    sha256 "bac415bfc9c372c4ff26fdc8e508bc7b07812035261e77c10d00865c39a4e232" => :sierra
    sha256 "bb6aebafefa77510dc0b07b6e1cd4dd763336626fb12d26f4360417b3b4417aa" => :el_capitan
  end

  depends_on :macos => :mavericks

  depends_on "gflags"
  depends_on "glog"
  depends_on "libxml2"
  depends_on "protobuf"
  depends_on "re2"
  depends_on "v8"

  def install
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    (testpath/"sample_test.js").write <<~EOS
      function SampleTest() {
      }
      registerTestSuite(SampleTest);

      addTest(SampleTest, function twoPlusTwoEqualsFour() {
        expectEq(4, 2+2);
      });
    EOS

    system "#{bin}/gjstest", "--js_files", "#{testpath}/sample_test.js"
  end
end
