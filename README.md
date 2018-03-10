# Introduction

Tools to develop barrelfish

- build.sh

Util to build barrelfish in docker container

- cpbin.sh

Create a chroot environment to build barrelfish user space programs

- env.sh

Use this with cpbin.sh. Execute this in chroot env. This will export necessary environment variables into env.


# Prerequisite

zsh, docker

# Usage

## Use build.sh

__All following command may need sudo priviledge if your account is not in docker group__

1. Create barrelfish develop docker image.
```bash
# may need sudo!
./build.sh docker build
```

2. Start a docker container
```bash
# you should change following line according to your barrelfish source position.
export BARRELFISH_SOURCE_ROOT=/home/xxx/projects/barrelfish
./build.sh docker run $BARRELFISH_SOURCE_ROOT
```

3. Run hake in container

    - Firstly, see which suites are available

        ```bash
        ./build.sh hake
        ```

        This will print following

        ---
            please set variable "S" as one of the following suite
            suite-name: vexpress
                    arch: armv7
                    plat: VExpressEMM-A15
                    build-dir: buildvexpress
            suite-name: x86_64
                    arch: x86_64
                    plat: X86_64_Full
                    build-dir: buildx86_64
        ---

        You can add the suite you need by editing the add_suites function in build.sh.

    - Then, select a suite and run build command

        ```bash
        # sudo -s if needed
        S=x86_64 ./build.sh hake
        S=x86_64 ./build.sh make
        ```
        make will use -j 4 flag for concurrency.

    - Finally, run the image in qemu

        ```bash
        S=x86_64 ./build.sh run
        ```

4. Addition
    
    If you want to build documentation of barrelfish, do following.
    ```bash
    # sudo -s if needed
    ./build.sh cd  # bring up a shell in docker container
    apt install latex*
    cd /barrelfish/build-*
    make Documentations
    ```

    You can use build.sh to find a struct definition in source code.
    ```bash
    ./build.sh fs dispatcher
    ```

## Use cpbin.sh and env.sh

It's very simple to use these tools.

```bash
# edit root in cpbin.sh
./cpbin.sh
# then execute env.sh in chroot env
```