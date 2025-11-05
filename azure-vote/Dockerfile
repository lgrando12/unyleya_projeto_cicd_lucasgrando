FROM tiangolo/uwsgi-nginx-flask:python3.6
RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org redis
ADD azure-vote /app
