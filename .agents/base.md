# base.md

## Purpose

This file defines baseline instructions for AI coding agents working inside this repository.

These rules are intentionally project-agnostic. Project-specific rules must be generated separately from project answers, detected tooling, and repository conventions.

## Priority

Follow instructions in this order:

1. Explicit user request in the current task.
2. Project-specific `AGENTS.md` or generated project instructions.
3. This base instruction file.
4. Existing repository conventions.
5. General best practices.

When instructions conflict, stop and ask for clarification unless the correct action is unambiguous from the current task.

## Working directory

Always work from the repository root unless the task explicitly targets a subdirectory.

Before making changes, identify the relevant workspace, package, app, or module. Do not modify neighboring workspaces unless the task explicitly requires it.

Do not assume that the current terminal directory is correct. Verify the repository root and package layout before running install, build, lint, test, or generation commands.

## Scope discipline

Solve only the requested problem.

Do not introduce unrelated refactors, formatting changes, dependency updates, architectural changes, or naming changes unless the user explicitly requested them.

Prefer the smallest safe change that fully solves the task.

If the task reveals a larger problem, mention it separately instead of silently expanding the scope.

## Repository inspection

Before editing, inspect existing files related to the task.

Follow existing naming, formatting, directory structure, imports, logging style, test style, and error-handling conventions.

Do not invent new conventions when an existing convention is already present.

## Change protocol

Before changing files, prepare a short touched-files plan:

```txt
Touched files:
- path/to/file.ext — reason
```

For small tasks, this can be brief. For larger tasks, include only files that are expected to be edited, not every inspected file.

After changes, summarize what changed and how it was verified.

## Editing rules

Preserve existing comments unless they are incorrect after the change.

Do not remove code, comments, tests, exports, public APIs, configuration, or documentation unless removal is explicitly required.

Do not rewrite complete files when a focused patch is enough.

Do not change generated files unless the project workflow requires it.

Do not modify lockfiles unless dependency changes are part of the task.

## Runtime and tooling verification

Before running project commands, verify the expected runtime and package manager from project files where possible.

Use the package manager already used by the project.

Do not switch package managers.

Do not add dependencies unless the task explicitly requires them or there is no reasonable dependency-free solution.

When adding a dependency is necessary, explain why before doing it.

## Commands

Prefer project-defined scripts over ad-hoc commands.

Use non-destructive commands by default.

Do not run commands that delete files, reset Git state, rewrite history, clear caches, reinstall all dependencies, or modify global environment unless explicitly requested.

Do not run long-running watch/dev commands unless the task specifically requires them. If a dev server is needed, use the existing project script and stop it after verification.

## Desktop and GUI automation safety

Do not send keystrokes, mouse input, focus changes, or window-management commands to the user's desktop unless the user explicitly requested that exact GUI automation in the current task.

Forbidden by default:

* `SendKeys`, synthetic keyboard input, or pasted command text into arbitrary windows.
* `SetForegroundWindow`, `ShowWindow`, focus stealing, or similar APIs to target desktop applications.
* Closing, minimizing, moving, or accepting dialogs in user-owned application windows.
* Broad process cleanup such as stopping every process with a matching name.

For GUI applications, prefer deterministic non-interactive interfaces such as command-line arguments, script files intentionally passed to that process, log files, exported reports, or application-specific automation APIs that target a known object instead of the active desktop.

If GUI interaction is unavoidable, stop and ask for explicit approval with the exact target process/window, the exact input to be sent, and the expected effect. Do not infer permission from a general request to test an application.

## Validation

Validate changes with the narrowest relevant command first.

Typical validation order:

1. Type check or static check for the touched package/module.
2. Lint for the touched package/module.
3. Unit or integration tests related to the change.
4. Build only when needed or when requested.

If validation cannot be run, state why and provide the exact command that should be run manually.

Do not claim that validation passed unless it actually ran successfully.

## Git safety

Do not create commits, branches, tags, pull requests, or releases unless explicitly requested.

Do not run `git reset`, `git clean`, `git checkout --`, `git restore`, `git rebase`, or force-push commands unless explicitly requested.

Before editing, do not discard user changes.

If there are unexpected existing changes in files you need to edit, stop and ask how to proceed unless the user explicitly told you to overwrite them.

## Types and correctness

Prefer explicit, safe types over implicit or weak types.

Do not use unsafe escape hatches such as broad casts, suppressed errors, ignored diagnostics, or disabled lint rules unless the user explicitly approves and there is no safer option.

Do not silence errors. Fix the root cause.

Preserve public contracts unless the task explicitly requires a breaking change.

When changing a public API, update related declarations, exports, tests, and documentation as required by the project.

## Error handling

Handle expected errors explicitly.

Do not swallow errors silently.

Do not replace specific errors with vague generic errors if the existing project style keeps useful context.

When adding logs, follow the existing logger and message style.

Do not introduce console logging in production code unless that is already the established convention.

## Formatting

Use the project formatter and lint rules.

Do not manually reformat unrelated sections.

Do not disable formatter or linter rules to make code pass.

If formatting rules are unclear, match nearby code.

## Documentation

Update documentation only when the behavior, public API, setup flow, command, or user-facing contract changes.

Keep documentation accurate and minimal.

Do not add marketing text, broad explanations, or unrelated examples to technical documentation.

## Tests

When behavior changes, update or add tests if the project has an existing test structure.

Prefer focused tests near the changed behavior.

Do not create a new test framework or test architecture unless explicitly requested.

Do not delete tests to make a build pass.

## Security and secrets

Never expose, print, commit, or hardcode secrets, tokens, private keys, credentials, cookies, or production URLs with credentials.

Use environment variables and existing project configuration patterns.

If a secret appears in user-provided input or repository content, treat it as sensitive and avoid repeating it unnecessarily.

## Environment files

Do not modify `.env`, `.env.local`, production environment files, or secret configuration unless explicitly requested.

If an environment variable is required, document the variable name and purpose without inventing secret values.

## Dependency policy

Do not add a dependency for functionality that can be implemented cleanly with existing project dependencies or standard platform APIs.

Do not upgrade dependencies unless the task explicitly requires an upgrade.

Do not mix dependency versions across workspaces without checking the existing dependency strategy.

## Generated output policy

Generated project instructions should be deterministic.

Given the same answers and the same template version, the generator should produce the same output.

Generated files should include a short header indicating that they were generated and where the source profile/template is stored.

Example:

```md
<!-- Generated from .agents/base.md and .agents/project-profile.json. Do not edit manually unless intentionally overriding generated output. -->
```

## Agent communication

Be direct and task-focused.

For code changes, report:

1. Files changed.
2. What changed.
3. Validation run.
4. Remaining risks or manual checks, if any.

Do not over-explain obvious code.

Do not provide large unrelated alternatives unless the user asks for options.

## Clarification policy

Ask a clarification question only when required to avoid a wrong or destructive change.

If the likely intent is clear and the change is safe, make a reasonable minimal decision and state it.

For ambiguous architecture or API decisions, prefer documenting the assumption instead of silently choosing a broad direction.

## Prohibited actions

Do not:

* Disable lint rules to hide a problem.
* Suppress type errors instead of fixing them.
* Replace project conventions with personal preferences.
* Rewrite unrelated files.
* Change public APIs without a task requirement.
* Add dependencies without necessity.
* Delete tests to make checks pass.
* Commit secrets or environment-specific values.
* Run destructive Git commands without explicit permission.
* Claim verification that was not performed.

## Project-specific extension points

Generated project instructions may extend this base with:

* Runtime and package manager versions.
* Framework-specific rules.
* Language and typing strategy.
* Repository layout.
* Build, lint, test, and review commands.
* Styling conventions.
* API conventions.
* Logging conventions.
* File naming rules.
* Public contract and declaration rules.
* Deployment or review workflow.

Project-specific instructions must not weaken the safety rules in this base file unless explicitly approved by the repository owner.
