class Cmod < Formula
  desc "Simple C/C++ modular build system"
  homepage "https://github.com/AntohiRobert/cmod"
  url "https://github.com/AntohiRobert/cmod/archive/refs/heads/main.tar.gz"
  version "0.1.1"
  sha256 "440a1f2817a44218d907a0780bfce500dfee138b46fcaf4dc6fba7e5e59ede0d"

  depends_on "python@3.12"
  depends_on "gcc@12"
  depends_on "git"

  def install
    # 1. Identificăm căile sigure către Python și GCC
    python_bin = Formula["python@3.12"].opt_bin/"python3.12"
    gcc_bin = Formula["gcc@11"].opt_bin

    # 2. Instalăm scriptul în libexec (locație izolată)
    libexec.install "cmod.py"

    # 3. Creăm wrapper-ul inteligent
    (bin/"cmod").write <<~EOS
      #!/bin/bash
      
      # --- FIX MACOS HEADERS (stdlib.h, stdio.h, etc.) ---
      if [[ "$(uname)" == "Darwin" ]]; then
        # Găsim calea către SDK-ul macOS actual
        export SDKROOT=$(xcrun --show-sdk-path 2>/dev/null)
        
        # Forțăm GCC să caute în SDK-ul Apple
        export CPATH="$SDKROOT/usr/include"
        export LIBRARY_PATH="$SDKROOT/usr/lib"
        
        # Adăugăm flag-uri pentru C++ standard headers din SDK
        export CPLUS_INCLUDE_PATH="$SDKROOT/usr/include/c++/v1:$CPATH"
      fi

      # --- FIX GCC MAPPING ---
      # Creăm un folder temporar pentru a mapa 'g++' -> 'g++-11'
      # Astfel cmod.py va găsi GCC 11 chiar dacă caută doar 'g++'
      SHADOW_BIN=$(mktemp -d)
      ln -s "#{gcc_bin}/g++-12" "$SHADOW_BIN/g++"
      ln -s "#{gcc_bin}/gcc-12" "$SHADOW_BIN/gcc"
      
      export PATH="$SHADOW_BIN:#{gcc_bin}:$PATH"
      export CMOD_CXX="#{gcc_bin}/g++-12"
      export CMOD_CC="#{gcc_bin}/gcc-12"

      # --- EXECUȚIE ---
      # Folosim binarul de python specificat pentru a evita "command not found"
      "#{python_bin}" "#{libexec}/cmod.py" "$@"
      
      # Cleanup la ieșire
      EXIT_CODE=$?
      rm -rf "$SHADOW_BIN"
      exit $EXIT_CODE
    EOS

    chmod 0755, bin/"cmod"
  end

  test do
    system "#{bin}/cmod", "init"
    assert_predicate testpath/"cmodconfig.json", :exist?
  end
end