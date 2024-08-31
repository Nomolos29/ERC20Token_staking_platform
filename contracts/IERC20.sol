//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NomCoin is ERC20("NomCoin", "NCOIN") {
  // state variable
  address public owner;

  constructor() {
    owner = msg.sender;
    _mint(msg.sender, 1000000e18);
  }
}