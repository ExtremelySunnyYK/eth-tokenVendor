pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // Payable functions are for contract to receieve ETH
  function buyTokens() public payable returns (uint256 tokensBought){
    require(msg.value > 0, "Wallet does not have ETH");

    uint256 amountToBuy = msg.value * tokensPerEth; //msg.value refers to the eth

    // Check balance of Vendor with OpenZeppelin BalanceOf Function
    uint256 vendorBalance = yourToken.balanceOf(address(this));
    require(vendorBalance >= amountToBuy, "Vendor does not have enough tokens in the deposit");

    // Transfer token to the msg.sender using OpenZeppelin Transfer Function
    (bool sent) = yourToken.transfer(msg.sender, amountToBuy);
    require(sent, "Transcation Failed");

    //emit Event
    emit BuyTokens(msg.sender, msg.value, amountToBuy);

    return amountToBuy;


  }
  // withdraw() function that lets the owner withdraw ETH
  function withdraw() public payable onlyOwner(){
    // check current eth balance
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, "No ETH left for withdrawal");

    // withdraw to owner address
    (bool sent, bytes memory data) = msg.sender.call{value: msg.value}("");
    require(sent, "Failed to send Ether back to owner address");
  }

  // sellTokens() function. transfer is used for your own token, while call is used for eth
  function sellTokens(uint256 tokenAmountToSell) public {
    // Check that the user's token balance is enough to do the swap
    uint256 userBalance = yourToken.balanceOf(msg.sender);
    require(userBalance >= tokenAmountToSell, "Your balance is lower than the amount of tokens you want to sell");

    // Check that the Vendor's balance is enough to do the swap
    uint256 amountOfETHToTransfer = tokenAmountToSell / tokensPerEth;
    uint256 ownerETHBalance = address(this).balance;
    require(ownerETHBalance >= amountOfETHToTransfer, "Vendor has not enough funds to accept the sell request");

    (bool sent) = yourToken.transferFrom(msg.sender, address(this), tokenAmountToSell);
    require(sent, "Failed to transfer tokens from user to vendor");


    (sent,) = msg.sender.call{value: amountOfETHToTransfer}("");
    require(sent, "Failed to send ETH to the user");
  }

}
