const express = require("express");
const app = express.Router();
const { readFileSync } = require("fs");
const { resolve } = require("path");

// home page
app.get("/", (req, res) => res.send(readFileSync(resolve(__dirname, "home.html"), "utf8")));

// exports
module.exports = app;