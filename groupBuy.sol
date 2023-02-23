// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;
 
// Abstract
interface USDC {
  function balanceOf(address account) external view returns (uint256);
 
  function allowance(address owner, address spender)
    external
    view
    returns (uint256);
 
  function transfer(address recipient, uint256 amount)
    external
    returns (bool);
 
  function approve(address spender, uint256 amount) external returns (bool);
 
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);
}
contract GroupBuy {
  uint256 public endTime;
  uint256 public startTime;
  address payable[] public buyers; 
  uint256 public price; 
  address public seller; 
  string public productName; 
  string public productDescription; 
  USDC public USDc;
 
  enum GroupBuyState {
    OPEN,
    ENDED
  }
 
  event NewOrder(address newBuyer);
  event WithdrawFunds();
  event GroupBuyClosed();
 
  constructor(
    address _seller,
    uint256 _endTime,
    uint256 _price,
    string memory _productName,
    string memory _productDescription
  ) {
    USDc = USDC(0x07865c6E87B9F70255377e024ace6630C1Eaa37F); 
    seller = _seller; 
    endTime = block.timestamp + _endTime;
    startTime = block.timestamp;  
    price = _price;  
    productName = _productName;
    productDescription = _productDescription;
  }
 
  function placeOrder() external payable returns (bool) {
    require(msg.sender != seller);
    require(getGroupBuyState() == GroupBuyState.OPEN);  
    require(hasCurrentBid(msg.sender) == false);
    USDc.transferFrom(msg.sender, address(this), price);
    buyers.push(payable(msg.sender));
    emit NewOrder(msg.sender);
    return true;
  }


  function withdrawFunds() external returns (bool) {
    require(getGroupBuyState() == GroupBuyState.ENDED);  
    require(msg.sender == seller); 
    USDc.transfer(seller, price * buyers.length);  
    emit WithdrawFunds();  
    emit GroupBuyClosed();
    return true;
  }


  function getGroupBuyState() public view returns (GroupBuyState) {
    if (block.timestamp >= endTime) return GroupBuyState.ENDED;
    return GroupBuyState.OPEN;  
  }


  function hasCurrentBid(address buyer) public view returns (bool) {
    bool isBuyer = false;
    for (uint256 i = 0; i < buyers.length; i++) {
      if (buyers[i] == buyer) {
        isBuyer = true;
      }
    }
    return isBuyer;
  }
  
  function getAllOrders()
    external
    view
    returns (address payable[] memory _buyers)
  {
    return buyers;
  }
}
