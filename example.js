const express = require("express");
const bodyParser = require("body-parser");
const mongoose = require("mongoose");
const User = require("./models/User");

mongoose.connect("mongodb://localhost/local", { useNewUrlParser: true }, () =>
  console.log("Connected to local database")
);

const app = express();
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

const port = 3000;

const nosqlcheck = require("./nosqlcheck.js");
const checker = new nosqlcheck(["id", "key", "string", "num", "boolean"]);

app.get("/createUser", function (req, res) {
  const user = new User({
    username: "Shaun",
    password: "pass123",
  });

  try {
    user.save().then((result) => res.send(result));
  } catch (err) {
    console.log(err);
    res.send(err);
  }
});

app.post("/login", function (req, res) {
  var username = req.body.username;
  var password = req.body.password;

  var original_query = { username: username, password: password };
  var augmented_query = {
    username: checker.trackInput(username),
    password: checker.trackInput(password),
  };

  var is_benign = checker.checkQuery(augmented_query);

  if (is_benign) {
    console.log("Benign Query");
    User.find(original_query).then(function (value) {
      console.log(value);
      res.send(is_benign);
    });
  } else {
    console.log("Potentially Malicious Query");
    res.send(is_benign);
  }
});

app.post("/login_unsafe", function (req, res) {
  var start = new Date();

  var username = req.body.username;
  var password = req.body.password;

  var query = { username: username, password: password };

  User.find(query).then(function (value) {
    res.send(value);
  });

  console.log(new Date() - start);
});

app.listen(port, function () {
  console.log(`NoSQL Injection Detection is listening on port ${port}!`);
});
