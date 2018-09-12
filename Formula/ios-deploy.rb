class IosDeploy < Formula
  desc "Install and debug iPhone apps from the command-line"
  homepage "https://github.com/phonegap/ios-deploy"
  url "https://github.com/ios-control/ios-deploy/archive/1.9.3.tar.gz"
  sha256 "9ef7430d20a777cd2916ab9d6aac849de11b349e85cf80048c95eca47d026e6c"
  head "https://github.com/phonegap/ios-deploy.git"

  # Fix upstream bug https://github.com/ios-control/ios-deploy/issues/349
  # Remove with next version
  patch do
    url "https://github.com/ios-control/ios-deploy/commit/9b23447e.diff?full_index=1"
    sha256 "9c676388e84e20d3032156ea6dc81ba29dee4b4ffb99d78a81b34aa0b81c12e3"
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "7d7f28b6bad93d0ffaaa4a0656f10caf03329a1dd087ff1dfd5b1b474665d2d6" => :mojave
    sha256 "9a8dd08fb6f05f9aa94253cfcff8ee8d95d6e4ebd47df0273ef184c3a308f52e" => :high_sierra
    sha256 "22cd1a7a916691d1a425377db4eceff20f686f83092c2141306bc4cdb3905573" => :sierra
    sha256 "29649cb0452652d45245eedccd4c16474efd07a629f4a916540117a73865e0c0" => :el_capitan
  end

  depends_on :xcode => :build
  depends_on :macos => :yosemite

  def install
    xcodebuild "-configuration", "Release", "SYMROOT=build"

    xcodebuild "test", "-scheme", "ios-deploy-tests", "-configuration", "Release", "SYMROOT=build"

    bin.install "build/Release/ios-deploy"
    include.install "build/Release/libios_deploy.h"
    lib.install "build/Release/libios-deploy.a"
  end

  test do
    system "#{bin}/ios-deploy", "-V"
  end
end
