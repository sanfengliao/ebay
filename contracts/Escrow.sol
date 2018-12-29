pragma solidity ^0.4.24;
contract Escrow {
    uint productId;
    address seller;
    address buyer;
    address arbiter;
    uint finalAmount;

    mapping(address => bool) refundChecked;
    uint refundCheckedCount;

    mapping(address => bool) payChecked;
    uint payCheckedCount;

    bool isFinish; // 该仲裁是否结束
    constructor(uint _productId, address _seller, address _buyer, address _arbiter) payable public {
        productId = _productId;
        seller = _seller;
        buyer = _buyer;
        arbiter = _arbiter;
        finalAmount = msg.value;
    }

    function getEscrowInfo() view public returns (uint productId, address seller, address buyer, address arbiter, uint finalAmount, uint refundCheckedCount, uint payCheckedCount, bool isFinish) {
        return (productId, seller, buyer, arbiter, finalAmount, refundCheckedCount, payCheckedCount, isFinish);
    }

    function refundCheckedToBuyer(address caller) payable public  returns (bool){
        require(!isFinish);
        if((caller == seller || caller == buyer || caller == arbiter) && !refundChecked[caller]) {
            refundChecked[caller] = true;
            refundCheckedCount +=1;
        } else {
            return false;
        }

        if(refundCheckedCount >= 2) {
            buyer.transfer(finalAmount);
            isFinish = true;
            return true;
        }
        return false;
    }

    function payCheckedToSeller(address caller) payable public returns (bool){
        require(!isFinish);
        if((caller == seller || caller == buyer || caller == arbiter) && !payChecked[caller]) {
            payChecked[caller] = true;
            payCheckedCount +=1;
        } else {
            return false;
        }

        if(payCheckedCount >= 2) {
            seller.transfer(finalAmount);
            isFinish = true;
            return true;
        }
        return false;
    }
}