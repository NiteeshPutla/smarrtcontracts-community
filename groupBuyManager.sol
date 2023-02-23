// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;
 
import "./groupBuy.sol";
 
contract GroupBuyManager {
  uint256 _groupBuyIDCounter;
  GroupBuy[] public groupBuys;
  mapping(address => uint256) public groupBuysIDs;
  function createGroupbuy(
    uint256 _endTime,
    uint256 _price,
    string calldata _productName,
    string calldata _productDescription
  ) external returns (bool) {
    require(_price > 0);
    require(_endTime > 5 minutes);
 
    uint256 groupBuyID = _groupBuyIDCounter;
    _groupBuyIDCounter++;
    GroupBuy groupBuy = new GroupBuy(
      msg.sender,
      _endTime,
      _price,
      _productName,
      _productDescription
    );
    groupBuys.push(groupBuy);
    groupBuysIDs[address(groupBuy)] = groupBuyID;
    return true;
  }
 
  function getGroupBuys()
    external
    view
    returns (address[] memory _groupBuys)
  {
    _groupBuys = new address[](_groupBuyIDCounter);
    for (uint256 i = 0; i < _groupBuyIDCounter; i++) {
      _groupBuys[i] = address(groupBuys[i]);
    }
    return _groupBuys;
  }
  function getGroupBuyInfo(address[] calldata _groupBuyList) external view
    returns (
      string[] memory productName,
      string[] memory productDescription,
      uint256[] memory price,
      address[] memory seller,
      uint256[] memory endTime,
      uint256[] memory groupBuyState
    )
  {
    endTime = new uint256[](_groupBuyList.length);
    price = new uint256[](_groupBuyList.length);
    seller = new address[](_groupBuyList.length);
    productName = new string[](_groupBuyList.length);
    productDescription = new string[](_groupBuyList.length);
    groupBuyState = new uint256[](_groupBuyList.length);
 
    for (uint256 i = 0; i < _groupBuyList.length; i++) {
      uint256 groupBuyID = groupBuysIDs[_groupBuyList[i]];
      productName[i] = groupBuys[groupBuyID].productName();
      productDescription[i] = groupBuys[groupBuyID].productDescription();
      price[i] = groupBuys[groupBuyID].price();
      seller[i] = groupBuys[groupBuyID].seller();
   	  endTime[i] = groupBuys[groupBuyID].endTime();
      groupBuyState[i] = uint256(
        groupBuys[groupBuyID].getGroupBuyState()
      );
    }
 
    return (
      productName,
      productDescription,
      price,
      seller,
      endTime,
      groupBuyState
    );
  }
}
