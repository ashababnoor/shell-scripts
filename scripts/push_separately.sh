#!/bin/sh

# Get the name of the current branch
current_branch=$(git symbolic-ref --short HEAD)

# Get the last commit pushed to the remote branch
last_pushed_commit=$(git rev-parse @{u})

# Loop through each commit since the last pushed commit and push individually
git log --pretty=format:"%H" $last_pushed_commit..HEAD | awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--] }' | while read commit; do
  echo "Pushing commit: $commit"
  git push origin $commit:$current_branch
  echo ""
  sleep 3
  
done

echo "All commits pushed individually."