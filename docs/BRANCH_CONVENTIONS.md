# KhedmaLink Branch & Pull Request Conventions

This document defines the branching strategy and pull request (PR) workflow for KhedmaLink development.

## Overview

KhedmaLink follows a milestone-based development approach with strict branching conventions to ensure code quality, traceability, and smooth collaboration.

## Branch Strategy

### Main Branches

#### `main`
- **Purpose:** Production-ready code
- **Protection:** Protected branch - requires PR approval and CI checks
- **Status:** Always deployable to production
- **Updates:** Only via merge from `develop` or hotfix branches
- **Commits:** No direct commits allowed

#### `develop`
- **Purpose:** Integration branch for completed milestones
- **Protection:** Protected branch - requires PR approval and CI checks
- **Status:** Pre-production integration
- **Updates:** Only via merge from feature branches
- **Commits:** No direct commits allowed

### Supporting Branches

#### Feature Branches: `feature/milestone-{number}-{short-description}`
- **Purpose:** Develop specific milestones
- **Source:** Branch from `develop`
- **Target:** Merge back to `develop`
- **Naming Convention:** `feature/milestone-{number}-{short-description}`
- **Examples:**
  - `feature/milestone-0-repo-charter`
  - `feature/milestone-1-flutter-foundation`
  - `feature/milestone-2-backend-foundation`
- **Lifetime:** Exists only during milestone development
- **Cleanup:** Delete after merge

#### Hotfix Branches: `hotfix/{short-description}`
- **Purpose:** Emergency fixes for production issues
- **Source:** Branch from `main`
- **Target:** Merge to both `main` and `develop`
- **Naming Convention:** `hotfix/{short-description}`
- **Examples:**
  - `hotfix/security-patch-auth`
  - `hotfix/critical-bug-payment`
- **Lifetime:** Short-lived, merged immediately after fix
- **Cleanup:** Delete after merge

#### Release Branches: `release/v{version}`
- **Purpose:** Prepare for production release
- **Source:** Branch from `develop`
- **Target:** Merge to both `main` and `develop`
- **Naming Convention:** `release/v{major}.{minor}.{patch}`
- **Examples:**
  - `release/v0.1.0`
  - `release/v1.0.0`
- **Lifetime:** Exists during release preparation
- **Cleanup:** Delete after release

#### Documentation Branches: `docs/{short-description}`
- **Purpose:** Documentation updates that don't require code changes
- **Source:** Branch from `develop`
- **Target:** Merge to `develop`
- **Naming Convention:** `docs/{short-description}`
- **Examples:**
  - `docs/update-api-docs`
  - `docs-add-architecture-decision`
- **Lifetime:** Short-lived
- **Cleanup:** Delete after merge

## Branch Naming Rules

### General Rules
- Use lowercase letters
- Use hyphens (`-`) to separate words
- Use underscores (`_`) only where specifically required
- Keep names descriptive but concise (max 50 characters)
- Avoid special characters and spaces

### Milestone Branch Naming
```
feature/milestone-{number}-{short-description}
```

**Components:**
- `feature` - Type of branch
- `milestone-{number}` - Milestone identifier (M0, M1, M2, etc.)
- `{short-description}` - Brief description of the work

**Examples:**
- ✅ `feature/milestone-0-repo-charter`
- ✅ `feature/milestone-1-flutter-foundation`
- ✅ `feature/milestone-3-auth-roles`
- ❌ `feature/M0-RepoCharter` (incorrect case)
- ❌ `feature/milestone_0_repo_charter` (incorrect separator)

### Hotfix Branch Naming
```
hotfix/{short-description}
```

**Components:**
- `hotfix` - Type of branch
- `{short-description}` - Description of the fix

**Examples:**
- ✅ `hotfix/security-patch-auth`
- ✅ `hotfix/critical-bug-payment`
- ❌ `hotfix/SecurityPatchAuth` (incorrect case)

## Pull Request Conventions

### PR Title Format

PR titles must follow this format:
```
[M{number}] {type}: {short-description}
```

**Components:**
- `[M{number}]` - Milestone identifier (e.g., [M0], [M1])
- `{type}` - Type of change (feat, fix, docs, refactor, test, chore)
- `{short-description}` - Brief description

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only changes
- `style` - Code style changes (formatting, etc.)
- `refactor` - Code refactoring
- `test` - Adding or updating tests
- `chore` - Maintenance tasks
- `perf` - Performance improvements

**Examples:**
- ✅ `[M0] feat: create repository structure`
- ✅ `[M1] feat: implement Flutter routing`
- ✅ `[M2] fix: database connection timeout`
- ✅ `[M3] docs: update API documentation`
- ❌ `Create repository structure` (missing milestone and type)
- ❌ `[M0] created repository structure` (incorrect type format)

### PR Description Template

Every PR must include a comprehensive description:

```markdown
## Milestone
M{number} - {Milestone Name}

## Summary
{Brief description of what this PR accomplishes}

## Changes
- {List of major changes}
- {Use bullet points for clarity}
- {Include both frontend and backend changes}

## Breaking Changes
{List any breaking changes, or state "None"}

## Database Changes
- {Migration files added/modified}
- {Schema changes}
- {Or state "None"}

## API Changes
- {New endpoints}
- {Modified endpoints}
- {Or state "None"}

## Testing
- {Tests added}
- {Test results}
- {Manual testing performed}

## Documentation
- {Documentation updated}
- {Or state "None"}

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests added and passing
- [ ] All CI checks passing
- [ ] No merge conflicts

## Related Issues
#{issue-number} (if applicable)
```

### PR Requirements

#### Before Creating a PR
1. **Branch must be up to date**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout feature/milestone-{number}-{description}
   git rebase develop
   ```

2. **Code must be formatted**
   - Flutter: `flutter format .`
   - Python: `black .` and `ruff check . --fix`

3. **Linting must pass**
   - Flutter: `flutter analyze`
   - Python: `ruff check .` and `mypy .`

4. **Tests must pass**
   - Flutter: `flutter test`
   - Python: `pytest`

5. **Build must succeed**
   - Flutter: `flutter build apk` (Android) and `flutter build web` (Web)
   - Python: Ensure imports and dependencies are correct

#### During PR Review
1. **Minimum reviewers:** 1 (preferably 2 for critical changes)
2. **Approval required:** At least 1 approval before merge
3. **CI checks:** All checks must pass
4. **Discussion time:** Allow 24 hours for review (unless urgent hotfix)

#### Before Merging
1. **Resolve all conflicts**
2. **Ensure all checks pass**
3. **Update documentation if needed**
4. **Squash commits** (for feature branches) to maintain clean history
5. **Delete branch after merge**

## Git Workflow

### Starting a New Milestone

1. **Create feature branch**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/milestone-{number}-{description}
   ```

2. **Develop the milestone**
   - Follow the milestone requirements
   - Commit frequently with descriptive messages
   - Test thoroughly

3. **Push and create PR**
   ```bash
   git push origin feature/milestone-{number}-{description}
   ```
   - Create PR following the conventions
   - Link to relevant milestone documentation

### Commit Message Format

Commit messages should follow Conventional Commits:

```
{type}({scope}): {subject}

{body}

{footer}
```

**Types:** feat, fix, docs, style, refactor, test, chore, perf

**Examples:**
- `feat(auth): implement JWT token validation`
- `fix(database): resolve connection pool timeout`
- `docs(api): update authentication endpoint documentation`
- `test(booking): add booking state transition tests`

### Handling Hotfixes

1. **Create hotfix branch from main**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b hotfix/{description}
   ```

2. **Implement the fix**
   - Make minimal changes
   - Add tests
   - Document the fix

3. **Merge to main and develop**
   ```bash
   # Merge to main
   git checkout main
   git merge hotfix/{description}
   git tag -a v{patch-version} -m "Hotfix: {description}"
   git push origin main --tags
   
   # Merge to develop
   git checkout develop
   git merge hotfix/{description}
   git push origin develop
   ```

4. **Delete hotfix branch**
   ```bash
   git branch -d hotfix/{description}
   git push origin --delete hotfix/{description}
   ```

## Milestone Integration Workflow

### Milestone Completion Process

1. **Developer completes milestone**
   - All requirements met
   - Tests passing
   - Documentation updated

2. **Create PR to develop**
   - Follow PR conventions
   - Include milestone exit criteria verification

3. **Code review**
   - Review against milestone requirements
   - Verify no future milestone work included
   - Check test coverage

4. **Merge to develop**
   - Squash merge
   - Delete feature branch

5. **Verification**
   - Run integration tests on develop
   - Verify milestone exit criteria

6. **Tag milestone**
   ```bash
   git checkout develop
   git tag -a m{number} -m "Milestone {number}: {description}"
   git push origin m{number}
   ```

## Branch Protection Rules

### `main` Branch
- ✅ Require pull request before merging
- ✅ Require approval from 1 reviewer
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging
- ❌ Do not allow bypassing the above settings

### `develop` Branch
- ✅ Require pull request before merging
- ✅ Require approval from 1 reviewer
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging
- ❌ Do not allow bypassing the above settings

## CI/CD Integration

### Required Checks for PRs
- Flutter format check
- Flutter analyze
- Flutter tests
- Python linting (ruff)
- Python type checking (mypy)
- Python tests
- Build verification
- Security scan (if configured)

### Automatic Actions
- Auto-format on push (optional)
- Auto-delete branch after merge
- Notify team on PR failure
- Create release notes on merge to main

## Best Practices

### DO ✅
- Keep branches focused and short-lived
- Write descriptive commit messages
- Update documentation with code changes
- Test thoroughly before creating PR
- Review PRs promptly
- Use draft PRs for work-in-progress
- Keep PRs small and focused
- Add tests for new features
- Update CHANGELOG.md

### DON'T ❌
- Work directly on main or develop
- Create long-lived feature branches
- Include multiple milestones in one PR
- Force push to shared branches
- Merge without review
- Skip tests
- Commit sensitive data
- Ignore CI failures
- Create PRs without description

## Troubleshooting

### Merge Conflicts
1. Pull latest changes from target branch
2. Resolve conflicts locally
3. Test thoroughly
4. Commit resolution
5. Push and update PR

### CI Failures
1. Check CI logs for specific errors
2. Reproduce locally if possible
3. Fix the issue
4. Push changes
5. Verify CI passes

### PR Review Delays
1. Add `@mention` to specific reviewers
2. Mark as urgent if needed (with justification)
3. Escalate to team lead if critical

## Glossary

- **Branch:** Parallel version of the codebase
- **PR (Pull Request):** Request to merge changes
- **CI (Continuous Integration):** Automated testing and validation
- **Rebase:** Reapply commits on top of another branch
- **Squash:** Combine multiple commits into one
- **Hotfix:** Emergency production fix
- **Milestone:** Major development phase

## References

- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

---

**Note:** These conventions are mandatory for KhedmaLink development. Deviations require team approval and documentation.
