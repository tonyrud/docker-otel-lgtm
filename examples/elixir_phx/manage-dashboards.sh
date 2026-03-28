#!/bin/bash
# Grafana Dashboard Management for Elixir Phoenix OTEL Example

GRAFANA_URL="http://localhost:3000" 
GRAFANA_AUTH="admin:admin"

# Function to create dashboard from JSON file
create_dashboard() {
    local json_file=$1
    echo "Creating dashboard from $json_file..."
    
    response=$(curl -s -X POST \
        http://$GRAFANA_AUTH@$GRAFANA_URL/api/dashboards/db \
        -H "Content-Type: application/json" \
        -d @$json_file)
    
    echo "Response: $response"
    
    # Extract URL from response
    url=$(echo $response | grep -o '"/d/[^"]*"' | tr -d '"')
    if [ ! -z "$url" ]; then
        echo "✅ Dashboard URL: $GRAFANA_URL$url"
    fi
}

# Function to generate test traffic for demonstration
generate_test_traffic() {
    echo "🎲 Generating test traffic for metrics-to-trace correlation..."
    
    # Fast requests 
    echo "Creating background activity..."
    for i in {1..5}; do
        curl -s "http://localhost:4000/rolldice/6" > /dev/null &
        curl -s "http://localhost:4000/rolldice/12" > /dev/null &
        sleep 1
    done
    
    sleep 2
    
    # High latency spike
    echo "⚡ Creating latency spike..."
    curl -s "http://localhost:4000/rolldice/100"
    
    echo -e "\n🎯 Check your dashboards for:"
    echo "1. Activity spikes in roll rate"
    echo "2. Latency increases in processing time" 
    echo "3. High latency request detection"
    echo "4. Live trace correlation via data links"
}

# Function to list existing dashboards
list_dashboards() {
    echo "📊 Existing dashboards:"
    curl -s http://$GRAFANA_AUTH@$GRAFANA_URL/api/search?query=elixir | \
        jq -r '.[] | "- \(.title): '$GRAFANA_URL'\(.url)"'
}

# Main menu
case "$1" in
    "create-basic")
        create_dashboard "grafana-dashboard.json"
        ;;
    "create-advanced") 
        create_dashboard "grafana-advanced-dashboard.json"
        ;;
    "create-all")
        create_dashboard "grafana-dashboard.json"
        create_dashboard "grafana-advanced-dashboard.json"
        ;;
    "test-traffic")
        generate_test_traffic
        ;;
    "list")
        list_dashboards
        ;;
    *)
        echo "Usage: $0 {create-basic|create-advanced|create-all|test-traffic|list}"
        echo ""
        echo "Commands:"
        echo "  create-basic     Create basic metrics-to-traces dashboard"
        echo "  create-advanced  Create advanced dashboard with alerts/logs"
        echo "  create-all       Create both dashboards"
        echo "  test-traffic     Generate test traffic for demo"
        echo "  list            List existing Elixir dashboards"
        echo ""
        echo "Examples:"
        echo "  $0 create-all && $0 test-traffic"
        echo "  $0 list"
        ;;
esac