#!/bin/bash

# Directory containing log files
log_directory="/Users/moreshwarpantwalavalkar/Documents/python"

# Output HTML file
output_file="log_table.html"

# Start HTML file
echo "<html>
<head>
<link rel='stylesheet' href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css'>
<style>
  .table-bordered th,
  .table-bordered td {
    border: 1px dotted black;
  }
</style>
</head>
<body>
<table id='logTable' class='table table-bordered'>

  <thead>
    <tr class='table-dark'>
      <th>Server Status</th>
      <th>Server Hostname</th>
      <th>ICM Connectivity</th>
      <th>Error</th>
    </tr>
  </thead>
  <tbody>" > "$output_file"

# Variable to store rows
rows=""

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
      row_classes="table-danger"
    else
      row_classes="table-primary"
    fi

    # Apply classes to error values greater than 25
    if [ "$error_value" -gt 25 ]; then
      error_classes="error-high"
    else
      error_classes=""
    fi

    # Add row to rows variable
    if [ "$icm_connectivity" = "connected" ]; then
      rows="<tr class=\"$row_classes\">
        <td class=\"fw-bold\">$server_status</td>
        <td>$server_hostname</td>
        <td class=\"text-center text-$icm_connectivity\">$icm_connectivity</td>
        <td class=\"$error_classes\">$error_value</td>
      </tr>$rows"
    else
      rows+="<tr class=\"$row_classes\">
        <td class=\"fw-bold\">$server_status</td>
        <td>$server_hostname</td>
        <td class=\"text-center text-$icm_connectivity\">$icm_connectivity</td>
        <td class=\"$error_classes\">$error_value</td>
      </tr>"
    fi

  else
    # Treat hostname as down if log file is 0 KB or does not exist
    server_hostname=$(basename "$log_file" .log)
    server_status="down"
    icm_connectivity="disconnected"
    error_value="N/A"
    row_classes="status-down"

    # Add row to rows variable
    rows+="<tr class=\"$row_classes\">
      <td>$server_status</td>
      <td>$server_hostname</td>
      <td>$icm_connectivity</td>
      <td>$error_value</td>
    </tr>"
  fi
done
# Add rows to HTML table
echo "$rows" >> "$output_file"

# End HTML file
echo "</tbody>
</table>

<script src='https://code.jquery.com/jquery-3.6.0.min.js'></script>
<script src='https://cdn.datatables.net/1.11.3/js/jquery.dataTables.min.js'></script>
<script src='https://cdn.datatables.net/buttons/2.1.0/js/dataTables.buttons.min.js'></script>
<script src='https://cdn.datatables.net/buttons/2.1.0/js/buttons.html5.min.js'></script>

<script src='log_table_script.js'></script>
]

</body>
</html>" >> "$output_file"

echo "HTML table generated successfully in $output_file."
