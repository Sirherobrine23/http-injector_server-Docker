const express = require("express");
const app = express.Router();
const { AddUser } = require("../Backend");
const fs = require("fs");
const { TokensFile } = require("../Paths");
const { GetUsersStatus } = require("../Backend")

app.post("*", (req, res) => res.sendStatus(404))

app.use(function (req, res, next){
    const { Token } = req.query;
    const tokens = JSON.parse(fs.readFileSync(TokensFile, "utf8"));
    for (let token of tokens) {
        if (token === Token) return next();
    }
    return res.status(400).json({error: "Token invalid"});
});

app.get("/add", (req, res) => {
    const { user, passworld, days, connections } = req.query;
    if (!(user)) res.status(400).send("Enter a valid user")
    if (!(passworld)) res.status(400).send("Enter a valid password")
    if (!(days)) res.status(400).send("Enter a valid date")
    if (!(connections)) res.status(400).send("inform a number of valid simultaneous connections")
    
    // Add user and check
    if (AddUser(user, passworld, parseInt(days), parseInt(connections)))
        return res.json({
            User: user,
            Passworld: passworld,
            Days: parseInt(days),
            Connections: parseInt(connections),
        });
    else
        return res.status(400).json({
            error: "Add User Failed",
        });
});

app.get("/status", (req, res) => {
    try {
        const UsersStatus = GetUsersStatus();
        const Status = req.query.Status || "";
        console.log(UsersStatus)
        if (/true|online/.test(Status.toLocaleLowerCase())) {
            return res.json(UsersStatus.filter(re => re.connections.used >= 0));
        } else if (/false|offline/.test(Status.toLocaleLowerCase())) return res.json(UsersStatus.filter(re => re.connections.used === 0))
        return res.json(UsersStatus)
    } catch (e) {
        console.log(e);
        return res.sendStatus(500);
    }
});

// Exports
app.all("*", (req, res) => res.sendStatus(404))
module.exports = app;