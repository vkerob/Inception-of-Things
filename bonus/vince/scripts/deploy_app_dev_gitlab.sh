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
    echo "[INFO] Obtention du token d'accès GitLab..." >&2
    curl_response=$(curl -k --silent --show-error --request POST \
        --form "grant_type=password" --form "username=root" \
        --form "password=6GPo6TnMvHMZJzDTZTEb4LrxDE5IvVbLvkRXoJWdgu3wkRGDRZOUEpNIxnepT8jL" \
        "$GITLAB_URL/oauth/token")

    if [[ -z "$curl_response" ]]; then
        echo "[ERREUR] Échec de la récupération du token (réponse vide)" >&2
        exit 1
    fi

    access_token=$(echo "$curl_response" | grep -o '"access_token":"[^"]*' | cut -d':' -f2 | tr -d '"')

    if [[ -z "$access_token" ]]; then
        echo "[ERREUR] Token d'accès introuvable dans la réponse : $curl_response" >&2
        exit 1
    fi

    echo "$access_token"
}

create_gitlab_repo() {
    access_token="$1"
    echo "[INFO] Création du dépôt GitLab $GITLAB_REPO_NAME..."

    curl_response=$(curl -k --silent --show-error --request POST \
        --header "Authorization: Bearer $access_token" \
        --header "Content-Type: application/x-www-form-urlencoded" \
        --data "name=$GITLAB_REPO_NAME&visibility=public" \
        "$GITLAB_URL/api/v4/projects")

    exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        echo "[ERREUR] La requête curl a échoué (code $exit_code)"
        echo "[DEBUG] curl_response = $curl_response"
        exit 1
    fi

    if echo "$curl_response" | grep -q '"message"'; then
        echo "[ERREUR] GitLab a renvoyé une erreur :"
        echo "$curl_response" | jq . 2>/dev/null || echo "$curl_response"
        exit 1
    fi

    echo "[SUCCÈS] Dépôt GitLab créé avec succès."
}


clone_github_repo() {
    echo "[INFO] Clonage du dépôt GitHub $GITHUB_REPO_ORIGIN_URL..."
    rm -rf /tmp/"$GITLAB_REPO_NAME"
    if ! git clone "$GITHUB_REPO_ORIGIN_URL" /tmp/"$GITLAB_REPO_NAME"; then
        echo "[ERREUR] Le clonage du dépôt GitHub a échoué."
        exit 1
    fi
    echo "[SUCCÈS] Dépôt GitHub cloné avec succès."
}

clone_github_repo
access_token=$(get_gitlab_access_token)
create_gitlab_repo "$access_token"

cd /tmp/"$GITLAB_REPO_NAME" || { echo "[ERREUR] Répertoire introuvable : /tmp/$GITLAB_REPO_NAME"; exit 1; }

gitlab_repo_url_with_token="https://oauth2:$access_token@$GITLAB_DOMAIN/root/$GITLAB_REPO_NAME.git"

echo "[INFO] Ajout du remote GitLab..."
if ! git remote add gitlab "$gitlab_repo_url_with_token"; then
    echo "[ERREUR] Impossible d'ajouter le remote GitLab."
    exit 1
fi
echo "[SUCCÈS] Remote GitLab ajouté avec succès."

cd "$CURRENT_DIR"

cd /tmp/"$GITLAB_REPO_NAME"

echo "[INFO] Push du contenu vers GitLab..."
if ! git push gitlab --all; then
    echo "[ERREUR] Le push vers GitLab a échoué."
    exit 1
fi

if ! git push gitlab --tags; then
    echo "[ERREUR] Le push des tags vers GitLab a échoué."
    exit 1
fi

echo "[SUCCÈS] Contenu poussé avec succès sur GitLab."
