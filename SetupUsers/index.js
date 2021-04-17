#!/usr/bin/env node
const express = require("express");
const fs = require("fs");
const path = require("path");
var cors = require("cors");
const bodyParser = require("body-parser");
const { resolve } = require("path");
const app = express();

app.use(cors());
app.use(bodyParser.json()); /* https://github.com/github/fetch/issues/323#issuecomment-331477498 */
app.use(bodyParser.urlencoded({ extended: true }));
// ******************************************************
const tokenFile = resolve(__dirname, "token.txt");
const ConfigFile = resolve((process.env.USERPROFILE||process.env.HOME), "HttpInjectorConfig.json");
require("crypto").randomBytes(Math.random() + 1 * 1000, function(err, buffer) {
    if (err) console.warn(err);
    const new_token = buffer.toString("hex");
    fs.writeFileSync(tokenFile, new_token)
    
})
// -----------------------------
app.get("/", (req, res) => {
    res.sendFile(resolve(__dirname, "pages", "index.html"))
});
app.get("/login", (req, res) => {
    res.sendFile(resolve(__dirname, "pages", "login.html"))
});
app.get("/configJson.js", (req, res) => {
  res.send(`var jsonConfig = ${readFileSync(ConfigFile, "utf8")}`)
});
app.post("/get_token", (req, res) => {
    const body = req.headers
    if (body.user !== process.env.USERNAME) return res.status(400).json({
        "messsage": "Check username"
    })
    if (body.pass !== process.env.PASSWORLD) return res.status(400).json({
        "messsage": "Check username"
    })
    res.send(fs.readFileSync(tokenFile, "utf8"))
});

app.post("/check_token", (req, res) => {
    const body = req.headers;
    const localToken = fs.readFileSync(tokenFile, "utf8")
    if (localToken === body.token) res.send("ok")
    else res.sendStatus(403)
});

app.post("/save_config", (req, res) => {
    const body = req.headers
    const localToken = fs.readFileSync(tokenFile, "utf8")
    if (localToken === body.token) {
        const parseConfig = JSON.stringify(JSON.parse(Buffer.from(body.injectorconfig, "base64").toString()), null, 4)
        fs.writeFileSync(ConfigFile, parseConfig)
    }
    else res.sendStatus(404)
});
// -----------------------------
const port = (process.env.port_api||1112)
app.listen(port, function (){
    console.log(`Web Config: ${port}`);
});
return port