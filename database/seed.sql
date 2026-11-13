INSERT INTO accounts (account_id, customer_name, customer_email, account_status)
VALUES
 (1001, 'Ana Souza', 'ana.souza@example.com', 'ACTIVE'),
 (1002, 'Bruno Lima', 'bruno.lima@example.com', 'ACTIVE'),
 (1003, 'Carla Mendes', 'carla.mendes@example.com', 'ACTIVE')
ON CONFLICT (account_id) DO NOTHING;

INSERT INTO transactions
 (transaction_id, account_id, card_id, amount, currency, merchant, status, created_at)
VALUES
 (90001, 1001, 'CARD-A1', 49.90, 'BRL', 'Mercado Central', 'APPROVED', NOW() - INTERVAL '45 seconds'),
 (90002, 1001, 'CARD-A1', 89.90, 'BRL', 'Loja Online', 'APPROVED', NOW() - INTERVAL '25 seconds'),
 (90003, 1001, 'CARD-A1', 129.90, 'BRL', 'Eletronicos Express', 'APPROVED', NOW() - INTERVAL '5 seconds'),
 (90004, 1002, 'CARD-B2', 35.00, 'BRL', 'Farmacia Boa Saude', 'APPROVED', NOW() - INTERVAL '2 minutes'),
 (90005, 1003, 'CARD-C3', 210.00, 'BRL', 'Posto Avenida', 'PENDING', NOW() - INTERVAL '90 seconds')
ON CONFLICT (transaction_id) DO NOTHING;
