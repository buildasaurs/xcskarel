# xcskarel

[![Travis Status](https://travis-ci.org/czechboy0/xcskarel.svg)](https://travis-ci.org/czechboy0/xcskarel)
[![Gem Version](https://badge.fury.io/rb/xcskarel.svg)](http://badge.fury.io/rb/xcskarel)

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](http://en.wikipedia.org/wiki/MIT_License)
[![Blog](https://img.shields.io/badge/blog-honzadvorsky.com-green.svg)](http://honzadvorsky.com)
[![Twitter Czechboy0](https://img.shields.io/badge/twitter-czechboy0-green.svg)](http://twitter.com/czechboy0)

Quickly manage your Xcode Server & Bots from the command line.

# :white_check_mark: install
Clone the repo or install from [RubyGems](https://rubygems.org/gems/xcskarel)

```
sudo gem install xcskarel
```

# :nut_and_bolt: usage
To see all options, run `xcskarel --help`.

## bots

```sh
$ xcskarel bots --host 10.99.0.57
[
  {
    "_id": "02440afb1e7a51dc9795319121038f17",
    "name": "buildasaur-release"
  }
]
```

## integrations

```sh
$ xcskarel integrations --bot "Builda Archiver" --host 192.168.1.64
[
  {
    "_id": "e5fed3c8bdf03d30278a016e64003a1d",
    "currentStep": "checkout",
    "number": 11
  },
  {
    "_id": "a3ad85e42b7b7edbf43f9dca4a14390f",
    "currentStep": "completed",
    "number": 10,
    "result": "checkout-error"
  }
]
```

## status

```sh
$ xcskarel status --host 192.168.1.64
+--------------------------------------------------+----------------------------------+---------+--------------+-----------+-------+
|                                                       https://192.168.1.64                                                       |
+--------------------------------------------------+----------------------------------+---------+--------------+-----------+-------+
| name                                             | id                               | branch  | current_step | result    | count |
+--------------------------------------------------+----------------------------------+---------+--------------+-----------+-------+
| Builda Archiver                                  | 6b3de48352a8126ce7e08ecf85093613 | master  | pending      |           | 11    |
| Builda On Commit                                 | 6c8d3225beff941b3a420554df16cb0d | master  | checkout     |           | 70    |
| BuildaBot [czechboy0/XcodeServerSDK] |-> swift-2 | 3ce25bc9ed5bfffb854947b02600166d | swift-2 | completed    | succeeded | 6     |
+--------------------------------------------------+----------------------------------+---------+--------------+-----------+-------+
```

## start an integration

```sh
$ xcskarel integrate --bot "Builda Archiver" --host 192.168.1.64
INFO [2015-09-03 17:04:59.14]: Successfully started integration 11 on Bot "Builda Archiver"
+--------------------------------------------------+----------------------------------+---------+--------------+-----------+-------+
|                                                       https://192.168.1.64                                                       |
+--------------------------------------------------+----------------------------------+---------+--------------+-----------+-------+
| name                                             | id                               | branch  | current_step | result    | count |
+--------------------------------------------------+----------------------------------+---------+--------------+-----------+-------+
| Builda Archiver                                  | 6b3de48352a8126ce7e08ecf85093613 | master  | pending      |           | 11    |
| Builda On Commit                                 | 6c8d3225beff941b3a420554df16cb0d | master  | checkout     |           | 70    |
| BuildaBot [czechboy0/XcodeServerSDK] |-> swift-2 | 3ce25bc9ed5bfffb854947b02600166d | swift-2 | completed    | succeeded | 6     |
+--------------------------------------------------+----------------------------------+---------+--------------+-----------+-------+
```

## integration issues

```sh
$ xcskarel issues --bot "Buildasaur Bot"
{
  "buildServiceWarnings": [
    {
      "message": "An error occurred while building, so archiving was skipped."
    }
  ],
  "errors": {
    "unresolvedIssues": [
      {
        "message": "No code signing identities found: No valid signing identities (i.e. certificate and private key pair) matching the team ID “7BJ2984YDK” were found."
      }
    ]
  }
}
```

you can also specify the Integration id like this `xcskarel issues --integration 6b3de48352a8126ce7e08ecf85093613`. When you specify a Bot id or a name, however, the last Integration is used.

## manage bot configurations in your git repo
- `config list`    Lists the Xcode Bot configurations found in this folder              
- `config new`     Starts the interactive process of creating a new config from an existing Bot         
- `config show`    Opens the selected config for editing

## others
- `xcskarel logs --host 10.99.0.57 --user honzadvorsky` - prints build and control logs from the remote Xcode Server
- `xcskarel health --host 10.99.0.57` - health information of the server like uptime etc

## server (wraps [xcscontrol](http://honzadvorsky.com/articles/2015-08-12-xcode_server_hacks_cli_xcscontrol/) commands)
- `xcskarel server start` - fully starts a local Xcode Server instance
- `xcskarel server stop` - stops the local Xcode Server instance
- `xcskarel server restart` - restarts the local Xcode Server instance
- `xcskarel server reset` - stops and deletes the local Xcode Server instance

## xcode
- `xcskarel xcode select` - Interactive `xcode-select`, finds all local Xcode's and asks which you want to use from now on

## options

Two options useful for all commands:

```
--no_pretty 
    Disables output JSON prettification
--no_filter 
    Prints full JSON payload for objects instead of just filtering the important ones
```

You can also use environment variables to specify your preferred server host and credentials with `XCSKAREL_HOST`, `XCSKAREL_USER`, and `XCSKAREL_PASS`. If no host is specified, `localhost` is used. To always use the server at, e.g. `192.168.1.64`, just add this to your `~/.zshrc` or `~/.bash_profile`:

```sh
export XCSKAREL_HOST="192.168.1.64"
```

# :octocat: my Xcode Server projects
- [Xcode Server Tutorials](http://honzadvorsky.com/pages/xcode_server_tutorials/) - on how to set up Xcode Server on your Mac in minutes
- [XcodeServerSDK](https://github.com/czechboy0/XcodeServerSDK) - full Xcode Server SDK written in Swift
- [Buildasaur](https://github.com/czechboy0/Buildasaur) - connecting Xcode Server with GitHub Pull Requests
- [XcodeServer-API-Docs](https://github.com/czechboy0/XcodeServer-API-Docs) - Unofficial attempt at full Xcode Server API documentation

# :gift_heart: Contributing
Please create an issue with a description of a problem or a pull request with a fix.

# :v: License
MIT

# :alien: Author
Honza Dvorsky - http://honzadvorsky.com, [@czechboy0](http://twitter.com/czechboy0)
