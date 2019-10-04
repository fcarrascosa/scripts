#!/bin/bash

differences=" $(git log --pretty="%s" $(git describe --tags --abbrev=0)..HEAD)"

while read -r line; do
    if [[ "$line" == *"BREAKING CHANGE:"* ]]; then
        version="major"
        break
    elif [[ "$line" == *"feat"* ]]; then
        version="minor"
    elif [[ "$line" == *"fix"* ]] || [[ "$line" == *"refactor"* ]]; then
        if [[ $version != "minor" ]]; then
            version="patch"
        fi;
    fi
done <<< "${differences}"

echo "${differences}"

if [[ -z ${version+x} ]];
    then
        echo "No version bump needed to this build"
    else
        oldVersion="$(npm info . version)"
        newVersion="$(npm version ${version} --no-git-tag-version | sed 's/v//')"

	sed -i -e "1 s/.*/# ${oldVersion} to ${newVersion}/" ./CHANGELOG.md
        printf '%s\n%s\n%s\n' "" "$(cat ./CHANGELOG.md)" > ./CHANGELOG.md
        printf '%s\n%s\n%s\n' "# [Unreleased]" "$(cat ./CHANGELOG.md)" > ./CHANGELOG.md

	cat ./CHANGELOG.md

	git add CHANGELOG.md
	git add package.json

	git commit -m "release: update version to ${newVersion}"

	git tag "v${newVersion}"

fi

echo ${version}