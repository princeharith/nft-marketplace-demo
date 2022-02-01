require("@nomiclabs/hardhat-waffle");
const fs = require("fs");
const privateKey = fs.readFileSync(".secret").toString();
const projectId = "6e0ef5c784744112b83bd1d93db54de6"


module.exports = {
  networks: {
    hardhat: {
      chainId: 1337
    }, 
    mumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${projectId}`,
      accounts: [privateKey]
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${projectId}`, 
      accounts: [privateKey]
    }
  },
  solidity: "0.8.4",
};
