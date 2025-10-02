FROM apache/airflow:2.7.2-python3.11

USER root

# Install system dependencies including Java for Spark
RUN apt-get update && apt-get install -y \
    gcc \
    openjdk-11-jdk \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER airflow

# Install Python packages
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Set Spark environment variables
ENV SPARK_HOME=/home/airflow/.local/lib/python3.11/site-packages/pyspark
ENV PYTHONPATH=$