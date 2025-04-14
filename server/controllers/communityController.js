const communityModel = require("../models/communityModels");
const userModel = require("../models/userModel");
const mongoose = require("mongoose");
const communityController = {};

communityController.createCommunity = async (req, res) => {
  try {
    const { name, description } = req.body;
    const leader = req.user.id;
    const newCommunity = await communityModel.create({
      name,
      description,
      leader,
    });
    newCommunity.members.push(leader);
    newCommunity.save()

    await userModel.findByIdAndUpdate({_id:leader}, {"$push":{
      communities:newCommunity._id
    }})

    res.json(newCommunity._id);
  } catch(error) {
    res.status(500).json({ message: "Failed to create community", error });
  }
};

communityController.getCommunity = async (req, res) => {
  try {
    const communityId = req.params.communityId;
    const community = await communityModel
      .findOne({ _id: communityId })
      .lean()
      .exec();
    if (community) res.json(community);
    else res.status(404).json({ message: "community not found" });
  } catch (error) {
    res.status(500).json({ message: "Failed to get community", error });
  }
};

communityController.getAllCommunity = async (req, res) => {
  try {
    const communities = await communityModel.find({}).lean().exec();
    if (communities) res.json(communities);
    else res.status(404).json({ message: "community not found" });
  } catch (error) {
    res.status(500).json({ message: "Failed to get community", error });
  }
};

communityController.addMember = async (req, res) => {
  try {
    const userId = req.user.id;
    const { communityId } = req.body;
    const community = await communityModel
      .findOne({ _id: communityId })
      .lean()
      .exec();

    if (community) {
      await communityModel.findByIdAndUpdate(
        { _id: communityId },
        {
          $push: {
            members: userId,
          },
        }
      );

      await userModel.findByIdAndUpdate(
        { _id: userId },
        {
          $push: {
            communities: communityId,
          },
        }
      );
      res.json({ message: "Member added successfully" });
    } else res.status(404).json({ message: "community not found" });
  } catch (error) {
    console.log(error);
    
    res.status(500).json({ message: "Failed to add member", error });
  }
};

communityController.createTask = async (req, res) => {
  try {
   
    const userId = req.user.id;
    const { communityId, title, description, deadline } = req.body;

    // Validate communityId as a valid ObjectId
    if (!mongoose.Types.ObjectId.isValid(communityId)) {
      return res.status(400).json({ message: 'Invalid communityId' });
    }

    // Validate community existence and ownership
    const community = await communityModel.findOne({ _id: communityId, leader: userId });

    if (!community) {
      return res.status(404).json({ message: 'Community not found or user not a member' });
    }

    // Create a new task object
    const newTask = {
      title,
      description,
      deadline,
    };

    // Make sure the tasks array exists before pushing
    if (!community.tasks) {
      community.tasks = [];
    }

    // Push the new task to the tasks array
    community.tasks.push(newTask);

    // Update the tasks directly in the database
    await communityModel.updateOne(
      { _id: communityId },
      { $set: { tasks: community.tasks } }
    );

    res.status(201).json({ message: 'Task created successfully' });
  } catch (error) {
    console.error('Error creating task:', error);
    res.status(500).json({ message: 'Failed to create task', error: error.message });
  }
};

communityController.userCommunities = async (req, res) => {
  const userId = req.user.id;
  const user=await userModel.findById(userId).select("communities").lean().exec();
  const communities = await communityModel.find({ _id: { $in: user.communities } }).lean().exec();
  if (!communities) res.status(404).json({ message: "communities not found" });
  
  res.json(communities);
}

module.exports = communityController;
