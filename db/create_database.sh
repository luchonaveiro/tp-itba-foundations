#!/bin/bash

echo 'Creating database...'
psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -f init.sql
echo 'Database created!'

