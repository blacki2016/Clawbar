cask "clawbar" do
  version "0.21.0"
  sha256 "09924bff38abadf7f473d280c5333589440774598fc9694061ba45616a402de5"

  url "https://github.com/blacki2016/Clawbar/releases/download/v#{version}/Clawbar-macOS.zip",
      verified: "github.com/blacki2016/Clawbar/"
  name "Clawbar"
  desc "Menu bar app and CLI for monitoring AI token usage"
  homepage "https://github.com/blacki2016/Clawbar"

  auto_updates true

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: ">= :sonoma"

  app "Clawbar.app"
  binary "#{appdir}/Clawbar.app/Contents/Helpers/clawbar", target: "clawbar"

  caveats do
    <<~EOS
      Clawbar installs the app into /Applications and links the CLI helper as `clawbar`.

      Run `clawbar --help` to get started.
    EOS
  end
end
