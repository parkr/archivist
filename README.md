# archivist

Update your history file to reflect the merge of pull requests.

## Status 

THIS REPOSITORY IS UNMAINTAINED. It has been abandoned due to because replaced by another project. At the moment the code isn't great and it may not even work. Some of this may be useful to others regardless or as a basis for another project. Feel free to fork and do with it what you please.

## Configuration

You must specify two environment variables in order to make the push up to GitHub:

1. `GH_USER` - your username
2. `GH_TOKEN` - the application-specific passcode for this app

You may also optionally set the following:

1. `ARCHIVIST_HISTFILE` - the path to your History markdown file
2. `LOG_LEVEL` - specify how detailed you'd like the logging for your app: "debug", "info", "warn", "error", "fatal"

## Usage

Add the URL of your installation of Archivist to your repository as a
Web Hook, and you're done.
