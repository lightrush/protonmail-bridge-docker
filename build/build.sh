#!/bin/bash

set -ex

VERSION=`cat VERSION`

# Clone new code
git clone https://github.com/ProtonMail/proton-bridge.git
cd proton-bridge
git checkout v$VERSION

ARCH=$(uname -m)
if [[ $ARCH == "armv7l" ]] ; then
	# This is expected to fail, and we use the following patch to fix
	make build-nogui || true
	# For 32bit architectures, there was a overflow error on the parser
	# This is a workaround for this problem found at:
	#   https://github.com/antlr/antlr4/issues/2433#issuecomment-774514106
	find $(go env GOPATH)/pkg/mod/github.com/\!proton\!mail/go-rfc5322*/ -type f -exec sed -i.bak 's/(1<</(int64(1)<</g' {} +
fi

# Listen on 0.0.0.0
find . -name "constants.go" -exec sed -i 's/Host = "127.0.0.1"/Host = "0.0.0.0"/' {} \;

# Build
make build-nogui
