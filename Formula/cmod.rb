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
    
    # Găsim calea către SDK-ul macOS (esențial pentru stdlib.h, stdio.h, etc.)
    sdk_path = `xcrun --show-sdk-path`.strip

    libexec.install "cmod.py"

    (bin/"cmod").write <<~EOS
      #!/bin/bash
      # 1. Creăm un folder temporar pentru symlink-uri
      SHADOW_BIN=$(mktemp -d)
      
      # 2. Mapăm g++ și gcc către versiunile Homebrew
      ln -s "#{gcc_bin}/g++-11" "$SHADOW_BIN/g++"
      ln -s "#{gcc_bin}/gcc-11" "$SHADOW_BIN/gcc"
      
      # 3. FIX PENTRU HEADERS (stdlib.h, wchar.h, etc.)
      # SDKROOT este variabila standard pe macOS pentru a indica locația headerelor
      export SDKROOT="#{sdk_path}"
      
      # Forțăm căile de include pentru GCC
      export CPATH="#{sdk_path}/usr/include"
      export CPLUS_INCLUDE_PATH="#{sdk_path}/usr/include/c++/v1:#{sdk_path}/usr/include"
      export LIBRARY_PATH="#{sdk_path}/usr/lib"

      # 4. Setăm restul mediului
      export CMOD_CXX="#{gcc_bin}/g++-11"
      export CMOD_CC="#{gcc_bin}/gcc-11"
      export PATH="$SHADOW_BIN:#{gcc_bin}:$PATH"
      
      # 5. Executăm scriptul Python
      "#{python_bin}" "#{libexec}/cmod.py" "$@"
      
      # 6. Curățăm
      EXIT_CODE=$?
      rm -rf "$SHADOW_BIN"
      exit $EXIT_CODE
    EOS

    chmod 0755, bin/"cmod"
  end

  test do
    # Test simplu pentru a vedea dacă găsește stdlib.h
    (testpath/"test.cpp").write <<~EOS
      #include <stdlib.h>
      #include <stdio.h>
      int main() { return 0; }
    EOS
    
    system "#{bin}/cmod", "init"
    # Simulăm un build manual prin wrapper pentru testare
    system "PATH=#{bin}:$PATH", "g++", "test.cpp", "-o", "test_out"
  end
end