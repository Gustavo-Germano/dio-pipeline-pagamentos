-- Regra de velocidade: sinaliza a partir da 3a transação do cartão
-- dentro dos 60 segundos anteriores, incluindo o evento atual.

INSERT INTO fraud_alerts
SELECT
    transaction_id,
    card_id,
    account_id,
    amount,
    created_at AS transaction_time,
    transactions_last_60s,
    '3_OR_MORE_TRANSACTIONS_IN_60_SECONDS' AS alert_reason
FROM (
    SELECT
        transaction_id,
        card_id,
        account_id,
        amount,
        created_at,
        COUNT(*) OVER (
            PARTITION BY card_id
            ORDER BY created_at
            RANGE BETWEEN INTERVAL '60' SECOND PRECEDING AND CURRENT ROW
        ) AS transactions_last_60s
    FROM transactions_cdc
)
WHERE transactions_last_60s >= 3;
