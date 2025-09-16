# Use official Python image
FROM python:3.9-slim

# Set work directory
WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy app source
COPY . .

# Run app
CMD ["python", "app.py"]