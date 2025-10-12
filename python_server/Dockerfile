FROM mcr.microsoft.com/playwright/python:v1.40.0-jammy
ENV PLAYWRIGHT_BROWSERS_PATH /root/.cache/ms-playwright/
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN playwright install --with-deps
COPY . .
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 edge_impulse_server:app