#!/bin/sh

echo "Cloning repositories..."

SITES=$HOME/Sites

# Private
git clone git@github.com:christophrumpel/laravelcoreadventures.git  $SITES/laravelcoreadventures
git clone git@github.com:christophrumpel/christoph-rumpel.com.git $SITES/christophrumpel

