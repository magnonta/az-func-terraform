from faker import Faker
from datetime import datetime
class CustomerDataProducer:
    """ A Class who Generate a dict dummy data with fields:
    customer_name, customer_buy_price, cc and createdAt
    """

    def __init__(self):
        self.__fake = Faker()
        self.__customer_name = self.__fake.name()
        self.__customer_buy_price = self.__fake.pricetag()
        self.__customer_card_number = self.__fake.credit_card_number()
        self.__createdAt = datetime.now().strftime('%d/%m/%Y %H:%M:%S')

    @property
    def generateCustomer(self):
        """
            :return dict customer:
                A Dict with keys: customer_name, customer_buy_price, cc and createdAt 
        """
        customer = {'customer_name': self.__customer_name, \
                    'customer_buy_price': self.__customer_buy_price, \
                    'cc': self.__customer_card_number, \
                    'createdAt': self.__createdAt}

        return customer
