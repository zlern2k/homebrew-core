class Pdal < Formula
  desc "Point data abstraction library"
  homepage "https://www.pdal.io/"
  url "https://github.com/PDAL/PDAL/archive/1.7.2.tar.gz"
  sha256 "cedfefbe54ca61cbb33d100d619c53873d84f480ff53deec2cf6dd91580f6a61"
  revision 1
  head "https://github.com/PDAL/PDAL.git"

  bottle do
    sha256 "0a894193d9d2fa7444bb046a9938ee030a0fffe6ab368bab986e3cc0e5d673a8" => :mojave
    sha256 "82d6a2f732c0157da27f0f08714e13d93ca44170492f92bb3d5beeccc3258e8c" => :high_sierra
    sha256 "b4dcdc14e28ef98f6d11efc93216e0d6038e2edadabbe15c7d0377d04bbfd890" => :sierra
    sha256 "ed28bdbe2fddbc1995dbb1248cd7c21b4bbd2f2a34e0929662be9f6fb1bd5be9" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "gdal"
  depends_on "hdf5"
  depends_on "laszip"
  depends_on "numpy"
  depends_on "pcl"
  depends_on "postgresql"

  def install
    system "cmake", ".", *std_cmake_args,
                         "-DWITH_LASZIP=TRUE",
                         "-DBUILD_PLUGIN_GREYHOUND=ON",
                         "-DBUILD_PLUGIN_ICEBRIDGE=ON",
                         "-DBUILD_PLUGIN_PCL=ON",
                         "-DBUILD_PLUGIN_PGPOINTCLOUD=ON",
                         "-DBUILD_PLUGIN_PYTHON=ON",
                         "-DBUILD_PLUGIN_SQLITE=ON"

    system "make", "install"
    doc.install "examples", "test"
  end

  test do
    system bin/"pdal", "info", doc/"test/data/las/interesting.las"
  end
end
