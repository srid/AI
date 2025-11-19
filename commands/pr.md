# PR Command

Create and open a draft pull request on GitHub for the current branch.

## Workflow

1. **Gather Information**
   - Get the current branch name using `git branch --show-current`
   - Get the default branch (usually `main` or `master`) using `git remote show origin | grep 'HEAD branch'`
   - Analyze the diff from the default branch to understand all changes (ignore individual commits)
   - Review changed files to understand the scope of changes

2. **Generate PR Content**
   - Create a descriptive title that summarizes the changes
   - Write a concise description that explains WHAT changed and WHY from a high-level perspective
   - Focus on user-facing changes and behavior, not implementation details
   - Use natural language without overly structured sections
   - Keep it brief - a few sentences to a short paragraph is usually enough

3. **Get User Confirmation**
   - Present the proposed PR title and description to the user
   - Ask for confirmation or request modifications
   - Allow the user to edit the title or description before proceeding

4. **Create Draft PR**
   - Once confirmed, use the `gh` CLI to create a draft PR:
     ```bash
     gh pr create --draft --title "TITLE" --body "DESCRIPTION"
     ```
   - Report the PR URL to the user

## Requirements

- The `gh` CLI must be installed and authenticated (if not installed, use `nix run nixpkgs#gh` to run it)
- The repository must have a remote configured on GitHub
- The current branch must have commits that aren't in the default branch

## Example Output Format

```markdown
PR Title: Add OAuth authentication

PR Description:
Adds OAuth login support for Google and GitHub. Users can now authenticate using their existing accounts from these providers. The password reset flow has also been improved with clearer email notifications.
```

## Notes

- Always create as a **draft** PR initially so the user can make further changes if needed
- If the branch name follows a convention (e.g., `feature/`, `fix/`), incorporate that context into the title
- If there are uncommitted changes, warn the user before proceeding
