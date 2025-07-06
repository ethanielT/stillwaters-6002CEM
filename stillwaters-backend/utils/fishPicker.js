const fishList = require('../data/fishList');

function getRandomFish() {
  const rarityRoll = Math.random();

  let chosenRarity;
  if (rarityRoll < 0.1) {
    chosenRarity = 'legendary';
  } else if (rarityRoll < 0.25) {
    chosenRarity = 'rare';
  } else if (rarityRoll < 0.5) {
    chosenRarity = 'uncommon';
  } else {
    chosenRarity = 'common';
  }

  const pool = fishList[chosenRarity];
  const randomIndex = Math.floor(Math.random() * pool.length);
  const chosenFish = pool[randomIndex];

  return {
    ...chosenFish,
    rarity: chosenRarity
  };
}

module.exports = getRandomFish;
