require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */

const {
  ETHERSCAN_API_KEY,
  PRIVATE_KEY,
  SEPOLIA_RPC_URL,
  // COINMARKETCAP_API_KEY,
} = process.env;

module.exports = {
  solidity: {
    compilers: [
      { version: "0.8.18" },
      { version: "0.8.19" },
      { version: "0.8.20" },
    ],
  },

  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337,
    },

    sepolia: {
      url: SEPOLIA_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 11155111,
      blockConfirmations: 6,
    },
  },

  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
    // customChains: [],
  },

  gasReporter: {
    enabled: true,
    currency: "USD",
    outputFile: "gas-report.txt",
    noColors: true,
    // coinmarketcap: COINMARKETCAP_API_KEY,
    token: "ETH",
  },

  namedAccounts: {
    deployer: {
      default: 0,
      1: 0,
    },
  },

  mocha: {
    timeout: 500000,
  },
};
