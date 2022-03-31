# Gitlab Runner

Gitlab просит указать данные банковской карты, чтобы использовать "общественные" раннеры, но в данный момент это не возможно для России. Ранера можно запустить собственного, и для этого я решил использовать Docker.

1. [Сначала нужно запустить ранер](https://docs.gitlab.com/runner/install/docker.html#option-1-use-local-system-volume-mounts-to-start-the-runner-container)

    ```bash
    docker run --privileged -d --name gitlab-runner --restart always -v $(pwd)/config:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock gitlab/gitlab-runner:latest
    ```

2. [Потом зарегистрировать](https://docs.gitlab.com/runner/register/index.html#docker)

    ```bash
    docker run --rm -it -v $(pwd)/config:/etc/gitlab-runner gitlab/gitlab-runner register
    ```
## Возможные ошибки 

### tcp: lookup docker on 8.8.4.4:53: no such host

Для решения, в конфиг ранера `config.toml` нужно добавить `volumes = ["/cache","/var/run/docker.sock:/var/run/docker.sock"]`, например:

`config.toml`
```toml
concurrent = 1
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "netology-96"
  url = "https://gitlab.com/"
  token = "supersecrettoken"
  executor = "docker"
  [runners.custom_build_dir]
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    tls_verify = false
    image = "docker:20.10.5-dind"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache","/var/run/docker.sock:/var/run/docker.sock"]
    shm_size = 0
```
