# Tópicos sugeridos

| Tópico | Finalidade | Chave sugerida |
|---|---|---|
| `payments.public.accounts` | CDC da tabela accounts | `account_id` |
| `payments.public.transactions` | CDC da tabela transactions | `transaction_id` |
| `payments-enriched` | Transações enriquecidas | `transaction_id` |
| `fraud-alerts` | Alertas da regra de velocidade | `card_id` |

Os nomes de tópicos CDC seguem o padrão comum do Debezium (`<prefixo>.<schema>.<tabela>`). Confirme o nome final no status/configuração do conector.
