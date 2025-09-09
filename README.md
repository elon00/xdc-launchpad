# 🚀 XDC Launchpad

<h4 align="center">
  A decentralized token launchpad built on the XDC Network
</h4>

🧪 A comprehensive platform for launching and managing ERC20 tokens on the XDC blockchain. Features include token creation, staking mechanisms, fee collection, and a full-featured frontend for interaction.

⚙️ Built using NextJS, RainbowKit, Hardhat, Wagmi, Viem, and Typescript.

## Features

- ✅ **XDCLaunchpadToken Contract**: ERC20 token with built-in staking and fee collection
- 🪝 **Custom Hooks**: React hooks for seamless smart contract interactions
- 🧱 **Web3 Components**: Pre-built components for blockchain interactions
- 🔥 **Staking System**: Deposit and withdraw tokens with staking functionality
- 🔐 **Wallet Integration**: Support for multiple wallet providers on XDC Network
- 📊 **Block Explorer**: Integrated block explorer for transaction tracking
- 🛠️ **Debug Tools**: Contract debugging and interaction tools

![XDC Launchpad](https://img.shields.io/badge/XDC-Network-blue?style=for-the-badge&logo=ethereum)

## Requirements

Before you begin, you need to install the following tools:

- [Node (>= v20.18.3)](https://nodejs.org/en/download/)
- Yarn ([v1](https://classic.yarnpkg.com/en/docs/install/) or [v2+](https://yarnpkg.com/getting-started/install))
- [Git](https://git-scm.com/downloads)

## Quickstart

To get started with XDC Launchpad, follow the steps below:

1. Clone the repository and install dependencies:

```bash
git clone <repository-url>
cd xdc-launchpad
yarn install
```

2. Set up environment variables:

```bash
cp packages/hardhat/.env.example packages/hardhat/.env
# Edit .env with your XDC network configuration
```

3. Run a local XDC network in the first terminal:

```bash
yarn chain
```

This command starts a local Hardhat network configured for XDC development.

4. On a second terminal, deploy the XDCLaunchpadToken contract:

```bash
yarn deploy
```

This deploys the main token contract to the local network.

5. On a third terminal, start the NextJS frontend:

```bash
yarn start
```

Visit your app on: `http://localhost:3000`.

## Available Scripts

- `yarn hardhat:test` - Run smart contract tests
- `yarn hardhat:compile` - Compile smart contracts
- `yarn hardhat:deploy` - Deploy contracts to network
- `yarn next:build` - Build the frontend
- `yarn start` - Start development server
- `yarn lint` - Run linting

## Project Structure

- `packages/hardhat/` - Smart contracts and deployment scripts
- `packages/nextjs/` - Frontend application with block explorer and debug tools
- `packages/hardhat/contracts/XDCLaunchpadToken.sol` - Main ERC20 token contract with staking

## Token Features

- **Total Supply**: 21 trillion XDCLP tokens
- **Transfer Fee**: 0.008 XDC per transfer
- **Staking**: Deposit/withdraw tokens for staking
- **ERC20Permit**: Gasless approvals support

## Security

This project includes comprehensive tests and follows best practices for smart contract development. See [SECURITY.md](SECURITY.md) for security considerations.

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see the [LICENCE](LICENCE) file for details.