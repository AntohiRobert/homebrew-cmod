class Cmod < Formula
  desc "Simple C/C++ modular build system"
  homepage "https://github.com/AntohiRobert/cmod"
  url "https://github.com/AntohiRobert/cmod/archive/refs/heads/main.tar.gz"
  version "0.1.2"
  sha256 "440a1f2817a44218d907a0780bfce500dfee138b46fcaf4dc6fba7e5e59ede0d"

  depends_on "python@3.12"
  depends_on "gcc@12"
  depends_on "git"

  def install
  gcc = Formula["gcc"].opt_bin
  python = Formula["python@3.12"].opt_bin/"python3.12"

  libexec.install "cmod.py"

  (bin/"cmod").write <<~EOS
    #!/bin/bash

    GCC_BINDIR="#{gcc}"

    export CMOD_CC="$GCC_BINDIR/gcc"
    export CMOD_CXX="$GCC_BINDIR/g++"

    if [[ "$(uname)" == "Darwin" ]]; then
      export SDKROOT="$(xcrun --show-sdk-path 2>/dev/null)"
      export CFLAGS="--sysroot=$SDKROOT"
      export CXXFLAGS="--sysroot=$SDKROOT"
    fi

    exec "#{python}" "#{libexec}/cmod.py" "$@"
  EOS

  chmod 0755, bin/"cmod"
end

  test do
    system "#{bin}/cmod", "init"
    assert_predicate testpath/"cmodconfig.json", :exist?
  end
end