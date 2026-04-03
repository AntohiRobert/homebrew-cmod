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
    # Identificăm căile corecte
    gcc_bin = Formula["gcc@11"].opt_bin
    python_bin = Formula["python@3.12"].opt_bin/"python3.12"

    # Instalăm scriptul original într-o zonă privată
    libexec.install "cmod.py"

    # Creăm wrapper-ul care forțează prioritizarea GCC
    (bin/"cmod").write <<~EOS
      #!/bin/bash
      # 1. Creăm un folder temporar pentru symlink-uri (shadowing)
      SHADOW_BIN=$(mktemp -d)
      
      # 2. Mapăm g++ și gcc la versiunile de la Homebrew (GCC 11)
      ln -s "#{gcc_bin}/g++-11" "$SHADOW_BIN/g++"
      ln -s "#{gcc_bin}/gcc-11" "$SHADOW_BIN/gcc"
      ln -s "#{gcc_bin}/c++-11" "$SHADOW_BIN/c++"
      
      # 3. Exportăm variabilele de mediu și punem SHADOW_BIN primul în PATH
      export CMOD_CXX="#{gcc_bin}/g++-11"
      export CMOD_CC="#{gcc_bin}/gcc-11"
      export PATH="$SHADOW_BIN:#{gcc_bin}:$PATH"
      
      # 4. Executăm scriptul Python
      "#{python_bin}" "#{libexec}/cmod.py" "$@"
      
      # 5. Curățăm folderul temporar
      EXIT_CODE=$?
      rm -rf "$SHADOW_BIN"
      exit $EXIT_CODE
    EOS

    chmod 0755, bin/"cmod"
  end

  test do
    system "#{bin}/cmod", "init"
    # Testăm dacă binarul g++ raportat de sistem este cel de la GCC (nu Apple)
    # Rulăm g++ prin wrapper ca să vedem ce versiune "vede" cmod
    output = shell_output("PATH=#{bin}:$PATH g++ --version")
    assert_match "Homebrew GCC", output
  end
end