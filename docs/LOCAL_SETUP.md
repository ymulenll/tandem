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

Installer tests and shell syntax checks passed. Nine targeted tests passed for
personal defaults, transcript-engine selection, crash reporting, import defaults,
and new-project guidance. Release and debug app builds succeeded. Playback was
observed in the staged app; validation and a 305-frame render check found no problems.

The full Swift suite was run and did not pass:

- Four playback-start timing assertions exceeded limits (roughly 0.3 seconds on this setup).
- Apple Vision crashed inside person segmentation during a matte-cancellation test.
- An Ogg fixture requires libvorbis, which this FFmpeg build does not include.

The demo uses no background cutout. Cutout reliability needs further investigation
before relying on it for an important edit. The optional speech-model integration
test was not enabled. No paid asset or generation services were used.
