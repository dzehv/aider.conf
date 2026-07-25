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

## Global Configuration (`.aider.conf.yml`)

Key settings configured in `.aider.conf.yml`:

- `auto-commits: false` — disables automatic git commits after edits to keep git history strictly under user control.
- `read` — automatically loads personal coding standards (`~/.config/aider/aider-coding-standards.md`) on startup.
- `weak-model` — specifies a cheaper/faster auxiliary model for low-complexity tasks (e.g. commit message generation, simple summaries). Example:

```yaml
weak-model: openrouter/deepseek/deepseek-v3.2
```

## Access & Security Controls

Aider provides multiple configuration options and CLI flags to control filesystem access, Git modifications, and execution approvals:

- **Auto-Confirmation (`--yes-always` / `yes-always: true` / `/yes-always`)**: Automatically accepts all confirmation prompts (file creations, edits, command execution suggestions) without asking interactively. *Use with caution.*
- **Git Auto-Commits (`--no-auto-commits` / `auto-commits: false` / `/auto-commits`)**: Prevents Aider from creating automatic Git commits after applying changes, preserving clean Git history under user control.
- **Git Integration (`--no-git` / `git: false`)**: Disables Git integration entirely, preventing Aider from checking git status, running git commands, or creating commits.
- **Subtree Isolation (`--subtree-only` / `subtree-only: true`)**: Restricts Aider to the current working directory subtree, preventing access or edits outside this directory in larger repositories.
- **Read-Only Context (`--read <file>` / `read: ...` / `/read`)**: Forces specific files to be loaded strictly in read-only mode so the AI can inspect context without authorization to edit them.
- **File Exclusion (`.aiderignore` / `--aiderignore <file>`)**: Prevents Aider from accessing, reading, indexing, or editing specified sensitive or binary files.
- **Secrets Management (`--env-file <file>`)**: Loads API keys and secret variables from a specified `.env` file path.

## Launch Parameters & CLI Flags

- `aider` — launch with default model (`deepseek-v4-pro`) and disabled auto-commits.
- `aider --no-auto-commits` — disable automatic git commits on startup (`auto-commits: false` in `.aider.conf.yml`).
- `aider --yes-always` — auto-confirm all prompts without asking interactively on startup.
- `aider --model <alias>` — quick switch model via alias (e.g. `sonnet`).
- `aider --read <file>` — add file(s) as read-only context on startup.
- `aider --edit-format <format>` — set edit format on startup (`diff`, `whole`, `udiff`, `architect`). *(Not recommended to override)*
- `aider --chat-history-file <file>` — isolate history for a specific task (e.g. `.history.feature.md`).
- `aider --chat-mode <mode>` — set chat mode on startup (`code`, `architect`, `ask`, `help`).
- `aider --subtree-only` — restrict Aider's context and operations strictly to the current directory subtree.
- `aider --no-git` — disable Git integration completely.
- `aider --weak-model <alias>` — specify an auxiliary model for low-cost tasks (e.g. `aider --weak-model ds3`).
- `aider --message "prompt..."` — start the session with a long multi‑line prompt passed as a command‑line argument (use quotes for line breaks).

## Chat Modes

Specify chat behavior via `--chat-mode <mode>` flag or `/chat-mode <mode>` in-session command:

- `code` — standard editing mode; directly modifies code files.
- `architect` — two-step mode; plans architecture/solutions before writing code.
- `ask` — conversational mode; answers questions about the codebase without making file changes.
- `help` — help mode; answers questions about Aider's usage, commands, and options.

*Note: In-session behavior can also be switched dynamically using `/chat-mode <mode>` (or shortcut commands like `/code` and `/architect`).*

## Edit Formats

Specify how the model applies code changes via `--edit-format <format>` flag or in `.aider.conf.yml` (`edit-format: <format>`):

- `diff` — block-based search and replace; standard and highly efficient for capable models.
- `whole` — rewrites the entire file; token-heavy but reliable, often used for smaller or weaker models.
- `udiff` — standard unified diff format; optimal for models heavily pre-trained on git diffs.
- `architect` — two-model approach where the primary model plans the solution and delegates code changes to an editor model.

> **Recommendation:** It is best to leave `--edit-format` set to default. Models are natively tuned for specific edit formats (Aider selects the optimal format automatically per model). Manually overriding this flag is not recommended as it may degrade model performance or result in edit errors.

## Model Aliases (Presets)

Defined in .aider.conf.yml:

- ds3    -> openrouter/deepseek/deepseek-v3.2
- ds4    -> openrouter/deepseek/deepseek-v4-pro
- sonnet -> openrouter/anthropic/claude-3.6-sonnet
- flash  -> openrouter/google/gemini-2.5-flash
- haiku  -> openrouter/anthropic/claude-3-haiku

## Interactive Session Commands

- `/clear` — wipe current conversation memory to start a fresh sub-task.
- `/model <alias>` — switch main model on the fly during the session.
- `/editor-model <alias>` — switch editor model used when in architect mode.
- `/weak-model <alias>` — switch auxiliary (weak) model on the fly during the session.
- `/chat-mode <mode>` — switch chat/edit mode on the fly (`code`, `architect`, `ask`, `help`).
- `/auto-commits` — toggle automatic git commits on/off during the session.
- `/yes-always` — toggle auto-confirmation mode on/off for prompts during the session.
- `/read <file>` — add read-only file to active context (reference without editing).
- `/diff` — view current uncommitted changes made by the agent in local files.
- `/undo` — revert the last applied changes.
- `/editor` — open your configured text editor to write or paste long prompts with line breaks, avoiding truncated prompts when sending to the model.
- `/paste` — enter multi‑line input mode for safe pasting of text with line breaks; type `END` on a new line to finish and send to the model.

## Working with Files & Context Management

Aider does not load the full content of all repository files into the model's context by default, saving tokens while maintaining structural awareness:

* **Repo Map:** Automatically builds and updates a lightweight architectural map of your entire project so the model knows what files, functions, and classes exist.
* **Adding Files for Editing:** Explicitly add files to the active session so the model can read or modify them:
  * **On startup:** `aider src/main.go src/utils.go`
  * **During the session:** `/add path/to/file.go`
* **Adding Read-Only Files for Context:** Add files that the model can reference as context without modifying them:
  * **On startup:** `aider --read path/to/file.go`
  * **During the session:** `/read path/to/file.go`
* **Session File Commands:**
  * `/ls` — list files currently active in the session context.
  * `/drop path/to/file.go` — remove a file from the active working context.

### Long‑Prompt Input Methods

Besides the in‑session `/editor` command, you can invoke an editor at startup or configure Aider to wait for your confirmation before sending prompts:

* **Multi‑line input via `/paste`** – if you are already in a session but don’t want to use an external editor, type `/paste`. Aider will open a multi‑line input mode where you can safely paste any text with line breaks. When finished, type `END` on a new line (or press the completion key combination specific to your version) and the text will be sent to the model.
* **Passing a prompt as a command‑line argument** – if you need to start a task immediately, pass your prompt in quotes directly when calling from the terminal:

```bash
aider --message "Your long and detailed multi‑line prompt..."
```

## Privacy & File Exclusion (`.aiderignore`)

To prevent sensitive, binary, or high-volume auto-generated files from being indexed, read, or modified by Aider, place a `.aiderignore` file in your repository root (or specify one via `--aiderignore <file>`). `.aiderignore` uses standard `.gitignore` syntax.

### Example `.aiderignore` File:

```gitignore
# Sensitive keys & environment variables
.env*
*.pem
*.key
secrets/

# Databases & local state
*.sqlite
*.db
*.log

# Dependencies & build outputs
node_modules/
dist/
build/
target/
vendor/

# Large binaries & media
*.pdf
*.zip
*.tar.gz
```
