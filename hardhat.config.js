require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();





/** @type import('hardhat/config').HardhatUserConfig */
const INFURA_API_KEY = process.env.INFURA_API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
// const INFURA_API_KEY = ""

module.exports = {
  solidity: "0.8.18",
  networks: {
    goerli: {
      url: "https://goerli.infura.io/v3/" + INFURA_API_KEY,
      accounts: [PRIVATE_KEY],
    },
  },
};
