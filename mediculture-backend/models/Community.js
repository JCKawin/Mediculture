const mongoose = require('mongoose');

const communityPostSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true
  },
  userDisplayName: {
    type: String,
    required: true
  },
  category: {
    type: String,
    required: true,
    enum: ['General Health', 'Mental Health', 'Nutrition', 'Fitness', 'Medicine', 'Other']
  },
  title: {
    type: String,
    required: true
  },
  content: {
    type: String,
    required: true
  },
  tags: [String],
  images: [String],
  likes: [{
    userId: String,
    timestamp: {
      type: Date,
      default: Date.now
    }
  }],
  comments: [{
    userId: String,
    userDisplayName: String,
    content: String,
    timestamp: {
      type: Date,
      default: Date.now
    }
  }],
  isAnonymous: {
    type: Boolean,
    default: false
  },
  isApproved: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('CommunityPost', communityPostSchema);
