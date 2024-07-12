// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Bank {
    address public immutable owner;

    event Deposit(address _ads, uint256 amount);
    event Withdraw(uint256 amount);

    constructor() payable {
        owner = msg.sender;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    //转入合约
    function transderToContract() public payable {
        payable(address(this)).transfer(msg.value);
    }

    //从合约提取
    function withdraw() external {
        require(msg.sender == owner, "only owner call withdraw");
        emit Withdraw(address(this).balance);
        selfdestruct(payable(owner));
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    //扩展
    function depositeErc20(IERC20 token, uint256 amount) external {
        require(
            token.transferFrom(msg.sender, payable(address(this)), amount),
            "depositeErc20 failed"
        );
    }

    function withDrawErc20(IERC20 token) external {
        require(msg.sender == owner, "only owner call withdraw");
        emit Withdraw(address(this).balance);
        //获取合约里有多少ERC20代币
        uint256 balance = token.balanceOf(address(this));
        //取出来
        token.transfer(owner, balance);
        //销毁合约
        selfdestruct(payable(owner));
    }
}
