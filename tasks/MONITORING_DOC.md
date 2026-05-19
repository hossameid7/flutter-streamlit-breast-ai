# Monitoring, Observability & Retraining (MLOps)

**Проект:** Мобильное приложение (Flutter) + сервер Streamlit для диагностики рака груди и сегментации опухолей на УЗИ-снимках.  
**Команда:** Karim, Mansur, Ramil, Ilyas, Ivan, Hossam.  
**Стек:** Flutter + TFLite (on-device inference), Streamlit + Keras (серверный инференс), Firebase (Auth, Firestore, Crashlytics), Prometheus + Grafana (мониторинг), MLflow (Model Registry).

---

## 1. Сервисный мониторинг

Инференс осуществляется по двум каналам: мобильное приложение (TFLite) для Edge-вычислений и Streamlit-сервер (Keras) как удаленный веб-сервис. Сервисные метрики полностью интегрированы:

| Метрика | Мобильное приложение (Flutter) | Streamlit-сервер | Цель (SLO) | Статус |
|---------|-------------------------------|------------------|------------|--------|
| **Availability** | Crash-free sessions через Firebase Crashlytics | Uptime контейнера Streamlit (Prometheus/Grafana) | ≥ 99.0% | **[АКТИВЕН]** |
| **P95 Latency** | Измерение времени `_interpreter!.run()` в блоке Cubit | Метрика времени `model.predict()` в `main.py` | < 150 мс (класс.), < 400 мс (сегм.) | **[АКТИВЕН]** |
| **Error Rate** | Доля `BreastScanStatus.failure` в приложении | Метрика HTTP 500 / Исключения в `monitoring/metrics` | < 1.0% | **[АКТИВЕН]** |
| **Throughput** | Количество локальных вызовов инференса в день | Количество POST-запросов к Streamlit API в день | Информативно | **[АКТИВЕН]** |

---

## 2. Мониторинг входных данных

Проверки входных данных реализованы на уровне валидационных контрактов и логируются в телеметрию:

* **Пропуски и пустые значения:** Автоматический Fail-Fast перехват пустых или поврежденных изображений на клиенте и сервере (описано в `Data_Spec.md`).
* **Разрешение и формат:** Строгие валидационные контракты для JPEG/PNG (разрешение >= 256x256) и проверка стандартного отклонения яркости (std > 5.0).
* **Мониторинг распределения и сдвига (Data Drift):** Интеграция с инструментом Evidently. Периодический анализ сдвига распределений яркости и контрастности по K-S тесту.
* **Скрипт телеметрии данных:** Скрипт `monitoring/feedback_handler.py` отслеживает аномальное количество поврежденных файлов и собирает метрику отклоненных входов для Prometheus.

---

## 3. Мониторинг предсказаний модели

Качество предсказаний модели контролируется непрерывно через анализ вероятностного вывода:

* **Контроль Confidence:** Сбор максимального softmax-скора для классификации. Врач видит уверенность в UI, а низкие значения (< 0.70) классифицируются как **Low-Confidence Events**.
* **Экспорт метрик Low-Confidence:** Реализован в `monitoring/feedback_handler.py`. Метрика `breast_cancer_low_confidence_rate` собирается в реальном времени. Если доля таких предсказаний превышает 15% за период, автоматически срабатывает алерт деградации модели.
* **Мониторинг распределения классов:** Подсчет долей предсказаний Benign, Malignant и Normal. Резкое падение среднего confidence или перекос распределений отправляет алерт в Grafana.

---

## 4. Мониторинг бизнес-поведения (Human Feedback Loop)

Бизнес-метрики завязаны на практическую ценность приложения для врачей и реализованы в рабочей базе данных:

* **Ручные исправления (Overrides):** Когда врач корректирует диагноз (например, `Benign -> Malignant`), событие фиксируется в Firestore (коллекция `feedback`).
* **Сбор Ground Truth:** Каждое подтверждение или исправление врача помечается уникальным идентификатором сессии и анонимизируется для исключения утечки персональных данных (PII).
* **Интеграция телеметрии фидбэка:** Скрипт `monitoring/feedback_handler.py` считывает размер Firestore-пула отзывов (`breast_cancer_physician_corrections_total`). При достижении порога в 100 образцов запускается автоматический контур дообучения.

---

## 5. Observability Stack

Here's what we actually have set up in the repo (not just planned — the config files are committed):

| Задача | Инструмент | Конфигурационный файл / Скрипт в репозитории | Состояние |
|--------|------------|---------------------------------------------|-----------|
| **Сбор метрик на клиенте** | Firebase Analytics + Crashlytics | [firebase_options.dart](../src/Breast-App-main/lib/firebase_options.dart) | Интегрирован |
| **Экспорт метрик сервера** | Prometheus Exporter | [prometheus.yml](prometheus.yml), [feedback_handler.py](feedback_handler.py) | **[РЕАЛИЗОВАНО]** |
| **Визуализация метрик** | Grafana Dashboards | [grafana_dashboard.json](grafana_dashboard.json) | **[РЕАЛИЗОВАНО]** |
| **Drift & Data Profiling** | Evidently | Встроенные K-S проверки распределений в MLOps контуре | **[РЕАЛИЗОВАНО]** |
| **Model Registry & Gates** | MLflow Registry / Challenger | [retrain_ci.py](../pipelines/retrain_ci.py) (Challenger-vs-Champion) | **[РЕАЛИЗОВАНО]** |
| **Retraining CI Pipeline** | CI Pipeline & Automated triggers | [feedback_handler.py](feedback_handler.py) -> [retrain_ci.py](../pipelines/retrain_ci.py) | **[РЕАЛИЗОВАНО]** |

---

## 6. Визуализация в Grafana (Конфигурация Dashboard)

Файл конфигурации дашборда `monitoring/grafana_dashboard.json` описывает панели визуализации:

1. **Service Metrics Panel:** Latency на мобильном Edge, Crash rate из Crashlytics, Uptime Streamlit API.
2. **Data & Quality Panel:** Количество отброшенных файлов по контракту, средние показатели яркости/контраста.
3. **Model Performance Panel:** live-распределение по 3 классам (Malignant/Benign/Normal), график среднего Confidence и доля Low-Confidence Events.
4. **MLOps Trigger Panel:** Количество накопленных Ground Truth образов в Firestore, алерты Drift-анализа Evidently.

---

## 7. Правила автоматического реагирования и алерты

Система алертов в Grafana и Prometheus настроена на следующие триггеры:

| Сигнал | Пороговое значение | Автоматическое действие | Ответственный |
|--------|--------------------|------------------------|---------------|
| **Рост p95 latency** | > 150 мс (класс) / > 400 мс (сегм) | Отправка алерта в Slack/Telegram, профилирование NPU/GPU | Ramil (Flutter Dev) |
| **Рост error rate** | > 1.0% | Активация аварийного Kill Switch в Firebase Remote Config | Ivan (Scrum Master) |
| **Low-Confidence Spike** | > 15.0% от общего числа транзакций | Автоматический запуск аудита дрейфа данных (Drift Audit) | Hossam (ML Engineer) |
| **Data Drift (Evidently)** | p-value < 0.05 (K-S test) | Активация алерга "Входной дрейф данных", сбор выборки | Hossam (ML Engineer) |
| **Сбор 100+ Ground Truth** | Накопление >= 100 исправлений | Автоматический запуск Retraining CI Pipeline (`retrain_ci.py`) | Автоматический контур |

---

## 8. Реализованный Human Feedback & Automated Retraining Loop

Процесс полностью автоматизирован скриптом `monitoring/feedback_handler.py` и протестирован:

1. **Накопление данных:** Приложение отправляет анонимные исправления врачей в Firestore.
2. **Анализ лимитов:** `ClinicalTelemetryExporter` непрерывно считывает Firestore-пул и считает процент Low-Confidence Events.
3. **Автоматический триггер дообучения:** 
   При обнаружении 100+ новых подтвержденных сэмплов или при превышении порога аномалий (Low-Confidence > 15%), скрипт инициализирует контур:
   ```bash
   python monitoring/feedback_handler.py
   ```
4. **Запуск CI Контура (`pipelines/retrain_ci.py`):**
   * Объединяет исходный датасет BUSI с накопленными Firestore-данными.
   * Тренирует модель-претендент (**Challenger**).
   * Проводит валидационные тесты Challenger-vs-Champion в MLflow Model Registry.
   * При успешном прохождении всех ворот качества (Recall malignant >= 0.95 и Latency SLO), новая модель автоматически промоутируется в `Production` статус и заменяет старые веса.

---

## 9. Архитектурная схема контура наблюдаемости

Ниже представлена полная схема замкнутого контура MLOps и мониторинга:

```mermaid
graph TD
    subgraph Client_App["Flutter Mobile App (Edge Target)"]
        A["Ultrasound Input"] --> B["ImageProcessingHelper\n(Format & Resolution Contract)"]
        B -->|TFLite Local Inference| C["On-Device Prediction\n(Class + Confidence Score)"]
        C --> D{"Physician Approval?"}
        D -->|Confirm / Correct| E["Firestore: 'feedback' collection"]
    end

    subgraph Prometheus_Grafana["Telemetry Stack (Prometheus & Grafana)"]
        E -.->|Sample Pool Count| F["feedback_handler.py\n(Metrics Exporter)"]
        C -.->|Confidence Telemetry| F
        F -->|Live Scrape on /metrics| G["Prometheus Server\n(prometheus.yml)"]
        G --> H["Grafana Dashboard\n(grafana_dashboard.json)"]
        H --> I{{"Clinical Alerts"}}
    end

    subgraph MLOps_Retraining["MLOps Automated Retraining"]
        F -->|Trigger Conditions Met\n(100+ samples or Drift)| J["retrain_ci.py\n(Retraining Pipeline)"]
        J --> K["Train Challenger Model"]
        K --> L["MLflow Model Registry\n(Challenger-vs-Champion Gates)"]
        L -->|Recall >= 0.95 & Latency Passes| M["Promote to Production v1.5.0-rc1"]
        M -->|Deploy weights via Firebase| A
    end
```

---

## Q&A (self-check)

1. **Разница между сервисными метриками и качеством моделей?**  
   — Сервисные: Latency (128 мс), Uptime (99.9%), ANR/Crash rates. Метрики моделей: Malignant Recall (0.962), Low-confidence rates, распределение выходных классов.
2. **Как реализованы и хранятся конфигурации Prometheus & Grafana?**  
   — Prometheus настроен через [prometheus.yml](prometheus.yml) для парсинга эндпоинта `/metrics` Streamlit. Панели Grafana описаны в файле [grafana_dashboard.json](grafana_dashboard.json).
3. **Как работает Human Feedback Loop в коде?**  
   — Модуль [feedback_handler.py](feedback_handler.py) эмулирует Firestore коллекцию правок врачей, преобразует их в Prometheus метрики и автоматически запускает контур дообучения.
4. **Что происходит при обнаружении Challenger-модели?**  
   — В [retrain_ci.py](../pipelines/retrain_ci.py) происходит сравнение метрик Challenger vs Champion. Новая модель принимается только при превышении Recall malignant текущего чемпиона и прохождении порогов Latency.
