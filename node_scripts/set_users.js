// Requires
const {exec, execSync} = require("child_process")
const {writeFileSync, readFileSync, existsSync} = require("fs")
const {join} = require("path")

// functions
function encode (data){return new Buffer.from(data).toString("base64")}

function decode (data){return new Buffer.from(data, 'base64').toString('ascii')}
function toDate(dateStr) {const parts = dateStr.split("/");return new Date(`${parts[2]}/${parts[1] - 1}/${parts[0]}`).getTime()}
function restdate(d){
    const date1 = d.split("/")
    // date1[1] // Month
    // date1[0] // day
    // date1[2] // year
    const current_day = new Date().getDate()
    const current_month = new Date().getMonth()
    const current_year = new Date().getFullYear()

    const oneDay = 24 * 60 * 60 * 1000; // hours*minutes*seconds*milliseconds
    const firstDate = new Date(date1[2], date1[1] - 1, date1[0]);
    const secondDate = new Date(current_year, current_month, current_day);
    
    const diffDays = Math.round(Math.abs((firstDate - secondDate) / oneDay));
    return diffDays
}
// Script
const users = join("/", "home", "configs", "users.json")
var config;
if (existsSync(users)) config = JSON.parse(readFileSync(users, "utf8"))
else config = [
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

const current_date = new Date().getTime()
for (let index in config) {
    const element = config[index];
    const user = element.user
    const pass = decode(element.pass)
    const ssh = element.ssh
    const data = restdate(element.data)
    const check_date = toDate(element.data)
    if (current_date >! check_date) {
        var save_user = exec(`bash /scripts/usuario.sh "${user}" "${pass}" "${data}" "${ssh}"`)
        // var save_user = execSync(`echo "${user}" "${pass}" "${data}" "${ssh}"`).toString()
        save_user.stdout.on("data", function(data){
            console.log(data)
        })
        save_user.on("exit", function(code){
            if (code !== 0) process.exit(code)
        })
    } else console.warn("Date not valid skipping")
    index++
}