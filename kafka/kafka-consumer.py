from kafka import KafkaConsumer
import json

KAFKA_CONFIG = {
    'bootstrap_servers': 'kafka:9092',  # Docker network
    'auto_offset_reset': 'earliest',
    'enable_auto_commit': True,
    'group_id': 'my-group',
    'value_deserializer': lambda v: json.loads(v.decode('utf-8')),
    'key_deserializer': lambda k: k.decode('utf-8') if k else None
}

consumer = KafkaConsumer("test-topic", **KAFKA_CONFIG)
print("Listening for messages on 'test-topic'...")

for message in consumer:
    print(f"Key: {message.key}, Value: {message.value}")