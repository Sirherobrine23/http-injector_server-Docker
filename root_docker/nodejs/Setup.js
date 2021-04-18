// Requires
const { execSync } = require("child_process")
const { writeFileSync, readFileSync } = require("fs");

// functions

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
var config = JSON.parse(readFileSync("/home/configs/settings.json"))

const current_date = new Date().getTime()
for (let userConfig of config.users) {
    const user = userConfig.user
    const pass = decode(userConfig.pass)
    const ssh = userConfig.ssh
    const data = restdate(userConfig.data)
    const check_date = toDate(userConfig.data)
    if (current_date >! check_date) {
        let result = execSync(`bash /scripts/usuario.sh "${user}" "${pass}" "${data}" "${ssh}"`).toString()
        console.log(result);
    }
    else console.warn("Date not valid skipping")
}

var SquidPortExport="";
for (let SquidPort of config.squid.ports) SquidPortExport += `http_port ${SquidPort}\n`

const SquidConfig = `acl all src 0.0.0.0/0 ::/0

# Allow
http_access allow all

# Deny
# http_access deny all

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
const DropebearConfig = `# disabled because OpenSSH is installed
# change to NO_START=0 to enable Dropbear
NO_START=0
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