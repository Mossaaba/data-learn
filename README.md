# data-learn

Data pipeline with Kafka, Spark, and Airflow for real-time data processing and workflow orchestration.

## Architecture

- **Apache Kafka**: Message streaming platform
- **Apache Spark**: Distributed data processing (PySpark)
- **Apache Airflow**: Workflow orchestration
- **AKHQ**: Kafka management UI
- **PostgreSQL**: Airflow metadata database
- **Redis**: Airflow message broker

## Quick Start

### 1. Start all services
```bash
docker-compose up -d
```

### 2. Access the UIs
- **Airflow**: http://localhost:8081 (admin/admin)
- **AKHQ (Kafka UI)**: http://localhost:8080
- **Jupyter (PySpark)**: http://localhost:8888
- **Spark UI**: http://localhost:4040

### 3. Initialize Airflow (first time only)
```bash
docker-compose run --rm airflow-init
```

## Kafka Operations

### Create a topic
```bash
docker exec -it $(docker ps -q -f name=kafka) kafka-topics --create \
    --topic test-topic --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1
```

### Send messages
```bash
docker compose up kafka-producer
```

### Read messages
```bash
docker compose up kafka-consumer
```

### Describe topic configs
```bash
docker-compose exec kafka kafka-configs --bootstrap-server localhost:9092 \
    --entity-type topics --entity-name test-topic --describe
```

## Airflow DAGs

The repository includes sample DAGs:

1. **data_pipeline_dag**: Processes lottery data and sends to Kafka
2. **kafka_monitoring_dag**: Monitors Kafka health and topics

## Data Pipeline Flow

1. **Airflow** orchestrates the workflow
2. **Data processing** reads CSV files and transforms data
3. **Kafka** streams processed data
4. **Spark** performs analytics and ML processing
5. **Monitoring** tracks pipeline health

## Development

- DAGs: `./airflow/dags/`
- Kafka scripts: `./kafka/`
- Data: `./data/`
- Notebooks: `./notebooks/` 
