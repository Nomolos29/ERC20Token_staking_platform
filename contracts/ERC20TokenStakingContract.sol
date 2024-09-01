    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.20;

    import "./IERC20.sol";


    // **ERC20 Staking Smart Contract**

    // **Objective:** Write an ERC20 staking smart contract that allows users to stake a specific ERC20 token for rewards.

    // **Requirements:**
    // Users should be able to stake the ERC20 token by transferring the tokens to the contract.
    // The contract should track the amount and duration of each user’s stake.
    // Implement a reward mechanism similar to the Ether staking contract, where rewards are based on the staking duration.
    // Users should be able to withdraw their staked tokens and the rewards after the staking period.
    // The contract should handle ERC20 token transfers securely and efficiently.


contract NomCoinMining {
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

  // checkers functions
  function isSenderAddressZero() private view {
    if (msg.sender == address(0)) { revert ZeroAddressDetected(); }
  }

  function stakeLocked() private view {
    if (wallets[msg.sender].stakeDuration > block.timestamp) { revert OngoingStake(); }
  }

  function calculateReward(uint _days) private {
    uint stakedBalance = wallets[msg.sender].stakedNomcoins;
    uint reward = (stakedBalance / 200000) * _days;

    totalSupplyLeft = IERC20(tokenAddress).balanceOf(address(this));

    if (reward > totalSupplyLeft) { revert totalSupplyMaxedOut(); }

    totalSupplyLeft -= reward;

    rewardBalance[msg.sender] += reward;
  }

  function stakeDeposit(uint nomcoinAmount, uint _stakeDurationInDays) external {
    isSenderAddressZero();
    if (wallets[msg.sender].stakeDuration != 0) { revert OngoingStake(); }
    if (nomcoinAmount == 0) { revert invalidInput(); }
    if (_stakeDurationInDays == 0) { revert invalidInput(); }

    nomcoinAmount = nomcoinAmount * 1e18;
    if (IERC20(tokenAddress).balanceOf(msg.sender) < nomcoinAmount) { revert insufficientFunds(); }


    IERC20(tokenAddress).transferFrom(msg.sender, address(this), nomcoinAmount);

    // uint _stakeDuration = block.timestamp + (_stakeDurationInDays * 24 * 60 * 60);
    uint _stakeDuration = block.timestamp + _stakeDurationInDays;

    wallets[msg.sender].stakedNomcoins += nomcoinAmount;
    wallets[msg.sender].stakeDuration = _stakeDuration;

    calculateReward(_stakeDurationInDays);

    emit depositSuccessful(msg.sender, nomcoinAmount, _stakeDurationInDays);
  }

  function myStakedBalance() external view returns(uint) {
    return wallets[msg.sender].stakedNomcoins;
  }

  function getStakeReward() external view returns(uint balance) {
    return rewardBalance[msg.sender];
  }

  function withdrawStakedAmount() external {
    isSenderAddressZero();
    stakeLocked();
    if (wallets[msg.sender].stakedNomcoins == 0) { revert invalidTransaction(); }

    uint initialStake = wallets[msg.sender].stakedNomcoins;

    wallets[msg.sender].stakedNomcoins -= wallets[msg.sender].stakedNomcoins;

    IERC20(tokenAddress).transfer(msg.sender, initialStake);

    wallets[msg.sender].stakeDuration = 0;
    emit withdrawalSuccessful(wallets[msg.sender].stakedNomcoins, msg.sender);
  }

  function withdrawAllFunds() external {
    isSenderAddressZero();
    stakeLocked();
    if (wallets[msg.sender].stakedNomcoins == 0) { revert invalidTransaction(); }

    uint reward = rewardBalance[msg.sender];
    uint initialStake = wallets[msg.sender].stakedNomcoins;

    uint withdrawalAmount = wallets[msg.sender].stakedNomcoins + reward;
    rewardBalance[msg.sender] = 0;

    wallets[msg.sender].stakedNomcoins -= wallets[msg.sender].stakedNomcoins;
    IERC20(tokenAddress).transfer(msg.sender, withdrawalAmount);

    wallets[msg.sender].stakeDuration = 0;
    emit withdrawAllFundSuccessful(initialStake, reward, withdrawalAmount);
  }

}