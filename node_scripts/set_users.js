// Requires
const {exec, execSync} = require("child_process")
const {writeFileSync, readFileSync, existsSync} = require("fs")
const {join} = require("path");

// functions
function encode (data){
    return new Buffer.from(data).toString("base64")
}

function decode (data){
    return new Buffer.from(data, 'base64').toString('ascii');
}

// Script
const users = join("/", "home", "configs", "users.json")
var config;
if (existsSync(users)) config = JSON.parse(readFileSync(users, "utf8"))
else config = [
    {
        "user": "teste",
        "pass": "dGhhdCdzIGJlY2F1c2UgeW91IGRpZG4ndCBjcmVhdGUgYSBwYXNzd29yZA==",
        "data": "1614306838218",
        "ssh": 10
    }
]

for (let index in config) {
    const element = config[index];
    const user = element.user
    const pass = decode(element.pass)
    const ssh = element.ssh
    const current_date = new Date().getTime()
    if (element.data > current_date) {
        const data = element.data
        const save_user = exec(`usuario.sh "${user}" "${pass}" "${data}" "${ssh}"`)
        save_user.stdout.on("data", function (data){
            console.log(data)
        })
        save_user.on("exit", function(err){
            if (err !==  0) process.exit(err)
        })
    }
    index++
}
