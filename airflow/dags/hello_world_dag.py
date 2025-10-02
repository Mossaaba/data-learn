from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator

def print_hello():
    print("Hello World from Airflow!")
    return "Hello World"

dag = DAG(
    'hello_world_dag',
    default_args={
        'owner': 'airflow',
        'depends_on_past': False,
        'start_date': datetime(2025, 10, 2),
        'retries': 0,
    },
    description='Simple Hello World DAG',
    schedule_interval=None,  # Manual trigger only
    catchup=False,
    tags=['hello', 'world', 'simple'],
)

hello_task = PythonOperator(
    task_id='print_hello_world',
    python_callable=print_hello,
    dag=dag,
)