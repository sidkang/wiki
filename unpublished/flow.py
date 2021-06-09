import time
import os

thefile = '/var/log/syslog'

def follow(thefile):
    thefile.seek(0, os.SEEK_END)
    while True:
        line = thefile.readline()
        if not line:
            time.sleep(0.05)
            continue
        yield line


if __name__ == '__main__':
    logfile = open("/var/log/syslog","r")
    loglines = follow(logfile)
    for line in loglines:
        if 'ssserver' in line:
            print(line, end='')
            
            
## REF
## http://www.dabeaz.com/generators/
## https://github.com/dabeaz/generators