console.warn("Starting image build");
const path = require("path")
const {exec, execSync} = require("child_process")
const ports_options = "-p 2222:22/tcp",
    variasbles = `-e ADMIN_USERNAME="${process.env.USERNAME}" -e ADMIN_PASSWORD="${process.env.PASSWORLD}"`,
    mounts = ``,
    docker_options = ``,
    // docker_options = `--privileged`,
    docker_name = {
        name: "http_injector",
        docker: "test/http_injector:latest"
    };
var docker_builder_c = `konsole -e docker build . -t ${docker_name.docker}`,
    docker_run_c = `konsole -e "docker run -ti --rm ${docker_options} --name ${docker_name.name} ${ports_options} ${mounts} ${variasbles} ${docker_name.docker}"`
function output(data){
    //if (data.slice(-1) == "\n") data = data.slice(0, -1)
    console.log(data)
}
if (execSync("docker ps -a").toString().includes(docker_name.name)) execSync(`konsole -e docker stop -f ${docker_name.name};konsole -e docker rm -f ${docker_name.name}; read Null`).toString()
const build = exec(docker_builder_c)
console.warn(docker_builder_c)
build.stdout.on("data", function(data){output(data)})
build.on("exit", (code) => {
    if (code === 0){

        console.warn(docker_run_c);
        const run = exec(docker_run_c)
        run.stdout.on("data", function (data) {output(data)})
        run.on("exit", function (code){
            if (code !== 0){
                if (execSync("docker ps -a").toString().includes(docker_name.name)) execSync(`konsole -e docker stop -f ${docker_name.name};konsole -e docker rm -f ${docker_name.name}; read Null`).toString()
            }
        })
    } else {
        console.error("We were unable to create the image of the docker, Run the following command in the terminal: "+docker_builder_c)
        process.exit(code)
    }
})