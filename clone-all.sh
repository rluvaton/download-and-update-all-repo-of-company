#!/usr/bin/env bash

COMPANY_NAME="<set-company-name-here>"

if [ "$COMPANY_NAME" == "<set-company-name-here>" ];
then
	echo "You must change the COMPANY_NAME variable to be the username of the company on GitHub"
  exit 1
fi

if [ $# -eq 0 ];
then
    echo "No arguments supplied, cloning all projects to './all-projects-in-$COMAPNY_NAME-for-better-search'"
    cd "./all-projects-in-$COMPANY_NAME-for-better-search"
else
		echo "Target folder passed, Cloning all projects to $1"
		cd "$1"
fi

og_dir=$(pwd)
echo "Cloning to: $og_dir"
echo ""
echo ""

# Over each project
gh repo list $COMPANY_NAME --limit 1000 | while read -r repo _; do
	echo ""
	echo "$repo"
	echo "------"

	cd "$og_dir"

	# company-name/repo-name -> repo-name
	folder_name=./${repo/$COMPANY_NAME\//}
	echo "Checking existance of $folder_name"

	# If folder doesn't exist then clone repo
	if [ ! -d "$folder_name" ]; then
		echo "	Repo not found, cloning..."
		
		gh repo clone $repo
		status=$?

		if [ $status -eq 0 ]; then 
			echo "	Successfully Cloned"
			
			cd "$folder_name"
			if [ ! -z "$(git submodule status --recursive)" ]; then
				echo "	$(basename $(pwd)) Have submodule, init..."
				git submodule update --init --recursive
			fi
		else

		  echo ""
			echo "	############################"
			echo "	FAILED TO CLONE $repo!"
			echo "	############################"
			echo ""
			continue
		fi
	else
		echo "	Repo found, updating..."
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

	fi
done
