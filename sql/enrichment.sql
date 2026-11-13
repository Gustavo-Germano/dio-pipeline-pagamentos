-- Enriquecimento de cada evento de transação com os dados da conta.
-- Execute no ambiente Flink após criar as tabelas em create-tables.sql.

INSERT INTO payments_enriched
SELECT
    t.transaction_id,
    t.account_id,
    a.customer_name,
    a.customer_email,
    t.card_id,
    t.amount,
    t.currency,
    t.merchant,
    t.status,
    t.created_at AS transaction_time
FROM transactions_cdc AS t
LEFT JOIN accounts_cdc FOR SYSTEM_TIME AS OF t.created_at AS a
    ON t.account_id = a.account_id;
