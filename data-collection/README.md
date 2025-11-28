# Data Collection Scripts

This directory contains scripts for collecting and generating security data for the Zero-Trust Cloud Lab project.

## Scripts

### 1. `synthetic_data_generator.py`

Generates synthetic security data for testing and development.

**Usage:**
```bash
python synthetic_data_generator.py
```

**Outputs:**
- `authentication_logs.json` / `.csv` - User authentication logs
- `security_events.json` / `.csv` - Security events and incidents
- `network_logs.json` / `.csv` - Network traffic logs

**Features:**
- Realistic authentication patterns
- Security incident scenarios
- Network traffic simulation
- Risk scoring
- Temporal patterns

### 2. `azure_log_collector.py`

Collects actual security logs from Azure services.

**Prerequisites:**
```bash
# Install dependencies
pip install -r requirements.txt

# Set Azure credentials
export AZURE_SUBSCRIPTION_ID=your-subscription-id
export AZURE_TENANT_ID=your-tenant-id
export AZURE_CLIENT_ID=your-client-id
export AZURE_CLIENT_SECRET=your-client-secret
```

**Usage:**
```bash
python azure_log_collector.py
```

**Outputs:**
- `azure_activity_logs.json` / `.csv` - Azure Activity Logs
- Other logs based on configuration

**Features:**
- Activity log collection
- NSG flow logs (requires setup)
- Azure AD logs (requires premium)
- Security Center alerts
- Blob storage upload

## Setup

### For Synthetic Data

No setup required. Just run:
```bash
python synthetic_data_generator.py
```

### For Azure Logs

1. **Install dependencies:**
```bash
pip install -r requirements.txt
```

2. **Configure Azure authentication:**

**Option A: Using Service Principal**
```bash
export AZURE_SUBSCRIPTION_ID=<your-subscription-id>
export AZURE_TENANT_ID=<your-tenant-id>
export AZURE_CLIENT_ID=<your-client-id>
export AZURE_CLIENT_SECRET=<your-client-secret>
```

**Option B: Using Azure CLI**
```bash
az login
az account set --subscription <your-subscription-id>
```

3. **Optional: Configure storage for upload**
```bash
export AZURE_STORAGE_CONNECTION_STRING=<your-connection-string>
export UPLOAD_TO_STORAGE=true
```

4. **Run collector:**
```bash
python azure_log_collector.py
```

## Data Schema

### Authentication Logs

```json
{
  "log_id": "uuid",
  "timestamp": "ISO-8601 datetime",
  "user_id": "uuid",
  "username": "string",
  "authentication_method": "password|mfa|sso|biometric",
  "source_ip": "IP address",
  "location": "City, Country",
  "device_info": "User agent string",
  "success": boolean,
  "risk_level": "low|medium|high",
  "mfa_status": "verified|not_required|failed",
  "failure_reason": "string (if failed)"
}
```

### Security Events

```json
{
  "event_id": "uuid",
  "timestamp": "ISO-8601 datetime",
  "event_type": "authentication|authorization|data_access|...",
  "severity": "low|medium|high|critical",
  "source_ip": "IP address",
  "destination_ip": "IP address",
  "user_id": "uuid",
  "resource": "Resource path",
  "action": "read|write|delete|...",
  "result": "allowed|blocked",
  "threat_type": "brute_force|...",
  "risk_score": 0-100,
  "metadata": {}
}
```

### Network Logs

```json
{
  "log_id": "uuid",
  "timestamp": "ISO-8601 datetime",
  "protocol": "TCP|UDP|ICMP",
  "source_ip": "IP address",
  "source_port": integer,
  "destination_ip": "IP address",
  "destination_port": integer,
  "bytes_sent": integer,
  "bytes_received": integer,
  "packets": integer,
  "action": "allow|deny",
  "flags": ["flag1", "flag2"],
  "session_duration": integer (seconds)
}
```

## Data Storage

### Local Storage

Generated files are saved in the current directory:
- JSON format: For structured access
- CSV format: For Excel/analysis tools

### Cloud Storage (Azure)

To upload to Azure Blob Storage:

1. Create storage account:
```bash
az storage account create \
  --name zerotruststorage \
  --resource-group zero-trust-lab-rg \
  --location eastus \
  --sku Standard_LRS
```

2. Create container:
```bash
az storage container create \
  --name security-data \
  --account-name zerotruststorage
```

3. Get connection string:
```bash
az storage account show-connection-string \
  --name zerotruststorage \
  --resource-group zero-trust-lab-rg
```

4. Set environment variable:
```bash
export AZURE_STORAGE_CONNECTION_STRING="your-connection-string"
export UPLOAD_TO_STORAGE=true
```

## Data Analysis

### Using Pandas

```python
import pandas as pd

# Load data
auth_logs = pd.read_csv('authentication_logs.csv')
security_events = pd.read_csv('security_events.csv')

# Analysis examples
failed_logins = auth_logs[auth_logs['success'] == False]
high_risk_events = security_events[security_events['risk_score'] > 70]

print(f"Failed logins: {len(failed_logins)}")
print(f"High-risk events: {len(high_risk_events)}")
```

### Using Azure Data Explorer (Kusto)

If you uploaded to Azure, you can query using KQL:

```kql
// Failed authentication attempts
SecurityLogs
| where EventType == "authentication"
| where Success == false
| summarize Count=count() by Username, bin(Timestamp, 1h)
| order by Count desc

// High-risk events
SecurityLogs
| where RiskScore > 70
| project Timestamp, EventType, SourceIP, Resource, RiskScore
| order by RiskScore desc
```

## Customization

### Adjust Data Volume

Edit the script to generate more/less data:

```python
auth_logs = generate_authentication_log(5000)  # Generate 5000 logs
security_events = generate_security_events(2000)  # Generate 2000 events
```

### Adjust Time Range

Change the lookback period:

```python
timestamp = generate_timestamp(days_ago=90)  # 90 days of data
```

### Custom Scenarios

Add custom threat scenarios in `synthetic_data_generator.py`:

```python
THREAT_TYPES.append("custom_attack_pattern")
```

## Troubleshooting

### Azure Authentication Errors

```bash
# Check Azure CLI login
az account show

# Re-login if needed
az login

# Verify subscription
az account list --output table
```

### Permission Errors

Ensure your Azure account has:
- Reader role on subscription
- Monitoring Reader role
- Storage Blob Data Contributor (for uploads)

### Module Not Found

```bash
# Install all requirements
pip install -r requirements.txt

# Or install individually
pip install azure-identity azure-mgmt-monitor pandas
```

## Next Steps

1. Generate synthetic data for testing
2. Collect real Azure logs (if available)
3. Upload data to Azure Storage
4. Proceed to Week 5 data analysis
5. Use data for testing zero-trust policies

## Resources

- [Azure Monitor Documentation](https://docs.microsoft.com/azure/azure-monitor/)
- [Azure Activity Logs](https://docs.microsoft.com/azure/azure-monitor/essentials/activity-log)
- [NSG Flow Logs](https://docs.microsoft.com/azure/network-watcher/network-watcher-nsg-flow-logging-overview)

