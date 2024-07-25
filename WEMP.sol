// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WEMPToken is ERC20, Ownable 
{
    using SafeERC20 for IERC20;

    IERC20 public empToken;

    event Wrapped(address indexed user, uint256 amount);
    event Unwrapped(address indexed user, uint256 amount);

    constructor(IERC20 _empToken) ERC20("Wrapped EMPRESS TOKEN", "WEMP") Ownable(msg.sender) {
        empToken = _empToken;
    }

    function wrap(uint256 amount) external {
        require(empToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        _mint(msg.sender, amount);
        emit Wrapped(msg.sender, amount);
    }

    function unwrap(uint256 amount) external {
        _burn(msg.sender, amount);
        require(empToken.transfer(msg.sender, amount), "Transfer failed");
        emit Unwrapped(msg.sender, amount);
    }
}
