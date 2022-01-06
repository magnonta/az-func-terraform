import azure.functions as func
import os
import json

from function import main


def test_when_call_function_should_return_200(mocker):
    mocker.patch('azure.storage.blob.BlobServiceClient.from_connection_string')
    mocker.patch('azure.storage.blob.BlobServiceClient.get_blob_client')
    mocker.patch('azure.storage.blob.BlobClient.upload_blob')
    assert main(func.HttpRequest(method="GET", url="http://localhost:7071/api/function",headers={}, body={})).status_code == 200, "Status code is not 200"

def test_when_call_function_should_return_error():
    assert main(func.HttpRequest(method="DELETE", url="http://localhost:7071/api/function",headers={}, body={})).status_code == 400, "Status code is not 200"

