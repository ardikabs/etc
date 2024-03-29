#!/bin/sh
# this is a boilerplate of base executor for your CI/CD runtime executor
# it could be set up with predefined dependencies for your CI/CD needs

GITLAB_URL="https://gitlab.com"
TEMPDIR=$(mktemp -d)

mkdir -p /opt/shared

# --------------
# Download external dependencies
# --------------
# As a starter script in our CI/CD box, we need to set apart between the box and the scripts
# As seen on the below example, there is 2 use case for CI/CD using GitlabCI and CI/CD with GitHub repository as scm
# Both use case provide the convention which `/bin/*` directory stored the scripts either a script or a binary
# and `shared/*` directory stored shared file that could be used for other script

# 1. Example use case for CI/CD using GitlabCI, utilize GitlabCI artifact

if ! curl -sfL -H "PRIVATE-TOKEN: ${CI_PERSONAL_ACCESS_TOKEN}" "${GITLAB_URL}/api/v4/projects/53/jobs/artifacts/master/download?job=ci-scripts" -o "${TEMPDIR}"/ci-scripts.zip; then
   cat >&2 <<'EOF'
   📎 Hey there! It looks like an error occurs when trying to download the scripts.

   It is probably an issue either from GitLab or the job is completely missing or unknown.

   Please contact the administrator (@ardikabs) for further details.

   Exiting...
EOF
   exit 1
fi

unzip -qq -o "${TEMPDIR}"/ci-scripts.zip -d "${TEMPDIR}"/ci-scripts
mv "${TEMPDIR}"/ci-scripts/bin/* /usr/local/bin/ || true
mv "${TEMPDIR}"/ci-scripts/shared/* /opt/shared || true

# 2. Example use case CI/CD with GitHub repository

git config --global url."https://${GITHUB_TOKEN}:x-oauth-basic@github.com/".insteadOf "https://github.com/"
git clone -b master https://github.com/ "${TEMPDIR}" <username >/pipelines
mv "${TEMPDIR}"/bin /usr/local/bin || true
mv "${TEMPDIR}"/shared /opt/shared || true

rm -rf "${TEMPDIR}"

exec "$@"
