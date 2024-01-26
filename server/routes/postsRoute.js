const postController = require("../controllers/postController");
const authorize = require("../middleware/authorize");
const router = require("express").Router();
const media = require("../middleware/media");

router
  .route("/post")
  .post(authorize, media.single("content-media"), postController.addPost)
  .put(authorize, postController.updatePost);

router
  .route("/post/:postId")
  .get(authorize, postController.getPost)
  .delete(authorize, postController.deletePost);

router.route("/comment/:postId").post(authorize, postController.addComment);

router.route("/like/:postId").post(authorize, postController.addLike);

router.route("/user/:userId").get(postController.getUserPost);

module.exports = router;
