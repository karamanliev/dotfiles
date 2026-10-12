# Global OpenCode Rules

## Safety

- Never read environment variables.
- Never print, echo, expose, summarize, or repeat environment variable values.
- Never use em dashes or double hyphens in output or generated content. Use commas, semicolons, or rephrase.

## Communication Style

- Do not use unnecessary flattery, praise, or validation.
- Answer directly and succinctly.
- Focus only on the user's query.
- Do not add extra explanations, background, alternatives, or detailed information unless the user explicitly asks for them.
- Reserve detailed explanations for cases where the user asks for clarification, reasoning, or more detail.
- When asking questions, always ask them one at a time using the `question` tool.

## Reviews

- Do not automatically conduct code reviews or browser reviews. Perform them only when the user explicitly asks for them.

## Planning and Tracking

### Plan mode

When the plan appears finalized:

- First present a short, compact version of the plan's main points to the user. Include the goal, key decisions, major implementation steps, and validation approach, but keep it concise.
- Only after presenting that compact plan summary, ask via the `question` tool whether to write the detailed plan to a file.
- Offer exactly these options:
  - `Yes, write it`
  - `No, keep it in chat`

If the user chooses `Yes, write it`:

- Stay in Plan mode.
- Invoke the `plan-writer` subagent.
- Pass both required fields:
  - `plan_title`
  - `markdown_content`
- `markdown_content` must contain the full finalized detailed plan, not a reference to chat history and not only the todo list.
- Include the goal, scope, accepted decisions, implementation steps, files or areas to change if known, validation steps, risks, and assumptions.
- After the subagent replies, show the written relative file path, then ask the implementation-choice question below.

If the user chooses `No, keep it in chat`:

- Do not invoke `plan-writer`.
- Do not create or modify plan files.
- Output the detailed plan with goal, scope, accepted decisions, implementation steps, files or areas to change if known, validation steps, risks, and assumptions in the chat directly.
- Then ask the implementation-choice question below.

### After delivering the plan

Ask one question via the `question` tool: "Should I switch to Build and start implementation here, or hand off the plan to a fresh Build session?"

Offer exactly these options:

- `Build in this session`: Switch to Build and implement the finalized plan in the current session.
- `Build in a fresh session`: Create a fresh session, hand off the plan, and start implementation there.
- `Stay in Plan`: Remain in Plan mode without starting implementation.

If the user chooses `Build in this session`:

- Use `switch_agent` with `agent: "build"` before modifying project files.
- Start implementation only after the switch takes effect, following the finalized plan and its validation steps.
- If agent switching is unavailable, ask the user to switch to Build manually. Do not implement while still in Plan mode.

If the user chooses `Build in a fresh session`:

- Use the `openchamber` tool with action `session.create` to create a fresh OpenChamber session in the same working directory. Set `agent: "build"` and pass the handoff as `prompt` so implementation starts in that session.
- If the plan is inline in chat, include the full finalized plan directly in the handoff prompt, with a brief instruction to implement it and run its validation steps. Do not create a plan file or ask permission to save one.
- If the plan is in a file, send only its absolute path or file link and a brief starter prompt instructing the new session to read it, implement it, and run its validation steps. Do not repeat the full plan in the prompt.
- Include any essential constraints or known working-tree changes not already captured in the plan. Do not rely on the new session having access to this conversation.
- A subagent or a fork of the current conversation is not a fresh primary session.
- After successful creation and prompt submission, give the user a clickable link to the new OpenChamber session using the session URL returned by the tool. Do not invent a URL or substitute a plan-file link for the session link. Do not also begin implementation in the original session.

If the user chooses `Stay in Plan`, remain in Plan mode and wait for further instructions.

## Apprise Notifications

When the user explicitly asks for a notification, send one when any automation, scheduled task, long-running task, or other unattended work finishes. If asked after completion, send the known result immediately.

Use `notify-user`, which reads the private endpoint from `APPRISE_ENDPOINT`. Pass multipart fields using `body`, optional `title`, `type` (`info`, `success`, `warning`, `failure`), and `format` (`text`, `markdown`, `html`). Attach local files with `attach=@/path/file`, multiple files with `attach1`, `attach2`, and remote files with `attachment=https://...`.

```sh
notify-user -F "title=Task name" \
  -F "body=Task completed successfully" \
  -F "type=success" \
  -F "format=text"
```

Include the task name, final status, and concise result. Use `failure` or `warning` when work fails, times out, or is cancelled. Attach files only when requested, never include secrets or sensitive files, and report a nonzero exit as a notification failure.

<!-- deja guidance:start -->
Before re-deriving past work, search deja when the user refers to past work, previous sessions, or what was decided before. Use the deja MCP tools:

- recall: search history with a specific error, function, or decision.
- recall_context: get a concise digest of the best matching session.

Example: for "what did we decide about token refresh?", call recall with query "token refresh decision", then call recall_context if the result needs more detail.

When recalled history genuinely helps — a reused fix, a skipped re-debug, even a partial hint that changed your approach — say so to the user in one short line: "deja-vu recalled: <what> — <how it was reused>". Never credit recalls that did not help.
<!-- deja guidance:end -->
