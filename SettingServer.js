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
    if (new Date().getTime() <! date) {console.warn("The date is not valid");process.exit(23)}
    return date
}

const BaseConfig = {
    "openssh": {
        "ports": [
            22
        ]
    },
    "dropebear": {
        "ports": [
            443
        ]
    },
    "squid": {
        "ports": [
            80,
            8080,
            554,
            1935,
            7070,
            8000,
            8001
        ]
    },
    "badvpn": {
        "port": 7300
    },
    "users": [
        {
            "user": "userteste",
            "pass": "dXN1YXJpbzEyMzQ=",
            "data": "24/12/2050",
            "ssh": "10"
        },
        {
            "user": "testeuser",
            "pass": "dXN1YXJpbzEyMzQ=",
            "data": "24/12/2050",
            "ssh": "10"
        }
    ]
}

const users = path.join((process.env.HOME||process.env.USERPROFILE), "user.json") 
if (!(fs.existsSync(users))) fs.writeFileSync(users, "[]")

const new_token = toDate(date_save)

var ConfigFile = JSON.parse(fs.readFileSync(users, "utf8"));

function verify (user){
    const json_config_path = path.join(process.env.HOME, "user.json") 
    const json_config = JSON.parse(fs.readFileSync(json_config_path, "utf8"))
    for (let teste in json_config){
        if (user === json_config[teste].user) return false
        teste++
    }
    return true
}

if (verify(username)){
    ConfigFile.push({
        "user": username,
        "pass": passworld,
        "data": new_token,
        "ssh": ssh_limit
    });
    fs.writeFileSync(users, JSON.stringify(ConfigFile), "utf8");

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