#!/usr/bin/env bash

COMPANY_NAME="<set-company-name-here>"

if [ "$COMPANY_NAME" == "<set-company-name-here>" ];
then
	echo "You must change the COMPANY_NAME variable to be the username of the company on GitHub"
  exit 1
fi

if [ $# -eq 0 ];
then
    echo "No arguments supplied, Updating all projects in './all-projects-in-$COMAPNY_NAME-for-better-search'"
    cd "./all-projects-in-$COMPANY_NAME-for-better-search"
else
		echo "Target folder passed, Updating all projects to $1"
		cd "$1"
fi


og_dir=$(pwd)
echo "Updating projects in $og_dir"
echo ""
echo ""

# Over each project
for folder_name in */ ; do
	echo ""
	echo "$folder_name"
	echo "------"

	cd "$og_dir"

	# Update repo if already exists
	cd "$folder_name"

	# - ignore all errors because some repos may have zero commits, 
	# so no main or master
	set +e
	git restore .

  # Remove remote-tracking references that no longer exist on the remote and don't fetch tags
	git pull --prune --no-tags
	
  # Remove Local branches that does not exist on the remote anymore
  git fetch -p && for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do git branch -D $branch; done

  set -e
done
