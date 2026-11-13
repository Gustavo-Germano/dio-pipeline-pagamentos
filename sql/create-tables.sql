-- Modelo para Confluent Cloud Flink SQL.
-- Configure os parâmetros de conexão e os formatos conforme os tópicos/schemas
-- efetivamente criados na sua conta Confluent Cloud.

CREATE TABLE transactions_cdc (
    transaction_id BIGINT,
    account_id BIGINT,
    card_id STRING,
    amount DECIMAL(12, 2),
    currency STRING,
    merchant STRING,
    status STRING,
    created_at TIMESTAMP_LTZ(3),
    WATERMARK FOR created_at AS created_at - INTERVAL '5' SECOND
) WITH (
    'connector' = 'kafka',
    'topic' = 'payments.public.transactions',
    'properties.bootstrap.servers' = '<BOOTSTRAP_SERVERS>',
    'properties.security.protocol' = 'SASL_SSL',
    'properties.sasl.mechanism' = 'PLAIN',
    'properties.sasl.jaas.config' = 'org.apache.kafka.common.security.plain.PlainLoginModule required username="<KAFKA_API_KEY>" password="<KAFKA_API_SECRET>";',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'avro-confluent',
    'avro-confluent.url' = '<SCHEMA_REGISTRY_URL>',
    'avro-confluent.basic-auth.credentials-source' = 'USER_INFO',
    'avro-confluent.basic-auth.user-info' = '<SR_API_KEY>:<SR_API_SECRET>'
);

CREATE TABLE accounts_cdc (
    account_id BIGINT,
    customer_name STRING,
    customer_email STRING,
    account_status STRING,
    created_at TIMESTAMP_LTZ(3),
    PRIMARY KEY (account_id) NOT ENFORCED
) WITH (
    'connector' = 'kafka',
    'topic' = 'payments.public.accounts',
    'properties.bootstrap.servers' = '<BOOTSTRAP_SERVERS>',
    'properties.security.protocol' = 'SASL_SSL',
    'properties.sasl.mechanism' = 'PLAIN',
    'properties.sasl.jaas.config' = 'org.apache.kafka.common.security.plain.PlainLoginModule required username="<KAFKA_API_KEY>" password="<KAFKA_API_SECRET>";',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'avro-confluent',
    'avro-confluent.url' = '<SCHEMA_REGISTRY_URL>',
    'avro-confluent.basic-auth.credentials-source' = 'USER_INFO',
    'avro-confluent.basic-auth.user-info' = '<SR_API_KEY>:<SR_API_SECRET>'
);

CREATE TABLE payments_enriched (
    transaction_id BIGINT,
    account_id BIGINT,
    customer_name STRING,
    customer_email STRING,
    card_id STRING,
    amount DECIMAL(12, 2),
    currency STRING,
    merchant STRING,
    status STRING,
    transaction_time TIMESTAMP_LTZ(3)
) WITH (
    'connector' = 'kafka',
    'topic' = 'payments-enriched',
    'properties.bootstrap.servers' = '<BOOTSTRAP_SERVERS>',
    'properties.security.protocol' = 'SASL_SSL',
    'properties.sasl.mechanism' = 'PLAIN',
    'properties.sasl.jaas.config' = 'org.apache.kafka.common.security.plain.PlainLoginModule required username="<KAFKA_API_KEY>" password="<KAFKA_API_SECRET>";',
    'key.format' = 'raw',
    'key.fields' = 'transaction_id',
    'value.format' = 'json'
);

CREATE TABLE fraud_alerts (
    transaction_id BIGINT,
    card_id STRING,
    account_id BIGINT,
    amount DECIMAL(12, 2),
    transaction_time TIMESTAMP_LTZ(3),
    transactions_last_60s BIGINT,
    alert_reason STRING
) WITH (
    'connector' = 'kafka',
    'topic' = 'fraud-alerts',
    'properties.bootstrap.servers' = '<BOOTSTRAP_SERVERS>',
    'properties.security.protocol' = 'SASL_SSL',
    'properties.sasl.mechanism' = 'PLAIN',
    'properties.sasl.jaas.config' = 'org.apache.kafka.common.security.plain.PlainLoginModule required username="<KAFKA_API_KEY>" password="<KAFKA_API_SECRET>";',
    'key.format' = 'raw',
    'key.fields' = 'card_id',
    'value.format' = 'json'
);
