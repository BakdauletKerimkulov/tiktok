#!/usr/bin/env python3
"""PreToolUse hook: в tutor mode запрещает правки lib/ и test/.

Активен, только пока существует .claude/.tutor-on в корне проекта.
Переключается командой /tutor on|off.

Exit 0 — пропустить вызов, exit 2 — заблокировать и вернуть stderr в модель.
"""
import json
import os
import pathlib
import sys

GUARDED_ROOTS = ("lib", "test")


def main() -> int:
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0  # непонятный вход — не мешаем работе

    project = pathlib.Path(data.get("cwd") or os.getcwd())

    if not (project / ".claude" / ".tutor-on").exists():
        return 0

    raw = (data.get("tool_input") or {}).get("file_path")
    if not raw:
        return 0

    try:
        rel = pathlib.Path(raw).resolve().relative_to(project.resolve())
    except ValueError:
        return 0  # файл вне проекта — не наша область

    if not rel.parts or rel.parts[0] not in GUARDED_ROOTS:
        return 0

    print(
        f"tutor mode: {rel} пишет только автор. "
        f"Дай подсказку текущего уровня (L1-L3) и верни вопрос вместо правки. "
        f"Решение в чате — /tutor solve. Снять режим — /tutor off.",
        file=sys.stderr,
    )
    return 2


if __name__ == "__main__":
    sys.exit(main())
