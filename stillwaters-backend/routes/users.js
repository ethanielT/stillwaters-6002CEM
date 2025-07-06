const express = require('express');
const router = express.Router();
const User = require('../models/User');
const getRandomFish = require('../utils/fishPicker');
const Log = require('../models/Log');
const fishList = require('../data/fishList');

// Create a new user with hashed password
router.post('/', async (req, res) => {
  try {
    const existing = await User.findOne({ username: req.body.username });
    if (existing) return res.status(400).send('Username already exists');

    const user = new User(req.body);
    await user.save();
    res.status(201).send({
      message: 'User created successfully',
      userId: user._id,
      username: user.username
    });
  } catch (err) {
    res.status(500).send({ error: err.message });
  }
});

// User login
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    const user = await User.findOne({ username });
    if (!user) return res.status(400).send('User not found');

    const isMatch = await user.comparePassword(password);
    if (!isMatch) return res.status(401).send('Invalid credentials');

    res.status(200).send({
      message: 'Login successful',
      userId: user._id,
      username: user.username
    });
  } catch (err) {
    res.status(500).send({ error: err.message });
  }
});

// Fish catching
router.post('/:id/catch', async (req, res) => {
  try {
    const fish = getRandomFish();
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).send('User not found');

    user.fishCollected.push({
      name: fish.name,
      date: new Date()
    });

    await user.save();
    res.status(200).json({ message: 'Fish caught!', fish });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Save log
router.post('/:id/log', async (req, res) => {
  try {
    const { type, fish, cancelled = false } = req.body;

    const log = new Log({
      userId: req.params.id,
      type,
      fish,
      cancelled
    });

    await log.save();
    res.json({ message: 'Log saved', log });
  } catch (err) {
    res.status(500).json({ message: 'Failed to save log', error: err.message });
  }
});


// Get logs
router.get('/:id/logs', async (req, res) => {
  try {
    const logs = await Log.find({ userId: req.params.id }).sort({ timestamp: -1 });
    res.json(logs);
  } catch (err) {
    res.status(500).json({ message: 'Failed to fetch logs', error: err.message });
  }
});

router.get('/:id/collection', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    const caughtFish = user.fishCollected;

    // Count how many times each fish was caught
    const collectionMap = {};
    caughtFish.forEach(f => {
      collectionMap[f.name] = (collectionMap[f.name] || 0) + 1;
    });

    const collection = {};

    for (const rarity in fishList) {
      collection[rarity] = fishList[rarity].map(fish => ({
        name: fish.name,
        count: collectionMap[fish.name] || 0
      }));
    }

    res.json(collection);
  } catch (err) {
    res.status(500).json({ message: 'Failed to load collection', error: err.message });
  }
});


module.exports = router;
