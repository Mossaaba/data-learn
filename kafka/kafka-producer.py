from kafka import KafkaProducer
import json

# Configuration du producteur Kafka
KAFKA_CONFIG = {
    
    'bootstrap_servers': 'localhost:9092',
    'value_serializer': lambda v: json.dumps(v).encode('utf-8'),
    'key_serializer': lambda k: str(k).encode('utf-8'),
    'acks': 'all',
    'retries': 5,
    'linger_ms': 10
}

producer = KafkaProducer(**KAFKA_CONFIG)

def send_message(topic, key, value):
    """
    Envoie un message au topic Kafka spécifié.
    """
    producer.send(topic, key=key, value=value)
    producer.flush()

if __name__ == "__main__":
    # Exemple d'envoi de message
    send_message('test-topic', 'clé2', {'message': 'Bonjour Kafka !'})
    print('Message envoyé !')
