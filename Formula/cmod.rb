class Cmod < Formula
  desc "Simple C/C++ modular build system"
  homepage "https://github.com/AntohiRobert/cmod"
  url "https://github.com/AntohiRobert/cmod/archive/refs/heads/main.tar.gz"
  version "0.1.1" # Incrementăm versiunea pentru schimbarile de mediu
  sha256 "440a1f2817a44218d907a0780bfce500dfee138b46fcaf4dc6fba7e5e59ede0d"

  depends_on "python@3.12"
  depends_on "gcc@11"
  depends_on "git"

  def install
    # 1. Identificăm binarul de Python (Homebrew folosește python3.12 pentru această formulă)
    python_formula = Formula["python@3.12"]
    # Căutăm binarul exact pentru a evita eroarea "no such file"
    python_bin = python_formula.opt_bin/"python3.12"
    
    # 2. Identificăm căile pentru GCC 11
    gcc_formula = Formula["gcc@11"]
    gcc_bin = gcc_formula.opt_bin
    gcc_lib = gcc_formula.opt_lib/"gcc/11"

    # 3. Instalăm scriptul sursă într-o locație privată (libexec)
    libexec.install "cmod.py"

    # 4. Creăm wrapper-ul care injectează căile de sistem
    (bin/"cmod").write <<~EOS
      #!/bin/bash
      
      # FIX PENTRU MACOS: Injectăm SDK Path pentru a găsi stdio.h, stdlib.h etc.
      if [[ "$(uname)" == "Darwin" ]]; then
        export SDKROOT=$(xcrun --show-sdk-path 2>/dev/null)
        export CPATH="$SDKROOT/usr/include"
        export LIBRARY_PATH="$SDKROOT/usr/lib"
        # Adăugăm și căile specifice C++ pentru Homebrew GCC
        export CPLUS_INCLUDE_PATH="#{gcc_lib}/include/c++:#{gcc_lib}/include/c++/x86_64-apple-darwin#{`uname -r`.strip.split('.')[0]}:$CPATH"
      fi

      # FIX PENTRU PYTHON: Folosim calea absolută determinată la instalare
      PYTHON_EXEC="#{python_bin}"
      
      # Setăm mediul pentru cmod.py
      export CMOD_CXX="#{gcc_bin}/g++-11"
      export CMOD_CC="#{gcc_bin}/gcc-11"
      
      # Shadowing: Punem folderul GCC 11 primul în PATH pentru ca 'g++' să fie găsit corect
      # Creăm un alias temporar pentru g++ dacă este necesar
      TMP_BIN=$(mktemp -d)
      ln -s "#{gcc_bin}/g++-11" "$TMP_BIN/g++"
      ln -s "#{gcc_bin}/gcc-11" "$TMP_BIN/gcc"
      
      export PATH="$TMP_BIN:#{gcc_bin}:$PATH"

      # Executăm scriptul
      "$PYTHON_EXEC" "#{libexec}/cmod.py" "$@"
      
      # Curățăm folderul temporar
      EXIT_CODE=$?
      rm -rf "$TMP_BIN"
      exit $EXIT_CODE
    EOS

    # Asigurăm drepturile de execuție
    chmod 0755, bin/"cmod"
  end

  test do
    # Verificăm dacă init funcționează fără erori de Python
    system "#{bin}/cmod", "init"
    assert_predicate testpath/"cmodconfig.json", :exist?
    
    # Verificăm dacă wrapper-ul injectează corect g++
    output = shell_output("#{bin}/cmod usage")
    assert_match "Usage scenario", output
  end
end