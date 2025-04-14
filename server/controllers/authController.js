const userModel = require("../models/userModel");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const authController = {};

authController.signup = async (req, res) => {
  const { username, email, password } = req.body;

  if (!username.trim() || !email.trim() || !password.trim())
    return res.status(400).json({ message: "all fields required" });
  else if (password.length < 8)
    return res.status(400).json({ message: "password length is too short" });

  try {
    const existingUser = await userModel.findOne({ email }).lean().exec();
    if (existingUser)
      return res.status(409).json({ message: "Email already used" });

    const user = await userModel.create({
      username,
      email,
      password,
    });

    if (user) res.status(201).json({ message: "user created" });
    else res.status(400).json({ message: "invalid user data received" });
  } catch (error) {
    res.status(500).json({ message: "server error" });
  }
};

authController.signin = async (req, res) => {
  const { email, password } = req.body;
  if (!email.trim() || !password.trim())
    return res.status(400).json({ message: "all fields required" });

  const existingUser = await userModel
    .findOne({ email })
    .select("password")
    .lean()
    .exec();

  if (!existingUser)
    return res.status(400).json({ message: "email not found" });

  const passwordMatch = await bcrypt.compare(password, existingUser.password);

  if (!passwordMatch)
    return res.status(401).json({ message: "wrong password" });

  const token = jwt.sign({ id: existingUser._id }, process.env.TOKEN_SECRET || "test-screte");

  res.status(200).json({ token });
};

module.exports = authController;
