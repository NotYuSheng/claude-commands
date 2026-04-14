# claude-commands

Personal Claude Code slash commands, available system-wide in every project.

## Commands

| Command | Description |
|---|---|
| `/clean-branches` | Audit and delete merged/stale local git branches |
| `/review-pr` | Review open PR comments, address valid ones, reply and resolve threads |
| `/gen-puml` | Regenerate all PlantUML diagrams in `docs/` |
| `/ship` | Create issue → branch → commit → PR, wired into the project board |

---

## Setup

### 1. Clone the repo

```bash
git clone git@github.com:<your-username>/claude-commands.git ~/Desktop/claude-commands
```

### 2. Install

```bash
cd ~/Desktop/claude-commands
./install.sh
```

This symlinks everything in `commands/` into `~/.claude/commands/`, making all commands available as `/clean-branches`, `/review-pr`, etc. in every Claude Code session.

Run `./install.sh` again after adding new commands — it's idempotent.

---

## Adding a new command

1. Write your command as a `.md` file in `commands/`.
2. Run `./install.sh`.
3. Commit and push.

---

## Structure

```
claude-commands/
├── commands/
│   ├── clean-branches.md
│   ├── gen-puml.md
│   ├── review-pr.md
│   └── ship.md
├── install.sh           # Symlinks commands/ into ~/.claude/commands/
└── README.md
```
