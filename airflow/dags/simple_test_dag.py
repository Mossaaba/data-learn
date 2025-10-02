from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'data-team',
    'depends_on_past': False,
    'start_date': datetime(2025, 10, 2),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}

dag = DAG(
    'simple_test_dag',
    default_args=default_args,
    description='Simple test DAG to verify Airflow is working',
    schedule_interval=timedelta(minutes=5),
    catchup=False,
    tags=['test'],
)

def test_python_task(**context):
    """Simple Python task for testing"""
    print("Hello from Airflow!")
    print(f"Execution date: {context['execution_date']}")
    print("Python task executed successfully")
    return "success"

def test_imports(**context):
    """Test if we can import required packages"""
    try:
        import pandas as pd
        print(f"Pandas version: {pd.__version__}")
        
        from kafka import KafkaProducer
        print("Kafka-python imported successfully")
        
        import json
        print("JSON module available")
        
        return "All imports successful"
    except Exception as e:
        print(f"Import error: {str(e)}")
        raise

# Task definitions
test_bash = BashOperator(
    task_id='test_bash_task',
    bash_command='echo "Hello from Bash!" && echo "Current time: $(date)" && echo "User: $(whoami)"',
    dag=dag,
)

test_python = PythonOperator(
    task_id='test_python_task',
    python_callable=test_python_task,
    dag=dag,
)

test_imports_task = PythonOperator(
    task_id='test_imports_task',
    python_callable=test_imports,
    dag=dag,
)

# Task dependencies
test_bash >> test_python >> test_imports_task