// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

contract PowerBankDemo is
    Initializable,
    UUPSUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable
{
    using SafeERC20 for IERC20;
    using Address for address;

    bytes32 public constant ADMIN_ROLE = keccak256("admin_role");
    bytes32 public constant UPGRADE_ROLE = keccak256("upgrade_role");

    enum OrderStatus {
        IN_PROCESS,
        COMPLETED
    }

    struct Order {
        address userAddr;
        uint256 startTime;
        uint256 endTime;
        address tokenAddress;
        uint256 deposit;
        uint256 fee;
        OrderStatus status;
    }

    mapping (address => bool) public tokenWhitelist;
    mapping (address => uint256) public tokenDeposits;

    mapping (string => Order) public orders;
    mapping (address => string[]) public userOrders;

    event PayOrder(string indexed _orderNum, address indexed _tokenAddress, address indexed _userAddr, uint256 _deposit);
    event SettleOrder(string indexed _orderNum, address indexed _tokenAddress, address indexed _userAddr, uint256 _amount, uint256 _endTime);
    event AddTokenWhitelist(address indexed _tokenAddress, uint256 _deposit);
    event RemoveTokenWhitelist(address indexed _tokenAddress);
    event SetTokenDeposit(address indexed _tokenAddress, uint256 _deposit);

    function initialize() public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADE_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADE_ROLE)
        override
    {

    }

    // ************************************** QUERY FUNCTION **************************************

    function checkTokenWhitelist(address _tokenAddress) public view returns(bool) {
        return tokenWhitelist[_tokenAddress];
    }

    function getTokenDeposit(address _tokenAddress) public view returns(bool, uint256) {
        return (tokenWhitelist[_tokenAddress], tokenDeposits[_tokenAddress]);
    }

    function getOrder(string memory _orderNum) public view returns(Order memory) {
        return orders[_orderNum];
    }

    function getUserOrders(address _userAddr) public view returns(string[] memory) {
        return userOrders[_userAddr];
    }

    function compareStrings(string memory str1, string memory str2) public pure returns (bool) {
        return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }

    // ************************************** PUBLIC FUNCTION **************************************

    function payOrder(string memory _orderNum, address _tokenAddress) external whenNotPaused() payable {
        // checks
        require(checkTokenWhitelist(_tokenAddress), "token not support");
        require(orders[_orderNum].startTime == 0, "order number exists");

        // pay for order
        uint256 deposit = tokenDeposits[_tokenAddress];

        if (_tokenAddress == address(0x0)) {
            require(deposit == msg.value, "invalid value");
        } else {
            require(msg.value == 0, "invalid transaction value");
            IERC20(_tokenAddress).safeTransferFrom(msg.sender, address(this), deposit);
        }

        // create order
        orders[_orderNum].userAddr = msg.sender;
        orders[_orderNum].startTime = block.timestamp;
        orders[_orderNum].tokenAddress = _tokenAddress;
        orders[_orderNum].deposit =  deposit;
        orders[_orderNum].status = OrderStatus.IN_PROCESS;

        userOrders[msg.sender].push(_orderNum);

        emit PayOrder(_orderNum, _tokenAddress, msg.sender, deposit);
    }

    function settleOrder(string memory _orderNum, uint256 _amount, uint256 _endTime) external onlyRole(ADMIN_ROLE) {
        // check
        require(orders[_orderNum].deposit >= _amount, "amount invalid");

        orders[_orderNum].fee = _amount;
        orders[_orderNum].endTime = _endTime;
        orders[_orderNum].status = OrderStatus.COMPLETED;

        address userAddr = orders[_orderNum].userAddr;
        for (uint256 i = 0; i < userOrders[userAddr].length; i++) {
            if (compareStrings(userOrders[userAddr][i], _orderNum)) {
                userOrders[userAddr][i] = userOrders[userAddr][userOrders[userAddr].length - 1];
                userOrders[userAddr].pop();
            }
        }

        uint256 returnAmt = orders[_orderNum].deposit - _amount;
        _safeTransfer(orders[_orderNum].tokenAddress, userAddr, returnAmt);

        emit SettleOrder(_orderNum, orders[_orderNum].tokenAddress, userAddr, _amount, _endTime);
    }

    // ************************************** ADMIN FUNCTION **************************************

    function addTokenWhitelist(address _tokenAddress, uint256 _deposit) external onlyRole(ADMIN_ROLE) {
        require(!tokenWhitelist[_tokenAddress], "token address has already in whitelist");
        tokenWhitelist[_tokenAddress] = true;
        tokenDeposits[_tokenAddress] = _deposit;

        emit AddTokenWhitelist(_tokenAddress, _deposit);
    }

    function removeTokenWhitelist(address _tokenAddress) external onlyRole(ADMIN_ROLE) {
        require(tokenWhitelist[_tokenAddress], "token address not in whitelist");
        tokenWhitelist[_tokenAddress] = false;
        tokenDeposits[_tokenAddress] = 0;

        emit RemoveTokenWhitelist(_tokenAddress);
    }

    function setTokenDeposit(address _tokenAddress, uint256 _deposit) external onlyRole(ADMIN_ROLE) {
        require(tokenWhitelist[_tokenAddress], "token address not in whitelist");
        tokenDeposits[_tokenAddress] = _deposit;

        emit SetTokenDeposit(_tokenAddress, _deposit);
    }

    // ************************************** INTERNAL FUNCTION **************************************

    /**
     * @notice Safe transfer function
     *
     * @param _tokenAddr Token address
     * @param _to        Address to get transferred BTC
     * @param _amount    Amount of BTC to be transferred
     */
    function _safeTransfer(address _tokenAddr, address _to, uint256 _amount) internal {
        if (_tokenAddr == address(0x0)) {
            (bool success, bytes memory data) = address(_to).call{
                value: _amount
            }("");

            require(success, "transfer call failed");
            if (data.length > 0) {
                require(
                    abi.decode(data, (bool)),
                    "transfer operation did not succeed"
                );
            }
        } else {
            bool success = IERC20(_tokenAddr).transfer(_to, _amount);
            require(success, "token transfer call failed");
        }
    }
}