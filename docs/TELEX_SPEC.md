# Vietnamese Telex specification

Build a deterministic offline composer that emits abstract text edits. UI and `UITextDocumentProxy` stay outside it.

| Input | Result |
| --- | --- |
| `aa` / `aw` | `â` / `ă` |
| `dd` | `đ` |
| `ee` / `oo` | `ê` / `ô` |
| `ow` / `uw` | `ơ` / `ư` |

Support delayed `w` placement after the remaining letters of the active word, for example `vuongw` → `vương`, while keeping `w` literal when no eligible `a/o/u` nucleus exists.
Normalize a partially marked `ưo` nucleus to `ươ`, so both direct `vưong` and Telex-order `vuwong` render as `vương`; preserve case and tolerate a redundant `w` after an already normalized quality vowel.

Tone keys: `s` acute, `f` grave, `r` hook, `x` tilde, `j` dot below; `z` removes a Telex mark. Preserve case. Interpret a key as Telex only with a valid target; otherwise keep it literal. Repeating the active mark removes/toggles it; another tone replaces it. Cover all behavior with tables.

## Modern tone placement

Identify the vowel nucleus after quality modifiers; prefer marked vowels (`ă â ê ô ơ ư`) where linguistically applicable; handle `qu`/`gi` onsets; apply modern placement for open clusters such as `oa`, `oe`, and `uy`; preserve case and normalize NFC at the document boundary.

Required corpus includes `tiếng`, `Việt`, `đường`, `trường`, `nguyễn`, `hòa`, `khỏe`, `thủy`, `quốc`, plus title/uppercase variants, each with keystroke sequence and expected output.

Whitespace/punctuation ends composition. Be conservative for URLs, emails, code-like and mixed tokens. Backspace edits active composition then reconciles rendering. When `documentContextBeforeInput` is missing, truncated, or changed, rebuild bounded state or degrade to literal safe input. Never persist composed text.

Tests cover every modifier/tone, case, replacement/removal, repeats, boundaries, backspace, cursor/context mismatch, nil/truncated context, NFC output, real words, and deterministic exactly-once edits.
