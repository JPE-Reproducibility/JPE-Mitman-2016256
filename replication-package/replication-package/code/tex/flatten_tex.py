#!/usr/bin/env python3
r"""
flatten_tex.py -- emit a self-contained .tex for the compiled paper.

The shipped manuscript (MacroElasticity_JPE_Rev3_1_I.tex) is a skeleton: every
number that the pipeline produces enters through an \input{} of a file in
output/tables/, and the reference list enters through bibtex. Compiling it
therefore yields a PDF whose content cannot be diffed against the shipped
source.

This script resolves those \input{}s against the freshly generated tables and
splices the .bbl in for \bibliography{}, writing one flat file. Diffing the
shipped skeleton against the flat file shows exactly which content the run
injected -- i.e. every reproduced number, in context.

Usage:  python3 flatten_tex.py <main.tex> <out.tex> [search-dir ...]
"""
import os
import re
import sys

INPUT_RE = re.compile(r'\\input\s*\{([^}]*)\}')
BIB_RE = re.compile(r'\\bibliography\s*\{([^}]*)\}')


def strip_comment(line):
    """Return the code part of a line, honouring \\% escapes."""
    out = []
    i = 0
    while i < len(line):
        c = line[i]
        if c == '\\' and i + 1 < len(line):
            out.append(line[i:i + 2])
            i += 2
            continue
        if c == '%':
            break
        out.append(c)
        i += 1
    return ''.join(out)


def resolve(name, base, search_dirs):
    cands = [name, name + '.tex'] if not name.endswith('.tex') else [name]
    for d in [base] + search_dirs:
        for c in cands:
            p = os.path.join(d, c)
            if os.path.isfile(p):
                return p
    return None


def expand(path, search_dirs, bbl, seen, main_root, depth=0):
    if depth > 20:
        sys.exit('ERROR: \\input nesting too deep at %s' % path)
    base = os.path.dirname(os.path.abspath(path))
    out = []
    with open(path, encoding='utf-8', errors='replace') as fh:
        for lineno, line in enumerate(fh, 1):
            code = strip_comment(line)

            m = INPUT_RE.search(code)
            if m:
                name = m.group(1).strip()
                target = resolve(name, base, search_dirs)
                if target is None:
                    sys.exit('ERROR: %s:%d cannot resolve \\input{%s}'
                             % (path, lineno, name))
                rel = os.path.relpath(target, os.path.dirname(os.path.abspath(main_root[0])))
                seen.append(rel)
                out.append('%%--- BEGIN generated: %s ---\n' % rel)
                out.append(expand(target, search_dirs, bbl, seen, main_root, depth + 1))
                if not out[-1].endswith('\n'):
                    out.append('\n')
                out.append('%%--- END generated: %s ---\n' % rel)
                continue

            m = BIB_RE.search(code)
            if m and bbl and os.path.isfile(bbl):
                out.append('%%--- BEGIN generated: %s ---\n' % os.path.basename(bbl))
                with open(bbl, encoding='utf-8', errors='replace') as bf:
                    out.append(bf.read())
                out.append('\n%%--- END generated: %s ---\n' % os.path.basename(bbl))
                seen.append(os.path.basename(bbl))
                continue

            out.append(line)
    return ''.join(out)


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    main_tex, out_tex = sys.argv[1], sys.argv[2]
    search_dirs = [os.path.abspath(d) for d in sys.argv[3:]]
    bbl = os.path.splitext(main_tex)[0] + '.bbl'

    seen = []
    text = expand(main_tex, search_dirs, bbl, seen, [main_tex])
    os.makedirs(os.path.dirname(os.path.abspath(out_tex)), exist_ok=True)
    with open(out_tex, 'w', encoding='utf-8') as fh:
        fh.write(text)
    print('flatten_tex.py: wrote %s (%d spliced files)' % (out_tex, len(seen)))
    for s in seen:
        print('    + %s' % s)


if __name__ == '__main__':
    main()
