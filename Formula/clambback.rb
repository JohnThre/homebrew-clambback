class Clambback < Formula
  desc "C++ network service with TLS transport support"
  homepage "https://github.com/JohnThre/clambback"
  url "https://github.com/JohnThre/clambback/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "401bfe93dbec70ced6eac398a1fd57856d62d134442ffc55dd705b2caf2701a3"
  license "GPL-3.0-or-later"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "openssl@3"

  def install
    args = std_cmake_args + %W[
      -DENABLE_MYSQL=OFF
      -DSYSTEMD_SERVICE=OFF
      -DINSTALL_DEFAULT_CONFIG=OFF
      -DDEFAULT_CONFIG=#{etc}/clambback/config.json
      -DCMAKE_PREFIX_PATH=#{Formula["boost"].opt_prefix};#{Formula["openssl@3"].opt_prefix}
    ]

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    return if (etc/"clambback/config.json").exist?

    (etc/"clambback").install "examples/server.json-example" => "config.json"
  end

  service do
    run [opt_bin/"clambback", etc/"clambback/config.json"]
    keep_alive true
    log_path var/"log/clambback.log"
    error_log_path var/"log/clambback.log"
  end

  test do
    assert_match "Welcome to clambback 0.1.0", shell_output("#{bin}/clambback --version 2>&1")
  end
end
