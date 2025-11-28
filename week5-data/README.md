# Week 5: Data Collection

## Objectives
- Gather Azure Security Dataset
- Perform initial data cleaning
- Store data on cloud storage
- Set up data pipeline

## Azure Security Dataset

### Dataset Sources

1. **Azure Security Center Data**
   - Security alerts and recommendations
   - Compliance assessments
   - Network security group logs

2. **Azure Active Directory Logs**
   - Sign-in logs
   - Audit logs
   - Risky user detections

3. **Azure Monitor Logs**
   - Activity logs
   - Resource logs
   - Metrics

4. **Network Security Logs**
   - NSG flow logs
   - Firewall logs
   - Application Gateway logs

### Alternative: Use Public Datasets

If you can't access real Azure security data, use these alternatives:

1. **Microsoft Sentinel Training Lab**
   - https://github.com/Azure/Azure-Sentinel
   
2. **KDD Cup 1999 Network Intrusion Dataset**
   - http://kdd.ics.uci.edu/databases/kddcup99/kddcup99.html

3. **CICIDS 2017 Dataset**
   - https://www.unb.ca/cic/datasets/ids-2017.html

4. **Synthetic Security Logs Generator**
   - Create synthetic logs for testing

## Tasks Checklist

- [ ] Identify dataset source
- [ ] Set up Azure Storage Account
- [ ] Create Azure Data Lake or Blob Storage
- [ ] Download/generate security dataset
- [ ] Perform initial data exploration
- [ ] Clean and preprocess data
- [ ] Upload to cloud storage
- [ ] Set up data access policies
- [ ] Document data schema

## Azure Storage Setup

### Create Storage Account

```bash
az storage account create \
  --name zerotruststorage \
  --resource-group zero-trust-lab-rg \
  --location eastus \
  --sku Standard_LRS \
  --kind StorageV2 \
  --access-tier Hot
```

### Create Blob Container

```bash
az storage container create \
  --name security-data \
  --account-name zerotruststorage \
  --auth-mode login
```

### Create Data Lake Storage

```bash
az storage account create \
  --name zerotrustdatalake \
  --resource-group zero-trust-lab-rg \
  --location eastus \
  --sku Standard_LRS \
  --kind StorageV2 \
  --enable-hierarchical-namespace true
```

## Data Collection Scripts

### 1. Azure Log Collector (Python)

Create `data-collection/azure_log_collector.py`:
- Connects to Azure Monitor
- Retrieves security-related logs
- Stores in blob storage

### 2. Data Generator (for testing)

Create `data-collection/synthetic_data_generator.py`:
- Generates synthetic security events
- Simulates authentication attempts
- Creates network traffic logs

### 3. ETL Pipeline

Create `data-collection/etl_pipeline.py`:
- Extract data from various sources
- Transform and clean data
- Load into cloud storage

## Data Schema

### Security Events Schema

```json
{
  "event_id": "string",
  "timestamp": "datetime",
  "event_type": "string",
  "severity": "string",
  "source_ip": "string",
  "destination_ip": "string",
  "user_id": "string",
  "resource": "string",
  "action": "string",
  "result": "string",
  "risk_score": "float",
  "metadata": "object"
}
```

### Authentication Logs Schema

```json
{
  "log_id": "string",
  "timestamp": "datetime",
  "user_id": "string",
  "username": "string",
  "authentication_method": "string",
  "source_ip": "string",
  "location": "string",
  "device_info": "string",
  "success": "boolean",
  "risk_level": "string",
  "mfa_status": "string"
}
```

## Data Processing Pipeline

### Architecture

```
Data Sources → Data Collection → Data Cleaning → Cloud Storage → Analysis
     ↓              ↓                  ↓              ↓             ↓
  Azure Logs    Python Script    Pandas/Spark   Blob Storage   Monitoring
```

## Security Considerations

1. **Data Privacy**
   - Anonymize sensitive information
   - Encrypt data at rest and in transit
   - Implement access controls

2. **Access Control**
   - Use Azure RBAC
   - Implement least privilege
   - Enable audit logging

3. **Compliance**
   - Follow GDPR guidelines
   - Implement data retention policies
   - Document data handling procedures

## Initial Data Analysis

Perform exploratory data analysis:
- Data volume and variety
- Time range coverage
- Event type distribution
- Anomaly detection patterns
- Missing values analysis

## Next Steps

- Week 6: Design system architecture based on data requirements
- Plan real-time vs batch processing
- Design data access patterns for zero-trust implementation

## Resources

- [Azure Storage Documentation](https://docs.microsoft.com/azure/storage/)
- [Azure Monitor Logs](https://docs.microsoft.com/azure/azure-monitor/)
- [Azure Sentinel](https://docs.microsoft.com/azure/sentinel/)

