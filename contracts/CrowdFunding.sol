// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract CrowdFunding{

    //受益人
    address public immutable beneficiary;
    //资助者
    mapping(address => uint256) public funders;

    //筹资目标数量
    uint256 public immutable fundingGoal;
    //当前募集数量
    uint256 public fundingAmount;
    //资助者人数
    uint256 public fundersKey;
    //是否关闭
    bool public isClosed;

    //构造函数
    constructor(address _beneficiary,uint _fundingGoal) {
        beneficiary = _beneficiary;
        fundingGoal = _fundingGoal;
    }

    //众筹
    function contribute() external payable {
        //检查当前众筹是否已关闭
        require(!isClosed,"this crow-funding is closed!");
        require(msg.value > 0,"contribute value must more than 0");

        //校验当前资助是否超过众筹目标
        bool isFinish;
        uint256 currentAdd = msg.value;
        if(fundingAmount + msg.value >= fundingGoal) {
            currentAdd = fundingGoal - fundingAmount;
            isFinish = true;
        }
        //资助者列表中是否有当前资助者
        if(funders[msg.sender] > 0){
            funders[msg.sender] += currentAdd;
        }else{
            funders[msg.sender] = currentAdd;
            fundersKey++;
        }
        fundingAmount += currentAdd;
        

        //已完成众筹，自动执行关闭操作
        if(isFinish){
            if(msg.value > currentAdd){
                //退款
                payable(msg.sender).transfer(msg.value - currentAdd);
            }
            this.close();
        }
    }


    //关闭操作
    function close() external returns (bool){
        //如果未完成众筹
        if(fundingAmount < fundingGoal){
            isClosed = false;
            return isClosed;
        }
        //如果完成众筹，则向受益人转账
        payable(beneficiary).transfer(fundingAmount);
        isClosed = true;
        return isClosed;
    }



}