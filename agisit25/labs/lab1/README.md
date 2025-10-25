<a href="https://dei.tecnico.ulisboa.pt/"><img style="float: right;" src="../../res/logodei.png"></a>

# Lab 1 - Environment Setup

## Overview and Lab Assessments
This first lab script is very simple: its goal is to install some basic tools that you will need in this course and to illustrate how they can be used to create local infrastructure in an automated way.

Subsequent labs describe more complex experiments and build on the tools you will be using today. Starting from Lab 2, labs will also include an assessment to be answered until the end of the week ([check all deadlines](../../README.md)). Lab assessments are individual and will be done through [Moodle](https://moodle.dei.tecnico.ulisboa.pt/). Each assessment consists of questions to be answered based on the lab experiments, the knowledge gained from them, and how it relates to lectures. There will be 6 assessments in total:

- Lab 1 will **not** be considered for the evaluation. It is provided to help you familiarize with Moodle and the evaluation process;

- Lab 2-6 will be considered for evaluation but we only count the **best 4** (i.e., you can skip one lab assessment without any penalty). The evarage of the best 4 assessments corresponds to 50% of your final grade in the course;

Lab experiments can be conducted on your own personal computer or on Lab desktops. Access to a public cloud, necessary for upcomming labs will also be provided.

Use lab classes to get support for solving exercises in which you had problems. **Going to the lab classes to read the lab tutorials for the first time and to see what is there to be done, without reading the script first, is discouraged.**

The Capstone Project, to be executed throughout the course, will provide the remaining 50% of the final evaluation grade. The corresponding deliverable should be submitted to Fenix before the end of the quarter ([check instructions](../../project)).

## BYOD (Bring Your Own Device) Lab Environment Preparation
One nice feature of the software stack you are going to use for the Lab experiments and in the Capstone Project is that it is portable to many platforms including YOUR OWN personal computers.

The instructions below will help you to configure your Laptop or Desktop properly, and are suitable for machines running the following Operating Systems:

- Microsoft Windows
- Apple macOS
- Debian-based Linux, such as Ubuntu (recommended).

For other computing environments or Operating Systems, you should be able to make the necessary adaptations to arrive at the desired software stack. Although you could also use a Raspberry Pi 4, that is not advisable 😂.

For the aforementioned Operating Systems, the setup makes use of package managers in order to keep the entire process clean, simple, and reproducible.

**Note 1:** Beware that when copying text strings from the command line examples or configuration texts and pasting them directly into your system or files may introduce/modify some characters, leading to errors or inadequate results.

**Note 2:** It is also possible to use the lab Desktops as the same software that we will be setting up in this lab tutorial is already installed.

## Setting up the Environment
In this course, we will always work in a Unix-based enviroment. This means that for Windows users, you need to set up the Windows Subsystem for Linux (WSL). You can follow the [instructions](https://learn.microsoft.com/en-us/windows/wsl/install) on how to install WSL on your system. We recomend you install the `Ubuntu` image.

Once you have your Unix-based environemt ready, go ahead and update the package manager, install `git`, and checkout [AGISIT's repo](https://gitlab.rnl.tecnico.ulisboa.pt/agisit/agisit25).

```
apt update
apt install git
git clone https://gitlab.rnl.tecnico.ulisboa.pt/agisit/agisit25.git
Cloning into 'agisit25'...
Username for 'https://gitlab.rnl.tecnico.ulisboa.pt': <ist_id>
Password for 'https://<ist_id>@gitlab.rnl.tecnico.ulisboa.pt': <ist_id_password>
```

The second main requirements for our lab environment is to have [Docker](https://www.docker.com/) installed. Docker is one application containarization solution built on Linux namespaces, cgroups, and chroots. You will learn more about it in lectures but for this lab, we will need it to launch applications in containers!

The instructions to install Docker differ slitghly depending on your host OS. You can find instructions in the [Get Docker Desktop](https://docs.docker.com/get-started/introduction/get-docker-desktop/) tutorial.

## Creating (your first ?) Docker Containers

Let's start by running a `Hello world!` echo inside a container:

```
> docker run --rm ubuntu echo "Hello world!"
Hello world!
```

It works, nice! Let's analyze the command to understand what really happened:
    - `docker run` launches the program `docker` with the command `run`. Everything after `run` are arguments passed down to the `run` command. To inspect all the possible options try running `> man docker-run`;
    - `--rm` tells docker to delete away the container after it finishes (we will learn more about this later). When unsure, always add this option to avoid old containers being left behind;
    - `ubuntu` corresponds to the container image that Docker should use. There are many images that can be used and even different versions of ubuntu in [docker hub](https://hub.docker.com/_/ubuntu);
    - `echo Hello World!` is the command that you issued already inside the container.

What if instead of running a single command, you wanted to open a session in the container, similar to what you would have if you logged into a remote machine with `ssh`? Well, then we just need to add `-it` to tell Docker to launch an interactive session and remove the `echo` command:

```
> docker run -it --rm ubuntu
root@a4bedef0b941:/# echo "Hello world!
Hello world!
root@a4bedef0b941:/# exit
```

Amazing! See how you were given `root` inside the container and that you were running inside a container with id `a4bedef0b941`.

## Stateless and Stateful Containers

Let's run the follow:

```
> docker run --rm ubuntu ls -l /tmp
total 0
> docker run --rm ubuntu touch /tmp/new_file
> docker run --rm ubuntu ls -l /tmp
total 0
```

What? Did you see what happened here? The changes we make are being lost after each command because we are not persisting the container. If you need to persist changes, then we need to create a container without the `--rm` option so that we can start it later again. For example:

```
> docker run -it --name my_ubuntu_container ubuntu
root@0a8bfb38ce76:/# ls -l /tmp
total 0
root@0a8bfb38ce76:/# touch /tmp/new_file
root@0a8bfb38ce76:/# ls -l /tmp
total 0
-rw-r--r-- 1 root root 0 Jul  9 12:24 new_file
root@0a8bfb38ce76:/# exit
```

 So far we've created a container, touched a new file, and existed. Let's try to start the container and check that the file is still there.

 ```
 docker start -i -a my_ubuntu_container
 root@0a8bfb38ce76:/# ls -l /tmp
total 0
-rw-r--r-- 1 root root 0 Jul  9 12:24 new_file
root@0a8bfb38ce76:/# exit
 ```

Still there! Curious about the `-i` and `-a` options? Check `man docker-start`. If you want to delete the container you can just use `docker rm`:

```
docker rm my_ubuntu_container
```

An alternative to keeping stateful containers around is to attach shared/mounted directories, i.e., directories that are shared between the host and the container. This can be useful to let the container access code and/or data. For instance, you can have your IDE running on the host and having the container compile and run your application.

Let's see how we can mount a volume inside a container:

```
> mkdir my_shared_dir
> touch my_shared_dir/my_shared_file
> docker run -it --rm ubuntu ls /tmp/
total 0
docker run -it --rm -v $PWD/my_shared_dir:/tmp/my_shared_dir ubuntu find /tmp
/tmp
/tmp/my_shared_dir
/tmp/my_shared_dir/my_shared_file
```

By using volumes you can keep all state outside the container and thus, always dispose containers.

## Building a Docker Image

Finally, imagine that on top of a bare Ubuntu container image, you need to install several packages in order for your application to work. What are our options?
    - share the binaries between the host and the container so that we you don't have to install anything;
    - have a script that runs every time we start the container;
    - prepare a Docker image;

Think about the pros and cons of each solution.

Let's assume that we want to create a Docker image that contains `python` so that we can start the container and don't worry about anything else. Note: there are Docker images that include `python` already but for the purpose of this tutorial, we will prepare one ourselves.

Read the following Dockerfile and try to understand what is happening:

```
> cat Dockerfile
# Use the official Ubuntu base image
FROM ubuntu:latest

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install Python and pip
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set python3 as the default python
RUN ln -s /usr/bin/python3 /usr/bin/python
```

This file describes a recipe to create a Docker image: it describes the starting image (`Ubuntu`), sets environment variables, runs the package manager to install python, and sets the default working directory and command. The next step is to copy-paste the previous code into a file named `Dockerfile`, and build the actual image:

```
> docker build -t my-python-image .
[+] Building 26.6s (8/8)
 => [internal] load build definition from Dockerfile
 => => transferring dockerfile: 536B
 => [internal] load metadata for docker.io/library/ubuntu:latest
 => [internal] load .dockerignore
 => => transferring context: 2B
 => [1/4] FROM docker.io/library/ubuntu:latest
 => [2/4] RUN apt-get update && apt-get install -y python3 python3-pip && apt-get clean && rm -rf /var/lib/apt/lists/*
 => [3/4] RUN ln -s /usr/bin/python3 /usr/bin/python
 => [4/4] WORKDIR /app
 => exporting to image
 => => exporting layers
 => => writing image sha256:cbc06da033b68c8eb04e46f3abbc152bcd8f3be8781556d77c0ac0ef7771c40d
 => => naming to docker.io/library/my-python-image
```

Cool! Let's see if it works:

```
> docker run --rm -it my-python-image python
Python 3.12.3 (main, Jun 18 2025, 17:59:45) [GCC 13.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>>
```

Nice! Just as a sanity check, what if we try to do the same but with the `ubuntu` image:

```
> docker run --rm -it ubuntu python
docker: Error response from daemon: failed to create task for container: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: exec: "python": executable file not found in $PATH: unknown.
```

Right... It fails, as expected :-)

## DIY: Do In Yourself

As an exercise to do onw your own, try to set up a simple website. For example, use [NGINX](https://nginx.org/) as a webserver and use an HTML page with some static content. Try the following steps:
- start with an NGINX image, i.e., a docker image that already containers NGINX. Launch it and see that it works;
- start with the Ubuntu image and install NGINX;
- try to host the webpage source from the host in a shared volume;
- finally, copy the webpage source into the Docker image at Docker image built time.

Tip: we didn't discuss networking. There are two easy options that you should investigate: a) running a container in the host network and b) port mapping. You should check the documentation to learn a bit more about [Docker networks](https://docs.docker.com/engine/network/). We will come back to this topic in the next lab.