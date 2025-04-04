#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>
#include <openssl/sha.h>
#include <algorithm>
#include <vector> // Add this line

// Function to convert a hex string to a byte vector
std::vector<unsigned char> hexToBytes(const std::string& hex) {
    std::vector<unsigned char> bytes;
    for (unsigned int i = 0; i < hex.length(); i += 2) {
        std::string byteString = hex.substr(i, 2);
        unsigned char byte = (unsigned char)strtol(byteString.c_str(), NULL, 16);
        bytes.push_back(byte);
    }
    return bytes;
}

std::string reverseString(const std::string& input) {
    std::string reversed = input;
    std::reverse(reversed.begin(), reversed.end());
    return reversed;
}

std::string reverseEndianness(const std::string& hexInput) {
    if (hexInput.length() % 2 != 0) {
        std::cerr << "Error: Input hex string must have an even number of characters." << std::endl;
        return ""; // Or throw an exception
    }

    std::string reversedHex;
    for (size_t i = 0; i < hexInput.length(); i += 2) {
        reversedHex = hexInput.substr(i, 2) + reversedHex; // Prepend each byte
    }

    return reversedHex;
}

// Function to compute the SHA256 hash of a byte vector
std::string sha256(const std::vector<unsigned char>& data) {
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256_CTX sha256;
    SHA256_Init(&sha256);
    SHA256_Update(&sha256, data.data(), data.size());
    SHA256_Final(hash, &sha256);
    std::stringstream ss;
    for (int i = 0; i < SHA256_DIGEST_LENGTH; i++) {
        ss << std::hex << std::setw(2) << std::setfill('0') << (int)hash[i];
    }
    return ss.str();
}

int main() {
    std::string hexInput;
    //std::cout << "Enter a hexadecimal string: ";
    //std::cin >> hexInput;

    hexInput = u8"00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001";
    
    // Convert the hex string to a byte vector
    std::vector<unsigned char> byteData = hexToBytes(hexInput);

    // Compute the SHA256 hash
    std::string hash = sha256(byteData);

    // Print the SHA256 hash
    std::cout << "SHA256 Hash: " << hash << std::endl;

    return 0;
}