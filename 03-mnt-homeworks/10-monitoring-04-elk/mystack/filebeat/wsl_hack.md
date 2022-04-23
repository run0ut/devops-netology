[Solution to get container's logs inside WSL and mount into filebeat executed inside docker inside WSL](https://github.com/microsoft/WSL/discussions/4176#discussioncomment-253018)

1. In windows:
    ```cmd
    net use w: \\wsl$\docker-desktop-data
    ```
1. In WSL2
    ```bash
    sudo mkdir /mnt/w
    sudo mount -t drvfs w: /mnt/w
    ls /mnt/w
    ```
1. Mount volume into container. For example. for docker-compose that would be:
    ```yml
        volumes:
          - "/mnt/w/version-pack-data/community/docker/containers:/var/lib/docker/containers:ro"
    ```