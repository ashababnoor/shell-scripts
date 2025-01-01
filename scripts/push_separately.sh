#!/bin/sh

# Set the sleep timer to a default value of 3 seconds if not provided
default_sleep_timer=3
sleep_timer=${1:-$default_sleep_timer}

# Get the name of the current branch
current_branch=$(git symbolic-ref --short HEAD)

# Get the last commit pushed to the remote branch
last_pushed_commit=$(git rev-parse @{u})

# Loop through each commit since the last pushed commit and push individually
git log --pretty=format:"%H" $last_pushed_commit..HEAD | awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--] }' | while read commit; do
  echo "Pushing commit: $commit"
  git push origin $commit:$current_branch
  echo ""
  sleep $sleep_timer
  
done

echo "All commits pushed individually."
