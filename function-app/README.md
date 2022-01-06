
# Azure Function Sample

This functions is a sample with objective is when running local, it will 
 - Connect with Azure
 - Generate some fake data
 - Upload this data to Storage Account

# How to Run Local ##

Clone repository, if vscode don't setup a virtual envirement run.

```
python3 -m venv ./.venv
. .venv/bin/activate
```

To run its local, you will __NEED__ setup a Envirement Variable for Azure Function, and you can setup on file *local.settings.json*, if you dind't have this file you can create on root of project with this:

```
{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "python",
    "AzureStringConnection": "<STRING CONNECTION>"
  }
}
```

Once you create this file, put the STRING CONNECTION on variable and in virtual envirement you can run 
```
func start
```

On terminal, and you will be able to send a resquest http to function locally and save the files on Azure.

## Request 

You can send a __GET__ or __POST__ request to
``http://localhost:7071/api/function`` with no header and no body in order to get a response a json of fake data generated and saved on Azure.

On Curl:
```
curl --location --request GET 'http://localhost:7071/api/function'
```
On python:
```
import requests

url = "http://localhost:7071/api/function"

payload={}
headers = {}

response = requests.request("GET", url, headers=headers, data=payload)

print(response.text)

```


# Run Tests

If you Have a Python Test Explorer extension, all test can be found there and you could run all in the extension.

if don't you can run on venv

``python3 -m pytest tests/``

### __Attention__
The tests don't make any interaction with Azure, all tests have mock the functions that interact with Azure, then the test don't persist any data on Azure.
##Tiy

# Debug on Vscode

With venv you can just run a __\_\_init\_\_.py__ with debugger and its gonna instance a http function on terminal, you can run a request with postman on url and debug:

You will need a stringConnetion named ``AzureStringConnection`` of Storage Account, to run this function and write on Azure.
you can put this on file local.setting.json in root.
And a container in that Storage Account with name landingzone.

Like this:

```
{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "python",
    "AzureStringConnection": "<STRING CONNECTION>"
  }
}
```

``function: [GET,POST] http://localhost:7071/api/function ``