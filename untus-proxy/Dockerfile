FROM python:3.13-alpine

WORKDIR /app

COPY ./requirements.txt /requirements.txt

RUN pip install --no-cache-dir --upgrade -r /requirements.txt

COPY ./src /app

USER 1000

EXPOSE 8000

CMD ["fastapi", "run", "main.py", "--port", "8000", "--proxy-headers"]
