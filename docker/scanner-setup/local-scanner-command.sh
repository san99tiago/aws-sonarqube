#!/bin/bash

# Documentation:
# --> https://docs.sonarsource.com/sonarqube/latest/analyzing-source-code/scanners/sonarscanner/

# Run Python Tests
pip install pytest coverage
coverage run -m pytest tests
coverage xml

# Important: make sure to have the "coverage.xml" file already at the same level (to be used as coverage report)
# It can be generated with the "unit tests" commands in the "pyproject.toml" tasks.

# Note: I won't use secrets, as these are dummy ones, but in production-workflows must be secrets
PROJECT_KEY=test-repo  # Usually same as repo name
SONARQUBE_URL=mysonarqube  # Endpoint for sonarqube (in this case the Docker SonarQube Service)
SONAR_TOKEN=sqa_96489117a8a357b596df8b9dab4ce2460afc3b99  # This is intentionally added here (example)

# Run this command to scan the local repo in the SonarQube Server endpoint that
# ... is exposed either in the docker-network, or in a public endpoint
docker run \
    --rm \
    -e SONAR_HOST_URL="http://${SONARQUBE_URL}:9000" \
    -e SONAR_SCANNER_OPTS="-Dsonar.projectKey=${PROJECT_KEY}" \
    -e SONAR_TOKEN="${SONAR_TOKEN}" \
    -v ".:/usr/src" \
    --network devops_santi \
    sonarsource/sonar-scanner-cli
