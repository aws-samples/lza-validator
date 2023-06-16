#!/bin/sh
set -e

cd source
yarn validate-config $1
