# Overnight Enforcement System

Automated overnight work execution and verification system for Sparkpit Labs.

## Overview

This system ensures overnight work actually produces results—not just heartbeat spam. Every task must create a tangible output file to be marked complete.

## Components

| File | Purpose |
|------|---------|
| `TODO.md` | Task queue with expected output files |
| `overnight_work.py` | Work executor with verification |
| `morning-check.sh` | Daily verification script |
| `overnight-work-cron.sh` | Hourly cron wrapper |
| `setup-passwordless-sudo.sh` | Passwordless sudo for deployments |

## How It Works

### Task Format (TODO.md)
```markdown
| YYYY-MM-DD | task-name | /abs/path/to/expected_output |
```

### Execution Flow
1. Cron runs hourly: `0 * * * *`
2. `overnight-work-cron.sh` calls `overnight_work.py --run`
3. Script reads TODO.md, finds today's tasks
4. Executes each task
5. **VERIFIES output file exists**
6. If output missing → logs failure

### Morning Verification
- Runs daily at 9 AM: `0 9 * * *`
- Checks all output files exist
- Reports any missing artifacts

## Usage

```bash
# Add a task
python3 overnight_work.py --add "task-name" "/path/to/output.txt"

# Run today's tasks
python3 overnight_work.py --run

# Verify completion
python3 overnight_work.py --check
./morning-check.sh
```

## Rules

1. **Every task needs output** — Nothing counts without artifact
2. **Morning check VERIFIES** — Can't fake completion
3. **NO HEARTBEAT_OK if blocked** — Log failure instead

## Current Tasks (TODO.md)

See `TODO.md` for active overnight tasks.
