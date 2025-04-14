const communityController = require("../controllers/communityController");
const taskController = require("../controllers/taskController");
const router = require("express").Router();

const authorize = require("../middleware/authorize");

router.route('/mycommunities')
    .get(authorize, communityController.userCommunities)
    
router.route("/community")
  .get(communityController.getAllCommunity)
  .post(authorize, communityController.createCommunity)
  .put(authorize, communityController.addMember)

router.route('/tasks')
    .get(taskController.getAlltasksOfComm)
    .post(authorize, communityController.createTask)
    
router.route("/community/:communityId")
  .get(communityController.getCommunity);

router.route("/add-member")
  .post(authorize, communityController.addMember)



module.exports = router;
