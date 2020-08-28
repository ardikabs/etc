#!/bin/bash
# this is a boilerplate of base executor for your CI/CD runtime executor
# it could be set up with predefined dependencies for your CI/CD needs

# We are expecting if something failed while gathering the dependencies
# the whole execution must be failed
set -euo pipefail

RED='\033[1;31m'
NC='\033[0m'

tempdir=$(mktemp -d)
mkdir -p /opt/shared

# --------------
# Download external dependencies
# --------------

# Downloaded content is a zipped file, it contains binary files and shared files
# located in the `bin/*` and `shared/*` respectively.
# You could be set up by up to your preference

curl -sSfL -H "PRIVATE-TOKEN: TKC5SnKKvc5nRwSqrE6E" "https://gitlab.com/api/v4/projects/53/jobs/artifacts/master/download?job=common-scripts" -o $tempdir/common-scripts.zip
curl -sSfL -H "PRIVATE-TOKEN: TKC5SnKKvc5nRwSqrE6E" "https://gitlab.com/api/v4/projects/54/jobs/artifacts/master/download?job=ci-scripts" -o $tempdir/ci-scripts.zip
curl -sSfL -H "PRIVATE-TOKEN: TKC5SnKKvc5nRwSqrE6E" "https://gitlab.com/api/v4/projects/55/jobs/artifacts/master/download?job=deployment-scripts" -o $tempdir/deployment-scripts.zip

unzip -qq -o $tempdir/common-scripts.zip -d $tempdir/common-scripts
mv $tempdir/common-scripts/bin/* /usr/local/bin/
mv $tempdir/common-scripts/shared/* /opt/shared

unzip -qq -o $tempdir/ci-scripts.zip -d $tempdir/ci-scripts
mv $tempdir/ci-scripts/bin/* /usr/local/bin/
mv $tempdir/ci-scripts/shared/* /opt/shared

unzip -qq -o $tempdir/deployment-scripts.zip -d $tempdir/deployment-scripts
mv $tempdir/deployment-scripts/bin/* /usr/local/bin/
mv $tempdir/deployment-scripts/shared/* /opt/shared/

exec /bin/bash $@