// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "hardhat/console.sol";
// Objective: Write an Ether staking smart contract that allows users to stake Ether for a specified period.

// Requirements:
// Users should be able to stake Ether by sending a transaction to the contract.
// The contract should record the staking time for each user.
// Implement a reward mechanism where users earn rewards based on how long they have staked their Ether.
// The rewards should be proportional to the duration of the stake.
// Users should be able to withdraw both their staked Ether and the earned rewards after the staking period ends.
// Ensure the contract is secure, especially in handling users’ funds and calculating rewards.

contract EtherStakingContract {
  // initaialising Owner Address
  address public owner;
  uint public initialContractBalance;

  // Creating struct to record and track time to funds
  struct Stake {
    uint unlockTime;
    uint stakedAmount;
  }

  constructor() payable {
    // Setting Owner Address to deployer address
    owner = msg.sender;
    initialContractBalance = msg.value;
  }

  // mapping struct by account address
  mapping (address => Stake) internal stakes;

  // mapping reward amount to staker's address
  mapping (address => uint) internal rewardBalance;

  // Custom Errors
  error ZeroAddressDetected();
  error OngoingStake();
  error totalSupplyMaxedOut();
  error invalidInput();
  error invalidTransaction();
  error transactionFailed();

  // Events for transactions
  event depositSuccessful(address indexed owner, uint indexed amount, uint indexed lockTime);
  event withdrawalSuccessful(uint indexed amount, address indexed _address);
  event withdrawAllFundSuccessful(uint indexed stakedAmount, uint indexed reward, uint indexed totalAmount);

  // checkers functions
  function isSenderAddressZero() private view {
    if (msg.sender == address(0)) { revert ZeroAddressDetected(); }
  }

  function stakeLocked() private view {
    if (stakes[msg.sender].unlockTime > block.timestamp) { revert OngoingStake(); }
  }

  function calculateReward(uint _days) internal {
    uint stakedBalance = stakes[msg.sender].stakedAmount;
    uint reward = (stakedBalance / 200000) * _days;

    if (reward > initialContractBalance) { revert totalSupplyMaxedOut(); }

    initialContractBalance -= reward;
    rewardBalance[msg.sender] += reward;
  }

  function stakeDeposit(uint _days) external payable {
    isSenderAddressZero();
    if (stakes[msg.sender].unlockTime != 0) { revert OngoingStake(); }
    if(_days == 0){
      revert invalidInput();
    }

    if(msg.value == 0){
      revert("invalid-input");
    }

    uint _unlockTime = block.timestamp + (_days * 24 * 60 * 60);
    // uint _unlockTime = block.timestamp + _days;

    stakes[msg.sender].stakedAmount = stakes[msg.sender].stakedAmount + msg.value;
    stakes[msg.sender].unlockTime = _unlockTime;
    calculateReward(_days);

    emit depositSuccessful(msg.sender, msg.value, _unlockTime);
  }

  function myStakedBalance() external view returns(uint) {
    return stakes[msg.sender].stakedAmount;
  }

  function getStakeReward() external view returns(uint balance) {
    return rewardBalance[msg.sender];
  }

  function withdrawStakedAmount() external {
    isSenderAddressZero();
    stakeLocked();

    if (stakes[msg.sender].stakedAmount <= 0) { revert invalidTransaction(); }

    uint initialStake = stakes[msg.sender].stakedAmount;

    stakes[msg.sender].stakedAmount -= stakes[msg.sender].stakedAmount;
    (bool sent,) = msg.sender.call{value: initialStake}("");

    if (sent == false) { revert transactionFailed(); }

    stakes[msg.sender].unlockTime = 0;
    emit withdrawalSuccessful(stakes[msg.sender].stakedAmount, msg.sender);
  }

  function withdrawAllFunds() external {
    isSenderAddressZero();
    stakeLocked();

    if (stakes[msg.sender].stakedAmount <= 0) { revert invalidTransaction(); }

    uint withdrawalAmount = stakes[msg.sender].stakedAmount + rewardBalance[msg.sender];
    rewardBalance[msg.sender] = 0;
    stakes[msg.sender].stakedAmount -= stakes[msg.sender].stakedAmount;
    (bool sent,) = msg.sender.call{value: withdrawalAmount}("");

    
    if (sent == false) { revert transactionFailed(); }

    stakes[msg.sender].unlockTime = 0;
    emit withdrawAllFundSuccessful(stakes[msg.sender].stakedAmount, rewardBalance[msg.sender], withdrawalAmount);
  }


}
