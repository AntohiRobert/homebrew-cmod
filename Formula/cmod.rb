class Cmod < Formula
  desc "Simple C/C++ modular build system"
  homepage "https://github.com/AntohiRobert/cmod"
  url "https://github.com/AntohiRobert/cmod/archive/refs/heads/main.tar.gz"
  version "0.1.0"

  depends_on "python@3.12"
  depends_on "git"
  depends_on "gcc@11"

  def install
    # 1. Instalăm scriptul python original într-o locație privată (libexec)
    libexec.install "cmod.py"

    # 2. Creăm un wrapper în bin/cmod care setează PATH-ul înainte de execuție
    # Acest wrapper va pune folderul bin de la GCC 11 în fața /usr/bin
    # și va crea un alias temporar (symlink) de la g++-11 la g++
    
    gcc_bin = Formula["gcc@11"].opt_bin
    
    (bin/"cmod").write <<~EOS
      #!/bin/bash
      # Creăm un folder temporar pentru a face maparea g++ -> g++-11
      temp_bin=$(mktemp -d)
      ln -s "#{gcc_bin}/g++-11" "$temp_bin/g++"
      ln -s "#{gcc_bin}/gcc-11" "$temp_bin/gcc"
      
      # Executăm scriptul python cu noul PATH setat
      PATH="$temp_bin:#{gcc_bin}:$PATH" #{Formula["python@3.12"].opt_bin}/python3.12 "#{libexec}/cmod.py" "$@"
      
      # Curățăm folderul temporar după execuție
      rm -rf "$temp_bin"
    EOS

    chmod 0755, bin/"cmod"
  end

  test do
    system "#{bin}/cmod", "init"
    # Verificăm că a rămas "g++" curat în config
    assert_match '"command": "g++ -fmodules-ts"', File.read("cmodconfig.json")
    assert_predicate testpath/"cmodconfig.json", :exist?
  end
end