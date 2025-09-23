from kafka import KafkaConsumer
import json

# Configuration du consommateur Kafka
KAFKA_CONFIG = {
    'bootstrap_servers': 'localhost:9092',
    'auto_offset_reset': 'earliest',
    'enable_auto_commit': True,
    'group_id': 'my-group',
    'value_deserializer': lambda v: json.loads(v.decode('utf-8')),
    'key_deserializer': lambda k: k.decode('utf-8') if k else None
}

def consume_messages(topic):
    consumer = KafkaConsumer(topic, **KAFKA_CONFIG)
    print(f"Lecture des messages du topic : {topic}")
    for message in consumer:
        print(f"Clé : {message.key}, Valeur : {message.value}")

if __name__ == "__main__":
    consume_messages('test-topic')
