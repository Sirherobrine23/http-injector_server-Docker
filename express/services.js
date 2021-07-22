const express = require("express");
const app = express.Router();
const path = require("path");
const fs = require("fs");
const { TokensFile } = require("../Paths");
const { restartServices } = require("../Backend");

// Token Verify
app.use(function (req, res, next){
    if (req.method === "GET") var { Token } = req.query; else var { Token } = req.body;
    if (req.path === "/") return next()
    const tokens = JSON.parse(fs.readFileSync(TokensFile, "utf8"));
    for (let token of tokens) {
        if (token === Token) return next();
    }
    return res.status(400).json({error: "Token invalid"});
});

// Index
app.all("/", ({res}) => res.send("index"))

// Restart Services
app.post("/restart", async (req, res) => {
    const Service = req.body.Service || "all";
    try {
        if (Service.toLocaleLowerCase() === "all") await restartServices()
        else if (/ssh[dD]/.test(Service.toLocaleLowerCase())) await restartServices("sshd");

        return res.json({
            Service
        });
    } catch (err) {
        console.log(err);
        return res.status(400).send("Back end error");
    }
});

app.post("/Config/Set", async (req, res) => {
    const ProgramS = (req.body.Program || "").split("\n").map(a=>a.toLocaleLowerCase());
    const ConfigObject = JSON.parse(req.body.ConfigObject || "{}");
    const ReturnArray = [];
    try {
        for (let Program of ProgramS) {
            // OpenSSH
            if (/ssh/.test(Program)) {
                const SshdConfig = [
                    "ChallengeResponseAuthentication no",
                    "UsePAM yes",
                    "X11Forwarding yes",
                    "PrintMotd no",
                    "AcceptEnv LANG LC_*",
                    "Subsystem sftp  /usr/lib/openssh/sftp-server",
                    "ClientAliveInterval 120",
                    "PasswordAuthentication yes",
                    "PermitTunnel yes",
                    "#Banner /etc/ssh/banner.html",
                ]
                
                // Banner
                if (ConfigObject.SshBanner) {
                    fs.writeFileSync("/etc/ssh/Banner", ConfigObject.SshBanner);
                    SshdConfig.push("Banner /etc/ssh/Banner")
                }

                // Port
                if (ConfigObject.SshPort)
                    for (let port of ConfigObject.SshPort)
                        SshdConfig.push(`Port ${port}`);
                else
                    SshdConfig.push("Port 22");
                fs.writeFileSync("/etc/ssh/sshd_config", SshdConfig.join("\n"));
                await restartServices("ssh");
                await restartServices("sshd");
                ReturnArray.push({
                    status: "ok",
                    Program: "OpenSsh",
                    config: SshdConfig
                })
            }
            // Dropbear
            else if (/dropbear/.test(Program)) {
                var DropbearExportDefault, DropbearExport="";
                for (let DropbearPort of config.DropebearPorts)
                    if (DropbearExportDefault) DropbearExportDefault = DropbearPort;
                    else DropbearExport += `-p ${DropbearPort} `;
                const DropebearConfig = [
                    "NO_START=0",
                    `DROPBEAR_PORT=${DropbearExportDefault}`,
                    `DROPBEAR_EXTRA_ARGS="${DropbearExport}"`,
                    "DROPBEAR_RECEIVE_WINDOW=65536",
                ]
                // Banner
                if (ConfigObject.DropebearBanner) {
                    fs.writeFileSync("/home/Banner", ConfigObject.DropebearBanner);
                    SshdConfig.push("DROPBEAR_BANNER=\"/home/Banner\"")
                }
                writeFileSync("/etc/default/dropbear", DropebearConfig.join("\n"));
                await restartServices("dropbear");
                ReturnArray.push({
                    status: "ok",
                    Program: "Dropbear",
                    config: DropebearConfig
                })
            }
            // Squid
            else if (/squid/.test(Program)) {
                const SquidConfig = [
                    "acl all src 0.0.0.0/0 ::/0",
                    "",
                    "acl blockdomains dstdomain \"/etc/squid/Block.conf\"",
                    "",
                    "# Allow",
                    "http_access allow all",
                    "",
                    "# Deny",
                    "http_access deny blockdomains",
                    "",
                    "# Options",
                    "visible_hostname Docker",
                    "via off",
                    "forwarded_for off",
                    "pipeline_prefetch off",
                ]
                // Port
                if (ConfigObject.SquidPort) {
                    for (let port of ConfigObject.SquidPort) SquidConfig.push(`http_port ${port}`);
                }

                // Block Domains
                // if (ConfigObject.SquidBlockDomains) {
                // 
                // }
                
                writeFileSync("/etc/squid/squid.conf", SquidConfig.join("\n"))
                await restartServices("squid");
                ReturnArray.push({
                    status: "ok",
                    Program: "Squid",
                    config: SquidConfig
                })
            }
        }
        return res.json(ReturnArray)
    } catch (err) {
        console.log(err);
        return res.status(400).send("Back-end Error")
    }
});

// Exports
app.all("*", ({res})=>res.sendStatus(404))
module.exports = app;