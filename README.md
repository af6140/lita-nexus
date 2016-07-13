# lita-nexus

Lita handlers to query nexus server for artifact and repository

## Installation

Add lita-nexus to your Lita instance's Gemfile:

``` ruby
gem "lita-nexus"
```

Encrypted password can be generated use example rsa_encrypt script

## Configuration
```ruby
Lita.configure do |config|
  config.handlers.nexus.url = "http://localhost:8081/"
  config.handlers.nexus.username = 'admin'
  #encrypted use rsa_public_key
  # config.handlers.nexus.password_hash =
  #  'Zrt3Hwo7Er4nu9Ne4r0Y6ykuxwxlmvKTrEN26G7EYw63Wtnt9K4H9e933NEZ
  #   eaqUhjoXKYCylhZNWsSj/KDnrEflCCr4eHkFq3kwNi9fRraI3kWVoBzg0v2E
  #   jn5sVCVgrIKG3W8p+RGKbm+HEnkNSZRKJumqJy3vtPcbgMdSlWZQPpwNP4X2
  #   c4NnOUNVY3nmEijX1FJkGnfL3pcZlJgx60lLhhLbGnKQkLz5LdeFRbiiXaVw
  #   acFQufgrhNN85AsKaUlDp/n8ISuMB1K1nGVdN2ZYByf1aKVYwnIWdj+omffz
  #   Da2gZuDpdDWvNfYsm7o3JV6BcmsS9YgiaeiBNi0l1Q=='
  config.handlers.nexus.password_plain = 'admin123'
  config.handlers.nexus.verify_ssl = false
  config.handlers.nexus.default_repository = 'entertainment'
  #used to decrypt password hash
  config.handlers.nexus.rsa_private_key = "#{File.expand_path('~')}/.ssh/id_rsa"
end
```

## Usage

* nexus artifact info webapps:sweetrewards:tar.gz:1.8.0
* nexus delete artifact webapps:sweetrewards:tar.gz:1.8.0
* nexus search artifact webapps:sweetrewards [limit 5]# only groupId and artifacId are effective, default return 5 latest version
* nexus license info # only for pro version
* nexus repo info snapshots
* nexus show current repo
* nexus set current repo releases
* nexus get artifact versions webapps:sweetrewards # use groupId and artifactId, limit to latest 5 versions by default
