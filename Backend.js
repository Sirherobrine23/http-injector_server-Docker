const fs = require("fs");
const path = require("path");
const child_process = require("child_process");
const { UniversalSpeedTest, SpeedUnits } = require("universal-speedtest");
const { homedir } = require("os");
const { UsersFile, UserDB } = require("./Paths");
if (!(global.fetch)) global.fetch = require("node-fetch");

function GetServices(){
    try {
        return child_process.execSync("service --status-all").toString("utf8").split("\n").filter(a=>a).map(Lines => Lines.split(/\s+/gi).filter(a=>!/^\[|^\]|^\+|^\-/.test(a)).filter(a=>a).join(""));
    } catch (err) {
        console.log(err);
        return [];
    }
}

async function Speedtest(){
    try {
        console.log("Starting the Internet Speed Test");
        const SpeedTest = new UniversalSpeedTest({measureUpload: true, downloadUnit: SpeedUnits.Gbps, timeout: 6 * 60 * 1000});
        const Speedtest_Result = await SpeedTest.runTestByNetmetr();
        console.log("Sucess in fetch speedtest result")
        const Ip_Result = (await (await fetch("https://ipinfo.io/json")).json())
        return {
            Date: new Date(),
            Speedtest_Result,
            Ip_Result
        }
    } catch (err) {
        console.log(err);
        return {
            Speedtest_Result: {
                ping: null,
                downloadSpeed: null,
                uploadSpeed: null,
                pingUnit: "ms",
                downloadUnit: "Bps",
                uploadUnit: "Bps"
            },
            Ip_Result: {
                ip: null,
                city: null,
                region: null,
                country: null,
                loc: null,
                org: null,
                postal: null,
                timezone: null
            }
        }
    }
}

// Get process list
function GetProcessList(){
    return child_process.execSync("ps -aux").toString("utf8").split("\n").filter(d=>{return !(/USER\s+/.test(d) || d === "")}).map(line => {
        line = line.split(/\s+/)
        return {
            command: (function(){
                var command = line[10];
                const argvLenght = (line.length - 11);
                for (let index = 0; index < argvLenght; index++) command += ` ${line[11 + index]}`;
                return command.trim();
            })(),
            pid: parseInt(line[1]),
            cpu: line[2],
            mem: line[3],
        }
    })
}

// Restart Service Command
function restartService(service) {
    return child_process.execSync(`services ${service} stop && services ${service} start`).toString("utf8")
}

// Restart Services
function restartServices(services) {
    for (let service of services) {
        restartService(service);
    }
}

// Users Status Array
function GetUsersStatus(){
    try {
        var sshMonitor = child_process.execFileSync("bash", [path.resolve(__dirname, "./ShellScripts/sshmonitor.sh")], {
            env: {
                ...process.env,
                database: UserDB,
            }
        }).toString("utf8")
        console.log(sshMonitor);
        sshMonitor = sshMonitor.split("\n").filter(a=>a.trim()).map(Users => Users.split(/\s+/gi)).map(Users => {
            let connections = Users[2].split("/").filter(a=>a).map(a=>a.trim());
            return {
                user: Users[0],
                Status: Users[1] === "Online",
                connections: {
                    total: connections[0],
                    used: connections[1]
                },
                time: Users[3],
            }
        })
        return sshMonitor;
    } catch (err){
        console.log(err);
        return []
    }
}

// Add user system
function AddUser(user = "UserTest", password = "hhahhahhaha", days = 7, connections = 2){
    const Users = JSON.parse(fs.readFileSync(UsersFile, "utf8"));
    try {
        // Checks
        // User
        if (typeof user !== "string") throw new Error("the user must be a string");
        if (user.length <= 2||user.length >= 10) throw new Error("Username Short or long");
        if (Users[user] || fs.readFileSync("/etc/passwd", "utf8").includes(user)) throw new Error("User already exists");

        // Passworld
        if (typeof password !== "string") throw new Error("the passworld must be a string");
        if (password.length <= 4) throw new Error("Password is too short");

        // Days
        if (typeof days !== "number") throw new Error("the days must be a number");
        if (days <= 1) throw new Error("invalid days");

        // Connections
        if (typeof connections !== "number") throw new Error("the connections must be a number");
        if (connections <= 1) throw new Error("invalid connections");

        // Create
        const PassworldEncrypt = child_process.execSync(`perl -e 'print crypt($ARGV[0], "password")' ${password}`).toString("utf8");
        const DateS = (()=>{
            const CDD = new Date(new Date().getTime() + (days * 24 * 60 * 60 * 1000));
            if (CDD.getTime() <= 0) throw new Error("Time Error");

            var day, mounth, year = CDD.getFullYear();
            if (CDD.getDay() <= 9) day = `0${CDD.getDay()}`; else day = CDD.getDay().toString();
            if (CDD.getMonth() <= 9) mounth = `0${CDD.getMonth()}`; else mounth = CDD.getMonth().toString();
            return `${year}-${mounth}-${day}`
        })();
        child_process.execSync(`useradd -e ${DateS} -M -s /bin/false -p ${PassworldEncrypt} ${user}`);
        Users[user] = {
            Username: user,
            Date: new Date(DateS),
            Password: PassworldEncrypt,
            Sessions: connections,
        }
        fs.writeFileSync(UsersFile, JSON.stringify(Users, null, 2));
        fs.appendFileSync(UserDB, `${user} ${days}\n`);
        return true;
    } catch (err) {
        console.log(err);
        return false;
    }
}

// Delete user from system
function DeleteUser(user){
    const Users = JSON.parse(fs.readFileSync(UsersFile, "utf8"));
    try {
        // Checks
        // User
        if (typeof user !== "string") throw new Error("the user must be a string");
        if (!(fs.readFileSync("/etc/passwd", "utf8").includes(user) || Users[user])) throw new Error("User doesn't exists");

        // Delete
        child_process.execSync(`userdel -r -f ${user}`);
        delete Users[user];
        fs.writeFileSync(UsersFile, JSON.stringify(Users, null, 2));
        return true;
    } catch (err) {
        console.log(err);
        return false;
    }
}

// Load Users to system
function LoadUsers(){
    try {
        const Users = JSON.parse(fs.readFileSync(UsersFile, "utf8"));
        for (let user in Object.getOwnPropertyNames(Users)) {
            user = Users[user];
            if (user.Username && user.Password && (1 >= (new Date().getTime() - new Date(user.Date).getTime()))) {
                child_process.execSync(`useradd -e ${user.Date} -M -s /bin/false -p ${user.Password} ${user.Username}`);
                fs.appendFileSync(UserDB, `${user.Username} ${user.Sessions}\n`);
            }
        }
        return true;
    } catch (err){
        console.log(err);
        return false;
    }
}

// Start badvpn
async function startBadvpn(){
    badvpn = "/bin/badvpn-udpgw"
    return new Promise(async (resolve_async, reject_async) => {
        try {
            if (fs.existsSync(badvpn)) {
                child_process.execFileSync("screen", ["-dmS", "Badvpn", badvpn]);
                setTimeout(() => {
                    const currentList = GetProcessList().filter(a => a.command.toLowerCase().includes("badvpn"))
                    if (currentList.length <= 0) reject_async("Badvpn is already running"); else resolve_async("Badvpn is running");
                }, 15 * 1000);
            } else {
                reject_async("Badvpn not installed");
            }
        } catch (err) {
            console.log(err);
            return false;
        }
    });
}

// Stop badvpn
async function stopBadvpn(){
    badvpn = "/bin/badvpn-udpgw"
    return new Promise(async (resolve_async, reject_async) => {
        try {
            if (fs.existsSync(badvpn)) {
                child_process.execFileSync("screen", ["-S", "Badvpn", "-X", "quit"]);
                setTimeout(() => {
                    const currentList = GetProcessList().filter(a => a.command.toLowerCase().includes("badvpn"))
                    if (currentList.length <= 0) resolve_async("Badvpn is stopped"); else reject_async("Badvpn is running");
                }, 15 * 1000);
            } else {
                resolve_async("Badvpn not installed");
            }
        } catch (err) {
            console.log(err);
            resolve_async("Badvpn error");
        }
    });
}

module.exports = {
    restartServices,
    restartService,
    GetServices,
    Speedtest,
    GetUsersStatus,
    GetProcessList,
    AddUser,
    DeleteUser,
    LoadUsers,
    startBadvpn,
    stopBadvpn,
}