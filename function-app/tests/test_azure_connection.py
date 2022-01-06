import os

from pytest_mock import mocker
from function.src.azure_connect import AzureUpload

CONST_CONTAINER = "landingzone"
CONST_FILE = "teste.txt"

def test_fnc_try_connect_azure_account_with_connection_string(mocker):
    string_connection = os.getenv("AzureStringConnection") if os.getenv("AzureStringConnection") is not None else ""
    mocker.patch('azure.storage.blob.BlobServiceClient.from_connection_string')
    assert AzureUpload(string_connection).get_connection.get('connetion') is True, "Can't Connect to Azure Account with String"


def test_write_data_on_azure_account(mocker):

    mocker.patch('azure.storage.blob.BlobServiceClient.from_connection_string')
    mocker.patch('azure.storage.blob.BlobServiceClient.get_blob_client')
    mocker.patch('azure.storage.blob.BlobClient.upload_blob')
    string_connection = os.getenv("AzureStringConnection")
    string_connection = os.getenv("AzureStringConnection") if os.getenv("AzureStringConnection") is not None else ""

    AzureClient = AzureUpload(string_connection)
    AzureClient.set_file(CONST_CONTAINER, CONST_FILE)
    assert AzureClient.get_connection.get('container') == CONST_CONTAINER, "Can't Connect with container and file"
    assert AzureClient.get_connection.get('file') == CONST_FILE, "Can't Connect with container and file"
    assert AzureClient.write_blob("Teste2") is True, "Could not write a file"



