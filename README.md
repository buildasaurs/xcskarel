# xcskarel

Quickly manage your Xcode Server & Bots from the command line.

# :white_check_mark: install
Clone the repo or get on [RubyGems](https://rubygems.org/gems/xcskarel)

```
sudo gem install xcskarel
```

# :nut_and_bolt: usage
To see all options, run `xcskarel --help`.

Two options useful for all commands below

```
--no_pretty 
    Disables output JSON prettification
--no_filter 
    Prints full JSON payload for objects instead of just filtering the important ones
```

## bots

```ruby
$ xcskarel bots --host 10.99.0.57
[
  {
    "_id": "02440afb1e7a51dc9795319121038f17",
    "name": "buildasaur-release"
  },
  {
    "_id": "02440afb1e7a51dc97953191217e5ab0",
    "name": "buildasaur-master"
  },
  {
    "_id": "069200f4acb7aa061c469e7b0ebd7d44",
    "name": "BuildaBot [czechboy0/Buildasaur] PR #123"
  }
]
```

## integrations

```ruby
$ xcskarel integrations --host 10.99.0.57 --bot 660bbc6a36d476a32a3830f944085904 
[
  {
    "_id": "c188b6a9c16869be006c66815fcb5177",
    "currentStep": "completed",
    "number": 5,
    "result": "test-failures"
  },
  {
    "_id": "c188b6a9c16869be006c66815fca5dbd",
    "currentStep": "completed",
    "number": 4,
    "result": "warnings"
  },
  {
    "_id": "660bbc6a36d476a32a3830f94487c29b",
    "currentStep": "completed",
    "number": 2,
    "result": "succeeded"
  }
]
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
