# Aider Global Configuration

Personal terminal-native AI development environment setup with OpenRouter, strict Git isolation, and custom coding standards.

## Installation

### Recommended Method (via `uv`)

Since Aider depends on packages like `scipy` and `numpy`, installation on very fresh Python versions (like Python 3.14) can sometimes fail if pre-built binary wheels are missing, triggering source compilation errors (e.g., missing OpenBLAS).

To avoid compilation issues and ensure everything installs smoothly, **force `uv` to use a stable Python version (e.g., 3.12)**:

```bash
uv tool install --python 3.12 aider-chat
```

## Alternative Method (via pipx)

If you prefer pipx, ensure your environment is up to date:

``` bash
brew install pipx
pipx ensurepath
pipx install aider-chat
```

## Repository Deployment

Clone this repository and run the install target (or link files to your home directory):

``` bash
make install
```

## Environment Variables

Aider requires an API key to communicate with models via OpenRouter. Set it in your shell profile (~/.bashrc, ~/.zshrc, etc.):

``` bash
export OPENROUTER_API_KEY="your_openrouter_api_key_here"
```

## Launch Parameters & CLI Flags

- aider — launch with default model (deepseek-v4-pro) and disabled auto-commits.
- aider --model sonnet — quick switch to Claude via alias.
- aider --edit-format <format> — set edit format on startup (diff, whole, udiff, architect).
- aider --chat-history-file .history.feature.md — isolate history for a specific large task.
- aider --chat-mode <mode> — set chat mode on startup (code, architect, ask, help).

## Chat Modes

Specify chat behavior via `--chat-mode <mode>` flag or `/chat-mode <mode>` in-session command:

- `code` — standard editing mode; directly modifies code files.
- `architect` — two-step mode; plans architecture/solutions before writing code.
- `ask` — conversational mode; answers questions about the codebase without making file changes.
- `help` — help mode; answers questions about Aider's usage, commands, and options.

## Edit Formats

Specify how the model applies code changes via `--edit-format <format>` flag or in `.aider.conf.yml` (`edit-format: <format>`):

- `diff` — block-based search and replace; standard and highly efficient for capable models.
- `whole` — rewrites the entire file; token-heavy but reliable, often used for smaller or weaker models.
- `udiff` — standard unified diff format; optimal for models heavily pre-trained on git diffs.
- `architect` — two-model approach where the primary model plans the solution and delegates code changes to an editor model.

*Note: In-session edit behavior can also be switched dynamically using `/chat-mode <mode>` (or shortcut commands like `/code` and `/architect`).*

## Model Aliases (Presets)

Defined in .aider.conf.yml:

- ds3    -> openrouter/deepseek/deepseek-v3.2
- ds4    -> openrouter/deepseek/deepseek-v4-pro
- sonnet -> openrouter/anthropic/claude-3.6-sonnet
- flash  -> openrouter/google/gemini-2.5-flash
- haiku  -> openrouter/anthropic/claude-3-haiku

## Interactive Session Commands

- /clear — wipe current conversation memory to start a fresh sub-task.
- /model <alias> — switch main model on the fly during the session.
- /editor-model <alias> — switch editor model used when in architect mode.
- /chat-mode <mode> — switch chat/edit mode on the fly (`code`, `architect`, `ask`, `help`).
- /diff — view current uncommitted changes made by the agent in local files.
- /undo — revert the last applied changes.

## Working with Files & Context Management

Aider does not load the full content of all repository files into the model's context by default, saving tokens while maintaining structural awareness:

* **Repo Map:** Automatically builds and updates a lightweight architectural map of your entire project so the model knows what files, functions, and classes exist.
* **Adding Files for Editing:** Explicitly add files to the active session so the model can read or modify them:
  * **On startup:** `aider src/main.go src/utils.go`
  * **During the session:** `/add path/to/file.go`
* **Session File Commands:**
  * `/ls` — list files currently active in the session context.
  * `/drop path/to/file.go` — remove a file from the active working context.
