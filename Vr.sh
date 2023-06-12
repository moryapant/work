#!/bin/bash

log_file="vrui.log"
lines_to_check=100

# Get the last 100 lines of the log file
last_lines=$(tail -n $lines_to_check "$log_file")

# Find the last occurrence of 'uniqueCallId' and its time
latest_call_time=""

while IFS= read -r line; do
  if [[ $line =~ .*uniqueCallId.* ]]; then
    call_time=$(echo "$line" | awk '{print $1, $2}')
    latest_call_time="$call_time"
  fi
done <<< "$last_lines"

# Compare with current system time and calculate time difference in hours
if [ -n "$latest_call_time" ]; then
  latest_call_timestamp=$(date -d "$latest_call_time" +%s)
  current_timestamp=$(date +%s)
  
  time_difference=$(( (current_timestamp - latest_call_timestamp) / 3600 ))
  
  echo "Last time 'uniqueCallId' was found: $latest_call_time"
  echo "Time difference: $time_difference hours ago"
else
  echo "No occurrence of 'uniqueCallId' found in the last $lines_to_check lines of the log."
fi
