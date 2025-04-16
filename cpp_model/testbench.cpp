#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>
#include <vector>
#include <openssl/sha.h>

std::string sha256_hex_string(const std::vector<unsigned char>& data) {
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256_CTX sha256;
    SHA256_Init(&sha256);
    SHA256_Update(&sha256, data.data(), data.size());
    SHA256_Final(hash, &sha256);
    std::stringstream ss;
    for (int i = 0; i < SHA256_DIGEST_LENGTH; ++i) {
        ss << std::hex << std::setw(2) << std::setfill('0') << (int)hash[i];
    }
    return ss.str();
}

std::vector<unsigned char> hex_string_to_bytes(const std::string& hex_string) {
    std::vector<unsigned char> bytes;
    for (size_t i = 0; i < hex_string.length(); i += 2) {
        std::string byte_string = hex_string.substr(i, 2);
        unsigned char byte = (unsigned char)std::stoi(byte_string, nullptr, 16);
        bytes.push_back(byte);
    }
    return bytes;
}

int main() {
    std::string hex_input;
    //std::cout << "Enter a hexadecimal integer: ";
    //std::cin >> hex_input;

    hex_input = "0000000000000000000000000000000000000000000000000000000000000001";

    std::vector<unsigned char> byte_input = hex_string_to_bytes(hex_input);
    std::string sha256_hash = sha256_hex_string(byte_input);

    std::cout << "SHA256 hash: " << sha256_hash << std::endl;

    return 0;
}