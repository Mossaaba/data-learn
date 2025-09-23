# data-learn

https://app.diagrams.net/#G1jMjnG4OHOrY8jtv7EEms94-Gzt3pxaZA#%7B%22pageId%22%3A%22EAk9UfSw3r8_gIUQp022%22%7D


# Run docker compose : 
docker-compose up -d

# Create a topic 
docker ps --> container id 

docker exec -it <kafka-container-id> kafka-topics --create \
    --topic test-topic --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1

# describe topics configs
docker-compose exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name test-topic --describe 

# Connect to spark 
