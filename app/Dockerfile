# --- Stage 1: Build Stage ---
FROM python:3.9-slim as builder

WORKDIR /app

# Install build dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# --- Stage 2: Final Runtime Stage ---
FROM python:3.9-slim

# Create the user first
RUN useradd -m myuser
USER myuser
WORKDIR /home/myuser/app

# Copy the installed libraries to the new user's home directory
COPY --from=builder --chown=myuser:myuser /root/.local /home/myuser/.local
COPY --chown=myuser:myuser . .

# Update PATH to the new user's local bin
ENV PATH=/home/myuser/.local/bin:$PATH

EXPOSE 9999

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "9999"]