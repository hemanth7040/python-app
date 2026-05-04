from fastapi import FastAPI, HTTPException
import boto3
from botocore.exceptions import ClientError
import os
import logging

# Setup basic logging for production visibility
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Production DevOps Project")

@app.get("/")
def read_root():
    return {
        "status": "online",
        "environment": os.getenv("ENV", "development"),
        "version": "1.0.1",
        "engineer": "Hemanth Kumar Motukuri"
    }

@app.get("/health")
def health_check():
    """Used by the Application Load Balancer to check if the container is alive."""
    return {"status": "healthy"}

@app.get("/get-secret")
def get_secret():
    """
    Demonstrates your ability to integrate app code with AWS Secrets Manager.
    This replaces hardcoded DB passwords.
    """
    secret_name = os.getenv("DB_SECRET_NAME", "my_production_secret")
    region_name = os.getenv("AWS_REGION", "us-east-1")

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name=region_name)

    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
        return {"message": "Secret retrieved successfully", "secret_id": secret_name}
    except ClientError as e:
        logger.error(f"Error retrieving secret: {e}")
        raise HTTPException(status_code=500, detail="Could not connect to AWS Secrets Manager")