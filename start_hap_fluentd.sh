#!/bin/bash

HAPI_AMQP_PASSWORD=hatohol /usr/libexec/hatohol/hap2/hatohol/hap2_fluentd.py --amqp-broker localhost --amqp-vhost hatohol --amqp-queue test --amqp-user hatohol --fluentd-launch "td-agent -c ~/azure_trapper/Azure-reader.conf -q"
