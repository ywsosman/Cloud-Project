#!/usr/bin/env python3
"""
Azure Security Log Collector for Zero-Trust Cloud Lab
Collects security-related logs from Azure services
"""

import os
import json
from datetime import datetime, timedelta
from typing import List, Dict
from azure.identity import DefaultAzureCredential
from azure.mgmt.monitor import MonitorManagementClient
from azure.mgmt.resource import ResourceManagementClient

# Note: Install required packages:
# pip install azure-identity azure-mgmt-monitor azure-mgmt-resource azure-storage-blob

class AzureLogCollector:
    """Collects security logs from Azure services"""
    
    def __init__(self, subscription_id: str):
        """
        Initialize Azure Log Collector
        
        Args:
            subscription_id: Azure subscription ID
        """
        self.subscription_id = subscription_id
        self.credential = DefaultAzureCredential()
        self.monitor_client = MonitorManagementClient(
            self.credential, self.subscription_id
        )
        self.resource_client = ResourceManagementClient(
            self.credential, self.subscription_id
        )
    
    def collect_activity_logs(self, days: int = 7) -> List[Dict]:
        """
        Collect Azure Activity Logs
        
        Args:
            days: Number of days to look back
            
        Returns:
            List of activity log entries
        """
        print(f"Collecting activity logs for the last {days} days...")
        
        start_time = datetime.utcnow() - timedelta(days=days)
        end_time = datetime.utcnow()
        
        filter_str = f"eventTimestamp ge '{start_time.isoformat()}Z' and eventTimestamp le '{end_time.isoformat()}Z'"
        
        logs = []
        activity_logs = self.monitor_client.activity_logs.list(
            filter=filter_str,
            select="eventTimestamp,level,operationName,resourceGroupName,resourceId,status,caller,claims"
        )
        
        for log in activity_logs:
            log_entry = {
                "timestamp": log.event_timestamp.isoformat() if log.event_timestamp else None,
                "level": log.level.value if log.level else None,
                "operation": log.operation_name.value if log.operation_name else None,
                "resource_group": log.resource_group_name,
                "resource_id": log.resource_id,
                "status": log.status.value if log.status else None,
                "caller": log.caller,
                "category": log.category.value if log.category else None,
                "claims": log.claims
            }
            logs.append(log_entry)
        
        print(f"✓ Collected {len(logs)} activity log entries")
        return logs
    
    def collect_nsg_flow_logs(self, resource_group: str, nsg_name: str) -> List[Dict]:
        """
        Collect Network Security Group flow logs
        
        Args:
            resource_group: Resource group name
            nsg_name: NSG name
            
        Returns:
            List of NSG flow log entries
        """
        print(f"Collecting NSG flow logs for {nsg_name}...")
        
        # Note: This requires NSG Flow Logs to be enabled and stored
        # Implementation depends on your storage setup
        
        # Placeholder - actual implementation would read from storage account
        logs = []
        print("✓ NSG flow logs collection (implement based on your setup)")
        return logs
    
    def collect_azure_ad_logs(self) -> List[Dict]:
        """
        Collect Azure Active Directory sign-in and audit logs
        
        Note: Requires Azure AD Premium and appropriate permissions
        
        Returns:
            List of Azure AD log entries
        """
        print("Collecting Azure AD logs...")
        
        # Note: This requires Microsoft Graph API
        # from azure.identity import DefaultAzureCredential
        # from msgraph.core import GraphClient
        
        # Placeholder - implement using Microsoft Graph API
        logs = []
        print("✓ Azure AD logs collection (requires Microsoft Graph API setup)")
        return logs
    
    def collect_security_alerts(self, resource_group: str = None) -> List[Dict]:
        """
        Collect Azure Security Center alerts
        
        Args:
            resource_group: Optional resource group filter
            
        Returns:
            List of security alerts
        """
        print("Collecting Security Center alerts...")
        
        # Note: This requires Azure Security Center and appropriate SDK
        # from azure.mgmt.security import SecurityCenter
        
        # Placeholder
        alerts = []
        print("✓ Security alerts collection (implement based on Security Center setup)")
        return alerts
    
    def save_logs(self, logs: List[Dict], filename: str, format: str = "json"):
        """
        Save collected logs to file
        
        Args:
            logs: List of log entries
            filename: Output filename
            format: Output format (json or csv)
        """
        if not logs:
            print(f"⚠ No logs to save for {filename}")
            return
        
        if format == "json":
            with open(filename, 'w') as f:
                json.dump(logs, f, indent=2, default=str)
            print(f"✓ Saved {len(logs)} logs to {filename}")
        
        elif format == "csv":
            import csv
            with open(filename, 'w', newline='') as f:
                if logs:
                    writer = csv.DictWriter(f, fieldnames=logs[0].keys())
                    writer.writeheader()
                    writer.writerows(logs)
            print(f"✓ Saved {len(logs)} logs to {filename} (CSV)")
    
    def upload_to_blob_storage(self, container_name: str, blob_name: str, data: str):
        """
        Upload data to Azure Blob Storage
        
        Args:
            container_name: Storage container name
            blob_name: Blob name
            data: Data to upload
        """
        from azure.storage.blob import BlobServiceClient
        
        connection_string = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
        if not connection_string:
            print("⚠ AZURE_STORAGE_CONNECTION_STRING not set")
            return
        
        try:
            blob_service_client = BlobServiceClient.from_connection_string(connection_string)
            blob_client = blob_service_client.get_blob_client(
                container=container_name, blob=blob_name
            )
            blob_client.upload_blob(data, overwrite=True)
            print(f"✓ Uploaded to Azure Blob Storage: {container_name}/{blob_name}")
        except Exception as e:
            print(f"✗ Failed to upload to blob storage: {e}")


def main():
    """Main execution function"""
    import sys
    
    # Check for Azure credentials
    subscription_id = os.getenv("AZURE_SUBSCRIPTION_ID")
    
    if not subscription_id:
        print("Error: AZURE_SUBSCRIPTION_ID environment variable not set")
        print("\nSet it using:")
        print("  export AZURE_SUBSCRIPTION_ID=your-subscription-id  # Linux/macOS")
        print("  $env:AZURE_SUBSCRIPTION_ID='your-subscription-id'  # PowerShell")
        sys.exit(1)
    
    print("=" * 60)
    print("Azure Security Log Collector")
    print("=" * 60)
    print(f"Subscription ID: {subscription_id}")
    print("")
    
    try:
        collector = AzureLogCollector(subscription_id)
        
        # Collect Activity Logs
        activity_logs = collector.collect_activity_logs(days=7)
        collector.save_logs(activity_logs, "azure_activity_logs.json")
        collector.save_logs(activity_logs, "azure_activity_logs.csv", format="csv")
        
        # Collect other logs as needed
        # Note: Implement based on your Azure setup
        
        print("\n" + "=" * 60)
        print("Log Collection Complete!")
        print("=" * 60)
        print(f"Total activity logs collected: {len(activity_logs)}")
        
        # Optional: Upload to Azure Storage
        upload_to_storage = os.getenv("UPLOAD_TO_STORAGE", "false").lower() == "true"
        if upload_to_storage and activity_logs:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            blob_name = f"logs/activity_logs_{timestamp}.json"
            collector.upload_to_blob_storage(
                "security-data",
                blob_name,
                json.dumps(activity_logs, indent=2, default=str)
            )
        
    except Exception as e:
        print(f"\n✗ Error collecting logs: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()

