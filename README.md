# Pipeline de Pagamentos em Tempo Real — CDC, Kafka, Flink e PostgreSQL

Projeto desenvolvido como entrega prática de Engenharia de Dados: captura de alterações no PostgreSQL (CDC), publicação de eventos em Kafka, validação de contratos com Schema Registry/Avro, enriquecimento e detecção de comportamento suspeito com Flink SQL.

> **Transparência sobre a execução:** este repositório contém a implementação SQL, contratos Avro, configuração de referência e um ambiente local reproduzível. A integração com Confluent Cloud depende de credenciais e recursos criados na conta do aluno. Nenhuma execução em nuvem ou evidência de processamento foi declarada como realizada neste repositório. Registre evidências reais na pasta `evidencias/` depois de executar o pipeline.

## Arquitetura

```text
Aplicação / transações
        |
        v
PostgreSQL (tabelas accounts e transactions)
        |
        | CDC (Debezium PostgreSQL Connector)
        v
Kafka / Confluent Cloud
        |
        +---- Schema Registry (Avro)
        |
        v
Flink SQL
   |             |
   v             v
Enriquecimento   Detecção de fraude
   |             |
   v             v
pagamentos_enriquecidos   alertas_fraude
```

## Estrutura

- `database/`: schema e dados de demonstração do PostgreSQL.
- `schemas/`: contratos Avro para contas e transações.
- `connectors/`: modelo de configuração do conector Debezium.
- `sql/`: tabelas, enriquecimento e regra de detecção no Flink SQL.
- `scripts/`: comandos auxiliares para o ambiente local.
- `evidencias/`: local para screenshots e resultados reais da execução.

## Regra de detecção implementada

Uma transação é sinalizada quando o mesmo cartão apresenta **3 ou mais transações em uma janela móvel de 60 segundos**. A consulta usa uma janela OVER ordenada por tempo de evento. O resultado é um alerta analítico; não bloqueia pagamentos.

## Pré-requisitos

- Docker e Docker Compose (para PostgreSQL local).
- Cliente PostgreSQL, como `psql`.
- Conta Confluent Cloud com Kafka, Schema Registry e Flink habilitados para executar a parte gerenciada.
- Permissões para criar tópicos, registrar schemas, configurar conectores e executar statements Flink.

## Executar o banco local

1. Copie `.env.example` para `.env` e ajuste as credenciais locais, se necessário.
2. Inicie o PostgreSQL:

   ```bash
   docker compose up -d postgres
   ```

3. Aplique o schema e os dados:

   ```bash
   docker compose exec -T postgres psql -U pipeline -d pagamentos < database/init.sql
   docker compose exec -T postgres psql -U pipeline -d pagamentos < database/seed.sql
   ```

4. Confira os registros:

   ```bash
   docker compose exec postgres psql -U pipeline -d pagamentos -c "SELECT * FROM transactions ORDER BY created_at;"
   ```

## Configuração Confluent Cloud

1. Crie um cluster Kafka, um Schema Registry e um ambiente Flink.
2. Crie os tópicos de origem para contas e transações. Os nomes sugeridos estão em `connectors/topics.md`.
3. Registre os schemas Avro de `schemas/` no Schema Registry, ajustando subject naming strategy e compatibilidade ao padrão do conector escolhido.
4. Configure o conector Debezium PostgreSQL usando `connectors/debezium-postgres.example.json`. Substitua todos os placeholders por valores reais; nunca publique credenciais.
5. Execute as instruções de `sql/create-tables.sql` no workspace Flink, ajustando bootstrap server, API key, API secret, registry endpoint e demais propriedades para os recursos da sua conta.
6. Execute `sql/enrichment.sql` e `sql/fraud-detection.sql`.
7. Gere transações de teste e valide os resultados nos tópicos de saída.

> A configuração JSON é um modelo de referência. Os campos aceitos variam conforme a versão do conector e o tipo de deployment Confluent. Valide no formulário/documentação do conector antes de implantar.

## Observações técnicas importantes

- O PostgreSQL local é um ponto de partida para validar schema e dados; ele não publica eventos Kafka sozinho.
- O arquivo do conector representa a configuração CDC a ser aplicada no Confluent Cloud.
- Os SQLs Flink usam propriedades de conexão como placeholders. Não substitua por credenciais reais no Git.
- O campo de tempo de evento é convertido para TIMESTAMP_LTZ no SQL. Ajuste o formato conforme o payload efetivamente emitido pelo conector.
- A consulta de fraude considera eventos com timestamp válido e watermark configurado. Em produção, avalie atraso de eventos, duplicidade, idempotência, late events e falsos positivos.
- Métricas operacionais recomendadas: lag do conector, throughput de entrada/saída, erros de desserialização, latência fim a fim, checkpoints/restarts do Flink e custo por recurso/hora.

## Evidências

Adicione nesta pasta somente evidências produzidas por uma execução real:
- PostgreSQL com dados de origem;
- conector CDC em estado Running;
- tópicos recebendo eventos;
- schemas registrados;
- statements Flink em execução;
- saída enriquecida e alertas de fraude;
- métricas e estimativa de custo observadas.

## Segurança

Nunca commite `.env`, API keys, API secrets, senhas ou certificados. Use secrets/variáveis de ambiente e rotacione qualquer credencial publicada acidentalmente.

## Próximos passos

- [ ] Validar a captura CDC no Confluent Cloud.
- [ ] Confirmar os schemas Avro registrados.
- [ ] Executar e validar os statements Flink.
- [ ] Capturar evidências reais e atualizar esta documentação.
- [ ] Registrar métricas observadas e custo estimado do ambiente.

## Autor

Gustavo Germano — [GitHub](https://github.com/Gustavo-Germano)
