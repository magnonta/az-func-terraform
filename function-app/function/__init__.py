import azure.functions as func
from function.src.function import function_main


def main(req: func.HttpRequest) -> func.HttpResponse:
    """"Main Function, this funtion will receive a azure.functions.HttpRequest Object.
        valids methods: GET and POST

    :param azure.functions.HttpRequest req:
        A object of Resquest of Azure Functions
        
    :return azure.functions.HttpResponse:
        A Object of Response of Azure Functions
    """
    try:
        if req.method not in ("GET", "POST"):
            raise Exception(f"Method {req.method} don't allowed")
        return function_main(req.get_body())
    except Exception as error:
        return func.HttpResponse(
                f"Someting go wrong ERROR: {error}",
                status_code=400
        )
    