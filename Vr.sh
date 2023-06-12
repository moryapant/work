#!/bin/bash

log_file="Vrui.log"
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

# Print the last call time
if [ -n "$latest_call_time" ]; then
  echo "Last time 'uniqueCallId' was found: $latest_call_time"

  # Calculate the time difference in seconds
  current_time=$(date +"%s")
  latest_call_unixtime=$(date -d "$latest_call_time" +"%s")
  time_diff=$((current_time - latest_call_unixtime))

  # Convert time difference to minutes or hours
  minutes=$((time_diff / 60))
  hours=$((time_diff / 3600))

  echo "Time difference: $minutes minutes ($hours hours)"
else
  echo "No occurrence of 'uniqueCallId' found in the last $lines_to_check lines of the log."
fi
