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

* commit
* diff
* show
* status

## Requirements

You've gotta be running a properly configured instance of [rosette-server](https://github.com/rosette-proj/rosette-server), but otherwise there are no external requirements.

## Running Tests

`bundle exec rake` should do the trick.

## Authors

* Cameron C. Dutro: http://github.com/camertron
