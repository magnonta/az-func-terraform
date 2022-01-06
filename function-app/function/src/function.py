import azure.functions as func
import os, uuid, json

from function.src.azure_connect import AzureUpload
from function.src.dummy_data_generator import CustomerDataProducer


def function_main(body:str):
    """"
        A Main flow of function, this function will, generate fake data and
        save content as string on Account Storage.

        :param str body:
        Payload from request

        :return:
        A azure.functions.HttpResponse.
    """

    dummy_data = CustomerDataProducer().generateCustomer
    azure_conn = AzureUpload(os.getenv("AzureStringConnection")) if os.getenv("AzureStringConnection") is not None else AzureUpload("")
    azure_conn.set_file("landingzone", "dummy_data.txt")
    azure_conn.write_blob(json.dumps(dummy_data))

    return func.HttpResponse(
                json.dumps(dummy_data),
                status_code=200
        )
