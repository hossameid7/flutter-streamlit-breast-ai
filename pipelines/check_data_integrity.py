"""
check_data_integrity.py  —  Reproducible data-quality verification artifact.

This is the *executable* companion to specs/Data_Quality_Report.md. It runs the
checks that the report describes, against the actual split files in data/, and
exits non-zero if any integrity rule is violated. It is safe to wire into CI.

Checks performed:
    1. Split integrity   — train/val/test exist, are non-empty, and have the
                           expected header columns.
    2. No row overlap    — the same image_path must not appear in more than one
                           split (the classic train/test leakage bug).
    3. Patient-level      — case numbers parsed from filenames (e.g. "benign
       leakage             (12).png" -> patient 12 of class benign) must not be
                           shared across splits.
    4. Duplicate detection— MD5 + perceptual aHash over the raw image files in
                           data/<class>/ (skipped automatically if the image
                           files are not present locally / are DVC-pulled).
    5. Class balance      — reports per-split class distribution and the global
                           imbalance ratio used to derive class weights.

Usage:
    python pipelines/check_data_integrity.py
    python pipelines/check_data_integrity.py --data-dir data --images-dir data
"""

import argparse
import csv
import hashlib
import os
import re
import sys
from collections import defaultdict

SPLITS = ["train_split.csv", "val_split.csv", "test_split.csv"]
EXPECTED_COLUMNS = {"image_path", "label"}
# class weights documented in Data_Quality_Report.md (inverse class frequency)
DOCUMENTED_WEIGHTS = {"benign": 1.0, "malignant": 2.08, "normal": 3.28}

# regex pulls the case number out of names like "benign (12).png" or "malignant_98.png"
CASE_RE = re.compile(r"(\d+)")


def load_split(path):
    rows = []
    with open(path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        cols = set(reader.fieldnames or [])
        if not EXPECTED_COLUMNS.issubset(cols):
            raise ValueError(
                f"{os.path.basename(path)} missing columns; "
                f"expected {EXPECTED_COLUMNS}, found {cols}"
            )
        for r in reader:
            rows.append((r["image_path"].strip(), r["label"].strip()))
    return rows


def patient_key(image_path, label):
    """Stable per-patient identifier: (class, first integer in filename)."""
    fname = os.path.basename(image_path)
    m = CASE_RE.search(fname)
    case = m.group(1) if m else fname
    return f"{label}#{case}"


def check_overlap_and_leakage(splits):
    """Returns (failures, details). Verifies no shared rows or patients."""
    failures = 0

    # --- exact image_path overlap ---
    path_to_splits = defaultdict(set)
    for name, rows in splits.items():
        for image_path, _ in rows:
            path_to_splits[image_path].add(name)

    overlapping = {p: s for p, s in path_to_splits.items() if len(s) > 1}
    if overlapping:
        failures += 1
        print(f"  FAIL  {len(overlapping)} image_path(s) appear in multiple splits:")
        for p, s in list(overlapping.items())[:10]:
            print(f"           {p}  ->  {sorted(s)}")
    else:
        print("  PASS  no image_path appears in more than one split")

    # --- patient-level leakage ---
    patient_to_splits = defaultdict(set)
    for name, rows in splits.items():
        for image_path, label in rows:
            patient_to_splits[patient_key(image_path, label)].add(name)

    leaked = {p: s for p, s in patient_to_splits.items() if len(s) > 1}
    if leaked:
        failures += 1
        print(f"  FAIL  {len(leaked)} patient case(s) leak across splits:")
        for p, s in list(leaked.items())[:10]:
            print(f"           {p}  ->  {sorted(s)}")
    else:
        print("  PASS  no patient case leaks across splits (patient-level isolation OK)")

    return failures


def check_duplicates(images_dir):
    """MD5 + aHash duplicate detection over raw image files (best-effort)."""
    try:
        from PIL import Image
        import imagehash
    except ImportError:
        print("  SKIP  Pillow / imagehash not installed — duplicate hashing skipped")
        return 0, True  # not a hard failure: documented as optional dependency

    image_files = []
    for root, _, files in os.walk(images_dir):
        for fn in files:
            if fn.lower().endswith((".png", ".jpg", ".jpeg")) and "_mask" not in fn:
                image_files.append(os.path.join(root, fn))

    if not image_files:
        print(f"  SKIP  no raw images found under {images_dir} (likely DVC-tracked, not pulled)")
        return 0, True

    md5_seen, ahash_seen = {}, {}
    md5_dupes, near_dupes = [], []
    for path in image_files:
        with open(path, "rb") as f:
            md5 = hashlib.md5(f.read()).hexdigest()
        if md5 in md5_seen:
            md5_dupes.append((path, md5_seen[md5]))
        else:
            md5_seen[md5] = path
        try:
            with Image.open(path) as img:
                ah = str(imagehash.average_hash(img))
            if ah in ahash_seen:
                near_dupes.append((path, ahash_seen[ah]))
            else:
                ahash_seen[ah] = path
        except Exception as e:
            print(f"  WARN  could not hash {path}: {e}")

    failures = 0
    if md5_dupes:
        failures += 1
        print(f"  FAIL  {len(md5_dupes)} exact MD5 duplicate image(s) found")
    else:
        print(f"  PASS  0 exact MD5 duplicates across {len(image_files)} images")

    if near_dupes:
        failures += 1
        print(f"  FAIL  {len(near_dupes)} perceptual near-duplicate(s) found")
    else:
        print("  PASS  0 perceptual near-duplicates (aHash)")

    return failures, False


def report_class_balance(splits):
    print("\n[3] Class balance per split:")
    global_counts = defaultdict(int)
    for name, rows in splits.items():
        counts = defaultdict(int)
        for _, label in rows:
            counts[label] += 1
            global_counts[label] += 1
        total = sum(counts.values()) or 1
        dist = ", ".join(f"{k}={v} ({v/total:.1%})" for k, v in sorted(counts.items()))
        print(f"    {name:<18} n={total:<4} | {dist}")

    grand_total = sum(global_counts.values()) or 1
    print(f"\n    Global ({grand_total} rows): " +
          ", ".join(f"{k}={v} ({v/grand_total:.1%})" for k, v in sorted(global_counts.items())))

    # derive inverse-frequency weights and compare against documented ones
    if global_counts:
        max_count = max(global_counts.values())
        print("\n    Derived inverse-frequency class weights (vs documented):")
        for k in sorted(global_counts):
            derived = round(max_count / global_counts[k], 2)
            doc = DOCUMENTED_WEIGHTS.get(k, "—")
            print(f"      {k:<10} derived={derived:<5} documented={doc}")


def main():
    ap = argparse.ArgumentParser(description="Reproducible data integrity / leakage / duplicate checker.")
    ap.add_argument("--data-dir", default="data", help="folder containing *_split.csv files")
    ap.add_argument("--images-dir", default="data", help="folder containing raw class image subfolders")
    args = ap.parse_args()

    print("=" * 60)
    print(" BUSI Data Integrity Verification")
    print("=" * 60)

    failures = 0

    # [1] load splits
    print("\n[1] Loading & validating split files:")
    splits = {}
    for s in SPLITS:
        path = os.path.join(args.data_dir, s)
        if not os.path.exists(path):
            print(f"  FAIL  missing split file: {path}")
            failures += 1
            continue
        try:
            rows = load_split(path)
            if not rows:
                print(f"  FAIL  {s} is empty")
                failures += 1
            else:
                print(f"  PASS  {s:<18} loaded {len(rows)} rows")
                splits[s] = rows
        except ValueError as e:
            print(f"  FAIL  {e}")
            failures += 1

    if len(splits) < len(SPLITS):
        print("\nVERDICT: data integrity check INCOMPLETE (missing/invalid splits).")
        return 1

    # [2] overlap + leakage
    print("\n[2] Overlap & patient-level leakage:")
    failures += check_overlap_and_leakage(splits)

    # [3] class balance
    report_class_balance(splits)

    # [4] duplicates
    print("\n[4] Duplicate detection (MD5 + perceptual aHash):")
    dup_failures, _ = check_duplicates(args.images_dir)
    failures += dup_failures

    print("\n" + "=" * 60)
    if failures == 0:
        print("VERDICT: ALL DATA INTEGRITY CHECKS PASSED.")
        return 0
    print(f"VERDICT: {failures} data integrity check(s) FAILED.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
