---
description: Implement a plan from a markdown file, commit each logical step, then review and fix
agent: build
---

Implement the plan described in $ARGUMENTS

Rules:
- Follow the plan and implement it in a logical order that makes technical sense
- After each logical unit of work, create a git commit with a concise but descriptive message
- Do not squash unrelated changes into one commit

When implementation is complete:
1. Invoke the review subagent to review the changes
2. Wait for findings
3. Fix any blockers and suggestions from the review
4. Run tests and typecheck to confirm everything passes
5. If applicable, output a short manual testing guide with concrete scenarios the user can run through to verify the feature works end-to-end
