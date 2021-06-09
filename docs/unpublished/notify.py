import time
import subprocess
import select
import re

f = subprocess.Popen(['tail','-F','/var/sys/log'], \
        stdout=subprocess.PIPE,stderr=subprocess.PIPE)
p = select.poll()
p.register(f.stdout)

while True:
    if p.poll(1):
        print f.stdout.readline()
        print('done\n\n')
    time.sleep(1)








import subprocess, re
def tail_and_quit(filename, regex_to_match):
    try:
        f = subprocess.Popen(['tail', '-F', filename], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        while True:
            line = f.stdout.readline()
            match = re.search(regex_to_match, line)
            if match: break
    finally: f.kill()