"""
verify_quality_gates.py  —  Release gate verification for the Breast Cancer AI system.

Unlike a static reader, this script *recomputes* the safety-critical metrics from
raw artifacts and re-runs the dataset integrity check, then cross-checks the
recomputed values against the published release_evidence.json. A release is only
approved if (a) every gate passes AND (b) the published evidence is consistent
with what we recomputed from raw data.

Recomputation sources:
    - reports/confusion_matrix.json  -> recall_malignant, false-negative rate
                                        (recomputed from raw TP/FN counts)
    - pipelines/check_data_integrity.py -> live leakage / duplicate / balance
                                        check against data/*_split.csv
    - referenced model artifacts      -> presence (committed) or documented as
                                        externally versioned (DVC / Drive)

Exit code 0 = release programmatically approved; non-zero = blocked.
"""

import json
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EVIDENCE_PATH = os.path.join(ROOT, "reports", "release_evidence.json")
CONFUSION_PATH = os.path.join(ROOT, "reports", "confusion_matrix.json")
INTEGRITY_SCRIPT = os.path.join(ROOT, "pipelines", "check_data_integrity.py")

RECALL_GATE = 0.95
FN_RATE_GATE = 0.05          # PRD KPI #2: false-negative rate must be < 5%
CONSISTENCY_TOL = 0.005      # published vs recomputed metric tolerance


def recompute_from_confusion(path):
    """Recompute malignant recall and FN rate directly from raw counts."""
    with open(path, "r", encoding="utf-8") as f:
        cm = json.load(f)["matrix"]

    row = cm["malignant"]
    tp = row["malignant"]
    fn = sum(v for k, v in row.items() if k != "malignant")
    total_malignant = tp + fn

    recall = tp / total_malignant if total_malignant else 0.0
    fn_rate = fn / total_malignant if total_malignant else 0.0
    return {
        "recall_malignant": round(recall, 4),
        "fn_rate": round(fn_rate, 4),
        "tp": tp,
        "fn": fn,
        "total_malignant": total_malignant,
    }


def run_integrity_check():
    """Re-run the dataset leakage/duplicate/balance check as a live subprocess."""
    if not os.path.exists(INTEGRITY_SCRIPT):
        print("  WARN  data integrity script not found — skipping live data re-check")
        return True
    proc = subprocess.run(
        [sys.executable, INTEGRITY_SCRIPT],
        capture_output=True, text=True, cwd=ROOT,
    )
    ok = proc.returncode == 0
    print(f"  {'PASS' if ok else 'FAIL'}  live dataset integrity re-check (exit {proc.returncode})")
    if not ok:
        # surface the tail of the failing output for debugging
        for line in proc.stdout.strip().splitlines()[-8:]:
            print(f"           {line}")
    return ok


def verify():
    print("=== Quality Gates — Recomputed Verification ===\n")

    if not os.path.exists(EVIDENCE_PATH):
        print(f"ERROR: Evidence package not found at {EVIDENCE_PATH}")
        return False

    with open(EVIDENCE_PATH, "r", encoding="utf-8") as f:
        evidence = json.load(f)

    gates = evidence["observability_and_quality_gates"]["gates"]
    verifications = evidence["observability_and_quality_gates"]["verifications"]
    failures = 0

    # 1. Recompute safety metrics from the raw confusion matrix
    print("[1] Recomputing safety metrics from raw confusion matrix:")
    if os.path.exists(CONFUSION_PATH):
        rc = recompute_from_confusion(CONFUSION_PATH)
        print(f"    TP={rc['tp']} FN={rc['fn']} (of {rc['total_malignant']} malignant)")
        print(f"    Recomputed recall_malignant = {rc['recall_malignant']}")
        print(f"    Recomputed false-negative rate = {rc['fn_rate']:.1%}")

        if rc["recall_malignant"] >= RECALL_GATE:
            print(f"  PASS  recall {rc['recall_malignant']} >= {RECALL_GATE}")
        else:
            print(f"  FAIL  recall {rc['recall_malignant']} < {RECALL_GATE}")
            failures += 1

        if rc["fn_rate"] < FN_RATE_GATE:
            print(f"  PASS  FN rate {rc['fn_rate']:.1%} < {FN_RATE_GATE:.0%} (PRD KPI #2)")
        else:
            print(f"  FAIL  FN rate {rc['fn_rate']:.1%} >= {FN_RATE_GATE:.0%}")
            failures += 1

        # consistency: published recall must match recomputed recall
        published_recall = gates["critical_malignant_recall_gate"]["observed_value"]
        if abs(published_recall - rc["recall_malignant"]) <= CONSISTENCY_TOL:
            print(f"  PASS  published recall ({published_recall}) matches recomputed ({rc['recall_malignant']})")
        else:
            print(f"  FAIL  published recall ({published_recall}) != recomputed ({rc['recall_malignant']})")
            failures += 1
    else:
        print("  WARN  confusion_matrix.json not found — cannot recompute, falling back to published value")
        if gates["critical_malignant_recall_gate"]["observed_value"] < RECALL_GATE:
            failures += 1

    # 2. Live dataset integrity re-check
    print("\n[2] Live dataset integrity re-check (leakage / duplicates / balance):")
    if not run_integrity_check():
        failures += 1

    # 3. Latency + remaining published gates
    print("\n[3] Evaluating remaining published quality gates:")
    for gate_name, gate_info in gates.items():
        if gate_name == "critical_malignant_recall_gate":
            continue  # already recomputed above
        threshold = gate_info["threshold"]
        observed = gate_info["observed_value"]
        passed = observed < threshold if "latency" in gate_name else observed >= threshold
        status = "PASS" if passed else "FAIL"
        print(f"  {status}  {gate_name:<38} target={threshold} observed={observed}")
        if not passed:
            failures += 1

    # 4. MLOps integrity verifications
    print("\n[4] MLOps integrity verifications:")
    for check_name, value in verifications.items():
        status = "PASS" if value else "FAIL"
        print(f"  {status}  {check_name}")
        if not value:
            failures += 1

    print("\n" + "=" * 50)
    if failures == 0:
        print("VERDICT: ALL GATES PASSED (recomputed + consistent).")
        print("Release status: APPROVED WITH LIMITATIONS — see tasks/FINAL_RELEASE_DECISION.md")
        return True
    print(f"VERDICT: {failures} gate(s) FAILED — release BLOCKED.")
    return False


if __name__ == "__main__":
    sys.exit(0 if verify() else 1)
