#!/usr/bin/env node
const express = require("express");
const fs = require("fs");
const path = require("path");
var cors = require("cors");
const bodyParser = require("body-parser");
const { resolve } = require("path");
const { execSync } = require("child_process");
const app = express();

app.use(cors());
app.use(bodyParser.json()); /* https://github.com/github/fetch/issues/323#issuecomment-331477498 */
app.use(bodyParser.urlencoded({ extended: true }));
// ******************************************************
const tokenFile = resolve(__dirname, "token.txt");
var ConfigFile
if (process.env.IS_DOCKER) ConfigFile = "/home/configs/settings.json";
else ConfigFile = resolve(__dirname, "..", "..", "HttpInjectorConfig.json");
console.log(ConfigFile);
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
app.get("/favicon.ico", (req, res) => {res.send("null")});
app.get("/configJson.js", (req, res) => {
    var config;
    if (fs.existsSync(ConfigFile)) config = fs.readFileSync(ConfigFile, "utf8")
    else config = {
        "openssh": {
            "ports": []
        },
        "dropebear": {
            "ports": []
        },
        "squid": {
            "ports": []
        },
        "badvpn": {
            "port": 7300
        },
        "users": []
    }
    res.send(`var jsonConfigFromServer = ${config}`)
});

app.get("/Settings.js", (req, res) => {
    res.sendFile(resolve(__dirname, "pages", "Settings.js"))
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
        res.send("ok")
        fs.writeFileSync(ConfigFile, parseConfig)
        console.log(execSync("service ssh restart"));
        console.log(execSync("service dropbear restart"));
        console.log(execSync("service squid restart"));
    }
    else res.send("Token Error")
});
// -----------------------------
const port = (process.env.port_api||1112)
app.listen(port, function (){
    console.log(`Web Config: ${port}`);
});
return port