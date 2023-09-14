const mongoose = require('mongoose');

const UserSchema = mongoose.Schema({
    username: String,
    password: String
}, {strict: false})

module.exports = mongoose.model("Users", UserSchema);