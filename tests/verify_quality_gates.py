import json
import os
import sys

def verify_gates(evidence_path):
    print("=== Quality Gates Automated Verification ===")
    
    if not os.path.exists(evidence_path):
        print(f"ERROR: Evidence package not found at {evidence_path}")
        sys.exit(1)
        
    with open(evidence_path, "r", encoding="utf-8") as f:
        evidence = json.load(f)
        
    gates = evidence["observability_and_quality_gates"]["gates"]
    verifications = evidence["observability_and_quality_gates"]["verifications"]
    
    failures = 0
    
    # 1. Evaluate gates
    print("\nEvaluating Quality Gates:")
    for gate_name, gate_info in gates.items():
        metric = gate_info["metric"]
        threshold = gate_info["threshold"]
        observed = gate_info["observed_value"]
        
        # Determine success condition dynamically
        passed = False
        if "latency" in gate_name:
            passed = observed < threshold
        else:
            passed = observed >= threshold
            
        status_str = "PASS" if passed else "FAIL"
        print(f"  * {gate_name:<35}: Target: {threshold:<6} | Observed: {observed:<6} | Status: [{status_str}]")
        
        if not passed:
            failures += 1
            
    # 2. Evaluate MLOps integrity verifications
    print("\nEvaluating MLOps Integrity Verifications:")
    for check_name, value in verifications.items():
        status_str = "PASS" if value else "FAIL"
        print(f"  * {check_name:<35}: Status: [{status_str}]")
        if not value:
            failures += 1
            
    print("\n==========================================")
    if failures == 0:
        print("VERDICT: ALL QUALITY GATES PASSED! Release is programmatically APPROVED.")
        return True
    else:
        print(f"VERDICT: FAILED {failures} quality gate(s). Release is programmatically BLOCKED.")
        return False

if __name__ == "__main__":
    evidence_file = os.path.join("reports", "release_evidence.json")
    success = verify_gates(evidence_file)
    if not success:
        sys.exit(1)
    sys.exit(0)
