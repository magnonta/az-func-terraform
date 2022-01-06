from function.src.dummy_data_generator import CustomerDataProducer


def test_when_invoke_generator_produce_dummy_data():

    dummy = CustomerDataProducer().generateCustomer
    assert dummy is not None and dummy != dict(), "Dummy Data is empty"


def test_when_invoke_generator_must_produce_random_data():

    dummy1 = CustomerDataProducer().generateCustomer
    dummy2 = CustomerDataProducer().generateCustomer
    assert any( [ dummy1[item] != dummy2[item] for item in dummy1] ), "All data is Equal, Producer not make random data."