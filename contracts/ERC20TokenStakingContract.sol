// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IERC20.sol";

contract NomCoinPreSale {
  // State Variables 
  address owner;
  address tokenAddress;
  uint public totalSupplyLeft;

  struct Wallet {
    uint stakedNomcoins;
    uint stakeDuration;
  }

  constructor(address _tokenAddress) {
    owner = msg.sender;
    tokenAddress = _tokenAddress;
  }

  // mapping struct by account address
  mapping (address => Wallet) internal wallets;

  // mapping reward amount to staker's address
  mapping (address => uint) internal rewardBalance;

  // custom error
  error ZeroAddressDetected();
  error OngoingStake();
  error totalSupplyMaxedOut();
  error invalidInput();
  error insufficientFunds();
  error invalidTransaction();

  // Events for transactions
  event depositSuccessful(address indexed owner, uint indexed amount, uint indexed lockTime);
  event withdrawalSuccessful(uint indexed amount, address indexed _address);
  event withdrawAllFundSuccessful(uint indexed stakedAmount, uint indexed reward, uint indexed totalAmount);
}