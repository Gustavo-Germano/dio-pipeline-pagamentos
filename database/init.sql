CREATE TABLE IF NOT EXISTS accounts (
    account_id      BIGINT PRIMARY KEY,
    customer_name   VARCHAR(120) NOT NULL,
    customer_email  VARCHAR(160) NOT NULL UNIQUE,
    account_status  VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_account_status CHECK (account_status IN ('ACTIVE', 'BLOCKED', 'CLOSED'))
);

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id  BIGINT PRIMARY KEY,
    account_id      BIGINT NOT NULL REFERENCES accounts(account_id),
    card_id         VARCHAR(64) NOT NULL,
    amount          NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    currency        CHAR(3) NOT NULL DEFAULT 'BRL',
    merchant        VARCHAR(120) NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'APPROVED',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_transaction_status CHECK (status IN ('APPROVED', 'DECLINED', 'PENDING'))
);

CREATE INDEX IF NOT EXISTS idx_transactions_card_created
    ON transactions (card_id, created_at);

CREATE INDEX IF NOT EXISTS idx_transactions_account
    ON transactions (account_id);

-- Para CDC lógico com Debezium, o usuário de replicação precisa de permissões
-- adequadas e wal_level=logical na instância PostgreSQL.
