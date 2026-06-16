import os
import sys
import time
import random
import subprocess

class ClinicalTelemetryExporter:
    """Clinical telemetry collection — exports Prometheus-compatible metrics and manages retraining triggers."""

    def __init__(self, metrics_file="monitoring/live_metrics.prom"):
        self.metrics_file = metrics_file
        self.feedback_pool = []
        self.low_confidence_events = 0
        self.total_predictions = 0
        self.confidence_scores = []
        self.latency_samples_ms = []  # p95 inference latency samples collected from client telemetry

        os.makedirs(os.path.dirname(self.metrics_file), exist_ok=True)
        print("[Telemetry] Active monitoring controller initialized.")

    def record_prediction(self, model_class, confidence, latency_ms=None, physician_override=None):
        """Records a clinical prediction event from Flutter/Streamlit telemetry."""
        self.total_predictions += 1
        is_low_confidence = confidence < 0.70

        self.confidence_scores.append(confidence)

        if latency_ms is not None:
            self.latency_samples_ms.append(latency_ms)

        if is_low_confidence:
            self.low_confidence_events += 1
            print(f"[Alert] Low-confidence prediction detected (Class: {model_class}, Confidence: {confidence:.3f})")

        if physician_override is not None:
            override_event = {
                "timestamp": time.time(),
                "model_class": model_class,
                "physician_override": physician_override,
                "confidence": confidence
            }
            self.feedback_pool.append(override_event)
            print(f"[Feedback] Physician corrected scan! Model: {model_class} -> Physician: {physician_override}")

        self.export_prometheus_metrics()

    def export_prometheus_metrics(self):
        """Writes a Prometheus text-format exposition file scraped by prometheus.yml."""
        low_confidence_rate = (self.low_confidence_events / self.total_predictions) if self.total_predictions > 0 else 0.0
        avg_confidence = (sum(self.confidence_scores) / len(self.confidence_scores)) if self.confidence_scores else 0.0

        # Compute p95 latency from collected samples
        if self.latency_samples_ms:
            sorted_latencies = sorted(self.latency_samples_ms)
            p95_idx = max(0, int(len(sorted_latencies) * 0.95) - 1)
            p95_latency = sorted_latencies[p95_idx]
        else:
            p95_latency = 0.0

        lines = [
            "# HELP breast_cancer_predictions_total Total count of diagnostic predictions processed.",
            "# TYPE breast_cancer_predictions_total counter",
            f"breast_cancer_predictions_total {self.total_predictions}",

            "# HELP breast_cancer_low_confidence_events_total Total count of low-confidence detections.",
            "# TYPE breast_cancer_low_confidence_events_total counter",
            f"breast_cancer_low_confidence_events_total {self.low_confidence_events}",

            "# HELP breast_cancer_low_confidence_rate Current ratio of low-confidence scans (fallback rate).",
            "# TYPE breast_cancer_low_confidence_rate gauge",
            f"breast_cancer_low_confidence_rate {low_confidence_rate:.4f}",

            "# HELP breast_cancer_physician_corrections_total Total physician ground-truth overrides logged in Firestore.",
            "# TYPE breast_cancer_physician_corrections_total counter",
            f"breast_cancer_physician_corrections_total {len(self.feedback_pool)}",

            "# HELP breast_cancer_avg_confidence_score Rolling average model prediction confidence score.",
            "# TYPE breast_cancer_avg_confidence_score gauge",
            f"breast_cancer_avg_confidence_score {avg_confidence:.4f}",

            "# HELP breast_cancer_inference_latency_p95_ms p95 on-device inference latency in milliseconds.",
            "# TYPE breast_cancer_inference_latency_p95_ms gauge",
            f"breast_cancer_inference_latency_p95_ms {p95_latency:.1f}",
        ]

        with open(self.metrics_file, "w") as f:
            f.write("\n".join(lines) + "\n")
            
    def check_retraining_rules(self):
        """Evaluates automated clinical trigger conditions to launch pipelines/retrain_ci.py."""
        print("\n--- Evaluating Clinical Telemetry Retraining Rules ---")
        override_count = len(self.feedback_pool)
        low_confidence_rate = (self.low_confidence_events / self.total_predictions) if self.total_predictions > 0 else 0.0
        
        print(f"  * Total Physician Overrides: {override_count}/100")
        print(f"  * Low-Confidence Ratio: {low_confidence_rate:.1%} (Trigger limit: > 15.0%)")
        
        trigger_pipeline = False
        
        if override_count >= 100:
            print("[Trigger Activated] Feedback dataset pool has reached the clinical 100-sample limit!")
            trigger_pipeline = True
        elif low_confidence_rate > 0.15:
            print("[Trigger Activated] Performance degradation detected! Low-confidence rate exceeds 15%!")
            trigger_pipeline = True
            
        if trigger_pipeline:
            print("\n[MLOps] Automatically initiating retraining CI pipeline: pipelines/retrain_ci.py...")
            try:
                # Run the MLOps retraining pipeline synchronously to simulate execution
                result = subprocess.run(
                    [sys.executable, "pipelines/retrain_ci.py"],
                    capture_output=True,
                    text=True,
                    check=True
                )
                print(result.stdout)
                print("[MLOps] Retraining CI Pipeline executed successfully. New Challenger validated.")
                return True
            except Exception as e:
                print(f"[Error] Failed to execute retraining pipeline: {e}")
                return False
        else:
            print("[MLOps] System telemetry stable. No triggers activated.")
            return False


if __name__ == "__main__":
    exporter = ClinicalTelemetryExporter()
    
    # 1. Simulate 40 incoming scans under normal operating conditions
    print("\n=== Phase 1: Simulating standard incoming telemetry scans ===")
    for _ in range(40):
        c = random.uniform(0.72, 0.99)
        lat = random.uniform(110, 145)  # on-device latency within SLO
        exporter.record_prediction(model_class=random.choice([0, 2]), confidence=c, latency_ms=lat)

    # 2. Simulate clinical drift: doctors upload low-quality or out-of-domain scans
    # causing a spike in low-confidence predictions and 102 physician-corrected overrides
    print("\n=== Phase 2: Simulating clinical drift & physician-corrected overrides ===")
    for i in range(102):
        c = random.uniform(0.50, 0.68)  # low confidence triggers fallback
        lat = random.uniform(130, 160)  # slightly elevated latency during drift
        exporter.record_prediction(
            model_class=random.choice([0, 2]),
            confidence=c,
            latency_ms=lat,
            physician_override=1
        )
        
    # 3. Check retraining triggers and run evaluation CI automatically
    exporter.check_retraining_rules()
