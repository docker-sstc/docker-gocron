#!/bin/bash

cd /gocron
./gocron web &
./gocron-node -allow-root &
wait -n
exit $?
