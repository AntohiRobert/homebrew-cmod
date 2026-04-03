class Cmod < Formula
  desc "Simple C/C++ modular build system"
  homepage "https://github.com/AntohiRobert/cmod"
  url "https://github.com/AntohiRobert/cmod/archive/refs/heads/main.tar.gz"
  version "0.1.0"


  depends_on "python@3.12"

  depends_on "git"

  depends_on "gcc@11"

  def install
  chmod 0755, "cmod.py"

  gcc=Formula["gcc@11"]
  ENV["CC"] = Formula["gcc@11"].opt_bin/"gcc-11"
  ENV["CXX"] = Formula["gcc@11"].opt_bin/"g++-11"

  bin.install "cmod.py" => "cmod"
  end

  test do
    system "#{bin}/cmod", "init"
    assert_predicate testpath/"cmodconfig.json", :exist?
  end
end
