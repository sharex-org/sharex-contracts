require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-foundry");
require('@openzeppelin/hardhat-upgrades');
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },

  sourcify: {
    enabled: true
  },

  networks: {
    b2testnet: {
      url: "https://b2-testnet.alt.technology/",
      accounts: [process.env.B2TESTNET_PRIVATE_KEY]
    },
    b2mainnet: {
      url: "https://rpc.bsquared.network/",
      accounts: [process.env.B2MAINNET_PRIVATE_KEY]
    },
    bnbmainnet: {
      url: "https://bsc-dataseed.bnbchain.org",
      accounts: [process.env.MAINNET_ADMIN_PRIVATE_KEY]
    },
    monadtestnet: {
      url: "https://testnet-rpc.monad.xyz",
      accounts: [process.env.MONADTESTNET_PRIVATE_KEY]
    }
  },
};
