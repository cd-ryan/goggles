#!/usr/bin/env python3

import re
import subprocess
import sys

try:
    response = subprocess.check_output([
        'curl', 
        'https://raw.githubusercontent.com/allsides-news/brave-goggles/main/right.goggles'],
        stderr=subprocess.DEVNULL)
except subprocess.CalledProcessError:
    sys.stderr.write('unable to download right.goggles\nis curl installed?')
    raise

response = str(response.decode('utf-8')) if isinstance(response, bytes) else str(response)
for line in response.split('\n'):
    if re.search(r'^!\s*', line) or not line.strip():  # skip comments or blank lines
        continue
    print(re.sub(r'\$boost(=[0-9]+)?', '$discard', line))  # replace $boost lines with $discard

