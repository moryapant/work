#!/bin/bash

# Directory containing log files
log_directory="/Users/moreshwarpantwalavalkar/Documents/python"

# Output HTML file
output_file="log_table.html"

# Start HTML file
echo "<html><body><table style=\"border-collapse: collapse;\"><tr><th style=\"border: 1px solid black; padding: 8px;\">Server Status</th><th style=\"border: 1px solid black; padding: 8px;\">Server Hostname</th><th style=\"border: 1px solid black; padding: 8px;\">ICM Connectivity</th><th style=\"border: 1px solid black; padding: 8px;\">Error</th></tr>" > "$output_file"

# Iterate over log files
for log_file in "$log_directory"/*.log; do
  # Check if log file exists and its size is 0 KB or more
  if [ -f "$log_file" ] && [ -s "$log_file" ]; then
    # Extract information from log file
    server_status=$(awk -F ': ' '/Server status is/{print $NF}' "$log_file")
    server_hostname=$(awk -F ': ' '/server hostname/{print $NF}' "$log_file")
    icm_connectivity=$(awk -F ': ' '/ICM connectivity/{print $NF}' "$log_file")
    error_value=$(awk -F ': ' '/error:/{print $NF}' "$log_file")

    # Determine row color based on server status and ICM connectivity
    if [[ "$server_status" != "running" || "$icm_connectivity" != "connected" ]]; then
      row_color="red"  # Use red color for non-running status or disconnected connectivity
    else
      row_color="green"  # Use green color for running status and connected connectivity
    fi

    # Apply bold styling to error values greater than 25
    if [ "$error_value" -gt 25 ]; then
      error_style="font-weight: bold; background-color: red;"
    else
      error_style=""
    fi

    # Add row to HTML table
    echo "<tr style=\"background-color: $row_color;\"><td style=\"border: 1px solid black; padding: 8px;\">$server_status</td><td style=\"border: 1px solid black; padding: 8px;\">$server_hostname</td><td style=\"border: 1px solid black; padding: 8px;\">$icm_connectivity</td><td style=\"border: 1px solid black; padding: 8px; $error_style\">$error_value</td></tr>" >> "$output_file"
  else
    # Treat hostname as down if log file is 0 KB or does not exist
    server_hostname=$(basename "$log_file" .log)
    server_status="down"
    icm_connectivity="disconnected"
    error_value="N/A"
    row_color="red"  # Use red color for down status and disconnected connectivity

    # Add row to HTML table
    echo "<tr style=\"background-color: $row_color;\"><td style=\"border: 1px solid black; padding: 8px;\">$server_status</td><td style=\"border: 1px solid black; padding: 8px;\">$server_hostname</td><td style=\"border: 1px solid black; padding: 8px;\">$icm_connectivity</td><td style=\"border: 1px solid black; padding: 8px; $error_style\">$error_value</td></tr>" >> "$output_file"
  fi
done

# End HTML file
echo "</table></body></html>" >> "$output_file"

echo "HTML table generated successfully in $output_file."
