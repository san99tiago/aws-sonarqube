# Built-in imports
import json
from typing import Optional
import logging

# External imports
import boto3
from botocore.exceptions import ClientError


logger = logging.getLogger()
logger.setLevel(level=logging.INFO)


class SecretHelper:
    """
    Class that works as a helper for low-level AWS Secret actions.
    """

    def __init__(self, secret_name: str) -> None:
        self.logger = logger
        self.secret_name = secret_name
        self.client_sm = boto3.client("secretsmanager")

    def get_secret_value(self) -> dict:
        """
        Obtain the AWS Secret value for this class.
        """
        try:
            secret_value = self.client_sm.get_secret_value(SecretId=self.secret_name)
            self.logger.info(
                f"Successfully retrieved the AWS Secret: {self.secret_name}"
            )
            self.secret_string = json.loads(secret_value["SecretString"])
            self.logger.debug("Successfully obtained the SecretString value.")
            return self.secret_string
        except ClientError as e:
            self.logger.exception(
                f"Error in pulling the AWS Secret: {self.secret_name}"
            )
            self.logger.exception(f"Error details: {str(e)}")
            raise e
