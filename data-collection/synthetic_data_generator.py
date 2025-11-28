#!/usr/bin/env python3
"""
Synthetic Security Data Generator for Zero-Trust Cloud Lab
Generates realistic security events and authentication logs for testing
"""

import json
import random
import uuid
from datetime import datetime, timedelta
from typing import List, Dict
import csv

# Sample data pools
USERNAMES = [
    "john.doe", "jane.smith", "bob.wilson", "alice.jones", "charlie.brown",
    "david.miller", "emma.davis", "frank.garcia", "grace.rodriguez", "henry.martinez"
]

USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15",
    "Mozilla/5.0 (iPad; CPU OS 14_0 like Mac OS X) AppleWebKit/605.1.15"
]

IP_ADDRESSES = [
    "192.168.1.100", "192.168.1.101", "192.168.1.102", "10.0.0.50",
    "172.16.0.100", "203.0.113.45", "198.51.100.23", "100.64.0.50"
]

LOCATIONS = [
    "New York, US", "London, UK", "Tokyo, JP", "Sydney, AU",
    "Berlin, DE", "Paris, FR", "Singapore, SG", "Toronto, CA"
]

RESOURCES = [
    "/api/users", "/api/data/secure", "/api/admin/config",
    "/api/reports", "/api/billing", "/api/settings", "/api/analytics"
]

ACTIONS = ["read", "write", "delete", "create", "update", "list"]

EVENT_TYPES = [
    "authentication", "authorization", "data_access", "admin_action",
    "suspicious_activity", "policy_violation", "resource_access"
]

THREAT_TYPES = [
    "brute_force", "credential_stuffing", "suspicious_login",
    "anomalous_access", "privilege_escalation", "data_exfiltration"
]


def generate_user_id() -> str:
    """Generate a random UUID for user"""
    return str(uuid.uuid4())


def generate_timestamp(days_ago: int = 30) -> datetime:
    """Generate a random timestamp within the last N days"""
    start = datetime.now() - timedelta(days=days_ago)
    end = datetime.now()
    delta = end - start
    random_seconds = random.randint(0, int(delta.total_seconds()))
    return start + timedelta(seconds=random_seconds)


def calculate_risk_score(event: Dict, timestamp: datetime = None) -> float:
    """Calculate risk score based on event characteristics"""
    risk = 0.0
    
    # Base risk by event type
    risk_factors = {
        "failed_login": 30,
        "suspicious_login": 50,
        "brute_force": 80,
        "privilege_escalation": 90,
        "data_exfiltration": 95,
        "anomalous_access": 60
    }
    
    risk += risk_factors.get(event.get("event_type", ""), 10)
    
    # Increase risk for multiple failures
    if event.get("success") is False:
        risk += 20
    
    # Unusual time (night hours)
    if timestamp:
        hour = timestamp.hour
        if hour < 6 or hour > 22:
            risk += 15
    
    # Foreign location (simple heuristic)
    if "Tokyo" in event.get("location", "") or "Singapore" in event.get("location", ""):
        risk += 10
    
    return min(risk, 100.0)


def generate_authentication_log(num_records: int = 1000) -> List[Dict]:
    """Generate synthetic authentication logs"""
    logs = []
    user_sessions = {}  # Track user sessions for realistic patterns
    
    for _ in range(num_records):
        username = random.choice(USERNAMES)
        
        # Get or create user ID
        if username not in user_sessions:
            user_sessions[username] = {
                "user_id": generate_user_id(),
                "failed_attempts": 0,
                "last_login": None
            }
        
        user_data = user_sessions[username]
        timestamp = generate_timestamp(30)
        
        # 80% success rate normally, but increase failures if previous failures
        success_probability = 0.8 - (user_data["failed_attempts"] * 0.1)
        success = random.random() < success_probability
        
        if success:
            user_data["failed_attempts"] = 0
            user_data["last_login"] = timestamp
            mfa_required = random.random() < 0.3  # 30% require MFA
        else:
            user_data["failed_attempts"] += 1
            mfa_required = False
        
        # Determine authentication method
        auth_methods = ["password", "mfa", "sso", "biometric"]
        weights = [0.5, 0.25, 0.15, 0.1]
        auth_method = random.choices(auth_methods, weights=weights)[0]
        
        # Risk level
        if not success:
            risk_levels = ["high", "medium"]
            risk_weights = [0.6, 0.4]
        elif mfa_required:
            risk_levels = ["low", "medium"]
            risk_weights = [0.7, 0.3]
        else:
            risk_levels = ["low", "medium", "high"]
            risk_weights = [0.7, 0.2, 0.1]
        
        risk_level = random.choices(risk_levels, weights=risk_weights)[0]
        
        log = {
            "log_id": str(uuid.uuid4()),
            "timestamp": timestamp.isoformat(),
            "user_id": user_data["user_id"],
            "username": username,
            "authentication_method": auth_method,
            "source_ip": random.choice(IP_ADDRESSES),
            "location": random.choice(LOCATIONS),
            "device_info": random.choice(USER_AGENTS),
            "success": success,
            "risk_level": risk_level,
            "mfa_status": "verified" if mfa_required and success else "not_required",
            "failure_reason": random.choice([
                "invalid_password", "account_locked", "expired_token", "invalid_mfa"
            ]) if not success else None
        }
        
        logs.append(log)
    
    return sorted(logs, key=lambda x: x["timestamp"])


def generate_security_events(num_records: int = 500) -> List[Dict]:
    """Generate synthetic security events"""
    events = []
    
    for _ in range(num_records):
        timestamp = generate_timestamp(30)
        event_type = random.choice(EVENT_TYPES)
        
        # Determine if this is a security incident
        is_incident = random.random() < 0.15  # 15% are incidents
        
        if is_incident:
            threat_type = random.choice(THREAT_TYPES)
            severity = random.choice(["high", "critical"])
            result = "blocked" if random.random() < 0.7 else "allowed"
        else:
            threat_type = None
            severity = random.choice(["low", "medium"])
            result = "allowed"
        
        event = {
            "event_id": str(uuid.uuid4()),
            "timestamp": timestamp.isoformat(),
            "event_type": event_type,
            "severity": severity,
            "source_ip": random.choice(IP_ADDRESSES),
            "destination_ip": random.choice(IP_ADDRESSES),
            "user_id": generate_user_id(),
            "resource": random.choice(RESOURCES),
            "action": random.choice(ACTIONS),
            "result": result,
            "threat_type": threat_type,
            "metadata": {
                "bytes_transferred": random.randint(100, 1000000),
                "duration_ms": random.randint(10, 5000),
                "protocol": random.choice(["HTTPS", "HTTP", "SSH", "RDP"])
            }
        }
        
        event["risk_score"] = calculate_risk_score(event, timestamp)
        events.append(event)
    
    return sorted(events, key=lambda x: x["timestamp"])


def generate_network_logs(num_records: int = 2000) -> List[Dict]:
    """Generate synthetic network security logs"""
    logs = []
    
    for _ in range(num_records):
        timestamp = generate_timestamp(30)
        
        # Network connection
        protocols = ["TCP", "UDP", "ICMP"]
        weights = [0.7, 0.2, 0.1]
        protocol = random.choices(protocols, weights=weights)[0]
        
        # Determine if suspicious
        is_suspicious = random.random() < 0.1  # 10% suspicious
        
        if is_suspicious:
            action = "deny"
            flags = ["SYN_FLOOD", "PORT_SCAN", "DDoS_ATTEMPT"]
        else:
            action = "allow"
            flags = []
        
        log = {
            "log_id": str(uuid.uuid4()),
            "timestamp": timestamp.isoformat(),
            "protocol": protocol,
            "source_ip": random.choice(IP_ADDRESSES),
            "source_port": random.randint(1024, 65535),
            "destination_ip": random.choice(IP_ADDRESSES),
            "destination_port": random.choice([80, 443, 22, 3389, 5432, 3306]),
            "bytes_sent": random.randint(64, 100000),
            "bytes_received": random.randint(64, 100000),
            "packets": random.randint(1, 1000),
            "action": action,
            "flags": flags,
            "session_duration": random.randint(1, 3600)
        }
        
        logs.append(log)
    
    return sorted(logs, key=lambda x: x["timestamp"])


def save_to_json(data: List[Dict], filename: str):
    """Save data to JSON file"""
    with open(filename, 'w') as f:
        json.dump(data, f, indent=2)
    print(f"[OK] Saved {len(data)} records to {filename}")


def save_to_csv(data: List[Dict], filename: str):
    """Save data to CSV file"""
    if not data:
        return
    
    with open(filename, 'w', newline='') as f:
        # Flatten nested dicts for CSV
        flat_data = []
        for record in data:
            flat_record = record.copy()
            if 'metadata' in flat_record:
                metadata = flat_record.pop('metadata')
                for key, value in metadata.items():
                    flat_record[f'metadata_{key}'] = value
            flat_data.append(flat_record)
        
        writer = csv.DictWriter(f, fieldnames=flat_data[0].keys())
        writer.writeheader()
        writer.writerows(flat_data)
    
    print(f"[OK] Saved {len(data)} records to {filename}")


def main():
    """Generate all synthetic datasets"""
    print("Generating synthetic security datasets...")
    print("=" * 50)
    
    # Generate authentication logs
    print("\n1. Generating authentication logs...")
    auth_logs = generate_authentication_log(1000)
    save_to_json(auth_logs, "authentication_logs.json")
    save_to_csv(auth_logs, "authentication_logs.csv")
    
    # Generate security events
    print("\n2. Generating security events...")
    security_events = generate_security_events(500)
    save_to_json(security_events, "security_events.json")
    save_to_csv(security_events, "security_events.csv")
    
    # Generate network logs
    print("\n3. Generating network logs...")
    network_logs = generate_network_logs(2000)
    save_to_json(network_logs, "network_logs.json")
    save_to_csv(network_logs, "network_logs.csv")
    
    # Statistics
    print("\n" + "=" * 50)
    print("Dataset Generation Complete!")
    print("=" * 50)
    print(f"Authentication Logs: {len(auth_logs)} records")
    print(f"Security Events: {len(security_events)} records")
    print(f"Network Logs: {len(network_logs)} records")
    print(f"Total: {len(auth_logs) + len(security_events) + len(network_logs)} records")
    
    # Security insights
    failed_logins = sum(1 for log in auth_logs if not log["success"])
    high_risk_events = sum(1 for event in security_events if event["risk_score"] > 70)
    blocked_connections = sum(1 for log in network_logs if log["action"] == "deny")
    
    print("\nSecurity Insights:")
    print(f"  - Failed login attempts: {failed_logins} ({failed_logins/len(auth_logs)*100:.1f}%)")
    print(f"  - High-risk events: {high_risk_events} ({high_risk_events/len(security_events)*100:.1f}%)")
    print(f"  - Blocked connections: {blocked_connections} ({blocked_connections/len(network_logs)*100:.1f}%)")


if __name__ == "__main__":
    main()

