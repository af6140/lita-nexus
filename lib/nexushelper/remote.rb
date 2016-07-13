require 'nexus_cli'
require 'openssl'
require 'base64'

module LitaNexusHelper
  module Remote
    def nexus_remote
      begin
        if config.password_plain.nil? || config.password_plain.length <1
          pk_path = config.rsa_private_key
          pk = OpenSSL::PKey::RSA.new File.read(pk_path)
          decrypted_pass = pk.private_decrypt Base64::decode64(config.password_hash)
        else
          decrypted_pass = config.password_plain
        end

        overrides = {
          :url => config.url,
          :repository => get_current_repo,
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
      #puts "info: #{info}"
      info
    end

    def search_for_artifact(coordinate)
      begin
        remote = nexus_remote
        nexus = remote.nexus
        #puts nexus.inspect
        info = remote.search_for_artifacts(coordinate)
      rescue Exception => e
        raise "Failed to search: #{e.message}"
      end
    end

    def get_license_info
      remote = nexus_remote
      if remote.respond_to? 'get_license_info'
        remote.get_license_info
      else
        'Only supported on professional version.'
      end
    end

    def get_repository_info(coordinate)
      remote = nexus_remote
      info = nil
      begin
        info = remote.get_repository_info(coordinate)
      rescue NexusCli::RepositoryNotFoundException => e
        info = "Repository not found"
      end
      #puts "info: #{info}"
      info
    end

    def delete_artifact(coordinate)
      remote = nexus_remote
      remote.delete_artifact(coordinate)
    end

    def get_current_repo
      config.current_repository || config.default_repository
    end

    def push_artifact(coordinate, file_path)
      remote = nexus_remote
      begin
        #boolean result
        success = remote.push_artifact(coordinate, file_path)
      rescue Exception => e
        raise "Failed to push artifact, #{e.message}"
      end
    end

    def search_with_lucene(coordinate)
      remote = nexus_remote
      nexus = remote.nexus
      artifact = NexusCli::Artifact.new(coordinate)
      query = {:g => artifact.group_id, :a => artifact.artifact_id, :e => artifact.extension, :v => artifact.version, :r => get_current_repo}
      query.merge!({:c => artifact.classifier}) unless artifact.classifier.nil?
      response = nexus.get(remote.nexus_url("service/local/lucene/search"), query)
      case response.status
        when 200
          return response.content
        else
          raise UnexpectedStatusCodeException.new(response.status)
      end
    end

  end#module Remote
end #module helper
