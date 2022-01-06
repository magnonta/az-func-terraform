from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient, __version__


class AzureUpload:
    """ 
        Function Connect to Azure Account Storage

        :param connection_string str:
            A Connection String  gets in portal of Azure.
    """

    def __init__(self, connection_string):

        self.error = None
        self.connection = None

        try:
            self.blob_service_client = BlobServiceClient.from_connection_string(connection_string)
            self.connection = True
        except Exception as error_conn:
            self.error = error_conn
            self.connection = False

        self.blob_client = None
        self.container = None
        self.file = None

    @property
    def get_blob_service_client(self):
        """ get a BlobServiceClient Object
        :return BlobClient:
            Return a BlobServiceClient Object
        """
        return self.blob_service_client

    @property
    def get_connection(self):
        """A property return infos about connetion"""
        return dict(connetion=self.connection, error=self.error, container= self.container, file=self.file)

    def set_file(self, container, file):
        """Function set a Container and File blob on Account Storage
        :param container str:
            Name of container on Storage Account
        :param file str:
            Name of file on Container
        :return bool:
            Return True if operation is successfull
        """
        self.container = container
        self.file = file
        self.blob_client = self.blob_service_client.get_blob_client(container=container, blob=file)
        return True

    @property
    def get_blob_client(self):
        """ get a BlobClient Object
        :return BlobClient:
            Return a BlobClient Object
        """
        return self.blob_client

    def write_blob(self, data:str):
        """
            This functions gets a content in str and convert to binary, and save in Blob file on
            Container set preview.

            :param data str:
                A content to write in String.
            :return bool:
                If its successfull write its return True
        """
        if self.blob_client is None:
            raise Exception("Blob Client is not set!")
        
        self.blob_client.upload_blob(data.encode('utf-8'), overwrite=True)
        return True