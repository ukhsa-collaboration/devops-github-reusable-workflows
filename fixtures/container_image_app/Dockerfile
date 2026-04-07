FROM python:3.13-slim

WORKDIR /srv/app
COPY app/ app/
ENV PYTHONPATH=/srv/app/app
CMD ["python", "-c", "import greetings; print(greetings.hello())"]
