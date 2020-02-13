import pytest
import datetime
from airflow.operators.bash_operator import BashOperator
from airflow import DAG


@pytest.fixture
def logstash_airflow_dag():
    def _logstash_airflow(**kwargs):
        return DAG(
            dag_id=kwargs['dag_id'],
            default_args=kwargs['default_args'],
            schedule_interval=kwargs['schedule_interval']
        )
    return _logstash_airflow


class TestLogstashAirflow:
    """ Test Logstash Airflow jobs """

    # Test whether logstash for es_example is running
    def test_es_example(self, logstash_airflow_dag, tmpdir):
        """
        Test whether es_example logstash is running
        :param logstash_airflow_dag:
        :param tmpdir:
        :return:
        """

        tmpfile = tmpdir.mkdir("logstash").join("es_example.txt")
        dag = logstash_airflow_dag(dag_id="logstash_es_example",
                                   default_args={"owner": "airflow", "start_date": datetime.datetime.now()}, # Change to fixed date for start_date in prod
                                   schedule_interval="@once")
        task = BashOperator(task_id="logstash_es_example",
                            bash_command=f" docker ps -a | grep -c es_example > {tmpfile}",
                            dag=dag)
        pytest.helpers.run_task(task=task, dag=dag)

        assert tmpfile.read().replace("\n", "") == "1"

    # Test whether logstash for mongo_example is running
    def test_mongo_example(self, logstash_airflow_dag, tmpdir):
        """
        Test whether mongo_example logstash is running
        :param logstash_airflow_dag:
        :param tmpdir:
        :return:
        """

        tmpfile = tmpdir.mkdir("logstash").join("mongo_example.txt")
        dag = logstash_airflow_dag(dag_id="logstash_mongo_example",
                                   default_args={"owner": "airflow", "start_date": datetime.datetime.now()}, # Change to fixed date for start_date in prod
                                   schedule_interval="@once")
        task = BashOperator(task_id="logstash_mongo_example",
                            bash_command=f" docker ps -a | grep -c mongo_example > {tmpfile}",
                            dag=dag)
        pytest.helpers.run_task(task=task, dag=dag)

        assert tmpfile.read().replace("\n", "") == "1"

    # Test whether logstash for mysql_example is running
    def test_mysql_example(self, logstash_airflow_dag, tmpdir):
        """
        Test whether mysql_example logstash is running
        :param logstash_airflow_dag:
        :param tmpdir:
        :return:
        """

        tmpfile = tmpdir.mkdir("logstash").join("mysql_example.txt")
        dag = logstash_airflow_dag(dag_id="logstash_mysql_example",
                                   default_args={"owner": "airflow", "start_date": datetime.datetime.now()}, # Change to fixed date for start_date in prod
                                   schedule_interval="@once")
        task = BashOperator(task_id="logstash_mysql_example",
                            bash_command=f" docker ps -a | grep -c mysql_example > {tmpfile}",
                            dag=dag)
        pytest.helpers.run_task(task=task, dag=dag)

        assert tmpfile.read().replace("\n", "") == "1"
