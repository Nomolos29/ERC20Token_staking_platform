import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import hre, { ethers } from "hardhat";
import { expect } from "chai";
import { etherStakingContractSol } from "../typechain-types/contracts";

describe("EtherStakingContract", function() {
  async function deployStakingContract() {

    const [owner, account1, account2] = await ethers.getSigners();

    const EtherStakingContractFactory = await ethers.getContractFactory("EtherStakingContract");

    const initialFunding = ethers.parseEther("1");

    // Deploy the contract and get the deployed instance
    const etherStakingContract = await EtherStakingContractFactory.deploy({value: initialFunding});


    return { etherStakingContract, owner, initialFunding, account1,  account2 };
  }

  async function stakeEther() {
    const { etherStakingContract, account1 } = await loadFixture(deployStakingContract);

    const stakeAmount = ethers.parseEther("1000");

    await etherStakingContract.connect(account1).stakeDeposit(1,{value: stakeAmount});

    return { stakeAmount };
  }

  describe("Deployment", function() {
    it("Should set the address that deploys the contract as the owner's address", async function() {
      const { etherStakingContract, owner } = await loadFixture(deployStakingContract);

      // Access the `owner` function on the deployed contract
      expect(await etherStakingContract.owner()).to.equal(owner.address);
    });

    it("Should fund account upon deployment", async function() {
      const { etherStakingContract, initialFunding } = await loadFixture(deployStakingContract);

      const contractBalance = ethers.provider.getBalance(etherStakingContract.getAddress());

      expect(await contractBalance).to.equal(initialFunding);
    })

    it("Should confirm that initialContractBalance is correctly set", async function() {
      const { etherStakingContract, initialFunding } = await loadFixture(deployStakingContract);

      expect(await etherStakingContract.initialContractBalance()).to.equal(initialFunding);
    })

  });

  describe("Deposit", function() {
    it("Should not accept zero value", async function() {
      const { etherStakingContract, account2 } = await loadFixture(deployStakingContract);

      const stakeAmount = ethers.parseEther("0");
      const days = ethers.parseUnits("0");

      const stakingDetail = etherStakingContract.connect(account2).stakeDeposit(days, {value: stakeAmount});


      expect(stakingDetail).to.be.revertedWithCustomError(etherStakingContract, "invalidInput");
      
    })

    it("Should confirm Deposit", async function () {
      const { etherStakingContract, initialFunding } = await loadFixture(deployStakingContract);
      const { stakeAmount } = await loadFixture(stakeEther);

      const contractBalance = ethers.provider.getBalance(etherStakingContract.getAddress());

      const newContractBalance = initialFunding + stakeAmount;

      expect(await contractBalance).to.equal(newContractBalance);
    })
  })
});