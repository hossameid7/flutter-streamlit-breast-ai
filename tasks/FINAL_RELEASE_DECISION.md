# Final Release Decision

**Project:** Flutter + Streamlit system for breast cancer diagnostics and tumor segmentation on ultrasound images.  
**Team:** Karim, Mansur, Ramil, Ilyas, Ivan, Hossam.  
**Stack:** Flutter + TFLite (on-device inference), Streamlit + Keras (server inference), Firebase (Auth, Firestore, Crashlytics), Prometheus + Grafana (monitoring), MLflow (Model Registry).

---

## 1. Readiness Table

We went through every component of the system and verified that it's actually working, not just described on paper:

| Область оценки | Готовность | Ссылка на артефакт / Код | Ключевые показатели и подтверждение |
| :--- | :--- | :--- | :--- |
| **Requirements / acceptance criteria** | Да | [PRD.md](../specs/PRD.md), [DoD.md](../specs/DoD.md) | Все критерии собраны в единую таблицу PRD. Метрики эффективности (F1-score 0.88, Recall malignant 0.969) и latency SLO (Classification < 150 мс, Segmentation < 400 мс) зафиксированы. |
| **Data / dataset quality** | Да | [Data_Spec.md](../specs/Data_Spec.md), [Data_Quality_Report.md](../specs/Data_Quality_Report.md) | УЗИ-датасет BUSI (780 снимков) верифицирован. Ошибки дубликатов устранены (Average hashing = 0). Stratified splits разделены на уровне пациентов для исключения утечек. |
| **Experiments / baseline** | Да | [Experiment_Report.md](../reports/Experiment_Report.md) | baseline-vs-candidate сравнения проведены. Champion-модели (ResNet-50 для классификации и ResNet-34 U-Net для сегментации) превзошли базовые модели. |
| **Deployment & Inference** | Да | [DEPLOYMENT_DOC.md](DEPLOYMENT_DOC.md), [README.md](../README.md) | Dual-Deployment Hybrid Architecture полностью развернута. Основной мобильный Edge-инференс (TFLite) дополнен вспомогательным Streamlit API сервером. |
| **Monitoring & Telemetry** | Да | [MONITORING_DOC.md](MONITORING_DOC.md), [feedback_handler.py](../monitoring/feedback_handler.py) | Prometheus scrape config и Grafana dashboard json созданы. feedback_handler.py полностью автоматизирует сбор Low-Confidence событий и Overrides из Firestore. |

---

## 2. Quality Gates Summary

We ran the automated verification script (`tests/verify_quality_gates.py`) and all gates passed:

*   **Классификация (Accuracy & Critical Recall):**
    *   *Критерий:* F1-score >= 0.85, Recall Malignant >= 0.95 на тестовом наборе.
    *   *Результат:* F1-score = **0.880**, Recall Malignant = **0.969** **[PASS]**.
*   **Производительность и Latency SLO:**
    *   *Критерий:* p95 Latency на Edge < 150 мс (Classification) и < 400 мс (Segmentation).
    *   *Результат:* p95 Latency = **128 мс** (Classification), **345 мс** (Segmentation) **[PASS]**.
*   **Сдвиг данных и валидация контрактов:**
    *   *Критерий:* Прохождение контрактов формата, разрешения >= 256x256 и std яркости > 5.0.
    *   *Результат:* Процент бракованных входов = **0.0%** **[PASS]**.
*   **MLOps Интеграция и Воспроизводимость:**
    *   *Критерий:* Наличие машиночитаемой (Evidence Package) и автоматического скрипта проверки.
    *   *Результат:* Создан [release_evidence.json](../reports/release_evidence.json). Скрипт [verify_quality_gates.py](../tests/verify_quality_gates.py) возвращает статус **SUCCESS** для всех условий **[PASS]**.

---

## 3. Machine-Readable Evidence Package

To back up the numbers above with actual data (not just self-description), we built a verification chain that **recomputes** the safety-critical metrics from raw artifacts and **re-runs** the dataset checks — it does not merely read pre-baked numbers:

1. **Пакет доказательств:** [release_evidence.json](../reports/release_evidence.json) — сериализованные значения метрик релиза.
2. **Сырые данные для пересчёта:**
   * [confusion_matrix.json](../reports/confusion_matrix.json) — сырые counts (TP/FN) с тестового набора. `verify_quality_gates.py` **пересчитывает** Malignant Recall = 31/32 = **0.969** и False-Negative Rate = 1/32 = **3.1%** напрямую из counts, затем сверяет с опубликованными значениями (consistency check).
   * [mlflow_runs.json](../reports/mlflow_runs.json) — экспорт всех 5 MLflow run'ов (baseline + candidate для обеих задач) с params, metrics и artifact-путями.
3. **Скрипт автоверификации:** [verify_quality_gates.py](../tests/verify_quality_gates.py):
   * пересчитывает recall/FN-rate из `confusion_matrix.json`;
   * запускает живую проверку датасета (`pipelines/check_data_integrity.py`) как subprocess — leakage / duplicates / class balance на реальных `data/*_split.csv`;
   * сверяет опубликованные метрики с пересчитанными и блокирует релиз при расхождении.
4. **Воспроизводимая проверка данных:** [check_data_integrity.py](../pipelines/check_data_integrity.py) — отдельный executable artifact (patient-level leakage, MD5 + aHash дубликаты, баланс классов).
5. **Запуск:**
   ```bash
   python pipelines/check_data_integrity.py   # data leakage / duplicates / balance
   python tests/verify_quality_gates.py       # recomputes metrics + re-checks data
   ```

---

## 4. Known Limitations & How We Handle Them

Some features were originally planned for future iterations but we went ahead and implemented the core parts:

*   **Риск 1: Сдвиг распределения данных УЗИ (Data Drift):**
    *   *Решение:* Интеграция с инструментом Evidently. Скрипт `monitoring/feedback_handler.py` отслеживает события низкой уверенности (Low-Confidence Events) и считает метрику сдвига, отправляя предупреждения.
*   **Риск 2: Отсутствие контура обратной связи от врачей (Human Feedback Loop UI):**
    *   *Решение:* Полностью реализована Firestore-эмуляция обратной связи. Модуль `monitoring/feedback_handler.py` считывает Firestore-исправления врачей и автоматически накапливает ground truth данные.
*   **Риск 3: Ручное дообучение моделей (Manual Retraining Pipeline):**
    *   *Решение:* Реализована автоматическая MLOps цепочка. `feedback_handler.py` считывает Firestore-пул и при накоплении >= 100 исправлений автоматически запускает скрипт `pipelines/retrain_ci.py`, который проводит Challenger-vs-Champion сравнение и обновляет продакшн веса модели в MLflow Model Registry.
*   **Риск 4: Сервисный мониторинг (Grafana & Prometheus):**
    *   *Решение:* Конфигурационные файлы Prometheus (`monitoring/prometheus.yml`) и Grafana Dashboard (`monitoring/grafana_dashboard.json`) полностью интегрированы в проект.

---

## 5. Final Decision

**RELEASE: APPROVED WITH LIMITATIONS** (controlled / limited rollout)

All automated quality gates pass (recomputed from raw data, not just read from a static file), Edge TFLite inference works in the Flutter client, the backup Streamlit API runs, and the MLOps telemetry + retraining loop is in place. **However, for a medical-AI system an unconditional "APPROVED" is not appropriate** — we therefore approve a *limited, supervised* release under the conditions below.

### 5.1 Why "with limitations" and not unconditional approval
This is a clinical decision-support tool ("second opinion" / copilot), **not** an autonomous diagnostic device. The evidence backing the decision has known boundaries:

* **Single dataset, modest test set.** Metrics are computed on the BUSI test split (120 images, 32 malignant). One single false negative moves recall by ~3 points. The numbers are good but the sample is small and from one data source — they do not yet prove generalization to other ultrasound machines, populations, or clinics.
* **Evidence is offline, not a live production run.** `release_evidence.json` / `confusion_matrix.json` come from offline evaluation. `verify_quality_gates.py` recomputes recall/FN-rate from the raw confusion matrix and re-runs the dataset integrity check, but it does **not** retrain the model or re-run full inference on raw images in this environment (model weights are externally stored — see DoD artifacts).
* **Latency/monitoring partly simulated.** p95 latency and telemetry are validated via profiling harness and simulated clinical streams (`monitoring/feedback_handler.py`), not yet from a fleet of real devices in production.
* **Weights live outside Git.** `.keras` / `.tflite` weights are versioned externally (DVC / Drive), so a clean-room rebuild depends on that external store being available.

### 5.2 Conditions of the limited release
1. **Human-in-the-loop is mandatory.** Every prediction is advisory; a qualified radiologist makes the final diagnosis. The model never produces a standalone clinical conclusion (per PRD Out-of-Scope).
2. **Shadow / pilot phase first.** Deploy to a small set of supervised users; collect physician overrides through the Firestore feedback loop before any wider rollout.
3. **Kill-switch armed.** The Firebase Remote Config kill-switch must stay enabled to disable ML analysis instantly on degradation (see DEPLOYMENT_DOC.md, rollback section).
4. **Drift monitoring active.** Low-confidence rate and physician-override pool are tracked; retraining (`pipelines/retrain_ci.py`) triggers automatically at the defined thresholds.
5. **Exit criteria to full approval.** Unconditional approval is revisited only after: (a) external/multi-site validation set evaluated, (b) p95 latency confirmed from real production devices, (c) a sustained physician-agreement rate from the pilot, and (d) reproducible weights pinned in the artifact store.

**Owner sign-off:** Эид Хоссам (ML models & pipelines), Зарипов Рамиль (Flutter client).
