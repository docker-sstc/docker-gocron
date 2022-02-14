#!/bin/sh -e

NAME="Root CA"
YEARS=99
if [ -n "$1" ]; then
	NODE_IP="$1"
	./certstrap request-cert --ip $NODE_IP --common-name $NODE_IP --passphrase ""
	./certstrap sign --CA "$NAME" --years $YEARS $NODE_IP
	exit 0
fi
./certstrap init --common-name "$NAME" --years $YEARS --passphrase ""
./certstrap request-cert --ip 127.0.0.1 --common-name 127.0.0.1 --passphrase ""
./certstrap sign --CA "$NAME" --years $YEARS 127.0.0.1
