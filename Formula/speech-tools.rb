class SpeechTools < Formula
  desc "C++ speech software library from the University of Edinburgh"
  homepage "http://festvox.org/docs/speech_tools-2.4.0/"
  url "http://festvox.org/packed/festival/2.5/speech_tools-2.5.0-release.tar.gz"
  sha256 "e4fd97ed78f14464358d09f36dfe91bc1721b7c0fa6503e04364fb5847805dcc"
  revision 1
  head "https://github.com/festvox/speech_tools.git"

  livecheck do
    url "http://festvox.org/packed/festival/?C=M&O=D"
    regex(%r{href=.*?(\d+(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "88ed5cfcaf1234243702c543cff1d41471292dcf40a00ac6c5d4bd269c02de26" => :catalina
    sha256 "49b05f1d4894a23065205b57ea9bb9eeef8e0e8b96a82a7457719197fdce9c56" => :mojave
    sha256 "b43389631b881f76529aa4458442b819dc5be784afbf5569f9e526ce3dc7e028" => :high_sierra
    sha256 "4d3681ee2194a92fcbad96371c499f5c2a71c59cfe8798b8092f0e57f793fca3" => :sierra
    sha256 "a0794d1d7f424833d2fe92726d26b6ebcc8dcf63b7f9700b19e1119ed7e2ca62" => :el_capitan
  end

  depends_on "libomp"

  uses_from_macos "ncurses"

  conflicts_with "align", because: "both install `align` binaries"

  def install
    ENV.deparallelize
    # Xcode doesn't include OpenMP directly any more, but with these
    # flags we can force the compiler to use the libomp we provided
    # as a dependency.  Normally you can force this on autoconf by
    # setting "ac_cv_prog_cxx_openmp" and "LIBS", but this configure
    # script does OpenMP its own way so we need to actually edit the script:
    inreplace "configure", "-fopenmp", "-Xpreprocessor -fopenmp -lomp"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    # install all executable files in "main" directory
    bin.install Dir["main/*"].select { |f| File.file?(f) && File.executable?(f) }
  end

  test do
    rate_hz = 16000
    frequency_hz = 100
    duration_secs = 5
    basename = "sine"
    txtfile = "#{basename}.txt"
    wavfile = "#{basename}.wav"
    ptcfile = "#{basename}.ptc"

    File.open(txtfile, "w") do |f|
      scale = 2 ** 15 - 1
      samples = Array.new(duration_secs * rate_hz) do |i|
        (scale * Math.sin(frequency_hz * 2 * Math::PI * i / rate_hz)).to_i
      end
      f.puts samples
    end

    # convert to wav format using ch_wave
    system bin/"ch_wave", txtfile,
      "-itype", "raw",
      "-istype", "ascii",
      "-f", rate_hz.to_s,
      "-o", wavfile,
      "-otype", "riff"

    # pitch tracking to est format using pda
    system bin/"pda", wavfile,
      "-shift", (1 / frequency_hz.to_f).to_s,
      "-o", ptcfile,
      "-otype", "est"

    # extract one frame from the middle using ch_track, capturing stdout
    pitch = shell_output("#{bin}/ch_track #{ptcfile} -from #{frequency_hz * duration_secs / 2} " \
                                                    "-to #{frequency_hz * duration_secs / 2}")

    # should be 100 (Hz)
    assert_equal frequency_hz, pitch.to_i
  end
end
