#!/usr/bin/env bash

# простой скрипт, в основном чтобы не забыть команду переключения неймспейса у текущего контекста
declare NS=${1:-no_arg}
case $NS in
    "stage"|"prod")
        kubectl create namespace $NS
        kubectl config set-context --current --namespace=$NS
        ;;
    "default")
        kubectl config set-context --current --namespace=$NS
        ;;
    *)
        echo "Введите stage, prod или default"
        ;;
esac