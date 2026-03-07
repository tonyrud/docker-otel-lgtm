#!/bin/sh

# Use environment variable with default fallback
SLEEP_INTERVAL=${SLEEP_INTERVAL:-2}

echo "Generating traffic to Elixir Phoenix dice server with ${SLEEP_INTERVAL}s intervals"

# Pre-calculate interval values to avoid arithmetic issues
COUNTER=1
SLOW_INTERVAL=$((SLEEP_INTERVAL * 10))
ERROR_INTERVAL=$((SLEEP_INTERVAL * 15))
VERY_SLOW_INTERVAL=$((SLEEP_INTERVAL * 25))

echo "Using intervals: slow=${SLOW_INTERVAL}, error=${ERROR_INTERVAL}, very_slow=${VERY_SLOW_INTERVAL}"

while true; do
  printf "Request interval #%s - sending traffic...\n" "$COUNTER"
  
  # === FAST BUT FREQUENT (high traffic, low latency) ===
  # These are called very often to create high-impact but fast queries
  curl -s http://host.docker.internal:4000/rolldice/6 > /dev/null
  
  # === MIXED PATTERNS (regular calls with different dice sides) ===
  # Called regularly to create diverse trace patterns
  curl -s http://host.docker.internal:4000/rolldice/12 > /dev/null
  curl -s http://host.docker.internal:4000/rolldice/2 > /dev/null
  curl -s http://host.docker.internal:4000/rolldice/3 > /dev/null
  
  # === SLOW BUT RARE (low traffic, high latency) ===
  # Called infrequently to create varied traffic patterns
  if [ $((COUNTER % SLOW_INTERVAL)) -eq 0 ]; then
    echo "Generating some slow requests to create high-latency traces..."
    echo ""
    curl -s http://host.docker.internal:4000/rolldice/100 > /dev/null
    # not a real endpoint
    curl -s http://host.docker.internal:4000/api/dice/50 > /dev/null
  fi
  
  if [ $((COUNTER % ERROR_INTERVAL)) -eq 0 ]; then
    echo "Generating some invalid requests to create errors and exceptions in traces/logs..."
    echo ""
    curl -s http://host.docker.internal:4000/rolldice/abc > /dev/null
  fi
  
  if [ $((COUNTER % VERY_SLOW_INTERVAL)) -eq 0 ]; then
    curl -s http://host.docker.internal:4000/rolldice/1000 > /dev/null
    curl -s http://host.docker.internal:4000/rolldice/timeout > /dev/null
  fi
  
  COUNTER=$((COUNTER + 1))
  sleep $SLEEP_INTERVAL
done