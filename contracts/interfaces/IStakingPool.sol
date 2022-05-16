// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.5.0;

import "@openzeppelin/contracts-v4/token/ERC721/IERC721.sol";

/* structs for io */

struct WithdrawParams {
  uint tokenId;
  bool withdrawStake;
  bool withdrawRewards;
  uint[] groupIds;
}

struct ProductParams {
  uint productId;
  bool setWeight;
  uint targetWeight;
  bool setPrice;
  uint targetPrice;
}

struct ProductInitializationParams {
  uint productId;
  uint8 weight;
  uint96 initialPrice;
  uint96 targetPrice;
}

interface IStakingPool is IERC721 {

  /* structs for storage */

  // stakers are grouped based on the timelock expiration
  // group index is calculated based on the expiration date
  // the initial proposal is to have 4 groups per year (1 group per quarter)
  struct Group {
    uint stakeShares;
    uint rewardsShares;
  }

  struct ExpiredGroup {
    uint accNxmPerRewardShareAtExpiry;
    uint stakeAmountAtExpiry;
    uint stakeShareSupplyAtExpiry;
  }

  struct Position {
    uint lastAccNxmPerRewardShare;
    uint stakeShares;
    uint rewardsShares;
  }

  struct Product {
    uint8 lastWeight;
    uint8 targetWeight;
    uint allocatedStake;
    uint lastBucket;
    uint targetPrice;
    uint96 lastPrice;
    uint32 lastPriceUpdateTime;
  }

  struct PoolBucket {
    uint rewardPerSecondCut;
  }

  struct ProductBucket {
    uint allocationCut;
  }

  function initialize(
    address _manager,
    bool isPrivatePool,
    uint initialPoolFee,
    uint maxPoolFee,
    ProductInitializationParams[] calldata params
  ) external;

  function operatorTransfer(address from, address to, uint[] calldata tokenIds) external;

  function updateGroups() external;

  function allocateStake(
    uint productId,
    uint period,
    uint gracePeriod,
    uint productStakeAmount,
    uint rewardRatio
  ) external returns (uint allocatedNXM, uint premium);

  function deallocateStake(
    uint productId,
    uint start,
    uint period,
    uint amount,
    uint premium
  ) external;

  function burnStake(uint productId, uint start, uint period, uint amount) external;

  function deposit(uint amount, uint groupId, uint _tokenId) external returns (uint tokenId);

  function withdraw(WithdrawParams[] memory params) external;

  function addProducts(ProductParams[] memory params) external;

  function removeProducts(uint[] memory productIds) external;

  function setProductDetails(ProductParams[] memory params) external;

  function manager() external view returns (address);

  function getActiveStake() external view returns (uint);

  function getProductStake(uint productId, uint coverExpirationDate) external view returns (uint);

  function getFreeProductStake(uint productId, uint coverExpirationDate) external view returns (uint);

  function getAllocatedProductStake(uint productId) external view returns (uint);

  function getPriceParameters(
    uint productId,
    uint maxCoverPeriod
  ) external view returns (
    uint activeCover,
    uint[] memory capacities,
    uint lastBasePrice,
    uint targetPrice
  );
}
