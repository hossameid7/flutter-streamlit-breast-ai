"""
retrain_ci.py  —  Automated Challenger-vs-Champion retraining pipeline.

This script is triggered by monitoring/feedback_handler.py when one of these
conditions fires:
    1) Physician-corrected samples pool in Firestore reaches >= 100
    2) Low-confidence prediction rate exceeds 15%

What it does (briefly):
    - Loads the current champion metrics from reports/release_evidence.json
    - Simulates a challenger training run (in prod this would call the real
      training notebook or a dedicated training script)
    - Compares challenger metrics against champion gates
    - If the challenger passes, promotes it in the MLflow registry
"""

import json
import os
import sys
import random
import time

# ── paths ──
EVIDENCE_PATH = os.path.join("reports", "release_evidence.json")
REGISTRY_DIR = os.path.join("reports", "models")

# quality gates we need to beat (same thresholds as in the PRD / DoD)
RECALL_GATE = 0.95        # malignant recall must be >= this
LATENCY_GATE_CLS = 150.0  # p95 ms for classification
LATENCY_GATE_SEG = 400.0  # p95 ms for segmentation


def load_champion_metrics():
    """Read the current champion numbers from the evidence package."""
    if not os.path.exists(EVIDENCE_PATH):
        print(f"[retrain_ci] WARNING: {EVIDENCE_PATH} not found, using defaults")
        return {
            "recall_malignant": 0.962,
            "accuracy": 0.875,
            "p95_latency_cls": 128.0,
            "p95_latency_seg": 345.0,
        }

    with open(EVIDENCE_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    cls_metrics = data["model_evaluation_metrics"]["classification"]
    seg_metrics = data["model_evaluation_metrics"]["segmentation"]

    return {
        "recall_malignant": cls_metrics["recall_malignant"],
        "accuracy": cls_metrics["accuracy"],
        "p95_latency_cls": cls_metrics["p95_latency_ms"],
        "p95_latency_seg": seg_metrics["p95_latency_ms"],
    }


def simulate_challenger_training():
    """
    In a real setup this would:
        1. Merge BUSI base data with the new Firestore feedback samples
        2. Fine-tune the ResNet-50 / ResNet-34 U-Net on the merged set
        3. Evaluate on the held-out test_split.csv

    For now we simulate a challenger model that is slightly better or
    slightly worse than the current champion — the gate comparison logic
    below is the important part.
    """
    print("[retrain_ci] Training challenger model on merged dataset ...")
    # pretend we're training for a bit
    time.sleep(1)

    # simulated challenger results (random jitter around known good values)
    challenger = {
        "recall_malignant": round(random.uniform(0.940, 0.975), 3),
        "accuracy":         round(random.uniform(0.860, 0.895), 3),
        "f1_score":         round(random.uniform(0.870, 0.900), 3),
        "p95_latency_cls":  round(random.uniform(120, 145), 1),
        "p95_latency_seg":  round(random.uniform(330, 390), 1),
    }

    print(f"[retrain_ci] Challenger results:")
    for k, v in challenger.items():
        print(f"    {k}: {v}")

    return challenger


def compare_and_promote(champion, challenger):
    """
    Run the quality-gate checks.  The challenger must:
        - Match or beat the champion on malignant recall
        - Stay within our latency SLOs
        - Pass the absolute recall threshold (>= 0.95)
    """
    print("\n[retrain_ci] -- Quality-Gate Evaluation --")
    passed = True

    # Gate 1: absolute recall floor
    if challenger["recall_malignant"] < RECALL_GATE:
        print(f"  FAIL  recall_malignant {challenger['recall_malignant']} < {RECALL_GATE}")
        passed = False
    else:
        print(f"  PASS  recall_malignant {challenger['recall_malignant']} >= {RECALL_GATE}")

    # Gate 2: must not be worse than the current champion recall
    if challenger["recall_malignant"] < champion["recall_malignant"]:
        print(f"  FAIL  challenger recall ({challenger['recall_malignant']}) < champion ({champion['recall_malignant']})")
        passed = False
    else:
        print(f"  PASS  challenger recall >= champion recall")

    # Gate 3: latency SLOs
    if challenger["p95_latency_cls"] > LATENCY_GATE_CLS:
        print(f"  FAIL  classification latency {challenger['p95_latency_cls']} ms > {LATENCY_GATE_CLS} ms")
        passed = False
    else:
        print(f"  PASS  classification latency {challenger['p95_latency_cls']} ms")

    if challenger["p95_latency_seg"] > LATENCY_GATE_SEG:
        print(f"  FAIL  segmentation latency {challenger['p95_latency_seg']} ms > {LATENCY_GATE_SEG} ms")
        passed = False
    else:
        print(f"  PASS  segmentation latency {challenger['p95_latency_seg']} ms")

    print()
    if passed:
        print("[retrain_ci] All gates passed — promoting challenger to Production in MLflow registry.")
        promote_model(challenger)
    else:
        print("[retrain_ci] Challenger REJECTED — keeping current champion weights.")

    return passed


def promote_model(metrics):
    """
    Simulates promoting the new model version in MLflow.
    In production this would call mlflow.register_model() and transition
    the stage from 'Staging' -> 'Production'.
    """
    version = f"v{random.randint(2,9)}.{random.randint(0,9)}.0-rc1"
    print(f"[retrain_ci] Registering new champion as BreastResNet50 {version}")
    print(f"[retrain_ci] Model weights would be exported to .tflite and pushed via Firebase Remote Config.")

    # log the promotion event
    event = {
        "promoted_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "version": version,
        "metrics": metrics,
    }
    log_path = os.path.join(REGISTRY_DIR, "promotion_log.json")
    os.makedirs(REGISTRY_DIR, exist_ok=True)

    history = []
    if os.path.exists(log_path):
        with open(log_path, "r", encoding="utf-8") as f:
            history = json.load(f)
    history.append(event)

    with open(log_path, "w", encoding="utf-8") as f:
        json.dump(history, f, indent=2, ensure_ascii=False)

    print(f"[retrain_ci] Promotion logged to {log_path}")


# ── main ──
def main():
    print("=" * 55)
    print(" Breast Cancer AI — Retraining CI Pipeline")
    print("=" * 55)

    champion = load_champion_metrics()
    print(f"\n[retrain_ci] Current champion metrics loaded:")
    for k, v in champion.items():
        print(f"    {k}: {v}")

    challenger = simulate_challenger_training()
    result = compare_and_promote(champion, challenger)

    if result:
        print("\n[retrain_ci] Pipeline finished: new model promoted.")
    else:
        print("\n[retrain_ci] Pipeline finished: champion unchanged.")

    return 0 if result else 1


if __name__ == "__main__":
    sys.exit(main())
