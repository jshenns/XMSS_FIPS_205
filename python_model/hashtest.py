import hashlib


my_string = "0000000000000000000000000000000000000000000000000000000000000001"

byte_data = bytes.fromhex(my_string)

print(hashlib.sha256(byte_data).hexdigest())

