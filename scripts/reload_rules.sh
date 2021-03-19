#!/bin/bash
# The unix socket is always enabled by default; you need to have JSON support in Python
sudo suricatasc -c reload-rules
