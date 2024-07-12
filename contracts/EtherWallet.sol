// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EtherWallet{
    address immutable owner;
    event Log(string funNam,address from ,uint256 amount,bytes data);

    constructor(){
        owner = msg.sender;
    }

    receive() external payable {
        emit Log("receive",msg.sender,msg.value,"store the money");
     }

     function withdraw() external payable {
        require(msg.sender == owner,"Not an owner");
        payable(msg.sender).transfer(100);
     }

    function withdraw2() external payable {
        require(msg.sender == owner,"Not an owner");
        //需要针对返回值进行处理
        bool success = payable(msg.sender).send(200);
        require(success, "Send Failed");
     }


     
    function withdraw3() external payable {
        require(msg.sender == owner,"Not an owner");
        //需要针对返回值进行处理
        (bool success, ) = msg.sender.call{value:300}("");
        require(success, "Call Failed");
     }
}