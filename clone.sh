#!/bin/sh

echo "Cloning repositories..."

SITES=$HOME/Sites

# Private
git clone git@github.com:christophrumpel/laravelcoreadventures.git  $SITES/laravelcoreadventures
git clone git@github.com:christophrumpel/christoph-rumpel.com.git $SITES/christophrumpel
git clone git@github.com:christophrumpel/masteringphpstorm.git $SITES/masteringphpstorm
git clone git@github.com:tatundkraft/onyx-jobboard.git $SITES/Clients/tatundkraft/onyx.jobboard
git clone git@github.com:christophrumpel/larastreamers.git $SITES/larastreamers

