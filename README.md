# Cipr #

Cipr is continuous integration for your pull requests.  It detects new pull reqests or changed pull requests and runs specs on them

## Basic Usage ##

    gem install cipr
    cipr -u <github_user> -p <github_password> [-d <code directory>] [-c '<command to run>'] [-pc '<prep commmand to run>'] <github_user>/<github_repo>

Pull requests are polled for at a decaying interval that maxes out at every 30 minutes.  You can automatically trigger the poll again by hitting ^C once.  To quit cipr, simply hit ^C twice quickly.

## Configuration ##

By default, cipr does the following

Watches your repository for open pull requests
Upon finding one, clones the repository in a new directory, applies the pull request patch, and runs 'rake spec' on it
The results are added as a comment to the pull request

If you have private repositories, you'll need to set up your ~/.netrc file like so:
    
    machine github.com
    login <github_username>
    password <github_password>

## About ##

Cipr (pronounced like sipper) is continuous integration for pull requests