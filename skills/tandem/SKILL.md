---
name: tandem
description: Edit videos in Yoelvis’s Tandem fork through the tandem command. Use for .tandem projects, trimming, titles, captions, B-roll, sound, review, and exports.
---

# Tandem

Use `tandem` to edit through the shared coordinator, undo history and review flow.
Read `~/Developer/content-creation/tandem/docs/AGENTS.md` for the command index,
then the relevant topic in `docs/agents/`. `tandem help <command>` is authoritative.
The detailed upstream guides include Mike’s editorial preferences and historical
recipes. Treat those as examples, not Yoelvis’s preferences.

## Local setup

- Video projects live under `~/Developer/content-creation/recordings/<project>/`.
- Keep the `.tandem` project beside the `source` folder so Record It takes pair.
- Transcripts default to Spanish through on-device SpeechAnalyzer.
- Use `TANDEM_AUTHOR=codex` or `--author codex` to identify agent edits.
- Run from the project folder or pass `--project <file.tandem>`.
- Optional provider keys belong in macOS Keychain. Never commit private media or keys.

## Editing and review

1. Read `tandem status` and `tandem timeline --summary` before editing.
   If there are unreviewed changes, ask whether to continue, unless the user
   has already authorized continuing that round.
2. Make labelled batches with `tandem apply`, using `--expect` with the revision
   you read. Dry-run complex changes. Never edit project JSON directly.
3. Inspect changed frames or a review clip. Use `tandem cut` for speech edits
   and check joins by sound; transcript timestamps alone are not cut boundaries.
4. Run `tandem check --changed`; include `--cuts` and listen checks when trimming speech.
5. Open the project for review and use `tandem handback` to identify key moments.
   Leave review markers for the user to resolve. Summarize changes and limitations.

Preserve the user’s meaning. Do not impose upstream rules about B-roll quotas,
cutout layouts, pause lengths, music, or pacing without the user’s direction.
Do not call paid providers without specific authorization. Use local files and
on-device analysis for the default workflow.
