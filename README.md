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

Aider uses the `AIDER_EDITOR`, `EDITOR`, `VISUAL` environment variables to determine which text editor to open for commands like `/editor`. If not set, it falls back to `vi`. You can either export `AIDER_EDITOR` in your shell profile (e.g., `export AIDER_EDITOR="emacs -nw"`) or pass it when launching Aider:

``` bash
export AIDER_EDITOR="emacs -nw"
```

## Global Configuration (`.aider.conf.yml`)

Key settings configured in `.aider.conf.yml`:

- `auto-commits: false` — disables automatic git commits after edits to keep git history strictly under user control.
- `read` — automatically loads personal coding standards (`~/.config/aider/aider-coding-standards.md`) on startup.
- `weak-model` — specifies a cheaper/faster auxiliary model for low-complexity tasks (e.g. commit message generation, simple summaries). Example:
- `cache-prompts: true` — enables prompt caching on the provider side (Anthropic / some OpenRouter models); reduces costs and latency for repeated context.
- `stream: false` — disables streaming; Aider waits for the full model response before displaying output.
- `editor` — sets the preferred text editor for `/editor` and similar commands. Can be overridden at launch with the `--editor` flag or an `AIDER_EDITOR` or `EDITOR` environment variables.
- `model-settings-file` — points to `~/.aider.model.settings.yml` for per-model overrides such as `extra_params.max_tokens`.

```yaml
weak-model: openrouter/deepseek/deepseek-v3.2
model-settings-file: ~/.aider.model.settings.yml
```

### Per-Model Output Limits (`.aider.model.settings.yml`)

Models with large output ceilings (e.g., Gemini 4 Carbon and Argon, up to 65k–131k tokens) can trigger `max_tokens` or credit-limit errors on OpenRouter because:

1. **Thinking tokens share the output budget** — hidden reasoning tokens count toward `max_tokens`.
2. **Context window budget** — `input_tokens + max_tokens` must not exceed the model's total context window.
3. **Worst-case credit pre-reservation** — OpenRouter reserves balance for the full requested `max_tokens` before each request, not just the actual response size.

`aider.model.settings.yml` caps `max_tokens` via `extra_params` (e.g., `16384`) so Aider does not request the full window ceiling on every edit:

```yaml
- name: openrouter/google/gemini-4-carbon
  extra_params:
    max_tokens: 16384
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
- `aider --editor-model <alias>` — specify a separate model for code edits in `architect` mode (e.g., `aider --model carbon --editor-model argon --architect`).
- `aider --model-settings-file <file>` — specify a YAML file with per-model overrides (such as `extra_params.max_tokens` for OpenRouter models).
- `aider --thinking-tokens <tokens>` — set the thinking token budget for reasoning models (`0` to disable); helps prevent reasoning tokens from exhausting `max_tokens`.
- `aider --max-chat-history-tokens <tokens>` — soft limit on chat history tokens before summarization, keeping input size well below `context_window - max_tokens`.
- `aider --cache-prompts` — enable prompt caching (supported by Anthropic and some OpenRouter models); reduces costs and latency for repeated context by caching system prompts and long file contexts on the provider side.
- `aider --no-stream` — disable streaming of model responses; waits for the full response before displaying output (useful when streaming causes issues or for cleaner logging).
- `aider --message "prompt..."` — start the session with a long multi‑line prompt passed as a command‑line argument (use quotes for line breaks).
- `aider --editor <editor-cmd>` — specify a text editor to use with `/editor` and similar commands (overrides the `EDITOR` environment variable and the `editor` config key).

## Chat Modes

Specify chat behavior via `--chat-mode <mode>` flag or `/chat-mode <mode>` in-session command:

- `code` — standard editing mode; directly modifies code files.
- `architect` — two-step mode; plans architecture/solutions before writing code. Ideal for pairing a reasoning model (`carbon`) as architect with a faster/cheaper model (`argon`) as `--editor-model` to keep `max_tokens` usage and OpenRouter credit reservations low.
- `ask` — conversational mode; answers questions about the codebase without making file changes.
- `help` — help mode; answers questions about Aider's usage, commands, and options.

*Note: In-session behavior can also be switched dynamically using `/chat-mode <mode>` (or shortcut commands like `/code` and `/architect`).*

## Edit Formats

Specify how the model applies code changes via `--edit-format <format>` flag or in `.aider.conf.yml` (`edit-format: <format>`):

- `diff` — block-based search and replace; standard and highly efficient for capable models.
- `whole` — rewrites the entire file; token-heavy and much more likely to hit `max_tokens` output limits on large files, often used only for smaller or weaker models.
- `udiff` — standard unified diff format; optimal for models heavily pre-trained on git diffs.
- `architect` — two-model approach where the primary model plans the solution and delegates code changes to an editor model (useful for separating planning `max_tokens` from code-generation `max_tokens`).

> **Recommendation:** It is best to leave `--edit-format` set to default. Models are natively tuned for specific edit formats (Aider selects the optimal format automatically per model). Manually overriding this flag is not recommended as it may degrade model performance or result in edit errors.

## Model Aliases (Presets)

Defined in .aider.conf.yml:

- ds3    -> openrouter/deepseek/deepseek-v3.2
- ds4    -> openrouter/deepseek/deepseek-v4-pro
- sonnet -> openrouter/anthropic/claude-3.6-sonnet
- flash  -> openrouter/google/gemini-2.5-flash
- carbon -> openrouter/google/gemini-4-carbon *(default `max_tokens` capped at `16384` in `aider.model.settings.yml`; medium reasoning shares output budget)*
- argon  -> openrouter/google/gemini-4-argon *(default `max_tokens` capped at `16384` in `aider.model.settings.yml`)*
- haiku  -> openrouter/anthropic/claude-3-haiku

## Interactive Session Commands

- `/clear` — wipe current conversation memory to start a fresh sub-task and free input budget for `max_tokens`.
- `/model <alias>` — switch main model on the fly during the session.
- `/editor-model <alias>` — switch editor model used when in architect mode.
- `/weak-model <alias>` — switch auxiliary (weak) model on the fly during the session.
- `/chat-mode <mode>` — switch chat/edit mode on the fly (`code`, `architect`, `ask`, `help`).
- `/auto-commits` — toggle automatic git commits on/off during the session.
- `/yes-always` — toggle auto-confirmation mode on/off for prompts during the session.
- `/cache-prompts` — toggle prompt caching on/off during the session.
- `/stream` — toggle streaming of model responses on/off during the session.
- `/read <file>` — add read-only file to active context (reference without editing).
- `/drop [file]` — remove a file from the active chat session (or all files if no argument is given) to reduce input tokens and leave room for `max_tokens`.
- `/tokens` — report the number of tokens used by the current chat context and their estimated cost (use this to verify `input + max_tokens` fits within the model's context window).
- `/diff` — view current uncommitted changes made by the agent in local files.
- `/undo` — revert the last applied changes.
- `/editor` — open your configured text editor to write or paste long prompts with line breaks, avoiding truncated prompts when sending to the model. The editor is determined by (in priority order): the `--editor` CLI flag, the `EDITOR` environment variable, the `editor` key in `.aider.conf.yml`, or `vi` as a final fallback.
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

### Output Token Limits (`max_tokens`) & OpenRouter

When using high-output reasoning models (such as Gemini 4 Carbon or Argon) via OpenRouter, hitting an output token or credit-limit error usually comes down to `max_tokens`:

* **Thinking tokens count toward output:** Hidden reasoning tokens share the `max_tokens` ceiling with generated code.
* **Window & credit reservation:** `input_tokens + max_tokens` must fit inside the model's context window, and OpenRouter pre-reserves account balance for the full requested `max_tokens` worst-case on every turn.
* **Mitigations:**
  * Cap `max_tokens` per model in `aider.model.settings.yml` via `extra_params` (configured to `16384` for `carbon` and `argon`).
  * Keep input context lean with `/drop`, `/clear`, and `/tokens`, and break large multi-file refactors into smaller steps.
  * Use `--thinking-tokens` to bound reasoning budget, or split roles with `--architect` (`carbon`) + `--editor-model argon`.

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
