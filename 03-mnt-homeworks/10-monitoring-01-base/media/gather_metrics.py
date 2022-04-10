#!/usr/bin/env python3

from datetime import datetime
import json 
import re

cur_datetime = datetime.now()
cur_date = cur_datetime.strftime("%Y-%m-%d")
cur_timestamp = cur_datetime.strftime("%s")
metcirs_log = f"/var/log/{cur_date}-awesome-monitoring.log"


def cpu_info():

    cpu_info = {
        "cpu_percent_load": 0,
        "load_average_minute": 0,
        "running_processes": 0,
        "total_processes": 0
    }

    # Количество потоков процессора
    # /proc/cpuinfo
    with open('/proc/cpuinfo', 'r') as f:
        number_of_cpus = float(0)
        for string in f:
            counter = re.match(r'^processor[\s]*\:[\s]*\d', string)
            if counter:
                number_of_cpus += 1

    # Load Average
    # /proc/loadavg
    with open('/proc/loadavg', 'r') as f:
        for string in f:
            la_1m, la_5m, la_15m, proc_info, newest_pid = string.split(' ')
            running_processes, total_processes = proc_info.split('/')

    cpu_info['running_processes'] = int(running_processes)
    cpu_info['total_processes'] = int(total_processes)
    cpu_info['load_average_minute'] = float(la_1m)
    cpu_info['cpu_percent_load'] = \
        int(float(cpu_info['load_average_minute'])/number_of_cpus*100)

    return cpu_info


def mem_info():
    mem_info = {
        "mem_total": 0,
        "mem_free": 0,
        "mem_available":0,
        "swap_total": 0,
        "swap_free": 0
    }
    return mem_info


def disk_info():
    # "/proc/diskstats"
    pass

def net_info():
    # "/proc/net/dev"
    pass

def main():

    # Записать таймстемп
    export_data = {"timestamp": cur_timestamp}
    # Добавить данные по системе
    export_data = {**export_data, **cpu_info(), **mem_info()}

    # Для дебага - лог в текущей директории
    metcirs_log = f"./{cur_date}-awesome-monitoring.log"

    # Записываем в файл
    with open(metcirs_log, 'a') as f:
        f.write(json.dumps(export_data))
        f.write('\n')


if __name__ == "__main__":
    main()
