GITLAB_REPO_NAME="vkerob-IoT-Part3"
GITHUB_USERNAME="vkerob"
GITLAB_URL="http://localhost/gitlab"
GITLAB_NEW_REPO_URL="https://localhost/gitlab/root/$GITLAB_REPO_NAME.git"
GITHUB_REPO_ORIGIN_URL="https://github.com/$GITHUB_USERNAME/$GITLAB_REPO_NAME"
CURRENT_DIR=$(pwd)


get_gitlab_access_token() {
    curl_response=$(curl --silent --show-error --request POST \
        --form "grant_type=password" --form "username=root" \
        --form "password=MonMotDePasseSuperSecret" "$GITLAB_URL/oauth/token")

    access_token=$(echo "$curl_response" | grep -o '"access_token":"[^"]*' | cut -d':' -f2 | tr -d '"')
    echo "$access_token"
}

# gitlab repo
create_gitlab_repo() {
    access_token="$1"
    curl_response=$(curl --silent --show-error --request POST \
        --header "Authorization: Bearer $access_token" --form "name=$GITLAB_REPO_NAME" \
        --form "visibility=public" "$GITLAB_URL/api/v4/projects")
}

# clone github repo
clone_github_repo() {
    rm -rf /tmp/"$GITLAB_REPO_NAME"
    git clone "$GITHUB_REPO_ORIGIN_URL" /tmp/"$GITLAB_REPO_NAME"
}


clone_github_repo
access_token=$(get_gitlab_access_token)


cd /tmp/"$GITLAB_REPO_NAME"
gitlab_repo_url_with_token="http://oauth2:$access_token@localhost/gitlab/root/$GITLAB_REPO_NAME.git"
git remote add gitlab "$gitlab_repo_url_with_token"


cd "$CURRENT_DIR"

