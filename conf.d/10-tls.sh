#!/bin/bash

TLS_CA_NAME="$CLUSTER_NAME CA"
TLS_CA_DAYS=3650
TLS_SERVER_DAYS=3650
## We're starting off with 2048 for now just because everything supports it, but you might want to give 4096 a try and see if anything breaks
TLS_CA_RSA_BITS=2048
TLS_SERVER_RSA_BITS=2048
## In the TLS section we'll generate and copy this file to every node
TLS_CA_CERT=/etc/ssl/${CLUSTER_NAME}-ca.crt
