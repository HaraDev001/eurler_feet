import { ethers } from "hardhat";

async function main() {
  const EulerFeetFactory = await ethers.getContractFactory("EulerFeet");
  const eulerFeet = await EulerFeetFactory.deploy();

  await eulerFeet.deployed();

  console.log("EulerFeet deployed to:", eulerFeet.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
