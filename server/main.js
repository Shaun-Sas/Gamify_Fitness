require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const logger = require("morgan");
const connectDB = require("./configs/connect.js");
const fs = require("fs")
const app = express();

app.use(logger("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cors());

if(!fs.existsSync("uploads")) 
  fs.mkdirSync("uploads")

app.use("/uploads", express.static('uploads'))

connectDB();

// routes
app.use("/post", require("./routes/postsRoute"));
app.use("/auth", require("./routes/authRoute"));
app.use("/user", require("./routes/userRoute"));
app.use("/community", require("./routes/communityRoutes"));
app.use("/connection", require("./routes/connectionRoute"));

const PORT = process.env.PORT || 5000;

mongoose.connection.once("open", () => {
  console.log("connected to db");
  app.listen(PORT, () => {
    console.log(`server started at ${PORT}`);
  });
});

mongoose.connection.on("error", (error) => {
  console.log(error);
});
