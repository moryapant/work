#!/bin/bash

# Directory containing log files
log_directory="/Users/moreshwarpantwalavalkar/Documents/python"

# Country file
country_file="/Users/moreshwarpantwalavalkar/Documents/python/country_file.txt"

# Output HTML file
output_file="log_table.html"

# Start HTML file
echo "<html>
<head>
<style>
  table {
    border-collapse: collapse;
    width: 100%;
  }

  th, td {
    text-align: left;
    padding: 8px;
  }

  th {
    background-color: #333;
    color: #fff;
  }

  tr:nth-child(even) {
    background-color: #f2f2f2;
  }

  .status-running {
    color: #008000;
    font-weight: bold;
  }

  .status-down {
    color: #ff0000;
    font-weight: bold;
  }

  .connectivity-connected {
    color: #008000;
  }

  .connectivity-disconnected {
    color: #ff0000;
  }

  .error-high {
    color: #ff0000;
    font-weight: bold;
    background-color: #ffe6e6;
  }
</style>
</head>
<body>
<table>
  <tr>
    <th>Server Status</th>
    <th>Server Hostname</th>
    <th>Country</th>
    <th>ICM Connectivity</th>
    <th>Error</th>
  </tr>" > "$output_file"

# Iterate over log files
for log_file in "$log_directory"/*.log; do
  # Check if log file exists and its size is 0 KB or more
  if [ -f "$log_file" ] && [ -s "$log_file" ]; then
    # Extract information from log file
    server_status=$(awk -F ': ' '/Server status is/{print $NF}' "$log_file")
    server_hostname=$(awk -F ': ' '/server hostname/{print $NF}' "$log_file")
    icm_connectivity=$(awk -F ': ' '/ICM connectivity/{print $NF}' "$log_file")
    error_value=$(awk -F ': ' '/error:/{print $NF}' "$log_file")

    # Determine row classes based on server status and ICM connectivity
    if [[ "$server_status" != "running" || "$icm_connectivity" != "connected" ]]; then
      row_classes="status-down"
    else
      row_classes="status-running"
    fi

    # Look up the country name based on the server hostname
    country=$(grep "^$server_hostname:" "$country_file" | cut -d':' -f2)
    if [ -z "$country" ]; then
      country="N/A"
    fi

    # Apply classes to error values greater than 25
    if [ "$error_value" -gt 25 ]; then
      error_classes="error-high"
    else
      error_classes=""
    fi

    # Add row to HTML table
    echo "<tr class=\"$row_classes\">
      <td>$server_status</td>
      <td>$server_hostname</td>
      <td class=\"$row_classes\">$country</td>
      <td>$icm_connectivity</td>
      <td class=\"$error_classes\">$error_value</td>
    </tr>" >> "$output_file"
  else
    # Treat hostname as down if log file is 0 KB or does not exist
    server_hostname=$(basename "$log_file" .log)
    server_status="down"
    icm_connectivity="disconnected"
    error_value="N/A"
    row_classes="status-down"

    # Look up the country name based on the server hostname
    country=$(grep "^$server_hostname:" "$country_file" | cut -d':' -f2)
    if [ -z "$country" ]; then
      country="N/A"
    fi

    # Add row to HTML table
    echo "<tr class=\"$row_classes\">
      <td>$server_status</td>
      <td>$server_hostname</td>
    <td class=\"$country_classes\">$country</td>
      <td>$icm_connectivity</td>
      <td>$error_value</td>
    </tr>" >> "$output_file"
  fi
done

# End HTML file
echo "</table>
</body>
</html>" >> "$output_file"

echo "HTML table generated successfully in $output_file."
