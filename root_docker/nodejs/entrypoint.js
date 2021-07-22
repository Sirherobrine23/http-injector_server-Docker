#!/usr/bin/env node
const { execSync, exec } = require("child_process");
const { existsSync, writeFileSync, readFileSync } = require("fs");

console.log("Performing the base configurations, please wait ...")
console.log("Configuring admin users, please wait ...");

// functions
function ConvertDatetorestdays(d){
    const date1 = d.split("/")
    // date1[0] = day, date1[1] = Month, date1[2] = year

    if (date1[1] > 12) throw new Error("monthe error data")
    if (date1[0] > 31) throw new Error("Day error data")

    const firstDate = new Date(date1[2], date1[1] - 1, date1[0]);
    const secondDate = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate());
    let days = ((firstDate - secondDate) / (24 * 60 * 60 * 1000 /* hours*minutes*seconds*milliseconds) */))
    if (days > 0) return Math.round(Math.abs(days));
    else return 0
}

console.log("User settings made successfully, configuring other things");

// Read file config
var config = JSON.parse(readFileSync(process.env.CONFIG_FILE, "utf8"))

var SquidPortExport="";
for (let SquidPort of config.squid.ports) SquidPortExport += `http_port ${SquidPort}\n`

var SquidBlockDomains="";
for (let DomainsBlocks of config.squid.domainsblock) SquidBlockDomains += `${DomainsBlocks}\n`

writeFileSync("/etc/squid/Block.conf", SquidBlockDomains)

const SquidConfig = `acl all src 0.0.0.0/0 ::/0

acl blockdomains dstdomain "/etc/squid/Block.conf"

# Allow
http_access allow all

# Deny
http_access deny blockdomains

#Ports
${SquidPortExport}

# Options
visible_hostname Docker
via off
forwarded_for off
pipeline_prefetch off`

// console.log(SquidConfig);
writeFileSync("/etc/squid/squid.conf", SquidConfig)

var DropbearExportDefault,
    DropbearExport="";
for (let DropbearPort of config.dropebear.ports) {
    if (DropbearExportDefault === undefined) DropbearExportDefault = DropbearPort;
    else DropbearExport += `-p ${DropbearPort} `;
}
const DropebearConfig = `NO_START=0
DROPBEAR_PORT=${DropbearExportDefault}
DROPBEAR_EXTRA_ARGS="${DropbearExport}"

DROPBEAR_RECEIVE_WINDOW=65536
DROPBEAR_BANNER="/etc/ssh/banner.html"`

// console.log(DropebearConfig);
writeFileSync("/etc/default/dropbear", DropebearConfig)

var OpenSSHPort="";
for (let SquidPort of config.openssh.ports) OpenSSHPort += `Port ${SquidPort}\n`

const SshConfig = `ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp  /usr/lib/openssh/sftp-server
ClientAliveInterval 120
PasswordAuthentication yes
PermitTunnel yes
Banner /etc/ssh/banner.html
${OpenSSHPort}`

// console.log(SshConfig);
writeFileSync("/etc/ssh/sshd_config", SshConfig)


try {
    execSync("pass=$(perl -e 'print crypt($ARGV[0], \"password\")' $password);useradd -m -p \"$pass\" \"$username\";addgroup $username sudo;usermod --shell /usr/bin/zsh --home /tmp/ $username;echo \"$username   ALL=(ALL:ALL) NOPASSWD: ALL\" >> /etc/sudoers", {
        env: {
            username: process.env.ADMIN_USERNAME,
            password: process.env.ADMIN_PASSWORD
        }
    })
    console.log("User admin sucess: "+process.env.ADMIN_USERNAME);
} catch (error) {
    console.log(error);
    process.exit(1);
}

console.log("Configuring users, please wait ...\n");

for (let userConfig of config.users) {
    const data = ConvertDatetorestdays(userConfig.data)
    const user = userConfig.user

    if (user.length > 10) console.warn(`${user} it's too long, jumping`)
    else if (0 > data) console.warn(`Skipping Users ${user}, as it is no longer valid, Days Remaining: ${data}`)
    else {
        try {
            execSync(`bash /scripts/usuario.sh "${user}" "${new Buffer.from(userConfig.pass, "base64").toString("ascii")}" "${data}" "${userConfig.ssh}"`).toString();
            console.log(`${user} add`);
        } catch (error) {
            console.log(error);
        }
    }
}
console.log("");

for (let service of [
    "dropbear",
    "ssh",
    "squid"
]) {
    try {
        execSync(`service ${service} start`).toString()
        console.log(`Sucess to start service: ${service}`);
    } catch (error) {
        console.log(error);
    }
}

require("./rest")
const ServiceStatus = require("./ServicesStatus").status
const UStF = "/tmp/users.json"
if (existsSync("/usuarios.db")){
    console.log("Starting the Rest API");
    setInterval(() => {
        // userteste       Offline        0/10      00:00:00
        // testeuser       Offline        0/10      00:00:00
        let restPush = {
            users: []
        }
        var Sshmonitor = execSync("bash /scripts/sshmonitor.sh").toString()
        Sshmonitor = Sshmonitor.split(/\r?\n/g)
        for (let index of Sshmonitor) {
            index = index.trim()
            if (!(index === "" || index === "\n")) {
                index = index.split(/\s+/g)
                restPush.users.push(index[0])
                restPush[index[0]] = {
                    Status: index[1],
                    Time: index[3]
                }
            }
        }
        writeFileSync(UStF, JSON.stringify(restPush, null, 4))
        // Check Services
        const CSs = ServiceStatus()
        if (!(CSs["ssh"])) {console.log("OpenSSH is stopped");process.exit(12)}
        if (!(CSs["dropbear"])) {console.log("Dropbear is stopped");process.exit(13)}
        if (!(CSs["squid"])) {console.log("Squid is stopped");process.exit(14)}
    }, 2000);
}

console.log(execSync("/scripts/badvpn.sh").toString());
const SetupConfig = exec("node index.js", {
    env: {
        USERNAME: process.env.ADMIN_USERNAME,
        PASSWORLD: process.env.ADMIN_PASSWORD,
        IS_DOCKER: true
    },
    cwd: "/SetupUsers"
})
SetupConfig.stdout.on("data", data => console.log(data))