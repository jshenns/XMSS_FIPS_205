import csv
import math

# -------------------------------
# Custom SHA-256 Implementation
# -------------------------------
class SHA256():
    def __init__(self, mode="sha256", verbose=0):
        if mode not in ["sha224", "sha256"]:
            print("Error: Given %s is not a supported mode." % mode)
            return 0

        self.mode = mode
        self.verbose = verbose
        self.H = [0] * 8
        self.t1 = 0
        self.t2 = 0
        self.a = 0
        self.b = 0
        self.c = 0
        self.d = 0
        self.e = 0
        self.f = 0
        self.g = 0
        self.h = 0
        self.w = 0
        self.W = [0] * 16
        self.k = 0
        self.K = [0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
                  0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
                  0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
                  0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
                  0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
                  0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
                  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
                  0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
                  0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
                  0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
                  0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
                  0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
                  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
                  0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
                  0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
                  0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2]

    def init(self):
        if self.mode == "sha256":
            self.H = [0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
                      0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19]
        else:
            self.H = [0xc1059ed8, 0x367cd507, 0x3070dd17, 0xf70e5939,
                      0xffc00b31, 0x68581511, 0x64f98fa7, 0xbefa4fa4]

    def next(self, block):
        self._W_schedule(block)
        self._copy_digest()
        if self.verbose:
            print("State after init:")
            self._print_state(0)

        for i in range(64):
            self._sha256_round(i)
            if self.verbose:
                self._print_state(i)

        self._update_digest()

    def get_digest(self):
        return self.H

    def _copy_digest(self):
        self.a = self.H[0]
        self.b = self.H[1]
        self.c = self.H[2]
        self.d = self.H[3]
        self.e = self.H[4]
        self.f = self.H[5]
        self.g = self.H[6]
        self.h = self.H[7]

    def _update_digest(self):
        self.H[0] = (self.H[0] + self.a) & 0xffffffff
        self.H[1] = (self.H[1] + self.b) & 0xffffffff
        self.H[2] = (self.H[2] + self.c) & 0xffffffff
        self.H[3] = (self.H[3] + self.d) & 0xffffffff
        self.H[4] = (self.H[4] + self.e) & 0xffffffff
        self.H[5] = (self.H[5] + self.f) & 0xffffffff
        self.H[6] = (self.H[6] + self.g) & 0xffffffff
        self.H[7] = (self.H[7] + self.h) & 0xffffffff

    def _print_state(self, round):
        print("State at round 0x%02x:" % round)
        print("t1 = 0x%08x, t2 = 0x%08x" % (self.t1, self.t2))
        print("k  = 0x%08x, w  = 0x%08x" % (self.k, self.w))
        print("a  = 0x%08x, b  = 0x%08x" % (self.a, self.b))
        print("c  = 0x%08x, d  = 0x%08x" % (self.c, self.d))
        print("e  = 0x%08x, f  = 0x%08x" % (self.e, self.f))
        print("g  = 0x%08x, h  = 0x%08x" % (self.g, self.h))
        print("")

    def _sha256_round(self, round):
        self.k = self.K[round]
        self.w = self._next_w(round)
        self.t1 = self._T1(self.e, self.f, self.g, self.h, self.k, self.w)
        self.t2 = self._T2(self.a, self.b, self.c)
        self.h = self.g
        self.g = self.f
        self.f = self.e
        self.e = (self.d + self.t1) & 0xffffffff
        self.d = self.c
        self.c = self.b
        self.b = self.a
        self.a = (self.t1 + self.t2) & 0xffffffff

    def _next_w(self, round):
        if round < 16:
            return self.W[round]
        else:
            tmp_w = (self._delta1(self.W[14]) +
                     self.W[9] +
                     self._delta0(self.W[1]) +
                     self.W[0]) & 0xffffffff
            for i in range(15):
                self.W[i] = self.W[i+1]
            self.W[15] = tmp_w
            return tmp_w

    def _W_schedule(self, block):
        for i in range(16):
            self.W[i] = block[i]

    def _Ch(self, x, y, z):
        return (x & y) ^ (~x & z)

    def _Maj(self, x, y, z):
        return (x & y) ^ (x & z) ^ (y & z)

    def _sigma0(self, x):
        return (self._rotr32(x, 2) ^ self._rotr32(x, 13) ^ self._rotr32(x, 22))

    def _sigma1(self, x):
        return (self._rotr32(x, 6) ^ self._rotr32(x, 11) ^ self._rotr32(x, 25))

    def _delta0(self, x):
        return (self._rotr32(x, 7) ^ self._rotr32(x, 18) ^ self._shr32(x, 3))

    def _delta1(self, x):
        return (self._rotr32(x, 17) ^ self._rotr32(x, 19) ^ self._shr32(x, 10))

    def _T1(self, e, f, g, h, k, w):
        return (h + self._sigma1(e) + self._Ch(e, f, g) + k + w) & 0xffffffff

    def _T2(self, a, b, c):
        return (self._sigma0(a) + self._Maj(a, b, c)) & 0xffffffff

    def _rotr32(self, n, r):
        return ((n >> r) | (n << (32 - r))) & 0xffffffff

    def _shr32(self, n, r):
        return (n >> r)


# -----------------------------------------
# Utility Functions for Formatting & Hashing
# -----------------------------------------
def print_digest(digest, length=8):
    print("0x%08x, 0x%08x, 0x%08x, 0x%08x" %
          (digest[0], digest[1], digest[2], digest[3]))
    if length == 8:
        print("0x%08x, 0x%08x, 0x%08x, 0x%08x" %
              (digest[4], digest[5], digest[6], digest[7]))
    else:
        print("0x%08x, 0x%08x, 0x%08x" %
              (digest[4], digest[5], digest[6]))
    print("")

def compare_digests(digest, expected, length=8):
    correct = True
    for i in range(length):
        if digest[i] != expected[i]:
            correct = False

    if not correct:
        print("Error:")
        print("Got:")
        print_digest(digest, length)
        print("Expected:")
        print_digest(expected, length)
    else:
        print("Test case ok.")

def hash_format(input_string):
    # Break the hex string into 8-character chunks and convert to integers.
    input_block = []
    n = 8
    for i in range(0, len(input_string), n):
        input_block.append(int("0x" + input_string[i:i+n], 16))
    return input_block

def hash_unformat(input_array=[]):
    output_string = ""
    for x in input_array:
        output_string += str(x)
    return output_string

def digest_to_hex(digest):
    # Convert each integer to an 8-digit hex string and join them.
    return ''.join("{:08x}".format(x) for x in digest)


# -------------------------------
# Hash, PRF, Chain, and XMSS Functions
# -------------------------------
# F computes SHA-256 hash of the input string.
# Modified to always work on a 128-character hex string.
def F(input_string):
    # If input_string is already a digest (list), convert it to hex string.
    if isinstance(input_string, list):
        input_string = digest_to_hex(input_string)
    # Ensure the input is exactly 128 hex characters (512 bits).
    if len(input_string) < 128:
        input_string = input_string + input_string

    elif len(input_string) > 128:
        input_string = input_string[:128]
    my_sha256 = SHA256(verbose=0)
    my_sha256.init()
    formatted_input = hash_format(input_string)
    my_sha256.next(formatted_input)
    return my_sha256.get_digest()

def T(len, input_array = []):
    # If input_string is already a digest (list), convert it to hex string.
    my_sha256 = SHA256(verbose=0)
    my_sha256.init()

    i = 0

    while(i<len-1):


        #print("my_string: " + my_string)
        my_string = str(input_array[i]) + str(input_array[i + 1])
        #print(my_string)
        formatted_input = hash_format(my_string)
        #print("formated my_string: " + str(formatted_input))
        my_sha256.next(formatted_input)
        i = i+2

    return my_sha256.get_digest()


# PRF hashes a seed connected with an index.
def PRF(seed, index):
    my_sha256 = SHA256(verbose=0)
    my_sha256.init()
    formatted_input = hash_format(seed)
    my_sha256.next(formatted_input)
    return my_sha256.get_digest()

# H: Another wrapper for SHA-256 hash.
def H(value):
    my_sha256 = SHA256(verbose=0)
    my_sha256.init()
    formatted_input = hash_format(value)
    my_sha256.next(formatted_input)
    return my_sha256.get_digest()

# Chain function: Applies F iteratively for s times starting from X.
def chain(X, i, s):
    tmp = X
    for _ in range(i, i + s):
        tmp = F(tmp)
    return tmp

# Function to record intermediate chain values.
def chain_intermediate(X, s):
    intermediates = []
    tmp = X
    for _ in range(s):
        tmp = F(tmp)
        intermediates.append(digest_to_hex(tmp))
    return intermediates

# WOTS public key generation function.
def wots_pkGen(SK_seed, w, length):
    temp = [0]*length
    for i in range(length):
        sk = F(SK_seed)
        temp[i] = digest_to_hex((chain(sk, 0, w - 1)))
    #print("temp[i] " + str(temp[i]))
    return T(67, temp)

# WOTS sign function
def wots_sign(M, SK_seed):

    csum = 0
    sig = []


    # checksum
    for i in range(64):
        csum = csum + 16-1-int(M[i+2],16)

    print(csum)

    # left shift csum by 4
    csum = csum << 4
    print(csum)

    csum = hex(csum)
    print(csum)

    msg = str(M[2:]) + str(csum[3:6])
    print(msg)
    print(len(msg))

    for i in range(67):
        sk = F(SK_seed)
        sig.append(chain(sk, 0, int(msg[i],16)))
        #print("wots sign msg[i] : " + str(int(msg[i],16)))

    return sig


# XMSS tree node computation.
def xmss_node(SK_seed, i, z):
    if z == 0:
        # Level 0 returns the WOTS public key (as a hex string).
        return wots_pkGen(SK_seed, 16, 67)
    else:
        lnode = xmss_node(SK_seed, 2 * i, z - 1)
        rnode = xmss_node(SK_seed, 2 * i + 1, z - 1)
        # Convert nodes to hex if needed for sequences.
        if isinstance(lnode, list):
            lnode = digest_to_hex(lnode)
        if isinstance(rnode, list):
            rnode = digest_to_hex(rnode)
        h_digest = F(lnode + rnode)  # H returns a digest (list of ints)
        # Return the raw digest for levels > 0.
        return h_digest

# XMSS signature generation function.
def xmss_sign(M, SK_seed, idx, h):
    AUTH = []
    for j in range(h):
        k = (idx // (2 ** j)) ^ 1
        AUTH.append(xmss_node(SK_seed, k, j))

    return (wots_sign(M, SK_seed), AUTH)

def xmss_pkFromSig(idx, wots_sig, AUTH, M, h):

    node_0 = wots_pkFromSig(M, wots_sig)


    for k in range(h):
        if math.floor(idx/(2**k)) % 2 == 0:
            input_string = str(digest_to_hex(node_0)) + str(digest_to_hex(AUTH[k]))
            node_1 = F(input_string)
        else:
            input_string = str(digest_to_hex(AUTH[k])) + str(digest_to_hex(node_0))
            node_1 = F(input_string)

        node_0 = node_1


    return node_0

def wots_pkFromSig(M,sig=[] ):

    my_csum = 0
    tmp_array = [0]*67


    # checksum
    for i in range(64):
        my_csum = my_csum + 16-1-int(M[i+2],16)

    print(my_csum)

    # left shift csum by 4
    my_csum = my_csum << 4
    print(my_csum)

    my_csum = hex(my_csum)
    print(my_csum)

    my_msg = str(M[2:]) + str(my_csum[3:6])
    print(my_msg)
    print(len(my_msg))

    for i in range(67):
        tmp_array[i] = chain(sig[i], int(my_msg[i], 16), 16-int(my_msg[i],16)-1)
        tmp_array[i] = digest_to_hex(tmp_array[i])


    return T(67, tmp_array)



def is_hex_string(s):
    try:
        int(s, 16)
        return True
    except ValueError:
        return False

# -------------------------------
# Main Function
# -------------------------------
def main():
    # Get user input.
    #user_input = input("Enter a string: ")
    user_input = "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001"
    message = "0x0000000000000000000000000000000000000000000000000000000000000001"
    # If the input is a valid hex string (and its length is a multiple of 8), assume it is already formatted.
    if is_hex_string(user_input) and (len(user_input) % 8 == 0):
        hex_input = user_input
    else:
        # Otherwise, convert to hex using UTF-8.
        hex_input = user_input.encode("utf-8").hex()

    # For our one-block implementation, force the hex string to be 128 characters (512 bits).
    if len(hex_input) % 8 != 0:
        hex_input = hex_input.ljust(((len(hex_input) // 8) + 1) * 8, '0')
    if len(hex_input) < 128:
        hex_input = hex_input.ljust(128, '0')
    elif len(hex_input) > 128:
        hex_input = hex_input[:128]

    # Compute SHA256 digest of the hex input.
    sha_digest = F(hex_input)
    print(sha_digest)
    sha_digest_hex = digest_to_hex(sha_digest)

    # Compute chain intermediate values (e.g., 5 iterations) and the final chain value.
    chain_vals = chain_intermediate(hex_input, 5)
    final_chain = chain(hex_input, 0, 5)
    final_chain_hex = digest_to_hex(final_chain)

    # Compute WOTS public key (using SK_seed as hex_input, w=16, length=32).
    wots_pk = digest_to_hex(wots_pkGen(hex_input, 16, 67))

    # Compute XMSS signature (using M as the original user_input, SK_seed as hex_input, idx=0, h=3).
    # (Using h=3 so that we get Level 0, Level 1, and Level 2 as in your sample.)
    sig, auth = xmss_sign(message, hex_input, 0, 8)

    xmss_pk_calc = xmss_pkFromSig(0,sig, auth, message,8)
    print("xmss_pk_calc : " + str(digest_to_hex(xmss_pk_calc)))

    pk = digest_to_hex(xmss_node(hex_input, 0, 8))


    print("pk: " + str(pk))

    wots_sig = wots_sign(message, hex_input)

    new_wots_sig = [0]*67
    new_auth = [0]*8

    for i in range(7, -1,-1):
        new_auth[i] = auth[7-i]

    for i in range(66,-1,-1):
        new_wots_sig[i]= wots_sig[66-i]

    hex_wots_sig = ""

    hex_auth = ""

    for i in range(8):
        hex_auth = hex_auth + str(digest_to_hex(new_auth[i]))

    for i in range(67):
        hex_wots_sig = hex_wots_sig + str(digest_to_hex(new_wots_sig[i]))



    print("wots_sig: " +hex_wots_sig)

    wots_pkFromSig_test = wots_pkFromSig(message, wots_sig)
    print("wots calc pk: " + str(digest_to_hex(wots_pkFromSig_test)))

    print("xmss_sig: " + hex_wots_sig+hex_auth)

    for i in range(len(auth)):
        auth[i] = digest_to_hex(auth[i])

    for i in range(len(sig)):
        sig[i] = digest_to_hex(sig[i])

    print("auth: " + str(auth))

    # Build a formatted string for the authentication path.
    auth_formatted = "\n".join("Level {}: {}".format(i, auth[i]) for i in range(len(auth)))

    csv_filename = "output.csv"
    with open(csv_filename, mode="w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["SHA256 Digest", "Final Chain Value", "Chain Intermediate Values", "WOTS Public Key", "XMSS Signature", "Authentication Path"])
        # Write one row of data.
        writer.writerow([
            sha_digest_hex,
            final_chain_hex,
            ";".join(chain_vals),
            wots_pk,
            ";".join(sig),
            auth_formatted
        ])

    # print outputs to the console.
    print("SHA256 Digest:")
    print(sha_digest_hex)
    print(sha_digest)
    print("\nFinal Chain Value (after 5 iterations):")
    print(final_chain_hex)
    print("\nChain Intermediate Values:")
    for val in chain_vals:
        print(val)
    print("\nWOTS Public Key:")
    print(wots_pk)
    print("\nXMSS Signature:")
    print("; ".join(sig))
    print("\nAuthentication Path:")
    for i, level in enumerate(auth):
        print("Level {}: {}".format(i, level))
    print(f"\nOutput written to {csv_filename}")

if __name__ == "__main__":
    main()