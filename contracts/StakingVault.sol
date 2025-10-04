// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract StakingVault is Ownable {
  IERC20 public stakingToken; uint256 public rewardRatePerSecond;
  mapping(address => uint256) public balances; mapping(address => uint256) public rewards; mapping(address => uint256) public lastUpdated;
  constructor(address _token, uint256 _rewardRatePerSecond) { stakingToken = IERC20(_token); rewardRatePerSecond = _rewardRatePerSecond; }
  function _update(address user) internal {
    if(lastUpdated[user] > 0) {
      uint256 dt = block.timestamp - lastUpdated[user];
      if(balances[user] > 0) { rewards[user] += (rewardRatePerSecond * dt * balances[user]) / 1e18; }
    }
    lastUpdated[user] = block.timestamp;
  }
  function stake(uint256 amount) external { require(amount>0); _update(msg.sender); stakingToken.transferFrom(msg.sender, address(this), amount); balances[msg.sender]+=amount; }
  function withdraw(uint256 amount) external { require(amount<=balances[msg.sender]); _update(msg.sender); balances[msg.sender]-=amount; stakingToken.transfer(msg.sender, amount); }
  function claim() external { _update(msg.sender); uint256 r = rewards[msg.sender]; require(r>0); rewards[msg.sender]=0; stakingToken.transfer(msg.sender, r); }
  function setRewardRate(uint256 v) external onlyOwner { rewardRatePerSecond = v; }
  function rescueERC20(address token, address to, uint256 amount) external onlyOwner { IERC20(token).transfer(to, amount); }
}
