class Ktor < Formula
  desc "Generates Ktor projects through the command-line interface"
  homepage "https://github.com/ktorio/ktor-cli"
  url "https://github.com/ktorio/ktor-cli/archive/refs/tags/0.2.1.tar.gz"
  sha256 "63a98fe44f912c9305e513d7c0428e06afdeb0f35c2088b1d500c9c9235f5226"
  license "Apache-2.0"
  head "https://github.com/ktorio/ktor-cli.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia:  "e2477ed41bf2cfe39653ddc1e61cd370eb8a79574798621aef5c3adfed537661"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "e2477ed41bf2cfe39653ddc1e61cd370eb8a79574798621aef5c3adfed537661"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "e2477ed41bf2cfe39653ddc1e61cd370eb8a79574798621aef5c3adfed537661"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "e2477ed41bf2cfe39653ddc1e61cd370eb8a79574798621aef5c3adfed537661"
    sha256 cellar: :any_skip_relocation, sonoma:         "0eb5d96c0bafe248c56d9434420403cf7e3d106aaf4da2397d2a090ce84cf787"
    sha256 cellar: :any_skip_relocation, ventura:        "0eb5d96c0bafe248c56d9434420403cf7e3d106aaf4da2397d2a090ce84cf787"
    sha256 cellar: :any_skip_relocation, monterey:       "0eb5d96c0bafe248c56d9434420403cf7e3d106aaf4da2397d2a090ce84cf787"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "6ed8ea3a6a761a8f040b936e3cb4ee5a6a95e02989cc94dd1837fcbdbd3a3172"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = "-X main.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:), "github.com/ktorio/ktor-cli/cmd/ktor"
  end

  test do
    assert_match "Ktor CLI version #{version}", shell_output("#{bin}/ktor --version")
    assert_match "Ktor CLI version #{version}", shell_output("#{bin}/ktor version")
    system bin/"ktor", "new", "project"
    assert_path_exists testpath/"project/build.gradle.kts"
    assert_path_exists testpath/"project/settings.gradle.kts"
    assert_path_exists testpath/"project/gradle.properties"
    assert_path_exists testpath/"project/src"
    assert_path_exists testpath/"project/gradle"
  end
end
