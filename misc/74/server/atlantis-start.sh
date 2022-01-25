# адрес сервера атлантиса, публичный, чтобы до него мог достучаться GitHub
# если нет возможности сделать, можно запустить локально и использовать ngrok 
# https://www.runatlantis.io/guide/testing-locally.html#download-ngrok
URL="" 
# рандомная строка
# https://www.runatlantis.io/docs/webhook-secrets.html
SECRET=""
# токен профиля на github, дока ка получить:
# https://www.runatlantis.io/docs/access-credentials.html
TOKEN=""
# имя пользователя (не login !!!!) на github
# например, https://github/my_username/my_repo <- my_username
USERNAME=""
# корень репозитория, в котором хранится конфиг инфтраструктуры
REPO_ALLOWLIST="github.com/run0ut/terraform-aws-74"
# путь к конфигу Atlantis https://www.runatlantis.io/docs/server-side-repo-config.html
REPO_CONFIG="/home/sergey/git/devops-netology/misc/74/server/server.yaml"
# Запуск сервера
./atlantis server \
    --atlantis-url="$URL" \
    --gh-user="$USERNAME" \
    --gh-token="$TOKEN" \
    --gh-webhook-secret="$SECRET" \
    --repo-allowlist="$REPO_ALLOWLIST" \
    --repo-config="$REPO_CONFIG" \
    --disable-repo-locking # <- чтобы не вешать локи Атлантиса
