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
    # 1. Referințe către dependențe
    gcc_bin = Formula["gcc@12"].opt_bin
    python_bin = Formula["python@3.12"].opt_bin/"python3.12"

    # 2. Mutăm scriptul sursă în libexec (izolare)
    libexec.install "cmod.py"

    # 3. Creăm wrapper-ul folosind utilitarul nativ Homebrew
    # Acesta va genera automat un script în bin/cmod
    (bin/"cmod").write_env_script python_bin, "#{libexec}/cmod.py",
      # Setăm variabilele de mediu necesare
      CMOD_CXX: "#{gcc_bin}/g++-12",
      CMOD_CC:  "#{gcc_bin}/gcc-12",
      # Adăugăm folderul GCC în PATH (pentru a fi găsit g++-12)
      PATH:     "#{gcc_bin}:$PATH",
      # Pe macOS, injectăm SDKROOT pentru stdlib.h/stdio.h
      SDKROOT:  OS.mac? ? "$(xcrun --show-sdk-path)" : nil

    # Nota: write_env_script se ocupă automat de chmod 0755
  end

  test do
    # Ne asigurăm că mediul de test este curat
    cd testpath do
      system "#{bin}/cmod", "init"
      assert_predicate Pathname.new("cmodconfig.json"), :exist?, "cmod init nu a creat config-ul!"
    end
  end
end