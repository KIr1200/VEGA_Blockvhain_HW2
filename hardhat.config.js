require("@nomicfoundation/hardhat-toolbox");


// Go to https://www.alchemyapi.io, sign up, create
// a new App in its dashboard, and replace "KEY" with its key
const ALCHEMY_API_KEY = "KEY";

// Replace this private key with your Goerli account private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Beware: NEVER put real Ether into testing accounts
const { API_URL, PRIVATE_KEY } = process.env


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    hardhat: {},
    goerli: {
       url: API_URL,
       accounts: [`0x${PRIVATE_KEY}`],
       gas: 2500000,
       gasPrice: 10*(10**9),
    }
 },
};
