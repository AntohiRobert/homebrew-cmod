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
    # Folosim variabila specifica pentru versiunea 11
    gcc_formula = Formula["gcc@11"]
    gcc_bin = gcc_formula.opt_bin
    
    # Homebrew instaleaza binarul ca python3.12 in folderul opt_bin al python@3.12
    python_bin = Formula["python@3.12"].opt_bin/"python3.12"

    # Mutam scriptul in libexec
    libexec.install "cmod.py"

    (bin/"cmod").write <<~EOS
      #!/bin/bash
      # Setam mediul pentru GCC 11
      export CMOD_CXX="#{gcc_bin}/g++-11"
      export CMOD_CC="#{gcc_bin}/gcc-11"
      
      # Injectam GCC 11 in PATH ca sa fie gasit daca scriptul apeleaza simplu 'g++'
      export PATH="#{gcc_bin}:$PATH"

      exec "#{python_bin}" "#{libexec}/cmod.py" "$@"
    EOS

    chmod 0755, bin/"cmod"
  end

  test do
    # Ne asiguram ca testul ruleaza intr-un folder curat
    system "#{bin}/cmod", "init"
    assert_predicate testpath/"cmodconfig.json", :exist?
    
    # Verificam ca gcc-11 este accesibil
    system Formula["gcc@11"].opt_bin/"g++-11", "--version"
  end
end