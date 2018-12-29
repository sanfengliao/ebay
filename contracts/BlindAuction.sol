pragma solidity ^0.4.24;


contract BlindAuction {
    // 
    enum ProductStatus {Open,Deal, Sold, UnSold} 

    struct Bid {
        address buyer;
        uint productId;
        uint value; // 公开的价格, 相当于订金, 该价格要大于实际竞拍的价格，否则此次竞拍不成功
        bool realed; // 是否退回了订金
    }


    uint productIndex;
    struct Product {
        uint id;
        string name;
        string desc;
        uint auctionStartTime;
        uint auctionEndTime;
        uint startPrice;
        address seller;

        address highestBidder; // 最高出价人
        uint highestBidPrice; // 最高出价
        uint totalBidCount;
        ProductStatus productStatus;

    }

    mapping(uint => Product) public products;

    mapping(uint => address) mediators;

    mapping(uint => uint) refundCheckedCount;

    mapping(uint =>uint) payCheckedCount;

    mapping(uint => mapping(address => bool)) refundChecked;
    mapping(uint => mapping(address => bool)) payChecked;
    constructor() public {
        productIndex = 0;
    }
    function addProduct(string name, string desc, uint auctionStartTime, uint auctionEndTime, uint startPrice) public {
        require(auctionStartTime < auctionEndTime, "时间不合法");
        productIndex += 1;
        products[productIndex] = Product(productIndex, name, desc, auctionStartTime, auctionEndTime, startPrice, msg.sender, 0, startPrice, 0, ProductStatus.Open);
        //products[productIndex] = product;
    }

    function getProductInfo(uint productId) view  public returns (uint id, string name, string desc, uint auctionStartTime, uint auctionEndTime, uint highestBidPrice, ProductStatus status, address seller, address highestBidder) {
        require(productId <= productIndex, "must less than");
        Product memory product = products[productId];
        return (product.id, product.name, product.desc, product.auctionStartTime, product.auctionEndTime, product.highestBidPrice, product.productStatus, product.seller, product.highestBidder);
    }
    function getProductCount() view public returns(uint) {
        return productIndex;
    }
    function getProductAuctionInfo(uint productId) view public returns (uint startPrice, address highestBidder, uint highestBidPrice, address seller, uint totalBidCount, ProductStatus status) {
        Product memory product = products[productId];
        
        return (product.startPrice, product.highestBidder, product.highestBidPrice, product.seller, product.totalBidCount, product.productStatus);
    }
    // bid，实际竞拍价格加密后的数据
    function bid(uint productId) payable public {
        Product storage p = products[productId];
        require(now >= p.auctionStartTime);
        require(now <= p.auctionEndTime);
        require(p.productStatus == ProductStatus.Open);
        require(msg.value >= p.startPrice);
        require(msg.value > p.highestBidPrice);
        
        // 保证两次出价的金额不会相同
        if (p.highestBidder != 0) {
            p.highestBidder.transfer(p.highestBidPrice);
        }
        p.highestBidPrice = msg.value;
        p.highestBidder = msg.sender;
        p.totalBidCount += 1;
    }

    function getProductTotalBid(uint productId) returns (uint) {
        return products[productId].totalBidCount;
    }

    // amount: 实际的出标价格
    // secret: 用来加密实际出标价格的秘钥
    /*function revealBid(uint productId, uint amount, string secret) payable public{
        var product = products[productId];

        //require(now > product.auctionEndTime);

        bytes32 sealedBid = keccak256(amount, secret);
        Bid memory bid = product.bids[msg.sender][sealedBid];

        // 检查是否会有这笔交易
        require(bid.buyer > 0);

        // 检查是否已经退款
        require(bid.realed == false);
        uint refund; // 退款金额
        if(product.productStatus == ProductStatus.Sold || product.productStatus == ProductStatus.UnSold){
            // 如果在公告出价阶段买家忘记了公告出价，导致错过了商品卖给了其他人，则全额退款
            refund = bid.value;
        } else if(amount > bid.value) {
            // 如果订金小于实际竞拍价格，则该次竞拍失败，退回订金  
            refund = bid.value;
        } else {
            if(product.highestBidder == 0) {
                product.highestBidder = msg.sender;
                product.highestBidPrice = amount;
                product.secondHighestBidPrice = product.startPrice;
                refund = bid.value - amount;
            } else {
                if(amount > product.highestBidPrice) {
                    product.secondHighestBidPrice = product.highestBidPrice;
                    // 将钱退回给原来出价最高的人
                    product.highestBidder.transfer(product.highestBidPrice);

                    product.highestBidPrice = amount;
                    product.highestBidder = msg.sender;
                    refund = bid.value - amount;
                } else if(amount > product.secondHighestBidPrice) {
                    product.secondHighestBidPrice = amount;
                    refund = bid.value;
                } else {
                    refund = bid.value;
                }
            }
        }
        if(refund > 0) {
            msg.sender.transfer(refund);
            product.bids[msg.sender][sealedBid].realed = true;
        }
    }*/

    // 成交函数，卖主可以在拍卖结束后成交，或者在拍卖过程中觉得价格够高了成交
    function done(uint productId) public {
        require(products[productId].productStatus == ProductStatus.Open, "商品拍卖为开始");
        require(now > products[productId].auctionStartTime, "时间未到");
        require(products[productId].highestBidder != 0);
        products[productId].productStatus = ProductStatus.Deal;

    }

    // 生成Escrow合同
    function checkAuction(uint productId) public returns(bool) {
        Product storage product = products[productId];
        //require(now > product.auctionEndTime);
        require(product.productStatus == ProductStatus.Deal, "ssss");

        // 由第三方提供仲裁
        require(product.highestBidder != msg.sender, "productssss");
        require(product.seller != msg.sender, "products");

        if(product.totalBidCount == 0) {
            product.productStatus = ProductStatus.UnSold;
            return false;
        } else {
            mediators[productId] = msg.sender;
            refundCheckedCount[productId] = 0;
            payCheckedCount[productId] = 0;
            return true;
        }
    }

    

    // 确认付款
    function payCheckedToSeller(uint productId)  payable  public returns(bool) {
       if ((products[productId].seller == msg.sender || products[productId].highestBidder == msg.sender || mediators[productId] == msg.sender) && !payChecked[productId][msg.sender]) {
           payChecked[productId][msg.sender] = true;
           payCheckedCount[productId] += 1;
       } else {
           return false;
       }
        if(payCheckedCount[productId] >= 2) {
            products[productId].seller.transfer(products[productId].highestBidPrice);
            products[productId].productStatus = ProductStatus.Sold;
            return true;
        }
        return true;
    }

    // 确认退款
    function refundCheckedToBuyer(uint productId) payable public returns(bool) {
        if ((products[productId].seller == msg.sender || products[productId].highestBidder == msg.sender || mediators[productId] == msg.sender) && !refundChecked[productId][msg.sender]) {
           refundChecked[productId][msg.sender] = true;
           refundCheckedCount[productId] += 1;
        } else {
            return false;
        }
        if(refundCheckedCount[productId] >= 2) {
            products[productId].highestBidder.transfer(products[productId].highestBidPrice);
            products[productId].productStatus = ProductStatus.UnSold;
        }
        return true;
    }

}