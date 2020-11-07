#!/bin/bash
# this is a boilerplate of base executor for your CI/CD runtime executor
# it could be set up with predefined dependencies for your CI/CD needs

# We are expecting if something failed while gathering the dependencies
# the whole execution must be failed
set -euo pipefail

RED='\033[1;31m'
NC='\033[0m'

GITLAB_URL="https://gitlab.com"
TEMPDIR=$(mktemp -d)

mkdir -p /opt/shared

function gitlab_download_artifact() {
    ref=$1
    job=$2
    curl -sSfL -H "JOB-TOKEN: $CI_JOB_TOKEN" "$GITLAB_URL/api/v4/projects/53/jobs/artifacts/$ref/download?job=$job" -o "$TEMPDIR/$job.zip" || {
        echo -e "${RED}Something goes wrong when try to download the common-scripts.${NC}\nPlease contact the administrator @team, exiting."
        exit 1
    }

    unzip -qq -o "$TEMPDIR/$job.zip" -d "$TEMPDIR/$job"
    mv "$TEMPDIR/$job"/bin/* /usr/local/bin/ || true
    mv "$TEMPDIR/$job"/shared/* /opt/shared || true
}

# --------------
# Download external dependencies
# --------------
# As a starter script in our CI/CD box, we need to set apart between the box and the scripts
# As seen on the below example, there is 2 use case for CI/CD using GitlabCI and CI/CD with GitHub repository as scm
# Both use case provide the convention which `/bin/*` directory stored the scripts either a script or a binary
# and `shared/*` directory stored shared file that could be used for other script

# 1. Example use case for CI/CD using GitlabCI, utilize GitlabCI artifact

curl -sSfL -H "JOB-TOKEN: $CI_JOB_TOKEN" "$GITLAB_URL/api/v4/projects/53/jobs/artifacts/master/download?job=ci-scripts" -o "$TEMPDIR"/ci-scripts.zip || {
    echo -e "${RED}Something goes wrong when try to download the common-scripts.${NC}\nPlease contact the administrator @team, exiting."
    exit 1
}

unzip -qq -o "$TEMPDIR"/ci-scripts.zip -d "$TEMPDIR"/ci-scripts
mv "$TEMPDIR"/ci-scripts/bin/* /usr/local/bin/ || true
mv "$TEMPDIR"/ci-scripts/shared/* /opt/shared || true

# 2. Example use case CI/CD with GitHub repository

git config --global url."https://${GITHUB_TOKEN}:x-oauth-basic@github.com/".insteadOf "https://github.com/"
git clone -b master https://github.com/<username>/pipelines "$TEMPDIR"
mv "$TEMPDIR"/bin /usr/local/bin || true
mv "$TEMPDIR"/shared /opt/shared || true

rm -rf "$TEMPDIR"
/bin/bash -c "$@"
