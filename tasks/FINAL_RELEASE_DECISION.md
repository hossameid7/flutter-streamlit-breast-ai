# ДЗ: Final AI Release Decision

**Проект:** Мобильное приложение (Flutter) + сервер Streamlit для диагностики рака груди и сегментации опухолей на УЗИ-снимках.  
**Команда:** Karim, Mansur, Ramil, Ilyas, Ivan, Hossam.  
**Стек:** Flutter + TFLite (on-device inference), Streamlit + Keras (серверный инференс), Firebase (Auth, Crashlytics), BLoC/Cubit.

Студент должен взять то, что уже сделал по проекту, и собрать короткое финальное решение о релизе.

Всего 5 пунктов.

---

## 1. Таблица readiness по уже сделанным частям

| Блок | Готово? | Где артефакт | Комментарий |
|------|---------|--------------|-------------|
| Requirements / acceptance criteria | yes | [specs/PRD.md](../specs/PRD.md), [specs/DoD.md](../specs/DoD.md) | PRD содержит KPI (−30% время, FN < 0.5%, fallback не более 15%), DoD включает 12 пунктов с eval-gates (Recall не ниже 0.95). Всё задокументировано и проверено на 20/20. |
| Data / dataset quality | yes | [specs/Data_Spec.md](../specs/Data_Spec.md), [notebooks/breast-classification.ipynb](../notebooks/breast-classification.ipynb) | Используется BUSI Dataset: 780 снимков, 3 класса (Benign, Malignant, Normal), описаны контракты качества (PNG/JPEG, минимальное разрешение 256x256), Fail-Fast на нерелевантные входы. |
| Experiments / baseline | yes | [notebooks/breast-classification.ipynb](../notebooks/breast-classification.ipynb), [notebooks/breast-segmentation.ipynb](../notebooks/breast-segmentation.ipynb) | Классификация на базе EfficientNetB0: F1 выше 0.85, Recall по классу Malignant не ниже 0.95. Сегментация на базе U-Net с IoU на тестовом наборе. Модели сохранены в форматах .keras и .tflite. |
| Deployment | yes | [tasks/DEPLOYMENT_DOC.md](DEPLOYMENT_DOC.md), [Makefile](../Makefile), [reports/models/](../reports/models/) | On-device инференс через TFLite в Flutter-приложении, серверная версия на Streamlit (Keras). Canary Release через Firebase Remote Config, откат через Kill Switch. Makefile содержит таргеты: make train, make eval, make serve. |
| Monitoring / retraining | yes | [tasks/MONITORING_DOC.md](MONITORING_DOC.md) | Firebase Crashlytics и Analytics покрывают latency, confidence и crash rate. Описана политика retraining (порог: Recall ниже 0.95 или накоплено 100 и более правок врачей). Архитектура Human Feedback Loop через Firestore задокументирована. |

---

## 2. Quality gates summary

Коротко указать:

**Пройдены:**
- Recall@malignant не ниже 0.95 — выполнено на валидационной выборке BUSI (DoD, пункт 3).
- F1-score выше 0.85 для задачи классификации — достигнуто согласно DEPLOYMENT_DOC (SLO).
- Latency: классификация менее 150 мс, сегментация менее 400 мс — on-device TFLite, SLO задокументированы.
- Availability не ниже 99% — Firebase Crashlytics подключён, Kill Switch реализован.
- Fallback при confidence ниже 0.7 — реализован в BreastDetectionService, порог из PRD не более 15%.
- Rollback plan — Kill Switch и Firebase Remote Config описаны в DoD (пункт 10).
- Data contracts — формат JPEG/PNG, минимальное разрешение 256x256, Fail-Fast реализован.

**Не пройдены:**
- Grafana dashboards — не развёрнуты, Firebase-экспорт в BigQuery не настроен в production.
- Prometheus и Streamlit метрики — Streamlit пишет только в stdout, экспорт не реализован.
- Human Feedback Loop в UI — кнопка подтверждения и исправления результата не добавлена в Flutter.
- Challenger-модель в MLflow — staging-версия не зарегистрирована, реестр моделей не заполнен.

**Требуют доработки:**
- Логирование mean_brightness и std_contrast в ImageProcessingHelper — запланировано, но не реализовано.
- Firebase Analytics event для low_confidence_prediction — предусмотрен, агрегация не настроена.
- Retraining pipeline — make train и make eval есть в Makefile, но автоматизация через GitHub Actions CI не завершена.

---

## 3. Главные риски перед релизом

Минимум 3 риска:

**Риск 1 — по данным:**  
При смене УЗ-аппарата в клинике возникает data drift: меняется текстура снимков, распределение яркости и контрастности. Модели обучены только на BUSI (780 снимков) и при изменении источника данных могут давать некорректные предсказания без каких-либо явных сбоев в приложении. Автоматическое обнаружение drift через Evidently и K-S тест пока не запущено в production-режиме.

**Риск 2 — по модели:**  
Порог Recall@malignant достигнут на тестовой выборке BUSI, но датасет сравнительно невелик — 780 снимков. Ложноотрицательные предсказания по классу Malignant в реальных клинических условиях несут серьёзные последствия (пропущенный рак). Модель не валидирована на внешних датасетах (UDIAT, INbreast) и не проходила проспективного клинического испытания.

**Риск 3 — по эксплуатации / monitoring / rollback:**  
Human Feedback Loop не реализован в интерфейсе — отсутствует механизм сбора ground truth из реальных сессий. Без накопленных правок врачей невозможно запускать retraining при деградации модели. Rollback через Firebase Remote Config описан на уровне документа, но не тестировался в production: canary-эксперимент с реальными пользователями не проводился.

---

## 4. Финальное release decision

**release approved with limitations**

---

## 5. Обоснование решения

Решение принято как release approved with limitations, потому что основные технические компоненты системы готовы и задокументированы, но часть критически важных элементов мониторинга и обратной связи ещё не введена в эксплуатацию.

Что уже готово: обе модели — классификации и сегментации — обучены на BUSI, конвертированы в TFLite и Keras, интегрированы в Flutter-приложение и Streamlit-сервер. Acceptance criteria из PRD и DoD задокументированы и проверены, итог 20/20. Deployment-план с Canary Release и Kill Switch описан и технически обоснован. Firebase Crashlytics подключён для базового service monitoring. Latency SLO (меньше 150 мс для классификации, меньше 400 мс для сегментации) выполнены на on-device инференсе.

Что ещё не готово: Human Feedback Loop (кнопка подтверждения и исправления в UI Flutter) не реализован, и без него невозможно собирать ground truth из реальных сессий и запускать retraining на актуальных данных. Grafana dashboards и Prometheus-экспорт для Streamlit-сервера не развёрнуты. Challenger-модель в MLflow не зарегистрирована — нет полноценного model registry для сравнения версий при обновлениях.

Ограничения при текущем релизе: система должна применяться только как вспомогательный инструмент ("второе мнение"), окончательное решение остаётся за врачом. Область применения ограничена популяцией, схожей с BUSI датасетом. При confidence ниже 0.7 система обязана выводить предупреждение пользователю. Применение в клиниках с другим УЗ-оборудованием требует предварительной валидации модели.

Следующий шаг: реализовать Human Feedback Loop в Flutter (коллекция feedback в Firestore), завершить автоматизацию retraining pipeline через GitHub Actions CI (make train — make eval), развернуть Grafana dashboards на основе экспорта Firebase в BigQuery, провести canary-тест процедуры rollback в реальном окружении.