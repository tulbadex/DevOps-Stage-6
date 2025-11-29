FROM python:3.8

WORKDIR /app
COPY requirements.txt .
RUN apt-get update && apt-get install -y gcc python3-dev
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "main.py"]