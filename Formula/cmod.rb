class Cmod < Formula
  desc "Simple C/C++ modular build system"
  homepage "https://github.com/AntohiRobert/cmod"
  url "https://github.com/AntohiRobert/cmod/archive/refs/heads/main.tar.gz"
  version "0.1.2"
  #sha256 "440a1f2817a44218d907a0780bfce500dfee138b46fcaf4dc6fba7e5e59ede0d"

  depends_on "python@3.12"
  depends_on "gcc@12"
  depends_on "git"

  def install
    # Identificăm căile corecte (Folosim GCC 12 constant)
    gcc_formula = Formula["gcc@12"]
    gcc_bin = gcc_formula.opt_bin
    python_bin = Formula["python@3.12"].opt_bin/"python3.12"

    libexec.install "cmod.py"

    (bin/"cmod").write <<~EOS
      #!/bin/bash
      
      # 1. Shadowing binari într-un folder temporar
      SHADOW_BIN=$(mktemp -d)
      
      # 2. Configurare mediu pentru macOS vs Linux
      if [[ "$(uname)" == "Darwin" ]]; then
        # Pe Mac, avem nevoie de SDK Path pentru headerele C (stdio.h etc.)
        # DAR nu forțăm CPLUS_INCLUDE_PATH pentru a evita erorile de allocator
        export SDKROOT=$(xcrun --show-sdk-path 2>/dev/null)
        
        # Creăm scripturi wrapper în loc de link-uri simple pentru a injecta sysroot
        # Asta îi spune lui GCC unde sunt headerele de sistem FĂRĂ să le strice pe cele C++
        echo -e "#!/bin/bash\\nexec #{gcc_bin}/g++-12 --sysroot=$SDKROOT \\"\\$@\\"" > "$SHADOW_BIN/g++"
        echo -e "#!/bin/bash\\nexec #{gcc_bin}/gcc-12 --sysroot=$SDKROOT \\"\\$@\\"" > "$SHADOW_BIN/gcc"
        chmod +x "$SHADOW_BIN/g++" "$SHADOW_BIN/gcc"
      else
        # Pe Linux, link-urile simple sunt suficiente
        ln -s "#{gcc_bin}/g++-12" "$SHADOW_BIN/g++"
        ln -s "#{gcc_bin}/gcc-12" "$SHADOW_BIN/gcc"
      fi
      
      # 3. Exportăm variabilele necesare pentru cmod.py
      export CMOD_CXX="$SHADOW_BIN/g++"
      export CMOD_CC="$SHADOW_BIN/gcc"
      export PATH="$SHADOW_BIN:#{gcc_bin}:$PATH"

      # 4. Execuție script Python
      "#{python_bin}" "#{libexec}/cmod.py" "$@"
      
      # 5. Cleanup
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