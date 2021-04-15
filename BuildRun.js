const { resolve } = require("path")
const { execSync } = require("child_process");
const { readFileSync } = require("fs");

let DockerConfig = JSON.parse(readFileSync(resolve(__dirname, "docker_config.json"), "utf8"))

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

console.log("Creating the Image");
let build_command = `docker build . -f ${DockerConfig.dockerfile} -t ${DockerConfig.docker_image}`;
console.log(build_command);
execSync(`konsole -e "${build_command}"`);

var CheckDocker = execSync("docker ps -a").toString()
CheckDocker = CheckDocker.split(/\r?\n/g)
for (let dockerId of CheckDocker){
    if (dockerId.includes(DockerConfig.docker_image)){
        dockerId = dockerId.split(" ");
        console.log(dockerId);
        console.log(execSync(`docker stop ${dockerId[0]}`));
    } else if (dockerId.includes(DockerConfig.name)){
        dockerId = dockerId.split(" ");
        console.log(dockerId);
        console.log(execSync(`docker stop ${dockerId[0]}`));
    }
}

console.log(`Running the image`);
let commadRun = `docker run -ti --rm ${optionsExport} --name ${DockerConfig.name} ${mountExport} ${portsExport} ${envExport} ${DockerConfig.docker_image}`;
console.log(commadRun);
execSync(`konsole --noclose -e '${commadRun}'`);