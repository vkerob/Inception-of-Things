#!/bin/bash

GITLAB_REPO_NAME="vkerob-IoT-Part3"
GITHUB_USERNAME="vkerob"
GITLAB_DOMAIN="gitlab.local"
GITLAB_URL="https://$GITLAB_DOMAIN"
GITLAB_NEW_REPO_URL="$GITLAB_URL/root/$GITLAB_REPO_NAME.git"
GITHUB_REPO_ORIGIN_URL="https://github.com/$GITHUB_USERNAME/$GITLAB_REPO_NAME"
CURRENT_DIR=$(pwd)

set -x

get_gitlab_access_token() {
    echo "[INFO] Getting GitLab access token..." >&2
    password="$(kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode)"
    echo "$password" >&2
    curl_response=$(curl -k --silent --show-error --request POST \
        --form "grant_type=password" --form "username=root" \
        --form "password=$password" \
        "$GITLAB_URL/oauth/token")

    if [[ -z "$curl_response" ]]; then
        echo "[ERROR] Failed to retrieve token (empty response)" >&2
        exit 1
    fi

    access_token=$(echo "$curl_response" | grep -o '"access_token":"[^"]*' | cut -d':' -f2 | tr -d '"')

    if [[ -z "$access_token" ]]; then
        echo "[ERROR] Access token not found in response: $curl_response" >&2
        exit 1
    fi

    echo "$access_token"
}

create_gitlab_repo() {
    access_token="$1"
    echo "[INFO] Creating GitLab repository $GITLAB_REPO_NAME..."

    curl_response=$(curl -k --silent --show-error --request POST \
        --header "Authorization: Bearer $access_token" \
        --header "Content-Type: application/x-www-form-urlencoded" \
        --data "name=$GITLAB_REPO_NAME&visibility=public" \
        "$GITLAB_URL/api/v4/projects")

    exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        echo "[ERROR] curl request failed (code $exit_code)"
        echo "[DEBUG] curl_response = $curl_response"
        exit 1
    fi

    if echo "$curl_response" | grep -q '"message"'; then
        echo "[ERROR] GitLab returned an error:"
        echo "$curl_response" | jq . 2>/dev/null || echo "$curl_response"
        exit 1
    fi

    echo "[SUCCESS] GitLab repository created successfully."
}


clone_github_repo() {
    echo "[INFO] Cloning GitHub repository $GITHUB_REPO_ORIGIN_URL..."
    rm -rf /tmp/"$GITLAB_REPO_NAME"
    if ! git clone "$GITHUB_REPO_ORIGIN_URL" /tmp/"$GITLAB_REPO_NAME"; then
        echo "[ERROR] GitHub repository cloning failed."
        exit 1
    fi
    echo "[SUCCESS] GitHub repository cloned successfully."
}

clone_github_repo
access_token=$(get_gitlab_access_token)
create_gitlab_repo "$access_token"

cd /tmp/"$GITLAB_REPO_NAME" || { echo "[ERROR] Directory not found: /tmp/$GITLAB_REPO_NAME"; exit 1; }

gitlab_repo_url_with_token="https://oauth2:$access_token@$GITLAB_DOMAIN/root/$GITLAB_REPO_NAME.git"

echo "[INFO] Adding GitLab remote..."
if ! git remote add gitlab "$gitlab_repo_url_with_token"; then
    echo "[ERROR] Cannot add GitLab remote."
    exit 1
fi
echo "[SUCCESS] GitLab remote added successfully."

cd "$CURRENT_DIR"

cd /tmp/"$GITLAB_REPO_NAME"

git config --global http.sslVerify false

echo "[INFO] Push du contenu vers GitLab..."
if ! git push gitlab --all; then
    echo "[ERROR] Push to GitLab failed."
    exit 1
fi

if ! git push gitlab --tags; then
    echo "[ERROR] Push tags to GitLab failed."
    exit 1
fi

echo "[SUCCESS] Content pushed successfully to GitLab."
