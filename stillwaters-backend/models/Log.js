const mongoose = require('mongoose');

const logSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  type: { type: String, enum: ['meditation', 'breathing'], required: true },
  fish: {
    name: String,
    rarity: String,
  },
  cancelled: { type: Boolean, default: false },
  timestamp: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Log', logSchema);
