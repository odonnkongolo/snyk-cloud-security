# Use the official, lightweight Python runtime as a parent image
FROM python:3.10-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

# Expose the default Flask APP port
EXPOSE 7777

# Command to run the Flask application
CMD ["flask", "--app", "flask-backend-app.py", "run", "--host=0.0.0.0", "--port=7777"]