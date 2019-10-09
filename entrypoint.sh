#!/bin/sh
set -eu

# Set up .netrc file with GitHub credentials
git_setup ( ) {
  cat <<- EOF > $HOME/.netrc
        machine github.com
        login $GITHUB_ACTOR
        password $GITHUB_TOKEN

        machine api.github.com
        login $GITHUB_ACTOR
        password $GITHUB_TOKEN
EOF
    chmod 600 $HOME/.netrc

    git config --global user.email "actions@github.com"
    git config --global user.name "GitHub Actions"
}


# This section only runs if there have been file changes
echo "Checking for uncommitted changes in the git working tree."
if ! [ -z "$(git status --porcelain)" ]
then
    git_setup
    
    # remove refs/head/ from branch name
    INPUT_BRANCH=${INPUT_BRANCH##refs/head/}
    
    echo "INPUT_BRANCH value: $INPUT_BRANCH";

    # Switch to branch from current Workflow run
    git checkout $INPUT_BRANCH

    git add .

    git commit -m "$INPUT_COMMIT_MESSAGE" --author="$GITHUB_ACTOR <$GITHUB_ACTOR@users.noreply.github.com>"

    git push --set-upstream origin "HEAD:$INPUT_BRANCH"
else
    echo "Working tree clean. Nothing to commit."
fi
