class Cmod < Formula
  desc "Simple C/C++ modular build system"
  homepage "https://github.com/AntohiRobert/cmod"
  url "https://github.com/AntohiRobert/cmod/archive/refs/heads/main.tar.gz"
  version "0.1.0"
  sha256 "440a1f2817a44218d907a0780bfce500dfee138b46fcaf4dc6fba7e5e59ede0d"

  depends_on "python@3.12"
  depends_on "git"
  depends_on "gcc@11"

  def install
    gcc_bin = Formula["gcc@11"].opt_bin
    python_bin = Formula["python@3.12"].opt_bin/"python3.12"

    libexec.install "cmod.py"

    # Găsim calea către SDK-ul macOS actual (unde se află wchar.h)
    sdk_path = `xcrun --show-sdk-path`.strip

    (bin/"cmod").write <<~EOS
      #!/bin/bash
      SHADOW_BIN=$(mktemp -d)
      
      # Link-uri pentru binarul principal
      ln -s "#{gcc_bin}/g++-11" "$SHADOW_BIN/g++"
      ln -s "#{gcc_bin}/gcc-11" "$SHADOW_BIN/gcc"
      
      # FIX PENTRU WCHAR.H:
      # Setăm variabilele de mediu pentru ca GCC să găsească headerele de sistem din SDK
      export CPATH="#{sdk_path}/usr/include"
      export LIBRARY_PATH="#{sdk_path}/usr/lib"
      
      # Alte setări de compilator
      export CMOD_CXX="#{gcc_bin}/g++-11"
      export CMOD_CC="#{gcc_bin}/gcc-11"
      export PATH="$SHADOW_BIN:#{gcc_bin}:$PATH"
      
      "#{python_bin}" "#{libexec}/cmod.py" "$@"
      
      EXIT_CODE=$?
      rm -rf "$SHADOW_BIN"
      exit $EXIT_CODE
    EOS

    chmod 0755, bin/"cmod"
  end
end