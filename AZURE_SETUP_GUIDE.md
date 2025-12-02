# Azure Security Dataset Collection Guide

## 🎯 Goal
Collect real Azure Security data for your Zero-Trust Cloud Lab project.

## 📋 Prerequisites

1. **Azure Account** (Free tier works!)
   - Sign up at: https://azure.microsoft.com/free/
   - Get $200 free credits for 30 days

2. **Azure CLI** installed
   - Download: https://aka.ms/installazurecliwindows
   - Or use: `winget install -e --id Microsoft.AzureCLI`

3. **Python 3.8+** (you already have this)

## 🚀 Step-by-Step Setup

### Step 1: Create Azure Account & Get Credentials

1. **Sign up for Azure:**
   - Go to: https://azure.microsoft.com/free/
   - Click "Start free"
   - Sign in with Microsoft account
   - Complete verification

2. **Get your Subscription ID:**
   ```powershell
   az login
   az account show --query id -o tsv
   ```
   Save this ID!

3. **Get Tenant ID:**
   ```powershell
   az account show --query tenantId -o tsv
   ```
   Save this ID!

### Step 2: Create Resource Group

```powershell
# Set variables (replace with your values)
$subscriptionId = "your-subscription-id"
$resourceGroup = "zero-trust-lab-rg"
$location = "eastus"

# Set active subscription
az account set --subscription $subscriptionId

# Create resource group
az group create --name $resourceGroup --location $location
```

### Step 3: Enable Azure Security Center (Free Tier)

```powershell
# Enable Security Center (now called Microsoft Defender for Cloud)
az security pricing create --name "VirtualMachines" --tier "Free" --resource-group $resourceGroup
```

### Step 4: Create Storage Account for Data

```powershell
# Create storage account
az storage account create `
    --name zerotruststorage `
    --resource-group $resourceGroup `
    --location $location `
    --sku Standard_LRS `
    --kind StorageV2

# Create container for security data
az storage container create `
    --name security-data `
    --account-name zerotruststorage `
    --auth-mode login
```

### Step 5: Get Storage Connection String

```powershell
# Get connection string
az storage account show-connection-string `
    --name zerotruststorage `
    --resource-group $resourceGroup `
    --query connectionString -o tsv
```

**Save this connection string!**

### Step 6: Enable Activity Logs

```powershell
# Create log analytics workspace
az monitor log-analytics workspace create `
    --resource-group $resourceGroup `
    --workspace-name zero-trust-workspace `
    --location $location

# Enable Activity Log export
az monitor diagnostic-settings create `
    --name "activity-logs" `
    --resource-group $resourceGroup `
    --workspace zero-trust-workspace `
    --logs '[{"category":"Administrative","enabled":true},{"category":"Security","enabled":true},{"category":"ServiceHealth","enabled":true}]'
```

### Step 7: Configure Python Script

1. **Set environment variables:**
   ```powershell
   # Create .env file in data-collection folder
   cd data-collection
   
   # Add these to .env file:
   AZURE_SUBSCRIPTION_ID=your-subscription-id
   AZURE_TENANT_ID=your-tenant-id
   AZURE_STORAGE_CONNECTION_STRING=your-connection-string
   UPLOAD_TO_STORAGE=true
   ```

2. **Install Python dependencies:**
   ```powershell
   pip install -r requirements.txt
   ```

### Step 8: Run Data Collection

```powershell
# Collect Activity Logs (last 7 days)
python azure_log_collector.py
```

This will:
- ✅ Collect Azure Activity Logs
- ✅ Save to JSON and CSV
- ✅ Upload to Azure Blob Storage (if configured)

## 📊 What Data You'll Get

### 1. **Activity Logs**
- Resource creation/deletion
- Security policy changes
- Access attempts
- Configuration changes

### 2. **Security Center Alerts** (if enabled)
- Threat detections
- Vulnerability assessments
- Compliance issues

### 3. **Network Security Group (NSG) Flow Logs**
- Network traffic patterns
- Allowed/denied connections
- Source/destination IPs

## 🔐 Security Best Practices

1. **Use Service Principal** (not personal account):
   ```powershell
   az ad sp create-for-rbac --name "zero-trust-collector" --role "Reader"
   ```
   Save the output (appId, password, tenant)

2. **Store credentials securely:**
   - Use Azure Key Vault (recommended)
   - Or environment variables (never commit to Git!)

3. **Limit permissions:**
   - Only "Reader" role needed
   - Scope to specific resource groups

## 📁 Data Storage

### Local Files (Generated):
- `azure_activity_logs.json` - Full logs
- `azure_activity_logs.csv` - CSV format
- `security_events.json` - Security-specific events
- `network_logs.json` - Network traffic (if NSG logs enabled)

### Azure Blob Storage:
- Container: `security-data`
- Organized by date: `logs/activity_logs_YYYYMMDD_HHMMSS.json`

## 🎯 Next Steps After Collection

1. **Analyze the data:**
   ```python
   import pandas as pd
   df = pd.read_csv('azure_activity_logs.csv')
   print(df.head())
   print(df.describe())
   ```

2. **Integrate with your system:**
   - Import into your database
   - Use for security analysis
   - Feed into zero-trust policies

3. **Set up automated collection:**
   - Azure Functions (serverless)
   - Scheduled runs (daily/hourly)
   - Event-driven triggers

## 🐛 Troubleshooting

### "Subscription not found"
```powershell
az account list --output table
az account set --subscription "your-subscription-id"
```

### "Permission denied"
- Check you're logged in: `az account show`
- Verify subscription access
- Check role assignments

### "Cannot connect to storage"
- Verify connection string
- Check storage account exists
- Verify container name

### "No data returned"
- Activity logs may take time to populate
- Check date range (logs older than 90 days may not be available)
- Verify diagnostic settings are enabled

## 📚 Resources

- [Azure Activity Logs](https://docs.microsoft.com/azure/azure-monitor/essentials/activity-log)
- [Azure Security Center](https://docs.microsoft.com/azure/security-center/)
- [Azure Storage](https://docs.microsoft.com/azure/storage/)
- [Azure CLI Reference](https://docs.microsoft.com/cli/azure/)

## ✅ Checklist

- [ ] Azure account created
- [ ] Azure CLI installed and logged in
- [ ] Resource group created
- [ ] Storage account created
- [ ] Activity logs enabled
- [ ] Environment variables set
- [ ] Python dependencies installed
- [ ] Data collection script run successfully
- [ ] Data files generated
- [ ] Data uploaded to Azure Storage (optional)

---

**Ready to start? Follow the steps above!** 🚀

