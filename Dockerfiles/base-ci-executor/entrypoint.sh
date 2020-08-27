#!/usr/bin/env bash
# this is a boilerplate of base executor for your CI/CD runtime executor
# it could be set up with predefined scripts for your CI/CD needs

tempdir=$(mktemp -d)

# --------------
# Download external dependencies dynamically
# --------------
#
# downloaded content is a zipped file, while unzipped all binaries
# located in same directories format which in `bin/*` directory
# you could set up by up to your preference
#
curl -sL -H "PRIVATE-TOKEN: TKC5SnKKvc5nRwSqrE6E" "https://gitlab.com/api/v4/projects/53/jobs/artifacts/master/download?job=common-scripts" -o $tempdir/common-scripts.zip
curl -sL -H "PRIVATE-TOKEN: TKC5SnKKvc5nRwSqrE6E" "https://gitlab.com/api/v4/projects/54/jobs/artifacts/master/download?job=deployment-scripts" -o $tempdir/ci-scripts.zip
curl -sL -H "PRIVATE-TOKEN: TKC5SnKKvc5nRwSqrE6E" "https://gitlab.com/api/v4/projects/55/jobs/artifacts/master/download?job=deployment-scripts" -o $tempdir/deployment-scripts.zip

unzip -qq -o $tempdir/common-scripts.zip -d $tempdir/common-scripts
mv $tempdir/common-scripts/bin/* /usr/local/bin/

unzip -qq -o $tempdir/ci-scripts.zip -d $tempdir/ci-scripts
mv $tempdir/ci-scripts/bin/* /usr/local/bin/

unzip -qq -o $tempdir/deployment-scripts.zip -d $tempdir/deployment-scripts
mv $tempdir/deployment-scripts/bin/* /usr/local/bin/

exec /bin/bash $@