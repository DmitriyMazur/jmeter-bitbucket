#!/bin/bash

export JIRA_API_TOKEN=$JIRA_SERVICE_TOKEN
export JIRA_USERNAME=$JIRA_SERVICE_EMAIL
export JIRA_URL=$JIRA_URL

# Create child Jira ticket
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S %Z")
JIRA_PARENT_KEY=$JIRA
JIRA_TITLE="Jmeter Results for $TEST_NAME: $TIMESTAMP | Environment: $ENVIRONMENT"
JIRA_DESCRIPTION="Results uploaded: $TIMESTAMP\nJMeter Script Name: $TEST_NAME\nEnvironment: $ENVIRONMENT\nConcurrent Users: $THREADS\nDuration: $THREAD_LIFETIME\nData File: $DATA_FILE"

# Check if FIX_VERSION is provided, if yes, include it in the JSON, otherwise, omit it
if [ -n "$FIX_VERSION" ]; then
  JIRA_JSON=$(jq -n \
    --arg parentKey "$JIRA_PARENT_KEY" \
    --arg title "$JIRA_TITLE" \
    --arg description "$JIRA_DESCRIPTION" \
    --arg fixVersion "$FIX_VERSION" \
    '{"fields":{"project":{"key":($parentKey | split("-")[0])},"issuetype":{"name":"Sub-task"},"parent":{"key":$parentKey},"summary":$title,"description":{"type":"doc","version":1,"content":[{"type":"paragraph","content":[{"type":"text","text":$description}]}]},"fixVersions":[{"name":$fixVersion}]}}')
else
  JIRA_JSON=$(jq -n \
    --arg parentKey "$JIRA_PARENT_KEY" \
    --arg title "$JIRA_TITLE" \
    --arg description "$JIRA_DESCRIPTION" \
    '{"fields":{"project":{"key":($parentKey | split("-")[0])},"issuetype":{"name":"Sub-task"},"parent":{"key":$parentKey},"summary":$title,"description":{"type":"doc","version":1,"content":[{"type":"paragraph","content":[{"type":"text","text":$description}]}]}}}')
fi

JIRA_API_URL="$JIRA_URL/rest/api/3/issue"
JIRA_RESPONSE=$(curl -s -H "Content-Type: application/json" -u $JIRA_USERNAME:$JIRA_API_TOKEN -X POST --data "$JIRA_JSON" $JIRA_API_URL)
CHILD_JIRA_KEY=$(echo $JIRA_RESPONSE | jq -r '.key')
echo "Child Jira Ticket Created: $CHILD_JIRA_KEY"

# Upload artifacts to the child Jira ticket
export JIRA_API_URL="$JIRA_URL/rest/api/3/issue/$CHILD_JIRA_KEY/attachments"
for artifact in $(ls artifacts); do
  if [ -d "artifacts/$artifact" ]; then
    # If it's a directory, zip it
    echo "Creating zip file for $artifact..."
    zip -r "artifacts/$artifact.zip" "artifacts/$artifact"
    ls -l "artifacts/$artifact.zip"
    artifact="$artifact.zip"
  fi
  echo "Uploading $artifact..."
  curl --max-time 300 -D- -u $JIRA_USERNAME:$JIRA_API_TOKEN -X POST -H "X-Atlassian-Token: no-check" -F "file=@artifacts/$artifact" $JIRA_API_URL
done
