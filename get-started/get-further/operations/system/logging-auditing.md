## Logging and auditing

The logging and auditing cluster properties of the Gateway can be set

### Logging
- CLUSTER_PROPERTY_log_levels: choose the log level

Logging levels can be found at https://docops.ca.com/ca-api-gateway/9-2/en/administer-the-gateway/gateway-logging-levels-and-thresholds

### Auditing

#### Audit levels:
- CLUSTER_PROPERTY_audit_adminThreshold: choose the level of the admin audit log
- CLUSTER_PROPERTY_audit_messageThreshold: choose the level of the message audit log
- CLUSTER_PROPERTY_audit_detailThreshold: choose the level of the audit detail log

#### Formatting audit logs:
- CLUSTER_PROPERTY_audit_log_service_detailFormat: format for details related to a service audit
- CLUSTER_PROPERTY_audit_log_service_footerFormat: format for the final (summary) log message of a service audit
- CLUSTER_PROPERTY_audit_log_service_headerFormat: format for the first log message of a service audit
- CLUSTER_PROPERTY_audit_log_other_format: format for other (non-service) audit logs
- CLUSTER_PROPERTY_audit_log_other_detailFormat: format for other (non-service) audit details

Details about:
- auditing: https://docops.ca.com/ca-api-gateway/9-2/en/reference/gateway-cluster-properties/audit-cluster-properties
- audit formatting: https://docops.ca.com/ca-api-gateway/9-2/en/administer-the-gateway/gateway-auditing-threshold-and-format
