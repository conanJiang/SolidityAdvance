// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract WETH {
    //余额
    mapping(address => uint256) public balances;
    //授权余额 被授权人 => （授权人 => 授权额度）
    mapping(address => mapping(address => uint256)) public allowances;

    event Transfer(address from, address to, uint256 amount);
    event Approval(address from, address to, uint256 amount);

    //存款
    function deposit() public payable {
        // 以太币转入合约的数量
        uint256 amount = msg.value;
        // 合约的余额增加
        balances[msg.sender] += amount;
        // 合约的总余额增加
        emit Transfer(address(this), msg.sender, amount);
    }

    //取款
    function withdraw(uint256 amount) public payable {
        require(balances[msg.sender] >= amount, "tokens is not enough");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    //授权
    function approve(address allowTo, uint256 amount) public {
        require(balances[msg.sender] >= amount, "tokens is not enough");
        allowances[allowTo][msg.sender] += amount;
        emit Approval(msg.sender, allowTo, amount);
    }

    //查询当前合约的 Token 总量
    function totalSupply() external view returns (uint256) {
        return address(this).balance;
    }

    //查询授权额度
    function allowance(address allowFrom, address allowTo)
        external
        view
        returns (uint256)
    {
        return allowances[allowTo][allowFrom];
    }

    //查询指定地址的 Token 数量
    function balanceOf(address _addr) external view returns (uint256) {
        return balances[_addr];
    }

    //转账
    function transfer(address _to, uint256 amount) external {
        transferFrom(msg.sender, _to, amount);
        emit Transfer(msg.sender, _to, amount);
    }

    //转账
    function transferFrom(
        address _from,
        address _to,
        uint256 amount
    ) public returns (bool) {
        require(balances[_from] >= amount, "tokens is not enough");
        //如果是授权转账的模式
        if (msg.sender != _from) {
            /******* 授权转账 **********/
            if (allowances[msg.sender][_from] >= amount) {
                allowances[msg.sender][_from] -= amount;
            } else {
                revert("tokens is not enough");
            }
        }

        balances[_from] -= amount;
        balances[_to] += amount;
        if (msg.sender != _from) {}
        emit Transfer(msg.sender, _to, amount);
        return true;
    }
}
