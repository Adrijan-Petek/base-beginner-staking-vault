const hre = require("hardhat");
require("dotenv").config();
async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with", deployer.address);
  const Token = await hre.ethers.getContractFactory("MyToken");
  const token = await Token.deploy("StakeToken", "STK", hre.ethers.parseUnits("1000000", 18));
  await token.waitForDeployment();
  console.log("Stake token:", await token.getAddress());
  const rate = hre.ethers.parseUnits("0.0001", 18);
  const Vault = await hre.ethers.getContractFactory("StakingVault");
  const vault = await Vault.deploy(await token.getAddress(), rate);
  await vault.waitForDeployment();
  console.log("Vault:", await vault.getAddress());
}
main().catch(e => { console.error(e); process.exitCode = 1; });
