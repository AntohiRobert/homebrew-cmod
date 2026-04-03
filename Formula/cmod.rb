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
    gcc_formula = Formula["gcc@11"]
    gcc_bin = gcc_formula.opt_bin
    python_bin = Formula["python@3.12"].opt_bin/"python3.12"

    libexec.install "cmod.py"

    # Logica specifica pentru macOS vs Linux
    extra_env = ""
    if OS.mac?
      sdk_path = `xcrun --show-sdk-path`.strip
      extra_env = <<~EOS
        export SDKROOT="#{sdk_path}"
        export CPATH="#{sdk_path}/usr/include"
        export CPLUS_INCLUDE_PATH="#{sdk_path}/usr/include/c++/v1:#{sdk_path}/usr/include"
        export LIBRARY_PATH="#{sdk_path}/usr/lib"
      EOS
    end

    # Wrapper-ul universal
    (bin/"cmod").write <<~EOS
      #!/bin/bash
      # 1. Shadowing binari pentru a forta g++-11 ca "g++"
      SHADOW_BIN=$(mktemp -d)
      ln -s "#{gcc_bin}/g++-11" "$SHADOW_BIN/g++"
      ln -s "#{gcc_bin}/gcc-11" "$SHADOW_BIN/gcc"
      
      # 2. Injectare variabile de mediu (doar pe macOS daca e cazul)
      #{extra_env}

      # 3. Setare mediu CMOD si PATH
      export CMOD_CXX="#{gcc_bin}/g++-11"
      export CMOD_CC="#{gcc_bin}/gcc-11"
      export PATH="$SHADOW_BIN:#{gcc_bin}:$PATH"
      
      # 4. Executare script Python
      "#{python_bin}" "#{libexec}/cmod.py" "$@"
      
      # 5. Cleanup
      EXIT_CODE=$?
      rm -rf "$SHADOW_BIN"
      exit $EXIT_CODE
    EOS

    chmod 0755, bin/"cmod"
  end

  test do
    # Test cross-platform: verifica daca init functioneaza
    system "#{bin}/cmod", "init"
    assert_predicate testpath/"cmodconfig.json", :exist?
    
    # Verifica daca compilatorul raportat este cel corect (GCC 11)
    output = shell_output("PATH=#{bin}:$PATH g++ --version")
    assert_match "11.", output
  end
end