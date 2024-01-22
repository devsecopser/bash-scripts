#!/bin/bash

if ! [ -d ./ssl ]; then mkdir ./ssl; fi;

openssl \
    req \
    -new \
    -nodes \
    -days 365 \
    -x509 \
    -newkey rsa:4096 \
    -keyout ./ssl/cert.key \
    -out ./ssl/cert.crt \
    -subj "/CN=vault.example.com" \
    -addext "subjectAltName = DNS:vault.example.com,IP:10.1.0.10"

