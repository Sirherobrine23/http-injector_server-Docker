const fs = require("fs")
const path = require("path")
const date_save = process.env.date
const username = process.env.user

function encode (data){return new Buffer.from(data).toString("base64")}
const passworld = encode(process.env.pass)
const ssh_limit = process.env.ssh_limit

function toDate(dateStr) {
    const parts = dateStr.split("/")
    const date = new Date(parts[2], parts[1] - 1, parts[0]).getTime()
    const full_date = new Date(parts[2], parts[1] - 1, parts[0]).toString()
    console.log(full_date)
    console.log(date)
    if (new Date().getTime() <! date) {
        console.warn("The date is not valid")
        process.exit(23)
    }
    return date
}

const users = path.join((process.env.HOME||process.env.USERPROFILE), "user.json") 
if (!(fs.existsSync(users))) fs.writeFileSync(users, "[]")

const uuid = require("uuid").v4
const new_token = toDate(date_save)

var tokens = JSON.parse(fs.readFileSync(users, "utf8"));

function verify (user){
    const json_config_path = path.join(process.env.HOME, "user.json") 
    const json_config = JSON.parse(fs.readFileSync(json_config_path, "utf8"))
    for (let teste in json_config){
        if (user === json_config[teste].user) return false
        teste++
    }
    return true
}
function sshuttle_port (){
    const json_config_path = path.join(process.env.HOME, "user.json");
    const json_config = JSON.parse(fs.readFileSync(json_config_path, "utf8"))
    const port = Math.trunc(Math.random() * 1000)
    for (let teste in json_config){
        const port_config = json_config[teste].sshuttle.port
        if (port === port_config) return sshuttle_port()
    }
    if (port < 50) return port
    else return sshuttle_port()
}
if (verify(username)){
    tokens.push({
        "user": username,
        "pass": passworld,
        "data": new_token,
        "ssh": ssh_limit,
        "pptp": true
    });
    fs.writeFileSync(users, JSON.stringify(tokens), "utf8");

    console.log(new_token);
} else {
    console.log("User exist")
}
function IsNotModule(){
    const isnot = "This is not a module"
    console.log(isnot)
    return isnot
}
module.exports = IsNotModule
export default IsNotModule