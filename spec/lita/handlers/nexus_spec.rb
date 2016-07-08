require "spec_helper"

describe Lita::Handlers::Nexus, lita_handler: true do
  before do
    registry.config.handlers.nexus.url = 'https://nexus.prod.co.entpub.net/nexus/'
    registry.config.handlers.nexus.username = 'dwang_sa'
    registry.config.handlers.nexus.password_hash =
     'Zrt3Hwo7Er4nu9Ne4r0Y6ykuxwxlmvKTrEN26G7EYw63Wtnt9K4H9e933NEZ
      eaqUhjoXKYCylhZNWsSj/KDnrEflCCr4eHkFq3kwNi9fRraI3kWVoBzg0v2E
      jn5sVCVgrIKG3W8p+RGKbm+HEnkNSZRKJumqJy3vtPcbgMdSlWZQPpwNP4X2
      c4NnOUNVY3nmEijX1FJkGnfL3pcZlJgx60lLhhLbGnKQkLz5LdeFRbiiXaVw
      acFQufgrhNN85AsKaUlDp/n8ISuMB1K1nGVdN2ZYByf1aKVYwnIWdj+omffz
      Da2gZuDpdDWvNfYsm7o3JV6BcmsS9YgiaeiBNi0l1Q=='
    registry.config.handlers.nexus.verify_ssl = false
    registry.config.handlers.nexus.default_repository = 'entertainment'
    registry.config.handlers.nexus.rsa_private_key = "#{File.expand_path('~')}/.ssh/id_rsa"
  end
  it do
    is_expected.to route_command('nexus artifact info webapps:sweetrewards:tar.gz:1.8.0').to(:cmd_artifact_info)
    is_expected.to route_command('nexus license info').to(:cmd_license_info)
    is_expected.to route_command('nexus repo info test').to(:cmd_repo_info)
    is_expected.to route_command('nexus delete artifact webapps:sweetrewards:tar.gz:1.8.0').to(:cmd_delete_artifact)
    is_expected.to route_command('nexus show current repo').to(:cmd_show_current_repository)
    is_expected.to route_command('nexus set current repo releases').to(:cmd_set_current_repository)
  end

  describe '#get artifact info' do
    it 'fecth artifact info' do
      send_command('nexus artifact info webapps:sweetrewards:tar.gz:1.8.0')
      puts replies
    end
  end

  describe '#search artifact info' do
    it 'search artifact' do
      send_command('nexus search artifact webapps:sweetrewards')
      puts replies
    end
  end

  describe '#get license info' do
    it 'fecth server license info' do
      send_command('nexus license info')
      puts replies
    end
  end

  describe '#get repo info' do
    it 'fecth repository info' do
      send_command('nexus repo info snapshots')
      puts replies

    end
    it 'show repository not found' do
      send_command('nexus repo info notexist')
      puts replies
    end
  end

  describe '#show and set current repo' do
    it 'get current repo' do
      send_command('nexus show current repo')
      puts "Getting current repo"
      puts replies
    end
    it 'set current repo ' do
      send_command('nexus set current repo releases')
      puts "Setting current repo"
      puts replies
    end
    it 'get current repo' do
      send_command('nexus show current repo')
      puts "Getting current repo, changed"
      puts replies
    end
  end
end
