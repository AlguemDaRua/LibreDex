#!/usr/bin/env python3
"""Static checker for Dart test files, for when `dart` is unavailable.

Deliberately narrow. It only reports things that are *literally stated* in
the source, never inferred, because an earlier version of this tool inferred
"required" from nullability and produced 55 false positives on Drift's
generated classes.

Two checks:

  1. A constructor call that omits a parameter marked `required`.
  2. An enum member that does not appear in the enum body.

Both are read straight from the declarations, so a hit here means the file
genuinely will not compile. It does not check types, values, or logic - it
exists to catch the mechanical mistakes that stop a test file loading at
all.

Usage:  python3 tools/check_test_symbols.py
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def dart_files(*roots: str) -> list[Path]:
    out: list[Path] = []
    for root in roots:
        out.extend(sorted((ROOT / root).rglob("*.dart")))
    return out


def class_body(source: str, name: str) -> str | None:
    m = re.search(r"\bclass\s+" + re.escape(name) + r"\b[^{]*\{", source)
    if not m:
        return None
    start, depth, i = m.end(), 1, m.end()
    while i < len(source) and depth > 0:
        if source[i] == "{":
            depth += 1
        elif source[i] == "}":
            depth -= 1
        i += 1
    return source[start:i - 1]


def split_top_level(text: str) -> list[str]:
    parts, buf, depth = [], "", 0
    for ch in text:
        if ch in "([{<":
            depth += 1
        elif ch in ")]}>":
            depth -= 1
        if ch == "," and depth == 0:
            parts.append(buf.strip())
            buf = ""
        else:
            buf += ch
    if buf.strip():
        parts.append(buf.strip())
    return [p for p in parts if p]


def required_params(body: str) -> set[str]:
    """Names of constructor params literally marked `required`.

    Matches both `required this.foo` and `required Type foo`.
    """
    m = re.search(r"\b\w+\s*\(\s*\{(.*?)\}\s*\)", body, re.S)
    if not m:
        return set()
    inner = re.sub(r"//[^\n]*", "", m.group(1))
    inner = re.sub(r"/\*.*?\*/", "", inner, flags=re.S)
    out: set[str] = set()
    for part in split_top_level(inner):
        if not part.startswith("required"):
            continue
        name = re.search(r"(?:this\.)?(\w+)\s*$", part.replace("required", "", 1).strip())
        if name:
            out.add(name.group(1))
    return out


def main() -> int:
    lib_sources = [f.read_text() for f in dart_files("lib")]

    classes: dict[str, set[str]] = {}
    enums: dict[str, set[str]] = {}
    for src in lib_sources:
        for name in re.findall(r"\bclass\s+(\w+)\b", src):
            body = class_body(src, name)
            if body and name not in classes:
                req = required_params(body)
                if req:
                    classes[name] = req
        for name, body in re.findall(r"\benum\s+(\w+)\s*\{([^}]*)\}", src, re.S):
            # Comments have to go first: doc comments contain semicolons
            # ("(default; keeps the classic calculator intact)"), and
            # splitting on `;` before stripping them truncates the member
            # list to whatever words appear before the comment's semicolon.
            body = re.sub(r"//[^\n]*", "", body)
            body = re.sub(r"/\*.*?\*/", "", body, flags=re.S)
            # Enhanced enums carry fields and methods after a `;`, and their
            # members take constructor arguments (`small(...)`), so members
            # are only what precedes the semicolon and may be followed by a
            # paren rather than a comma.
            decl = body.split(";")[0]
            members = set(re.findall(r"(\w+)\s*(?:,|\(|$)", decl))
            enums.setdefault(name, set()).update(members)

    problems: list[str] = []

    for test in dart_files("test"):
        text = test.read_text()
        rel = test.relative_to(ROOT)

        for cls, req in classes.items():
            for call in re.finditer(r"\b" + re.escape(cls) + r"\s*\(", text):
                start = call.end()
                depth, i = 1, start
                while i < len(text) and depth > 0:
                    if text[i] == "(":
                        depth += 1
                    elif text[i] == ")":
                        depth -= 1
                    i += 1
                args = text[start:i - 1]
                passed = {m.group(1) for m in re.finditer(r"(\w+)\s*:", args)}
                missing = req - passed
                if missing:
                    line = text[:call.start()].count("\n") + 1
                    problems.append(
                        f"{rel}:{line}: {cls}(...) missing required: "
                        f"{', '.join(sorted(missing))}"
                    )

        for enum_name, members in enums.items():
            for m in re.finditer(r"\b" + re.escape(enum_name) + r"\.(\w+)", text):
                if m.group(1) in members or m.group(1) == "values":
                    continue
                line = text[:m.start()].count("\n") + 1
                problems.append(
                    f"{rel}:{line}: {enum_name}.{m.group(1)} is not a member "
                    f"(have: {', '.join(sorted(members))})"
                )

    if problems:
        print(f"{len(problems)} problem(s) found:\n")
        for p in problems:
            print("  " + p)
        return 1

    print("ok: no missing `required` args, no unknown enum members")
    return 0


if __name__ == "__main__":
    sys.exit(main())
