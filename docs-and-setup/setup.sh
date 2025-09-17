#!/bin/bash

# Blockscout with Anvil Setup Script
# This script sets up a complete development environment with Anvil and Blockscout

set -e

echo "🚀 Setting up Blockscout with Anvil..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if Foundry is installed
if ! command -v anvil &> /dev/null; then
    print_warning "Foundry (Anvil) is not installed. Installing now..."
    
    # Install Foundry
    curl -L https://foundry.rustup.rs | sh
    source ~/.bashrc
    foundryup
    
    print_status "Foundry installed successfully!"
fi

# Create Anvil state directory
print_status "Creating Anvil state directory..."
mkdir -p ~/.anvil

# Check if port 8545 is available
if lsof -Pi :8545 -sTCP:LISTEN -t >/dev/null ; then
    print_warning "Port 8545 is already in use. Please stop the process using this port."
    print_status "You can check what's using the port with: lsof -i :8545"
    exit 1
fi

# Start Anvil in background
print_status "Starting Anvil..."
anvil --host 0.0.0.0 --port 8545 --chain-id 31337 --state ~/.anvil/anvilBlockchainState.json &
ANVIL_PID=$!

# Wait for Anvil to start
print_status "Waiting for Anvil to start..."
sleep 5

# Check if Anvil is running
if ! kill -0 $ANVIL_PID 2>/dev/null; then
    print_error "Failed to start Anvil"
    exit 1
fi

print_status "Anvil started successfully! (PID: $ANVIL_PID)"

# Start Blockscout
print_status "Starting Blockscout..."
docker compose -f docker-compose/docker-compose.yml up -d

# Wait for Blockscout to start
print_status "Waiting for Blockscout to start..."
sleep 30

# Check if Blockscout is running
if ! curl -s http://localhost/api/v2/stats > /dev/null; then
    print_warning "Blockscout might not be fully started yet. Please wait a moment and check http://localhost"
else
    print_status "Blockscout started successfully!"
fi

# Display status
echo ""
print_status "🎉 Setup complete!"
echo ""
echo "📋 Status:"
echo "  • Anvil: Running on http://localhost:8545 (PID: $ANVIL_PID)"
echo "  • Blockscout: Running on http://localhost"
echo ""
echo "🔧 Useful commands:"
echo "  • Mine 1 block: curl -X POST -H 'Content-Type: application/json' --data '{\"jsonrpc\":\"2.0\",\"method\":\"evm_mine\",\"params\":[],\"id\":1}' http://localhost:8545"
echo "  • Check Anvil status: curl -X POST -H 'Content-Type: application/json' --data '{\"jsonrpc\":\"2.0\",\"method\":\"eth_blockNumber\",\"params\":[],\"id\":1}' http://localhost:8545"
echo "  • Check Blockscout status: curl -s http://localhost/api/v2/stats | jq"
echo ""
echo "🛑 To stop:"
echo "  • Stop Anvil: kill $ANVIL_PID"
echo "  • Stop Blockscout: docker compose -f docker-compose/docker-compose.yml down"
echo ""
print_status "Happy coding! 🚀"
