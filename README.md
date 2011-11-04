# Cipr #

Cipr is continuous integration for your pull requests.  It detects new pull reqests or changed pull requests and runs specs on them

## Basic Usage ##

    gem install cipr
    cipr [-u <github_user> [-p <github_password> | -t <github_token>]] http://github.com/<github_user>/<github_repo>

## Configuration ##

By default, cipr does the following

Watches your repository for open pull requests
Upon finding one, clones the repository in a new directory, applies the pull request patch, and runs 'rake spec' on it
The results are added as a comment to the pull request

## TODO ##

Provide a mechanism for defining what to run on a repo

## About ##

Cipr (pronounced like sipper) is continuous integration for pull requests