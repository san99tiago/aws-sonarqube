# Built-in imports
import os
import json
import pytest

# External imports
import boto3
from moto import mock_secretsmanager
from botocore.exceptions import ClientError

# Own imports
from src.secret_helper import SecretHelper


@pytest.fixture
def aws_credentials():
    """Mocked AWS configuration for moto library."""
    os.environ["AWS_ACCESS_KEY_ID"] = "testing"
    os.environ["AWS_SECRET_ACCESS_KEY"] = "testing"
    os.environ["AWS_SECURITY_TOKEN"] = "testing"
    os.environ["AWS_SESSION_TOKEN"] = "testing"
    os.environ["AWS_DEFAULT_REGION"] = "us-east-1"


@pytest.fixture
def mock_secret(aws_credentials):
    """Provide mocked client and configurations for secrets tests"""
    with mock_secretsmanager():
        secrets_manager = boto3.client(
            "secretsmanager", os.environ.get("AWS_DEFAULT_REGION")
        )
        secret_name = "test-secret-santi"
        secret_value = {
            "username": "test-user",
            "password": "test-password",
        }
        secrets_manager.create_secret(
            Name=secret_name, SecretString=json.dumps(secret_value)
        )
        yield secrets_manager


def test_get_secret_success(mock_secret):
    secret_helper = SecretHelper("test-secret-santi")
    retrieved_secret = secret_helper.get_secret_value()

    assert retrieved_secret["username"] == "test-user"
    assert retrieved_secret["password"] == "test-password"


def test_secret_helper_non_existent_secret(mock_secret):
    secret_helper = SecretHelper("test-non-existent-secret")
    with pytest.raises(ClientError):
        secret_helper.get_secret_value()
