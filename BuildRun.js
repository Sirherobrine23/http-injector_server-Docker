console.warn("Starting image build");
const {exec, execSync} = require("child_process")
const ports_options = "-p 2242:22",
    variasbles = `-e ADMIN_USERNAME="${process.env.USERNAME}" -e ADMIN_PASSWORD="${process.env.PASSWORLD}"`;
var mounts = ``;
var docker_options = `--no-cache `
const path = require("path")
var docker_builder_c = "docker build . -t test/http_injector:latest",
    docker_run_c = `docker run -d --rm --name http_injector ${ports_options} ${mounts} ${variasbles} test/http_injector:latest`
function output(data){
    //if (data.slice(-1) == "\n") data = data.slice(0, -1)
    console.log(data)
}
const logs = execSync("docker ps").toString()
const logs2 = execSync("docker ps --all").toString()
if (logs.includes("http_injector")) console.log(execSync("docker stop http_injector").toString())
else if (logs2.includes("http_injector")) console.log(execSync("docker rm http_injector").toString())
console.warn(`Docker Run Optins: ${ports_options}, ${variasbles}, ${mounts}, ${docker_options}`)
var build = exec(docker_builder_c)
build.stdout.on("data", function(data){output(data)})
build.on("exit", (code) => {
    if (code === 0){
        var run = exec(docker_run_c)
        run.stdout.on("data", function (data) {output(data)})
        run.on("exit", function (code){
            if (code === 0){
                const docker_log = exec("docker logs -f http_injector")
                docker_log.stdout.on("data", function (data){output(data)})
                
            } else {
                console.error("We were unable to run the docker image, run it manually with the following command: "+docker_run_c.replace("run -d ", "run "))
                process.exit(code)
            }
        })
    } else {
        console.error("We were unable to create the image of the docker, Run the following command in the terminal: "+docker_builder_c)
        process.exit(code)
    }
})