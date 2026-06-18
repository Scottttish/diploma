from app.tasks.celery_app import celery_app

# start the worker:  celery -A celery_worker.celery_app worker --loglevel=info
# start beat scheduler: celery -A celery_worker.celery_app beat --loglevel=info
