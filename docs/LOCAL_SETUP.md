# Yoelvis’s local setup

- Fork: https://github.com/ymulenll/tandem
- Clone: ~/Developer/content-creation/tandem
- App: ~/Applications/Tandem.app
- Launcher: ~/.local/bin/tandem
- Projects: ~/Developer/content-creation/recordings/<project>/
- Spanish transcripts: es-ES, on-device SpeechAnalyzer. English can use Bark.
- Upstream crash reporting is disabled. Filmora imports only rewrite paths explicitly supplied.
- Historical Decision Models recipes remain examples and contain Mike’s media paths.

## Open the verified demo

```bash
tandem app "$HOME/Developer/content-creation/recordings/Tandem Demo/Tandem Demo.tandem"
```

The demo links to the successful iPhone and screen take in Setup Test/source.
The originals are unchanged. Both videos are on a linked timeline, side by side,
with the camera’s audio on Voice. The single empty first frame is trimmed in the project.
The app completed a 13-word transcript with the configured Spanish analysis settings.
The brief test take contains English test speech; this verifies the pipeline, not Spanish transcription accuracy.

## Verification on 2026-11-16

The full `swift test` suite passes: 2,497 tests counted, 63 skipped by the
suite’s opt-in or environment checks, zero failures. Installer tests and shell
syntax checks pass. The rebuilt signed app opened the saved demo and played it.

The original pending issues are resolved:

- Playback-start timing checks pass with MacBook speakers as the output after
  Bluetooth headphones were disconnected. No timing assertions were relaxed.
- Vision cutout shutdown now waits for decoder and processing workers before
  the job cleans up. A deterministic held-frame regression failed before the
  fix and passes now, as does the real matte-cancellation test in the full suite.
- The Ogg fixture uses FFmpeg’s native Vorbis encoder, so it does not require
  an optional libvorbis encoder. Actual Ogg decoding and normalization pass.
- English Bark fallback fixtures explicitly select English, independently of
  the app’s Spanish default.

Full validation also exposed dark semi-transparent overlay previews. The
straight-alpha scaling path now resamples with explicit premultiplication and
restores straight alpha afterward, preserving both colour and soft edges.
Coverage includes ProRes, HEVC-with-alpha and QuickTime Animation previews and
playback. Only alpha preview caches change version; ordinary camera and screen
previews retain their existing cache keys.

No paid services were used. Optional live-provider, real-footage and model
integration tests remain subject to their existing opt-in requirements.
