# Python project
This folder includes some python script examples

# Requirements
  * Install [pipenv](https://github.com/pypa/pipenv) for virtual environment 
  * Install [pyenv](https://github.com/pyenv/pyenv) to set global python to 3.6/3.7
  * Update prod/test env in <em>configs/database.ini</em>, for example section <em>[prod]</em>
  * Create a folder <em>python/logs</em> to store logging files
  * Install necessary packages in **requirements.txt** by ``` pipenv install -r requirements.txt ``` 
   
# Major folders
  * airflow
    > - Scripts to run data flows in ariflow control. 
      Add scripts to <em>airflow/dags</em> to register tasks to airflow control
    > - <em>airflow.cfg</em> is to define configurations of airflow
  * configs
    > - Store configs including ElasticSearch, Mongo, other scripts
  * ElasticSearch
    > - Scripts to extract data from ElasticSearch
  * Mongo
    > - Scripts to extract data from Mongo
  * tests
    > - Functions and integrations tests
  * utils
    > - Some util/help function to connect DBs 

# Usage
  * Manage jobs on airflow by add scripts to folders under <em>airflow<em>
  * To start other scripts, under <em>python</em> run ``` pipenv run python script.py ```
  * To run testcases, for example, 
  under <em>python</em> run ``` pipenv run pytest tests/logstash/test_logstash.py ```