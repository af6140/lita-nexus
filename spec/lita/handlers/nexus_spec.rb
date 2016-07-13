require "spec_helper"
require 'docker'

describe Lita::Handlers::Nexus, lita_handler: true do
  before :all do
    @image = Docker::Image.create('fromImage' => 'sonatype/nexus:oss')
    #
    @container_data =  Docker::Container.create( 'Image' => 'sonatype/nexus:oss',
      'Cmd' => "true"
    )
    @container_data.rename('lita_nexus_data')
    @container_data.start

    sleep 5

      #check docker image documentation
    default_settings =[
      'MAX_HEAP=768m'
    ]
    @container_nexus = Docker::Container.create( 'Image' => 'sonatype/nexus:oss',
      'Env'=> default_settings,
      'ExposedPorts' => {
        '8081/tcp' => {}
      },
      'HostConfig' => {
        'PortBindings' => { '8081/tcp' => [{ 'HostPort' => '8081' }] }
      },
      'VolumesFrom' => ['lita_nexus_data']
    )
    @container_nexus.rename('lita_nexus')
    @container_nexus.start

    # waiting container to startup
    wait_time = ENV['LITA_NEXUS_WAIT_TIME'] || 20
    sleep wait_time



    #now upload test artifact to server
    test_jar1 = File.expand_path("../../../fixtures/file/maven-reporting-api-2.0.9.jar", __FILE__)
    test_jar2 = File.expand_path("../../../fixtures/file/maven-reporting-api-2.0.6.jar", __FILE__)
    #puts robot.handlers.to_a[0].class
    overrides = {
      :url => 'http://localhost:8081',
      :repository => 'releases',
      :username => 'admin',
      :password => 'admin123'
    }
    nexus_remote ||= NexusCli::RemoteFactory.create(overrides, false)

    puts "Upload testing artifact: #{test_jar1}"
    success =  nexus_remote.push_artifact('org.apache.maven.reporting:maven-reporting:jar:2.0.9', test_jar1)
    unless success
      raise "Failed to upload test artifact"
    end
    puts "Upload testing artifact: #{test_jar2}"
    success =  nexus_remote.push_artifact('org.apache.maven.reporting:maven-reporting:jar:2.0.6', test_jar2)
    unless success
      raise "Failed to upload test artifact"
    end

  end


 after :all do
   puts "Shutting down containers"
   @container_nexus.stop
   @container_nexus.delete(:force => true)
   sleep 1
   @container_data.delete(:force => true)
 end

  before do
    registry.config.handlers.nexus.url = 'http://localhost:8081/'
    registry.config.handlers.nexus.username = 'admin'
    # registry.config.handlers.nexus.password_hash =
    #  'C3Enajd6ygmzot1CB8H7FdYb7oLOpOr+fZMisp4HDfb8l1YDaNRxUhCYKxYq
    #   ma3qv6fxmU3wkPLfcN1c/u164jgGVPPl4mi8PtZxbN2uAh0hm/sIqTAoFczy
    #   6lctLPNNYb3eK+4lH/XvOHeS1L+uSwPIiQNub//IsE7MeWz3gW6AXr0I5sUt
    #   k81o63GwYqdT0VS4PpJqfl2zq8LHd6s0SFUfZv02HvW0TvwNxmjiWnsRYLcs
    #   aU9B+umfH9rCqNXNqDaAgEDXBTbMkqTjwQvRi0qMouQmITPC7dnC2lYsC/Ka
    #   HXpfWKIFjbVtf5Tslfj1l5/9mW7PTtwyeXc7z50iUA=='
    registry.config.handlers.nexus.password_plain='admin123'
    registry.config.handlers.nexus.verify_ssl = false
    registry.config.handlers.nexus.default_repository = 'releases'
    registry.config.handlers.nexus.rsa_private_key = "#{File.expand_path('~')}/.ssh/id_rsa"

  end
  it do
    is_expected.to route_command('nexus artifact info webapps:sweetrewards:tar.gz:1.8.0').to(:cmd_artifact_info)
    is_expected.to route_command('nexus license info').to(:cmd_license_info)
    is_expected.to route_command('nexus repo info test').to(:cmd_repo_info)
    is_expected.to route_command('nexus delete artifact webapps:sweetrewards:tar.gz:1.8.0').to(:cmd_delete_artifact)
    is_expected.to route_command('nexus show current repo').to(:cmd_show_current_repository)
    is_expected.to route_command('nexus set current repo releases').to(:cmd_set_current_repository)
    is_expected.to route_command('nexus search artifact org.apache.maven.reporting:maven-reporting limit 5').to(:cmd_search_artifact)
  end

  describe '#get artifact info' do
    #let(:robot) { Lita::Robot.new(registry) }
    it 'fecth artifact info should return info' do
      send_command('nexus artifact info org.apache.maven.reporting:maven-reporting:jar:2.0.9')
      expect(replies.last).to match(/repositoryPath/)
    end
  end

  describe '#search artifact info' do
    it 'search artifact should return artifact' do
      send_command('nexus search artifact org.apache.maven.reporting:maven-reporting limit 5')
      expect(replies.first).to match(/Artifact found: [0-9]+/)
      expect(replies.last).to match(/org.apache.maven.reporting:maven-reporting/)
    end
    it 'search artifact with default limit should return artifact' do
      send_command('nexus search artifact org.apache.maven.reporting:maven-reporting')
      expect(replies.first).to match(/Artifact found: [0-9]+/)
      expect(replies.last).to match(/org.apache.maven.reporting:maven-reporting/)
    end
  end

  describe '#get license info' do
    it 'fecth server license info should show message with "professional version"' do
      send_command('nexus license info')
      expect(replies.last).to match(/professional version/)
    end
  end

  describe '#get repo info' do
    it 'fecth repository info should show snapshots' do
      send_command('nexus repo info snapshots')
      expect(replies.last).to match(/<id>snapshots/)

    end
    it 'show repository not found' do
      send_command('nexus repo info notexist')
      expect(replies.last).to match(/not found/)
    end
  end

  describe '#show and set current repo' do
    it 'get current repo should show as releases' do
      send_command('nexus show current repo')
      #puts replies
      expect(replies.last).to match(/releases/)
    end
    it 'set current repo with success ' do
      send_command('nexus set current repo snapshots')
      expect(replies.last).to match(/Success/)
    end
    it 'get current repo shoud show as snapshots' do
      send_command('nexus show current repo')
      #puts replies
      expect(replies.last).to match(/snapshots/)
    end
  end

  describe '#get artifact versions' do
    it 'get artifact versions should show both versions' do
      send_command('nexus get artifact versions org.apache.maven.reporting:maven-reporting')
      expect(replies.last).to include('2.0.6')
      expect(replies.last).to include('2.0.9')
    end
  end
end
