#!/usr/bin/env python3
"""Generate qa-report/bugs.csv from BUG_REPORT.md (single source of truth) and
assert report/CSV consistency. Run from repo root:
    python3 qa-report/scripts/gen-bugs-csv.py
"""
import csv, glob, re, sys, os

REPORT = 'qa-report/BUG_REPORT.md'
OUT = 'qa-report/bugs.csv'
PATCH_DIR = 'qa-report/patches/*.diff'
PATCH_FILES = {os.path.basename(p) for p in glob.glob(PATCH_DIR)}

def map_patch(cell: str) -> str:
    cell = cell.strip()
    if not cell or cell.lower().startswith('none'):
        return 'none'
    ids = re.findall(r'(?:API|WEB)-\d{3}', cell)
    if not ids:
        # maybe already a filename or free text
        names = re.findall(r'[\w-]+\.diff', cell)
        return '; '.join(dict.fromkeys(names)) if names else 'none'
    out = []
    for i in dict.fromkeys(ids):
        match = [f for f in PATCH_FILES if f.startswith(i + '-')]
        out.append(match[0] if match else i)
    return '; '.join(out)

def verified(patch: str, text: str) -> str:
    if patch == 'none':
        return 'no'
    if 'Patch verified' in text or '✔' in text:
        return 'yes'
    return 'no'

def fields_from_section(block: str) -> dict:
    markers = ['Severity', 'Status', 'Root cause', 'Fix', 'Patches', 'Patch',
               'Regression test', 'Test', 'Effort', 'Risk']
    positions = []
    for m in markers:
        for mm in re.finditer(re.escape(f'**{m}:**'), block):
            positions.append((mm.start(), mm.end(), m))
    positions.sort()
    vals = {}
    for idx, (start, end, name) in enumerate(positions):
        stop = positions[idx + 1][0] if idx + 1 < len(positions) else len(block)
        vals.setdefault(name, block[end:stop].strip())
    sev_m = re.search(r'\*\*Severity:\*\*\s*(\w+)', block)
    status_m = re.search(r'\*\*Status:\*\*\s*(\w+)', block)
    patch_cell = vals.get('Patch') or vals.get('Patches') or 'none'
    patch = map_patch(patch_cell)
    test = vals.get('Regression test') or vals.get('Test') or ''
    return {
        'severity': sev_m.group(1) if sev_m else '',
        'status': status_m.group(1) if status_m else 'Confirmed',
        'root_cause': vals.get('Root cause', '').replace('\n', ' ').strip(),
        'patch': patch,
        'patch_verified': verified(patch, patch_cell + ' ' + test),
        'regression_test': test.replace('\n', ' ').strip(),
        'effort': (vals.get('Effort', '').split('|')[0].strip().rstrip('.') or ''),
    }

def parse_report(text: str):
    rows = []
    # sections: ## 2. Critical / ## 3. High -> ### BUG-xxx — title
    for sev, heading in [('Critical', '## 2. Critical'), ('High', '## 3. High')]:
        chunk = text.split(heading, 1)[1]
        # cut at next top-level section
        for stop in ['\n## 4.', '\n## 3.', '\n## 5.']:
            if stop in chunk:
                chunk = chunk.split(stop, 1)[0]
        for m in re.finditer(r'^### ((?:BUG|IMP)-\d+) — (.+)$', chunk, re.M):
            start = m.end()
            nxt = re.search(r'^### |^---$', chunk[start:], re.M)
            block = chunk[start: start + (nxt.start() if nxt else len(chunk))]
            row = {'id': m.group(1), 'title': m.group(2).strip()}
            row.update(fields_from_section(block))
            if not row['severity']:
                row['severity'] = sev
            rows.append(row)
    # tables: ## 4. Medium / ## 5. Low
    for sev, heading in [('Medium', '## 4. Medium'), ('Low', '## 5. Low')]:
        chunk = text.split(heading, 1)[1]
        for stop in ['\n## ', '\n**Bugs with no patch']:
            if stop in chunk:
                chunk = chunk.split(stop, 1)[0]
        for line in chunk.splitlines():
            if not re.match(r'^\| (BUG|IMP)-\d+ \|', line):
                continue
            cells = [c.strip() for c in line.strip().strip('|').split(' | ')]
            assert len(cells) == 6, f'expected 6 cells, got {len(cells)}: {line[:80]}'
            _id, title, conf, root, patch_cell, test = cells
            patch = map_patch(patch_cell)
            rows.append({
                'id': _id, 'title': title,
                'severity': 'Improvement' if _id.startswith('IMP-') else sev,
                'status': conf,
                'root_cause': root, 'patch': patch,
                'patch_verified': verified(patch, patch_cell + ' ' + test),
                'regression_test': test, 'effort': '',
            })
    return rows

def main():
    text = open(REPORT, encoding='utf-8').read()
    rows = parse_report(text)
    rows.sort(key=lambda r: (r['id'].startswith('IMP-'), r['id']))
    ids = [r['id'] for r in rows]

    # ---- assertions ----
    problems = []
    def check(cond, msg):
        if not cond:
            problems.append(msg)

    check(len(ids) == len(set(ids)), 'duplicate IDs')
    bugs = [r for r in rows if r['id'].startswith('BUG-')]
    imps = [r for r in rows if r['id'].startswith('IMP-')]
    sev = {}
    for r in rows:
        sev[r['severity']] = sev.get(r['severity'], 0) + 1

    # verdict sentence
    m = re.search(r'Critical \*\*(\d+)\*\*.*?High \*\*(\d+)\*\*.*?'
                  r'Medium \*\*(\d+)\*\*.*?Low \*\*(\d+)\*\*.*?'
                  r'Improvement \*\*(\d+)\*\* — \*\*(\d+) total\*\* \((\d+) bugs \+ (\d+)',
                  text, re.S)
    check(m, 'verdict severity sentence not found')
    if m:
        vc, vh, vm, vl, vi, vt, vb, vp = map(int, m.groups())
        check(sev.get('Critical') == vc, f"Critical {sev.get('Critical')} != verdict {vc}")
        check(sev.get('High') == vh, f"High {sev.get('High')} != verdict {vh}")
        check(sev.get('Medium') == vm, f"Medium {sev.get('Medium')} != verdict {vm}")
        check(sev.get('Low') == vl, f"Low {sev.get('Low')} != verdict {vl}")
        check(sev.get('Improvement') == vi, f"Improvement {sev.get('Improvement')} != verdict {vi}")
        check(len(rows) == vt, f'rows {len(rows)} != total {vt}')
        check(len(bugs) == vb, f'bugs {len(bugs)} != {vb}')
        check(len(imps) == vp, f'imps {len(imps)} != {vp}')

    patched = [r for r in bugs if r['patch'] != 'none']
    nopatch = sorted(r['id'] for r in bugs if r['patch'] == 'none')
    m = re.search(r'Patched bugs: (\d+)', text)
    check(m and int(m.group(1)) == len(patched), f"patched count mismatch: report {m and m.group(1)} vs csv {len(patched)}")
    m = re.search(r'Bugs with no patch \((\d+)\):\s*([^\n]+(?:\n[^\n]+)*?) —', text)
    check(m and int(m.group(1)) == len(nopatch), f"no-patch count mismatch: report {m and m.group(1)} vs csv {len(nopatch)}")
    if m:
        listed = []
        for tok in re.findall(r'(?:BUG|IMP-)?\d{3}', m.group(2)):
            listed.append(tok if tok.startswith(('BUG', 'IMP')) else 'BUG-' + tok)
        check(sorted(listed) == nopatch, f'no-patch list differs: report-only={set(listed)-set(nopatch)} csv-only={set(nopatch)-set(listed)}')

    m = re.search(r'Confirmed: (\d+) bugs \+ (\d+) improvements; Suspected: (\d+)', text)
    conf_b = sum(1 for r in bugs if r['status'] == 'Confirmed')
    conf_i = sum(1 for r in imps if r['status'] == 'Confirmed')
    sus = sorted(r['id'] for r in rows if r['status'] == 'Suspected')
    if m:
        check((conf_b, conf_i) == (int(m.group(1)), int(m.group(2))),
              f'confirmed mismatch: csv {conf_b}+{conf_i} vs report {m.group(1)}+{m.group(2)}')
        check(len(sus) == int(m.group(3)), f"suspected {len(sus)} != report {m.group(3)}")

    for r in rows:
        check(r['severity'] in {'Critical', 'High', 'Medium', 'Low', 'Improvement'}, f"{r['id']} bad severity")
        check(r['status'] in {'Confirmed', 'Suspected'}, f"{r['id']} bad status {r['status']!r}")
        check(r['title'] and len(r['title']) > 5, f"{r['id']} empty title")
        check(r['root_cause'], f"{r['id']} empty root_cause")
        check(r['regression_test'], f"{r['id']} empty regression_test")
        for p in [x.strip() for x in r['patch'].split(';') if x.strip() != 'none']:
            check(p in PATCH_FILES, f"{r['id']} patch file missing: {p}")
    check('BUG-018' not in ids, 'BUG-018 must stay unused')
    check(ids == sorted(ids, key=lambda k: (k.startswith('IMP-'), k)), 'IDs not ordered')

    with open(OUT, 'w', newline='', encoding='utf-8') as fh:
        w = csv.DictWriter(fh, fieldnames=['id', 'severity', 'status', 'title', 'root_cause',
                                           'patch', 'patch_verified', 'regression_test', 'effort'])
        w.writeheader()
        for r in rows:
            w.writerow({k: r.get(k, '') for k in w.fieldnames})

    print(f'CSV: {len(rows)} rows ({len(bugs)} bugs + {len(imps)} IMP) | severity {sev}')
    print(f'patched {len(patched)} | no-patch {len(nopatch)} | suspected {sus} | verdict+lists consistent')
    if problems:
        print('ASSERTION FAILURES:')
        for p in problems:
            print('  -', p)
        sys.exit(1)
    print('ALL ASSERTIONS PASS')

if __name__ == '__main__':
    main()
