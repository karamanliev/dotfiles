# Global OpenCode Rules

- NEVER read environment variables.
- NEVER print, echo, expose, or repeat environment variable values.
- NEVER use em dashes (--) in any output or generated content; use commas, semicolons, or rephrase instead.

## Task Planning & Tracking

**Plan mode (discussing before building):**
- As soon as a task or feature is being planned, immediately create a todo list with all known tasks using the TodoWrite tool.
- Keep the todo list updated throughout the back-and-forth discussion; add, remove, or revise tasks as the plan evolves.
- The todo list is the shared source of truth for what will be built; it should reflect the latest agreed-upon plan at all times.
- After you believe a plan is finalized and output it to the user, ask via the `question` tool whether the user wants the detailed plan written to a file. Offer these options: `Yes, write it`, `No, keep it in chat`, and `I want changes to the plan`.
- If the user chooses `Yes, write it`, stay in Plan mode and invoke the `plan-writer` subagent to write the detailed plan into `.opencode/plans/` in the current project.

**Build mode (actively implementing):**
- Before starting work, ensure the todo list reflects the final agreed plan.
- Mark each task `in_progress` when you start it. Only one task should be `in_progress` at a time.
- Mark each task `completed` immediately after finishing it; do not batch completions.
- If new tasks emerge during implementation, add them to the list before starting them.
