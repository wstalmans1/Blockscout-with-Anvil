# Anvil + Blockscout Architecture & Usage Guide

## Overview

This document explains the architecture of the Anvil + Blockscout development environment and provides clear usage instructions for developers.

## Architecture Components

### 1. **Blockscout Project Folder** 📁
**What it is:** The source code and configuration for the blockchain explorer

**What it contains:**
- **Docker Compose files** (`docker-compose.yml`) - Defines how to run multiple services
- **Configuration files** - Tells Blockscout how to connect to your blockchain
- **Source code** - The actual explorer application
- **Documentation** - Setup guides and integration instructions

**What it does:**
- Provides the **blueprint** for running the explorer
- Contains **configuration** that tells Blockscout to connect to `localhost:8545` (your Anvil)
- **Orchestrates** multiple Docker containers to work together
- Acts as the **"control center"** for managing the application

### 2. **Anvil Terminal** 🖥️
**What it is:** Your local blockchain node running in manual mode

**What it does:**
- **Runs the blockchain** - Creates and maintains the blockchain state
- **Provides RPC endpoint** - Listens on `localhost:8545` for API calls
- **Handles transactions** - Processes all blockchain operations
- **Manages accounts** - Provides pre-funded test accounts
- **Stores state** - Saves blockchain data to `~/.anvil/anvilBlockchainState.json`

**Why it's separate:**
- Anvil is a **standalone blockchain node**
- It doesn't need Docker - it runs directly on your system
- It's **lightweight and fast** for development

### 3. **Docker Desktop** 🐳
**What it is:** Containerization platform that runs multiple services

**What it does:**
- **Runs Blockscout services** - Database, backend, frontend, proxy, etc.
- **Manages dependencies** - PostgreSQL, Redis, Nginx, etc.
- **Isolates services** - Each service runs in its own container
- **Handles networking** - Connects containers to each other and your host

**Why it's needed:**
- Blockscout is **complex** - needs database, cache, web server, etc.
- **Docker simplifies** - Instead of installing 10+ services manually
- **Consistent environment** - Works the same on any machine

## How They Work Together

```
Anvil Terminal (Blockchain Node)
        ↓ RPC calls (localhost:8545)
Docker Desktop
├── Blockscout Backend Container
├── PostgreSQL Database Container  
├── Redis Cache Container
├── Blockscout Frontend Container
└── Nginx Proxy Container
        ↓ Serves web interface
Your Browser (http://localhost)
```

## Data Flow

1. **You mine a block** in Anvil terminal
2. **Anvil updates** its blockchain state
3. **Blockscout backend** (Docker container) polls Anvil via RPC
4. **Backend processes** the new block data
5. **Backend stores** data in PostgreSQL (Docker container)
6. **Backend caches** frequently accessed data in Redis (Docker container)
7. **Frontend** (Docker container) fetches data from backend
8. **Nginx proxy** (Docker container) serves the frontend to your browser

## Why This Architecture?

### **Separation of Concerns**
- **Anvil** = Blockchain logic (fast, lightweight)
- **Docker** = Complex web application (database, cache, web server)
- **Blockscout project** = Configuration and orchestration

### **Development Benefits**
- **Anvil is fast** - No Docker overhead for blockchain operations
- **Blockscout is isolated** - All its dependencies are containerized
- **Easy to manage** - Start/stop services independently
- **Reproducible** - Same setup works on any machine

## Usage Instructions

### **First Time Setup**

1. **Install Prerequisites**
   ```bash
   # Install Foundry (includes Anvil)
   curl -L https://foundry.rustup.rs | sh
   foundryup
   
   # Install Docker Desktop
   # Download from: https://www.docker.com/products/docker-desktop
   ```

2. **Clone and Setup**
   ```bash
   git clone https://github.com/wstalmans1/Blockscout-with-Anvil.git
   cd Blockscout-with-Anvil
   ```

3. **Start the Environment**
   ```bash
   # Start Anvil (in one terminal)
   mkdir -p ~/.anvil
   anvil --host 0.0.0.0 --port 8545 --chain-id 31337 --state ~/.anvil/anvilBlockchainState.json
   
   # Start Blockscout (in another terminal)
   docker compose -f docker-compose/docker-compose.yml up -d
   ```

4. **Access the Explorer**
   - Open your browser and go to: [http://localhost](http://localhost)

### **Daily Usage**

#### **Starting the Environment**

1. **Start Anvil** (Terminal 1)
   ```bash
   anvil --host 0.0.0.0 --port 8545 --chain-id 31337 --state ~/.anvil/anvilBlockchainState.json
   ```

2. **Start Blockscout** (Terminal 2)
   ```bash
   cd /path/to/Blockscout-with-Anvil
   docker compose -f docker-compose/docker-compose.yml up -d
   ```

3. **Verify Everything is Running**
   ```bash
   # Check Anvil
   curl -X POST -H "Content-Type: application/json" \
     --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
     http://localhost:8545
   
   # Check Blockscout
   curl -s http://localhost/api/v2/stats | jq
   ```

#### **Using the Environment**

1. **Mine Blocks Manually**
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

2. **Explore the Blockchain**
   - Open [http://localhost](http://localhost) in your browser
   - View blocks, transactions, and accounts
   - Use the search functionality

#### **Stopping the Environment**

1. **Stop Blockscout**
   ```bash
   docker compose -f docker-compose/docker-compose.yml down
   ```

2. **Stop Anvil**
   - Press `Ctrl + C` in the Anvil terminal

## Important Notes

### **What You CAN Close:**
- ✅ **Your code editor** (VS Code, etc.)
- ✅ **File explorer** showing the project
- ✅ **Any other applications**

### **What You CANNOT Close:**
- ❌ **The project folder** (needed for docker commands)
- ❌ **Terminal with Anvil** (needed for blockchain)
- ❌ **Docker Desktop** (needed to run containers)

### **Why the Project Folder is Essential**

The Blockscout project folder is **always needed** because:

1. **Docker Compose Needs the Configuration**
   ```bash
   # This command reads files from the project folder:
   docker compose -f docker-compose/docker-compose.yml up -d
   #                    ↑ This file is in the project folder!
   ```

2. **State Management**
   - Docker containers are **stateless** by default
   - When you stop containers (`docker compose down`), they **lose all data**
   - The project folder contains **persistent volumes** and **configuration**

3. **Control Commands**
   You need the project folder to:
   ```bash
   # Start the application
   docker compose up -d
   
   # Stop the application  
   docker compose down
   
   # View logs
   docker compose logs
   
   # Restart services
   docker compose restart
   ```

## Troubleshooting

### **Common Issues**

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

4. **Docker containers not starting**
   ```bash
   # Check Docker Desktop is running
   # Restart Docker Desktop if needed
   docker system prune -f  # Clean up if needed
   ```

### **Debug Commands**

```bash
# Check Anvil status
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545

# Check Blockscout status
curl -s http://localhost/api/v2/stats | jq

# Check Docker containers
docker ps | grep blockscout

# View container logs
docker compose logs backend
docker compose logs frontend
```

## Best Practices

### **Development Workflow**

1. **Start Anvil first** - The blockchain must be running before Blockscout
2. **Start Blockscout second** - Let it connect to the running blockchain
3. **Use manual mining** - For deterministic testing
4. **Stop in reverse order** - Blockscout first, then Anvil

### **State Management**

- **Anvil state persists** - Your blockchain data survives restarts
- **Blockscout state is temporary** - Database resets when containers stop
- **Use Anvil's state file** - For persistent blockchain data

### **Performance Tips**

- **Keep Anvil running** - Don't restart unless necessary
- **Use Docker Desktop efficiently** - Stop containers when not needed
- **Monitor resource usage** - Docker can be memory-intensive

## Summary

The Anvil + Blockscout environment consists of three essential components:

1. **Blockscout Project Folder** - The control center and configuration
2. **Docker Desktop** - The execution environment for the web application
3. **Anvil Terminal** - The blockchain node providing the data

All three components must work together to provide a complete blockchain development and exploration environment. The project folder acts as the "remote control" for managing the entire system, while Docker Desktop provides the runtime environment, and Anvil provides the actual blockchain data.

Remember: **The project folder is always needed** - it's not just a one-time setup, but the ongoing control center for your blockchain development environment! 🚀
