// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract DOLAToken is ERC20, Ownable {
    IERC20 public BDOLAToken;
    IERC20 public ROIToken;
    uint256 public pegRatio;
    uint256 public constant PRECISION = 1e18;
    event PegRatioUpdated(uint256 newPegRatio);
    event Minted(address indexed recipient, uint256 amount);
    event Burned(address indexed sender, uint256 amount);
    constructor(address _BDOLAToken, address _ROIToken) 
        ERC20("DOLAToken", "DOLA") 
        Ownable(msg.sender){
        BDOLAToken = IERC20(_BDOLAToken);
        ROIToken = IERC20(_ROIToken);
        pegRatio = 1 * PRECISION;
    }
    function setPegRatio(uint256 _pegRatio) external onlyOwner {
        require(_pegRatio > 0, "Peg ratio must be greater than zero");
        pegRatio = _pegRatio;
        emit PegRatioUpdated(_pegRatio);
    }
    function mint(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");
        uint256 collateralAmount = _amount * pegRatio / PRECISION;
        require(BDOLAToken.transferFrom(msg.sender, address(this), collateralAmount), "Collateral transfer failed");
        _mint(msg.sender, _amount);
        emit Minted(msg.sender, _amount);
    }
    function burn(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");
        require(balanceOf(msg.sender) >= _amount, "Insufficient DOLA balance");
        uint256 collateralAmount = _amount * pegRatio / PRECISION;
        require(BDOLAToken.transfer(msg.sender, collateralAmount), "Collateral transfer failed");
        _burn(msg.sender, _amount);
        emit Burned(msg.sender, _amount);
    }
    function collateralBalance() external view returns (uint256) {
        return BDOLAToken.balanceOf(address(this));
    }
    function adjustPeg() external onlyOwner {
        uint256 dolaSupply = totalSupply();
        uint256 roiBalance = ROIToken.balanceOf(address(this));

        if (dolaSupply > 0 && roiBalance > 0) {
            pegRatio = (roiBalance * PRECISION) / dolaSupply;
            emit PegRatioUpdated(pegRatio);
        }
    }
}
