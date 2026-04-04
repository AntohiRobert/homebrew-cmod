class Cmod < Formula
  desc "Simple C/C++ modular build system (GCC 12 enforced)"
  homepage "https://github.com/AntohiRobert/cmod"

  head do
    url "https://github.com/AntohiRobert/cmod.git"
    branch "main"
  end

  depends_on "python@3.12"
  depends_on "gcc@12"
  depends_on "git"

  def install
    libexec.install "cmod.py"

    python = Formula["python@3.12"].opt_bin/"python3.12"

    (bin/"cmod").write <<~EOS
      #!/bin/bash
      exec "#{python}" "#{libexec}/cmod.py" "$@"
    EOS

    chmod 0755, bin/"cmod"
  end

  test do
    system "#{bin}/cmod", "init"
  end
end