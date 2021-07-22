const express = require("express");
const cors = require("cors");
const app = express();
const fs = require("fs")
const Speedtest = require("./speedtest")

const UStF = "/tmp/users.json"
const tokenTest = function (ResPass) {
    const passWorld = process.env.ADMIN_PASSWORD
    if (ResPass === passWorld) return true
    else return false
}

app.get("/users_status", (req, res) => {
    const UsersStatus = JSON.parse(fs.readFileSync(UStF, "utf8"))
    res.json(UsersStatus)
})
app.get("/speedtest", (req, res) => {
    let Json = Speedtest.test()
    res.json(Json)
})

const RESTApiPort = 1132
app.listen(RESTApiPort, ()=>{
    console.log(`Rest API in port: ${RESTApiPort}`);
})