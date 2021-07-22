const { resolve } = require("path")
const { execSync, exec, spawnSync } = require("child_process");
const { readFileSync, createWriteStream } = require("fs");
const { writeFileSync } = require("node:fs");
const { exit } = process;

var DockerConfig;
let DockerConfigFile = resolve(__dirname, "docker_config.json");
DockerConfig = JSON.parse(readFileSync(DockerConfigFile, "utf8"))

var portsExport="";
for (let ports of DockerConfig.ports){
    portsExport += `-p ${(ports.external||ports.port)}:${ports.port}/${(ports.protocoll||"tcp")} `
}

var mountExport="";
for (let mounts of DockerConfig.mounts){
    mountExport += `-v ${resolve(mounts.from)}:${mounts.path} `
}

var envExport="";
for (let envs of DockerConfig.env){
    envExport += `-e ${envs.name}="${envs.value}" `
}

var optionsExport="";
for (let options of DockerConfig.options){
    optionsExport += `${options} `
}

console.log("Checking and stopping");
var CheckDocker = execSync("docker ps -a").toString()
CheckDocker = CheckDocker.split(/\r?\n/g)
for (let dockerId of CheckDocker){
    const arrayDocker = dockerId.trim().split(/\s+/)
    console.log(arrayDocker);
    if (dockerId.includes(DockerConfig.docker_image)||dockerId.includes(DockerConfig.name)) {
        console.log(`Docker Container ID: ${arrayDocker[0]}`);
        try {
            let Status = execSync(`docker stop ${arrayDocker[0]}`).toString()
            console.log(Status);
        } catch (error) {
            console.log(error);
        }
    }
}

var docker = execSync("docker image ls").toString().split(/\r?\n/g)
for (let dockerImage of docker){
    if (dockerImage.includes(DockerConfig.docker_image)) {
        dockerImage = dockerImage.trim().split(/\s+/)
        console.log(dockerImage);
        console.log(spawnSync(`docker rmi ${dockerImage[2]}`));
    }
}

console.log("Creating the Image");
let build_command = `docker build ${resolve(__dirname)} -f ${DockerConfig.dockerfile} -t ${DockerConfig.docker_image}`;
console.log(`Command to build: ${build_command}`);
writeFileSync(resolve(__dirname, "DockerBuildRun.log"), "")
const build = exec(build_command);
build.stdout.on("data", (data) => {if (data.slice(-1) === "" || data.slice(-1) === "\n") data = data.slice(0, -1);console.log(data);})
build.stderr.on("data", (data) => {if (data.slice(-1) === "" || data.slice(-1) === "\n") data = data.slice(0, -1);console.log(data);})
build.stdout.pipe(createWriteStream(resolve(__dirname, "DockerBuildRun.log"), {flags: "a"}))
build.stderr.pipe(createWriteStream(resolve(__dirname, "DockerBuildRun.log"), {flags: "a"}))

build.on("exit", function(code){
    if (code === 0){
        console.log("\n");
        console.log("\n");
        console.log("Running the image");
        var name = "";if (DockerConfig.name) name = `--name ${DockerConfig.name}`;
        const commadRun = `docker run --rm ${optionsExport} ${name} ${mountExport} ${portsExport} ${envExport} ${DockerConfig.docker_image}`.trim().split(/\s+/).join(" ");
        console.log(`Command run: ${commadRun}`);
        
        const run = exec(commadRun);
        run.stdout.on("data", (data) => {if (data.slice(-1) === "" || data.slice(-1) === "\n") data = data.slice(0, -1);console.log(data)});
        run.stderr.on("data", (data) => {if (data.slice(-1) === "" || data.slice(-1) === "\n") data = data.slice(0, -1);console.log(data)});
        run.stdout.pipe(createWriteStream(resolve(__dirname, "DockerBuildRun.log"), {flags: "a"}));
        run.stderr.pipe(createWriteStream(resolve(__dirname, "DockerBuildRun.log"), {flags: "a"}));
        run.on("exit", code => process.exit(code));
    } else exit(1)
})