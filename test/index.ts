import { expect } from "chai";
import { ethers } from "hardhat";

describe("Feet", function () {
  it("Should deploy the contract", async function () {
    const Feet = await ethers.getContractFactory("Feet");
    const feet = await Feet.deploy();
    await feet.deployed();

    expect(await feet.symbol()).to.equal("FEET");
  });
});
