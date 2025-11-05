# ===============================
# Stage 1: Build dependencies
# ===============================
FROM python:3.10-slim AS builder
WORKDIR /app

# Cài dependencies trước để tận dụng cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# ===============================
# Stage 2: Runtime
# ===============================
FROM python:3.10-slim

# Môi trường
ENV PYTHONUNBUFFERED=1

# Tạo thư mục làm việc
WORKDIR /app

# Copy dependencies từ stage builder
COPY --from=builder /usr/local /usr/local

# Copy toàn bộ mã nguồn và script entrypoint
COPY . /app
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Tạo user không phải root để chạy an toàn
RUN adduser --disabled-password --gecos "" botuser && \
    mkdir -p /app/sqlite3 /app/report && \
    chown -R botuser:botuser /app

# Đặt user mặc định
USER root

# Entrypoint để tự fix quyền, tạo file .env và log khi start
ENTRYPOINT ["/app/entrypoint.sh"]

# Lệnh mặc định chạy bot
CMD ["python", "bot.py"]