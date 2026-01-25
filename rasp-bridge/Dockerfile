FROM python:3.14-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Install systemd client or ssh client if needed to control host system
# BUT for controlling host systemd, we best mount the socket or use SSH
RUN apt-get update && apt-get install -y ssh systemd-sysv

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
