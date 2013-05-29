#!/usr/bin/env sh
plackup -E production -s Starman --workers=10 --port 12345 -a Munge-App/bin/app.pl
