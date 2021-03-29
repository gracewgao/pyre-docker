### About

[pyre-check](https://github.com/facebook/pyre-check) is an open source tool developed and maintained by Facebook to perform Static Code Analysis (SCA) on Python applications. 

This Docker image builds pyre-check from source for a **quicker & painless setup** (especially on systems that are not yet officially supported)!

It runs [Debian GNU/Linux 10 (buster)](https://www.debian.org/) and has been tested on the Apple M1.

### Development Setup

Before starting, ensure that [Docker](https://docs.docker.com/get-docker/) is installed on your computer.

1. Clone this repository and navigate into it 
    ```bash 
    git clone https://github.com/gracewgao/pyre-docker
    cd pyre-docker
    ```

2. Build the Docker image with the tag `pyre-check` (or another tag if you wish)
   ```bash
   docker build -t pyre-docker .
   ```   

3. Run the new image in a new container `pyre-container` (or another name if you wish)
   ```bash
   docker run \                           
   --name pyre-container \
   -v /path/to/your/directory:/src \
   -t -i \
   pyre-check /bin/bash
   ```

4. Inside the container, run any pyre-check command now with `pyre`!

### Contributing

Feel free to report any bugs or installation errors that you find!