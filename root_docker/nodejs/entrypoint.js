#!/usr/bin/env node
const { execSync, exec } = require("child_process");
const { existsSync, writeFileSync } = require("fs");

console.log("Performing the base configurations, please wait ...")
console.log("Configuring admin users, please wait ...");
console.log(execSync(`pass=$(perl -e 'print crypt($ARGV[0], "password")' $password);useradd -m -p "$pass" "$username";addgroup $username sudo;usermod --shell /usr/bin/zsh --home /tmp/ $username;echo "$username   ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers`, {env: {username: process.env.ADMIN_USERNAME, password: process.env.ADMIN_PASSWORD}}).toString());

console.log("Configuring users, please wait ...");
const Setup = exec("node Setup.js", {cwd: "/nodejs"})
Setup.stdout.on("data", (data) => console.log(data))
Setup.on("exit", code => {
    if (code === 0){
        console.log(execSync("service dropbear start").toString());
        console.log(execSync("service ssh start").toString());
        console.log(execSync("service squid start").toString());
        require("./rest")
        const ServiceStatus = require("./ServicesStatus").status
        const UStF = "/tmp/users.json"
        if (existsSync("/root/usuarios.db")){
            console.log("Starting the Rest API");
            setInterval(() => {
                // userteste       Offline        0/10      00:00:00
                // testeuser       Offline        0/10      00:00:00
                let restPush = []
                var Sshmonitor = execSync("bash /scripts/sshmonitor.sh").toString()
                Sshmonitor = Sshmonitor.split(/\r?\n/g)
                for (let index of Sshmonitor) {
                    index = index.trim()
                    if (!(index === "" || index === "\n")) {
                        index = index.split(/\s+/g)
                        restPush.push(index)
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
    }
    else {
        console.log(code);
        process.exit(code)
    }
})
console.log(execSync("/scripts/badvpn.sh").toString());
const SetupConfig = exec(`node index.js`, {
    env: {
        USERNAME: process.env.ADMIN_USERNAME,
        PASSWORLD: process.env.ADMIN_PASSWORD,
        IS_DOCKER: true
    },
    cwd: "/SetupUsers"
})
SetupConfig.stdout.on("data", data => console.log(data))