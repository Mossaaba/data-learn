# data-learn


# Run docker compose : 
docker-compose up -d

# Create a topic 
docker ps --> container id 

docker exec -it <kafka-container-id> kafka-topics --create \
    --topic test-topic --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1


# Connect to spark 
# df = spark \
  .readStream \
  .format("kafka") \
  .option("kafka.bootstrap.servers", "kafka:9092") \
  .option("subscribe", "test-topic") \
  .load()