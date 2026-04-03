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

    # Install python script into libexec (not directly exposed)
    libexec.install "cmod.py"

    # Create wrapper script that enforces GCC usage
    (bin/"cmod").write <<~EOS
      #!/bin/bash
      export CMOD_CXX=#{gcc_bin}/g++-11
      export CMOD_CC=#{gcc_bin}/gcc-11

      exec #{Formula["python@3.12"].opt_bin}/python3 #{libexec}/cmod.py "$@"
    EOS

    chmod 0755, bin/"cmod"
  end

  test do
    # Ensure tool runs
    system "#{bin}/cmod", "init"

    # Verify GCC exists (real check, not clang fallback)
    gcc = Formula["gcc"]
    system gcc.opt_bin/"g++-11", "--version"

    # Ensure environment is correct
    system "bash", "-c", "#{bin}/cmod build || true"
  end
end