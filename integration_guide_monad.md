# Integration Guide

## Confirguration

### Testnet

- MON is native token, so do not need to approve
- Order contract address: 0xc1189535d0De120b5DeA3704BEa0e29af0715433
- Deposit amount: 0.001 MON (1000000000000000, decimal=18)

## Order contract

call order contract

Because of MON is the native token, so need to call the contract function with the value.

### Pay for order

    function payOrder(uint256 _orderNum, address _tokenAddress) external payable

Parameters:
- _orderNum: order number
- _tokenAddress: token contract address, MON is native token, the token address = 0x0000000000000000000000000000000000000000

### Pay for order event

    event PayOrder(uint256 _orderNum, address indexed _tokenAddress, address indexed _userAddr, uint256 _deposit);

Parameters:
- _orderNum: order number
- _tokenAddress: payment token address (USDT contract address)
- _userAddr: user address
- _deposit: deposit amount

### Settle order

    function settleOrder(uint256 _orderNum, uint256 _amount, uint256 _endTime) external

Parameters:
- _orderNum: order number
- _amount: power bank borrow fee, multiply by 1000000 (USDT decimal = 6)
- _endTime: return timestamp

### Settle order event

    event SettleOrder(uint256 indexed _orderNum, address indexed _tokenAddress, address indexed _userAddr, uint256 _amount, uint256 _endTime);

Parameters:
- _orderNum: order number
- _tokenAddress: payment token address (USDT contract address)
- _userAddr: user address
- _amount: the fee of borrowing power bank
- _endTime: the return timestamp

### Query order info

    function getOrder(uint256 _orderNum) public view returns(Order memory)

Parameters:
- _orderNum: order number

Returns:
- Order Object:
  - address userAddr: user address
  - uint256 startTime: borrow timestamp
  - uint256 endTime: return timestamp
  - address tokenAddress: payment token address
  - uint256 deposit: deposit amount
  - uint256 fee: the fee of borrowing power bank
  - OrderStatus status: order status

### Query user in-process order list

    function getUserOrders(address _userAddr) public view returns(uint256[])

Parameters:
- _userAddr: user address

Returns:
- uint256[]: order number list