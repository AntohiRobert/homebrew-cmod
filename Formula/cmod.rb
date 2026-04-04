class Cmod < Formula
  desc "Simple C/C++ modular build system (GCC 12 enforced)"
  homepage "https://github.com/AntohiRobert/cmod"
  url "https://github.com/AntohiRobert/cmod/archive/refs/heads/main.tar.gz"
  version "0.1.2"
  # sha256 "440a1f2817a44218d907a0780bfce500dfee138b46fcaf4dc6fba7e5e59ede0d"

  depends_on "python@3.12"
  depends_on "gcc@12"
  depends_on "git"

  def install
    python_bin = Formula["python@3.12"].opt_bin/"python3.12"

    libexec.install "cmod.py"

    (bin/"cmod").write <<~EOS
      #!/bin/bash

      # No compiler injection here anymore.
      # GCC 12 is enforced inside cmod.py itself.

      exec "#{python_bin}" "#{libexec}/cmod.py" "$@"
    EOS

    chmod 0755, bin/"cmod"
  end

  test do
    system "#{bin}/cmod", "init"
    assert_predicate testpath/"cmodconfig.json", :exist?
  end
end