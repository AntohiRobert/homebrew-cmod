class Cmod < Formula
  desc "Simple C/C++ modular build system"
  homepage "https://github.com/AntohiRobert/cmod"
  url "https://github.com/AntohiRobert/cmod/archive/refs/heads/main.tar.gz"
  version "0.1.0"

  depends_on "python@3.12"
  depends_on "git"
  depends_on "gcc"

  def install
    gcc = Formula["gcc"]
    gcc_bin = gcc.opt_bin
    python = Formula["python@3.12"].opt_bin/"python3"

    # IMPORTANT: correct source path
    libexec.install buildpath/"cmod.py"

    (bin/"cmod").write <<~EOS
      #!/bin/bash
      export CMOD_CXX=#{gcc_bin}/g++-11
      export CMOD_CC=#{gcc_bin}/gcc-11

      exec #{python} #{libexec}/cmod.py "$@"
    EOS

    chmod 0755, bin/"cmod"
  end

  test do
    system "#{bin}/cmod", "init"

    gcc = Formula["gcc"]
    system gcc.opt_bin/"g++-11", "--version"
  end
end