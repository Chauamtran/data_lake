import os
from datetime import timedelta, datetime
from airflow import DAG
from airflow.operators.bash_operator import BashOperator

WORKFLOW_DAG_ID = 'logstash_mongo_hdfs_authen'
WORKFLOW_DEFAULT_ARGS = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email': ['zaracattle@gmail.com'],
    'email_on_failure': True,
    'email_on_retry': True,
    'retries': 3,
    'retry_delay': timedelta(minutes=5)
}

# INIT DAG
logstash_mongo_hdfs_authen_dag = DAG(dag_id=WORKFLOW_DAG_ID,
                                     start_date=datetime(2020, 2, 1),
                                     schedule_interval="@once",
                                     catchup=False,
                                     default_args=WORKFLOW_DEFAULT_ARGS)

python_path = os.environ['PYTHONPATH']

call_logstash = "{}/system/logstash/logstash.sh".format(os.environ['PYTHONPATH'])

if os.path.exists(call_logstash):

    authen_mongo_kafka_hdfs = BashOperator(task_id='authen_mongo_kafka_hdfs',
                                           bash_command="cd {}/system/logstash/ ; ./logstash.sh {} {}".format(python_path,
                                                                                                             'up',
                                                                                                             'mongo_hdfs_authen'),
                                           dag=logstash_mongo_hdfs_authen_dag)

else:
    raise Exception("Can not execute {}".format(call_logstash))


