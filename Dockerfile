# Sử dụng Python 3.10
FROM python:3.10-slim

# Môi trường: không buffer stdout/stderr (log realtime)
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Copy toàn bộ project vào container
COPY . /app
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Cài dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Tạo folder report trong container và user không phải root
RUN mkdir -p /app/report && \
    adduser --disabled-password --gecos "" botuser || true && \
    chown -R botuser:botuser /app

# Chạy app dưới user không phải root
USER botuser

# Entrypoint tạo .env từ mẫu nếu cần, tạo thư mục data/report, v.v.
ENTRYPOINT ["/app/entrypoint.sh"]

# Default CMD: chạy bot
CMD ["python", "bot.py"]

