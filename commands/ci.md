# CI Command

Stage all changes, generate a commit message, and commit after user approval.

## Workflow

1. **Stage All Changes**
   - Run `git add -A` to stage all changes (new files, modifications, deletions)

2. **Show Status and Generate Commit Message**
   - Run `git status` to show what will be committed
   - Analyze the staged changes using `git diff --cached`
   - Generate a concise, descriptive commit message that:
     - Summarizes WHAT changed in a single line (50-72 characters)
     - If needed, adds a brief description of WHY in the body
     - Uses imperative mood (e.g., "Add feature" not "Added feature")
     - Follows conventional commit style if appropriate

3. **Present to User for Approval**
   - Display the generated commit message
   - Show the `git status` output of what will be committed
   - Ask the user to confirm or modify the commit message
   - Allow the user to edit the message before proceeding

4. **Commit Changes**
   - Once approved, run `git commit -m "MESSAGE"` (or `git commit -F -` with multi-line message)
   - Report the commit hash and summary to the user

## Important Constraints

- **NEVER auto-commit**: ALWAYS ask user for approval before running `git commit` - NEVER commit without explicit user confirmation
- **Single commit only**: This command creates exactly ONE new commit on top of the current branch
- **No history rewriting**: Never use `--amend`, `--fixup`, rebase, or reset operations
- **No pushing**: Never run `git push` - commit stays local only
- **No other mutations**: The only git operation is `git commit` to create a single new commit

## Requirements

- Must be in a git repository
- There must be changes to commit (either unstaged or already staged)

## Example Output Format

```markdown
Staged changes:
M  src/app.ts
A  src/utils/helper.ts
D  old-file.js

Proposed commit message:
Add helper utilities and refactor app

Removes deprecated old-file.js and introduces new helper functions
for data validation. Updates app.ts to use the new utilities.

Do you approve this commit message? (yes/no/edit)
```

## Notes

- If there are already staged changes, ask the user if they want to add unstaged changes too
- If there are no changes at all, inform the user and exit
- Keep the commit message clear and focused on the user-facing impact
- The default branch of the commit message should be concise (50-72 chars)
