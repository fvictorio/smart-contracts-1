const { artifacts, web3 } = require('hardhat');
const { toBN, BN } = web3.utils;
const Decimal = require('decimal.js');
const CoverMockStakingPool = artifacts.require('CoverMockStakingPool');

function calculatePriceIntegral (
  basePrice,
  activeCover,
  capacity,
) {
  const price = basePrice.mul(activeCover.pow(toDecimal(8)).div(toDecimal(8).mul(capacity.pow(toDecimal(7)))).add(activeCover));
  return price;
}

function calculatePrice (
  amount,
  basePrice,
  activeCover,
  capacity) {

  amount = toDecimal(amount);
  basePrice = toDecimal(basePrice);
  activeCover = toDecimal(activeCover);
  capacity = toDecimal(capacity);
  return (calculatePriceIntegral(
    basePrice,
    activeCover.add(amount),
    capacity,
  ).sub(calculatePriceIntegral(
    basePrice,
    activeCover,
    capacity,
  ))).div(amount);
}

async function createStakingPool (
  cover, productId, capacity, targetPrice, activeCover, stakingPoolCreator, stakingPoolManager, currentPrice,
) {

  const tx = await cover.connect(stakingPoolCreator).createStakingPool(stakingPoolManager.address);

  const receipt = await tx.wait();

  const { stakingPoolAddress, manager, stakingPoolImplementation } = receipt.events[0].args;

  const stakingPool = await CoverMockStakingPool.at(stakingPoolAddress);

  await stakingPool.setStake(productId, capacity);
  await stakingPool.setTargetPrice(productId, targetPrice);
  await stakingPool.setUsedCapacity(productId, activeCover);

  await stakingPool.setPrice(productId, currentPrice); // 2.6%

  return stakingPool;
}

function toDecimal (x) {
  return new Decimal(x.toString());
}

module.exports = {
  calculatePrice,
  createStakingPool,
};
