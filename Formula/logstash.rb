class Logstash < Formula
  desc "Tool for managing events and logs"
  homepage "https://www.elastic.co/products/logstash"
  # Pinned at 6.2.x because of a licencing issue
  # See: https://github.com/Homebrew/homebrew-core/pull/28995
  url "https://artifacts.elastic.co/downloads/logstash/logstash-6.2.4.tar.gz"
  sha256 "4040c2b6a1e9c6908b12885659021a35dca415c6b884cef6938fcc589e94431e"
  head "https://github.com/elastic/logstash.git"

  bottle :unneeded

  depends_on :java => "1.8"

  def install
    if build.head?
      # Build the package from source
      system "rake", "artifact:tar"
      # Extract the package to the current directory
      mkdir "tar"
      system "tar", "--strip-components=1", "-xf", Dir["build/logstash-*.tar.gz"].first, "-C", "tar"
      cd "tar"
    end

    inreplace "bin/logstash",
              %r{^\. "\$\(cd `dirname \${SOURCEPATH}`\/\.\.; pwd\)\/bin\/logstash\.lib\.sh\"},
              ". #{libexec}/bin/logstash.lib.sh"
    inreplace "bin/logstash-plugin",
              %r{^\. "\$\(cd `dirname \$0`\/\.\.; pwd\)\/bin\/logstash\.lib\.sh\"},
              ". #{libexec}/bin/logstash.lib.sh"
    inreplace "bin/logstash.lib.sh",
              /^LOGSTASH_HOME=.*$/,
              "LOGSTASH_HOME=#{libexec}"

    libexec.install Dir["*"]
    bin.install libexec/"bin/logstash", libexec/"bin/logstash-plugin"
    bin.env_script_all_files(libexec/"bin", Language::Java.java_home_env("1.8"))
  end

  def caveats; <<~EOS
    Please read the getting started guide located at:
      https://www.elastic.co/guide/en/logstash/current/getting-started-with-logstash.html
  EOS
  end

  plist_options :manual => "logstash"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>KeepAlive</key>
          <false/>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>ProgramArguments</key>
          <array>
            <string>#{opt_bin}/logstash</string>
          </array>
          <key>EnvironmentVariables</key>
          <dict>
          </dict>
          <key>RunAtLoad</key>
          <true/>
          <key>WorkingDirectory</key>
          <string>#{var}</string>
          <key>StandardErrorPath</key>
          <string>#{var}/log/logstash.log</string>
          <key>StandardOutPath</key>
          <string>#{var}/log/logstash.log</string>
        </dict>
      </plist>
    EOS
  end

  test do
    # workaround https://github.com/elastic/logstash/issues/6378
    (testpath/"config").mkpath
    ["jvm.options", "log4j2.properties", "startup.options"].each do |f|
      cp prefix/"libexec/config/#{f}", testpath/"config"
    end
    (testpath/"config/logstash.yml").write <<~EOS
      path.queue: #{testpath}/queue
    EOS
    (testpath/"data").mkpath
    (testpath/"logs").mkpath
    (testpath/"queue").mkpath

    data = "--path.data=#{testpath}/data"
    logs = "--path.logs=#{testpath}/logs"
    settings = "--path.settings=#{testpath}/config"

    output = pipe_output("#{bin}/logstash -e '' #{data} #{logs} #{settings} --log.level=fatal", "hello world\n")
    assert_match "hello world", output
  end
end
