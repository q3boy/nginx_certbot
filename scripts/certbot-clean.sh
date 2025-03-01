#!/bin/bash

cd /etc/letsencrypt/live/

rm -rf *

cd /etc/letsencrypt/archive/

rm -rf *

cd /etc/letsencrypt/renewal/

rm -rf *
