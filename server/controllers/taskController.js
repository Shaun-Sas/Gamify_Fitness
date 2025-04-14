const communityModel = require("../models/communityModels");
const taskController = {}


taskController.addTask = async (req, res) => {
    const { commId, taksName, description } = req.body;

    const comm = await communityModel.findByIdAndUpdate(commId, {
        $push: {
            tasks: {
                title: taksName,
                description
            }
        }
    }, {new: true})

    return res.json(comm)
}

taskController.getAlltasksOfComm = async (req, res) => {
    const commId = req.query.commId;
    const comm = await communityModel.findById(commId).select("tasks").lean().exec()
    return res.json(comm.tasks)
}


module.exports = taskController;