## Week 5 – Azure Security Dataset Summary

**Goal for Week 5**
- Gather a real Azure Security dataset.
- Perform light cleaning.
- Store the data in the cloud.

**Data Source**
- Platform: **Microsoft Azure**
- Subscription: **Azure subscription 1** (`40374cd5-6fe6-4d50-8207-12af93346498`)
- Tenant: `b476abf0-4105-4c4d-b52e-bc452056d281`
- Data type: **Azure Activity Logs** (security‑relevant operational events).

**Collection Method**
- Script: `data-collection/azure_log_collector.py`
- Authentication: `InteractiveBrowserCredential` (user sign‑in) with correct tenant ID.
- Time range: Last **7 days** from time of execution.
- Number of events collected (run shown in logs): **24** activity log entries.

**Fields Collected (CSV header)**
- `timestamp` – when the event happened (UTC).
- `level` – severity/importance (e.g., `Informational`).
- `operation` – operation name (e.g., `Microsoft.Storage/storageAccounts/write`).
- `resource_group` – Azure resource group (e.g., `zero-trust-lab-rg`).
- `resource_id` – full Azure resource ID.
- `status` – result status (e.g., `Started`, `Succeeded`).
- `caller` – user or principal that performed the action.
- `category` – log category (e.g., `Administrative`, `Security`).
- `claims` – identity and authentication claims (MFA, IP, tenant, groups, etc.).

**Local Storage (Project Folder)**
- `data-collection/azure_activity_logs.json`  
  - Full JSON list of activity log events.
- `data-collection/azure_activity_logs.csv`  
  - Tabular version of the same events, ready for analysis.

**Cloud Storage (Azure Blob Storage)**
- Storage account: `zerotruststorage1`
- Resource group: `zero-trust-lab-rg`
- Container: `security-data`
- Example blob path:  
  - `security-data/logs/activity_logs_YYYYMMDD_HHMMSS.json`
- Connection string stored in `.env` (not committed) under  
  `AZURE_STORAGE_CONNECTION_STRING`.

**Initial Cleaning Performed**
- Converted timestamps to ISO‑8601 with timezone.
- Normalized enum fields (level, status, category, operation) to strings.
- Flattened nested objects into simple columns.
- Exported both JSON and CSV formats for flexibility.

**How to Re‑collect / Refresh Data**
1. Optional: perform some actions in the Azure Portal (create/delete small test resources) to generate new logs.
2. From the project root:
   - `cd data-collection`
   - `python azure_log_collector.py`
3. New files `azure_activity_logs.json` and `azure_activity_logs.csv` will be generated, and a JSON copy will be uploaded to the `security-data` container.

**How This Supports the Zero‑Trust Lab**
- Provides **real Azure security telemetry** for:
  - Anomaly detection (unusual operations/IPs/users).
  - Audit logging in the auth‑service.
  - Building dashboards and alerting in later weeks.
- Satisfies Week 5 requirement: **“Azure Security Dataset + initial cleaning + cloud storage.”**


