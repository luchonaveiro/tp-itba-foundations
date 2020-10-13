#!/bin/bash

echo 'Creating database...'
psql -h pg-docker -U postgres -d postgres -f init.sql
echo 'Database created!'

