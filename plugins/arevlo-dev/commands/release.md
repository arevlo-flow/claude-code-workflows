---
description: Create a semver release with tag and GitHub release notes
argument-hint: <version> (e.g., v1.0.0, patch, minor, major)
allowed-tools: Bash,AskUserQuestion
---

Create a semantic version release with git tag and GitHub release.

Version argument: $ARGUMENTS

## Steps:

1. **Get latest tag:**
   ```bash
   git describe --tags --abbrev=0 2>/dev/null || echo "none"
   ```

2. **Determine new version:**
   - If argument is `patch`: bump patch (v1.0.0 → v1.0.1)
   - If argument is `minor`: bump minor (v1.0.0 → v1.1.0)
   - If argument is `major`: bump major (v1.0.0 → v2.0.0)
   - If argument is explicit version (e.g., `v1.2.0`): use that
   - If no argument: show latest tag and ask user what to bump

3. **Get commits since last tag:**
   ```bash
   git log <last-tag>..HEAD --oneline
   ```
   - If no commits since last tag, warn user and confirm they want to proceed

4. **Generate release notes:**
   - Summarize commits into release notes
   - Format as markdown with sections if appropriate
   - Show to user and ask for confirmation/edits

5. **Create annotated tag:**
   ```bash
   git tag -a <version> -m "<one-line summary>"
   ```

6. **Push tag:**
   ```bash
   git push origin <version>
   ```

7. **Create GitHub release:**
   ```bash
   gh release create <version> --title "<version>" --notes "<release-notes>"
   ```

8. **Confirm** with link to the release.

## Examples:

```bash
/release patch      # v1.0.0 → v1.0.1
/release minor      # v1.0.0 → v1.1.0
/release major      # v1.0.0 → v2.0.0
/release v2.0.0     # explicit version
/release            # interactive - asks what to bump
```
