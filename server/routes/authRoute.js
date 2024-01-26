const authController = require("../controllers/authController");
const media = require("../middleware/media");
const router = require("express").Router();


router.route("/signup")
    .post(media.single("profile-pic"), authController.signup)

router.route("/signin")
    .post(authController.signin)

module.exports = router;
