import pytest

pytest_plugins = ['helpers_namespace']


@pytest.helpers.register
def run_task(task, dag):
    task.run(
        start_date=dag.default_args["start_date"],
        end_date=dag.default_args["start_date"]
    )