rosette-core
========

[![Build Status](https://travis-ci.org/rosette-proj/rosette-client.svg?branch=master)](https://travis-ci.org/rosette-proj/rosette-client.svg?branch=master)

## Installation

`gem install rosette-client`

## Usage

Configure it! Create the file `~/.rosette/config.yml` with configuration options for your Rosette setup:

```yaml
:host: rosette.mycompany.com
:port: 8080
:version: v1
```

You should now be able to change directory into a git repository and run rosette commands. If you installed Ruby with rbenv, don't forget to run `rbenv rehash` to make rosette-client's executable available.

## Commands

`git rosette commit [<ref>]`

Causes the given ref to be processed. If ref is omitted, the current `HEAD` is assumed. Phrases will be extracted and stored in the data store.

`git rosette diff <ref1> [<ref2> | <path>] [-- <path1> <path2> ...]`

Show the diff between two refs. If the second ref is omitted, the current `HEAD` is assumed. You can separate paths from ref arguments with `--` for consistency with the `git diff` command. This command will print phrases that were added, removed, or changed between the two refs.

`git rosette show [<ref>]`

Print the phrases that were added, removed, or changed in the given ref. If the ref is omitted, the current `HEAD` is assumed.

`git rosette status [<ref>]`

Print the translation status of the given ref. This includes how many phrases were found and the percentage translated in each supported locale. If ref is omitted, the current `HEAD` is assumed.

`git rosette snapshot [<ref>]`

Print a snapshot of the phrases for the given ref. If ref is omitted, the current `HEAD` is assumed.

`git rosette repo_snapshot [<ref>]`

Print the snapshot hash for the given ref. A snapshot is a hash of file paths to commit ids, where each commit id represents the commit the file last changed in. If ref is omitted, the current `HEAD` is assumed.

`git rosette pull <ref> -f <path> -s <serializer>`

Serializes translations for the given ref using the given serializer and writes them to disk at the given path. The `-f <path>` argument can contain several interpolation variables:

1. `%{locale.language}` - just the language portion of the locale, eg 'pt' for 'pt-BR'
2. `%{locale.territory}` - just the territory portion of the locale, eg 'BR' for 'pt-BR'
3. `%{locale.code}` - the full locale code including both language and territory, eg 'pt-BR'

Example: `git rosette pull master -f config/locales/%{locale.language}.yml -s yaml/rails`

`git rosette untranslated <ref>`

Prints a list of currently untranslated phrases by locale for the given ref.

## Requirements

You've gotta be running a properly configured instance of [rosette-server](https://github.com/rosette-proj/rosette-server) to communicate with, but otherwise there are no external requirements.

## Running Tests

`bundle exec rake` should do the trick.

## Authors

* Cameron C. Dutro: http://github.com/camertron
