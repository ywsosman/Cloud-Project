# 🚀 Quick Azure Security Dataset Setup

## ⚡ Fast Track (5 Minutes)

### Step 1: Login to Azure
```powershell
az login
```

### Step 2: Run Setup Script
```powershell
cd "D:\youssef\Fullstack Course\Cloud Project"
.\data-collection\azure_setup.ps1
```

This will:
- ✅ Check Azure CLI
- ✅ Create resource group
- ✅ Create storage account
- ✅ Set up logging
- ✅ Give you all the credentials you need

### Step 3: Configure Environment
```powershell
cd data-collection
# Copy the values from the script output
# Create .env file with:
# AZURE_SUBSCRIPTION_ID=<from script>
# AZURE_TENANT_ID=<from script>
# AZURE_STORAGE_CONNECTION_STRING=<from script>
# UPLOAD_TO_STORAGE=true
```

### Step 4: Install Dependencies
```powershell
pip install -r requirements.txt
```

### Step 5: Collect Data!
```powershell
python azure_log_collector.py
```

**Done!** You'll have real Azure Security data! 🎉

---

## 📋 What You'll Get

### Files Generated:
- `azure_activity_logs.json` - All activity logs
- `azure_activity_logs.csv` - CSV format
- Data uploaded to Azure Storage (if enabled)

### Data Includes:
- ✅ Resource creation/deletion
- ✅ Security policy changes
- ✅ Access attempts
- ✅ Configuration changes
- ✅ Authentication events
- ✅ Network security events

---

## 🎯 Manual Setup (If Script Doesn't Work)

### 1. Get Your Subscription Info
```powershell
az account show
```
Save: `id` (subscription ID) and `tenantId`

### 2. Create Resource Group
```powershell
az group create --name zero-trust-lab-rg --location eastus
```

### 3. Create Storage Account
```powershell
az storage account create `
    --name zerotruststorage `
    --resource-group zero-trust-lab-rg `
    --location eastus `
    --sku Standard_LRS

az storage container create `
    --name security-data `
    --account-name zerotruststorage `
    --auth-mode login
```

### 4. Get Connection String
```powershell
az storage account show-connection-string `
    --name zerotruststorage `
    --resource-group zero-trust-lab-rg `
    --query connectionString -o tsv
```

### 5. Create .env File
In `data-collection/` folder, create `.env`:
```env
AZURE_SUBSCRIPTION_ID=<your-subscription-id>
AZURE_TENANT_ID=<your-tenant-id>
AZURE_STORAGE_CONNECTION_STRING=<your-connection-string>
UPLOAD_TO_STORAGE=true
```

### 6. Run Collector
```powershell
cd data-collection
pip install -r requirements.txt
python azure_log_collector.py
```

---

## ✅ Verification

After running, check:
```powershell
# Local files
Get-ChildItem data-collection\*.json

# Azure Storage (if uploaded)
az storage blob list `
    --container-name security-data `
    --account-name zerotruststorage `
    --auth-mode login
```

---

## 🐛 Common Issues

### "az: command not found"
Install Azure CLI: https://aka.ms/installazurecliwindows

### "Not logged in"
Run: `az login`

### "Subscription not found"
Run: `az account list` then `az account set --subscription <id>`

### "Permission denied"
Your account needs "Reader" role on the subscription

---

## 📚 Full Guide

See `AZURE_SETUP_GUIDE.md` for detailed instructions.

---

**Ready? Start with Step 1!** 🚀

