#!/bin/bash

gocron web &
gocron-node &
wait -n
exit $?
