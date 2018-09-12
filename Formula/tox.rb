class Tox < Formula
  include Language::Python::Virtualenv

  desc "Generic Python virtualenv management and test command-line tool"
  homepage "https://tox.readthedocs.org/"
  url "https://files.pythonhosted.org/packages/4e/9e/4a586cc3fc6bcd36b78aaeefca09a9fe6204752b9fb5a8c060e0bcc5fb40/tox-3.3.0.tar.gz"
  sha256 "433bb93c57edae263150767e672a0d468ab4fefcc1958eb4013e56a670bb851e"

  bottle do
    cellar :any_skip_relocation
    sha256 "46cdec66c79c5870c3e65c7e3661a60f7567dca583411e58e67f23dabd49d547" => :mojave
    sha256 "2a627b356bb3986c506afaec5f2ea42ce062b2e947c567c28d8ca4295455caa8" => :high_sierra
    sha256 "e9c4fc4b74993e2d6bbb7d953a7dd6ab9c8aa65b6dc3c2e27dee077dd01fd978" => :sierra
    sha256 "042a9edf97959b862f1534c5b925224bd1b8365685b37a7a4c908a247da80b28" => :el_capitan
  end

  depends_on "python"

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/77/32/439f47be99809c12ef2da8b60a2c47987786d2c6c9205549dd6ef95df8bd/packaging-17.1.tar.gz"
    sha256 "f019b770dd64e585a99714f1fd5e01c7a8f11b45635aa953fd41c689a657375b"
  end

  resource "pluggy" do
    url "https://files.pythonhosted.org/packages/a1/83/ef7d976c12d67a5c7a5bc2a47f0501c926cabae9d9fcfdc26d72abc9ba15/pluggy-0.7.1.tar.gz"
    sha256 "95eb8364a4708392bae89035f45341871286a333f749c3141c20573d2b3876e1"
  end

  resource "py" do
    url "https://files.pythonhosted.org/packages/4f/38/5f427d1eedae73063ce4da680d2bae72014995f9fdeaa57809df61c968cd/py-1.6.0.tar.gz"
    sha256 "06a30435d058473046be836d3fc4f27167fd84c45b99704f2fb5509ef61f9af1"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/3c/ec/a94f8cf7274ea60b5413df054f82a8980523efd712ec55a59e7c3357cf7c/pyparsing-2.2.0.tar.gz"
    sha256 "0832bcf47acd283788593e7a0f542407bd9550a55a8a8435214a1960e04bcb04"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/16/d8/bc6316cf98419719bd59c91742194c111b6f2e85abac88e496adefaf7afe/six-1.11.0.tar.gz"
    sha256 "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9"
  end

  resource "toml" do
    url "https://files.pythonhosted.org/packages/0e/e8/1aa958599e5326b690a31334112da68a9b75e7563879e2c5103ca219d30a/toml-0.9.6.tar.gz"
    sha256 "380178cde50a6a79f9d2cf6f42a62a5174febe5eea4126fe4038785f1d888d42"
  end

  resource "virtualenv" do
    url "https://files.pythonhosted.org/packages/33/bc/fa0b5347139cd9564f0d44ebd2b147ac97c36b2403943dbee8a25fd74012/virtualenv-16.0.0.tar.gz"
    sha256 "ca07b4c0b54e14a91af9f34d0919790b016923d157afda5efdde55c96718f752"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    ENV["LC_ALL"] = "en_US.UTF-8"
    pyver = Language::Python.major_minor_version("python3").to_s.delete(".")
    (testpath/"tox.ini").write <<~EOS
      [tox]
      envlist=py#{pyver}
      skipsdist=True

      [testenv]
      deps=pytest
      commands=pytest
    EOS
    (testpath/"test_trivial.py").write <<~EOS
      def test_trivial():
          assert True
    EOS
    assert_match "usage", shell_output("#{bin}/tox --help")
    system "#{bin}/tox"
    assert_predicate testpath/".tox/py#{pyver}", :exist?
  end
end
