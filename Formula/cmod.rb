class Cmod < Formula
  desc "Simple C/C++ modular build system"
  homepage "https://github.com/AntohiRobert/cmod"
  url "https://github.com/AntohiRobert/cmod/archive/refs/heads/main.tar.gz"
  version "0.1.0"


  depends_on "python@3.12"

  depends_on "git"

  depends_on "gcc@11"

def install
  gcc = Formula["gcc@11"]

  ENV["HOMEBREW_CC"] = gcc.opt_bin/"gcc-11"
  ENV["HOMEBREW_CXX"] = gcc.opt_bin/"g++-11"

  ENV["CC"] = gcc.opt_bin/"gcc-11"
  ENV["CXX"] = gcc.opt_bin/"g++-11"

  ENV.prepend_path "PATH", gcc.opt_bin

  system "which", "g++-11" # debug (optional)

  bin.install "cmod.py" => "cmod"
end

  test do
    system "#{bin}/cmod", "init"
    system "#{ENV["CXX"]}", "--version"
  end
end
