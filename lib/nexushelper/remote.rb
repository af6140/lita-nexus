require 'nexus_cli'
require 'openssl'
require 'base64'

module LitaNexusHelper
  module Remote
    def nexus_remote
      begin
        pk_path = config.rsa_private_key
        pk = OpenSSL::PKey::RSA.new File.read(pk_path)
        decrypted_pass = pk.private_decrypt Base64::decode64(config.password_hash)
        overrides = {
          :url => config.url,
          :repository => config.default_repository,
          :username => config.username,
          :password => decrypted_pass
        }
        nexus_remote ||= NexusCli::RemoteFactory.create(overrides, config.verify_ssl||false)
      rescue NexusCli::NexusCliError => e
        say e.message, :red
        exit e.status_code
      end
    end

    def get_artifact_info(coordinate)
      remote = nexus_remote
      info = nil
      begin
        info = remote.get_artifact_info(coordinate)
      rescue NexusCli::ArtifactNotFoundException => e
        info = "Artifact not found"
      end
      puts "info: #{info}"
      info
    end

    def search_for_artifact(coordinate)
      remote = nexus_remote
      info = remote.search_for_artifacts(coordinate)
    end

    def get_license_info
      remote = nexus_remote
      if remote.respond_to? 'get_license_info'
        remote.get_license_info
      else
        'Only supported on professional version.'
      end
    end
  end#module Remote
end #module helper
