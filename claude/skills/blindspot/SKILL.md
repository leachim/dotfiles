---
name: blindspot
description: Surface what I don't know about work in progress. Modes: pass, directions, interview, notes, quiz.
---

# blindspot

`/blindspot [mode] [topic]` — default `pass`.

All modes:
- Read the current diff and files. Don't answer from memory of the conversation.
- No reassurance, no recap of what went well.
- Empty section → one line saying so. Don't pad.
- Order by cost of being wrong.

## pass
Max 10 items:
- decided without asking
- assumptions baked into the code
- what will surprise you later
- what I skipped
- what I asserted but didn't verify

## directions
4–6 options that differ in kind. Two options sharing a data model and a module boundary count as one.
Must include: do nothing (with its real cost), one that deletes instead of adds, one overkill, one too crude.
End with a pick and what would change it.

## interview
3–5 questions, one batch. A question qualifies only if different answers change the work.
Each question: "if X → A, if Y → B", plus a default so it can be skipped.
Never ask what the repo already answers.

## notes
Append to implementation-notes.md as you go, only for decisions with a live alternative:

    <date> <decision>
    ambiguous:
    chose:
    because:
    instead of:
    reverse by:

## quiz
One question at a time. Target places where a wrong model causes later damage.
Grade honestly. Show the code or output that settles it.
