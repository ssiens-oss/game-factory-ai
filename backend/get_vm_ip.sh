#!/usr/bin/env bash

virsh domifaddr win11 \
  | grep ipv4 \
  | awk '{print $4}' \
  | cut -d'/' -f1
