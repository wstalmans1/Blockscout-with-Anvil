# Blockscout with Anvil Integration

This repository contains a complete setup for integrating [Blockscout](https://github.com/blockscout/blockscout) (blockchain explorer) with [Anvil](https://book.getfoundry.sh/anvil/) (local blockchain development node) for development and testing purposes.

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- [Foundry](https://book.getfoundry.sh/getting-started/installation) (includes Anvil)
- Git

### 1. Start Anvil (Manual Mode)

```bash
# Create Anvil state directory
mkdir -p ~/.anvil

# Start Anvil with manual mining
anvil --host 0.0.0.0 --port 8545 --chain-id 31337 --state ~/.anvil/anvilBlockchainState.json
```

### 2. Start Blockscout

```bash
# Clone and start Blockscout
git clone https://github.com/blockscout/blockscout.git
cd blockscout
docker compose -f docker-compose/docker-compose.yml up -d
```

### 3. Access the Explorer

Open your browser and go to: [http://localhost](http://localhost)

## 📚 Documentation

- **[Complete Integration Guide](ANVIL_INTEGRATION_GUIDE.md)** - Comprehensive guide for integrating Anvil and Blockscout into your projects
- **[Manual Mining Controls](ANVIL_INTEGRATION_GUIDE.md#manual-mining-controls)** - How to implement manual mining in your frontend
- **[Backend Integration](ANVIL_INTEGRATION_GUIDE.md#backend-integration)** - Connecting your backend to Anvil
- **[Frontend Integration](ANVIL_INTEGRATION_GUIDE.md#frontend-integration)** - Connecting your frontend to Anvil

## 🔧 Features

- **Manual Mining Control** - Mine blocks on demand for deterministic testing
- **Persistent State** - Anvil state persists between restarts
- **Real-time Explorer** - Blockscout provides a web interface to explore your blockchain
- **Development Ready** - Pre-configured for local development

## 🛠️ Manual Mining

### Command Line

```bash
# Mine 1 block
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"evm_mine","params":[],"id":1}' \
  http://localhost:8545

# Mine 10 blocks
for i in {1..10}; do
  curl -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"evm_mine","params":[],"id":1}' \
    http://localhost:8545 > /dev/null 2>&1
done
```

### JavaScript/TypeScript

```javascript
// Mine a single block
const response = await fetch('http://localhost:8545', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    jsonrpc: '2.0',
    method: 'evm_mine',
    params: [],
    id: 1
  })
});
```

## 🔍 Verification

### Check Anvil Status

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545
```

### Check Blockscout Status

```bash
curl -s http://localhost/api/v2/stats | jq
```

## 🐛 Troubleshooting

### Common Issues

1. **Port 8545 already in use**
   ```bash
   lsof -i :8545
   # Kill the process using the port
   kill -9 <PID>
   ```

2. **Blockscout not showing blocks**
   ```bash
   docker compose logs backend
   ```

3. **Connection refused**
   - Ensure Anvil is running
   - Check if Docker containers are running: `docker ps`

## 📖 Learn More

- [Anvil Documentation](https://book.getfoundry.sh/anvil/)
- [Blockscout Documentation](https://docs.blockscout.com/)
- [Foundry Book](https://book.getfoundry.sh/)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Blockscout](https://github.com/blockscout/blockscout) - The blockchain explorer
- [Foundry](https://github.com/foundry-rs/foundry) - The development toolkit
- [Anvil](https://book.getfoundry.sh/anvil/) - The local blockchain node