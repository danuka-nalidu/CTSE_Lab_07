#!/bin/bash
# Test script for Event-Driven Microservices Lab

echo "=========================================="
echo "Event-Driven Microservices Test Script"
echo "=========================================="
echo ""

# Function to send order
send_order() {
    local orderId=$1
    local item=$2
    local quantity=$3
    local amount=$4
    
    echo "[TEST] Sending order: $orderId - $item (Qty: $quantity, Amount: $amount)"
    
    curl -X POST http://localhost:8080/orders \
      -H "Content-Type: application/json" \
      -d "{\"orderId\":\"$orderId\",\"item\":\"$item\",\"quantity\":$quantity,\"amount\":$amount}" \
      2>/dev/null
    
    echo ""
    echo "[TEST] Waiting 2 seconds for event processing..."
    sleep 2
}

# Check if services are running
echo "[CHECK] Verifying all services are running..."
docker-compose ps

echo ""
echo "========== SERVICE STATUS CHECK =========="
echo "[CHECK] API Gateway:"
curl -s http://localhost:8080/actuator/health 2>/dev/null | jq '.status' || echo "Not responding"

echo ""
echo "[CHECK] Order Service:"
curl -s http://localhost:8081/actuator/health 2>/dev/null | jq '.status' || echo "Not responding"

echo ""
echo "========== SENDING TEST ORDERS =========="
echo ""

# Send test orders
send_order "ORD-2026-001" "Laptop" 1 1299.99
send_order "ORD-2026-002" "iPhone 15" 2 1598.98
send_order "ORD-2026-003" "4K Monitor" 1 499.99

echo ""
echo "========== VIEWING EVENT LOGS =========="
echo ""
echo "[LOGS] Order Service (Order Publishing):"
docker-compose logs --tail=5 order-service | grep -i "produced\|sent\|KafkaProducer" || echo "No recent producer logs"

echo ""
echo "[LOGS] Inventory Service (Event Consumption):"
docker-compose logs --tail=10 inventory-service | grep -i "received\|stock" || echo "No recent messages"

echo ""
echo "[LOGS] Billing Service (Event Consumption):"
docker-compose logs --tail=10 billing-service | grep -i "received\|invoice" || echo "No recent messages"

echo ""
echo "========== KAFKA TOPIC INSPECTION =========="
echo ""
echo "[KAFKA] Topics in cluster:"
docker exec kafka kafka-topics --list --bootstrap-server kafka:9092 2>/dev/null

echo ""
echo "[KAFKA] Messages in order-topic:"
docker exec kafka kafka-console-consumer --topic order-topic --from-beginning \
  --max-messages=3 --bootstrap-server kafka:9092 2>/dev/null

echo ""
echo "=========================================="
echo "Test Complete!"
echo "=========================================="
echo ""
echo "To view realtime logs:"
echo "  docker-compose logs -f"
echo ""
echo "To stop services:"
echo "  docker-compose down"
