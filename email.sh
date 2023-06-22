#!/bin/bash

# Set the path to your log files folder
log_folder="/Users/moreshwarpantwalavalkar/Documents/python/alert_email"

# Set the path to the country file
country_file="/Users/moreshwarpantwalavalkar/Documents/python/alert_email/country.txt"

# Set the recipient's email address
recipient_email="recipient@example.com"

# Set the path to the output HTML file
output_file="/Users/moreshwarpantwalavalkar/Documents/python/alert_email/email.html"

# Read the country information from the file into a temporary file
temp_file=$(mktemp)

# Process the country file to create a lookup table
while IFS=':' read -r hostname country; do
    echo "$hostname $country" >> "$temp_file"
done < "$country_file"

# Start building the HTML content
html_content="<html><head><title>Server Status</title>"
html_content+="<link rel=\"stylesheet\" type="text/css" href="styles.css"></head>"
html_content+="<body><div class="container"><table>"
html_content+="<thead><tr><th>Country</th><th>Error Count</th><th>Status</th></tr></thead>"
html_content+="<tbody>"

# Iterate through the log files in the folder
for log_file in "$log_folder"/*.log; do
    # Extract server status, hostname, and error count
    server_status=$(grep -E "server status is:" "$log_file" | cut -d ":" -f 2 | tr -d '[:space:]')
    hostname=$(grep -E "hostname is:" "$log_file" | cut -d ":" -f 2 | tr -d '[:space:]')
    error_count=$(grep -E "error count:" "$log_file" | cut -d ":" -f 2 | tr -d '[:space:]')
    ICM_PG=$(grep -E "ICM PG :" "$log_file" | cut -d ":" -f 2 | tr -d '[:space:]')

    # Check if the server is connected (assuming status is "Connected" or "Connected\n")
    if [[ "$ICM_PG" == "Connected"* ]]; then
        # Get the country based on the hostname
        country=$(grep -E "^$hostname " "$temp_file" | awk '{print $2}')

        # Append a row with the country instead of the hostname
        html_content+="<tr><td>${country:-Not Found}</td><td>$error_count</td><td class="connected">Connected</td></tr>"
    fi
done

# Close the HTML content
html_content+="</tbody></table></div></body></html>"

# Write the HTML content to the output file
echo "$html_content" > "$output_file"

# Send email
subject="Server Status Report"
body=$(cat "$output_file")
echo "$body" | mail -s "$subject" -a "Content-type: text/html;" "$recipient_email"

echo $body

# Clean up temporary files
rm "$temp_file"

echo "HTML page generated and email sent successfully"
