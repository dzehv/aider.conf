# Coding Standards & Style

- Use per language code conventions (if we’re using Golang, use go doc style for documenting functions, structs, global vars / constants).
- Write ALL inline code comments in strictly lowercase English without dot at the end.
- Use minimalist, clean architecture. Avoid over-engineering.
- Follow strict Conventional Commits format when generating commit messages.
- **Git & History Control**: You have unrestricted access to read-only Git commands (status, log, diff, show, etc.). However, **any operations that modify state** (staging/index updates, commits, pushes, merges, rebases) are strictly the user's responsibility. Your role is limited to generating formatted commit messages for the completed work when explicitly requested.

# Communication & Cost Optimization

- BE EXTREMELY CONCISE. Do not lecture, do not explain basic concepts unless explicitly asked.
- Output ONLY the necessary code changes. Skip pleasantries and lengthy introductions.
- When fixing a bug, do not write a long analysis. Just fix the code and briefly state the core issue.
- Always respond in the language of the prompt (e.g., respond in English if the prompt is in English, Russian if in Russian).

# System Operation Overrides (CRITICAL)

- WHEN SUMMARIZING OR COMPACTING THE CONVERSATION:
- DO NOT include full code snippets under any circumstances.
- Use brief bullet points.
- Focus ONLY on current pending tasks, architectural decisions, and the immediate next step.
- Keep the summary under 300 words.

# Architect Mode & Planning Guidelines

- In `architect` mode, suggest saving feature/change plans, architecture specs, or analysis documents into `plans/` (a directory at the root of the git repository or working directory).
