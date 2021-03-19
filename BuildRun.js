console.warn("Starting image build");
const path = require("path")
const {exec, execSync} = require("child_process")
const ports_options = "-p 2233:22/tcp -p 10086:10086/udp -p 1723:1723/tcp -p 1792:1792/tcp",
    variasbles = `-e ADMIN_USERNAME="${process.env.USERNAME}" -e ADMIN_PASSWORD="${process.env.PASSWORLD}"`,
    // docker_options = `--privileged`,
    docker_name = {
        name: "http_injector",
        docker: "http_injector:latest"
    };
// console.log(execSync(`docker stop  $(docker ps -a |grep -v 'CONTAINER'|awk '{print $1}')`).toString());
execSync(`konsole -e docker build . -t ${docker_name.docker}`)
console.log(`Running the image`);
execSync(`konsole --noclose -e "docker run -ti --rm --privileged --name ${docker_name.name} ${variasbles} ${ports_options} ${docker_name.docker}"`)