require 'nokogiri'
require 'versionomy'


module Lita
  module Handlers
    class Nexus < Handler

      namespace 'Nexus'

      # insert handler code here
      config :url, required: true, type: String
      config :username, required: true, type: String
      #use either plain password or encrypted one
      config :password_hash, required: false, type: String
      config :password_plain, required: false, type: String
      config :default_repository, required: false, type: String
      config :verify_ssl, required: false, type: [TrueClass,FalseClass], default: false
      config :rsa_private_key, required: true, type: String
      config :current_repository, required: false, type: String
      config :search_limit, required: false, type: Integer, default: 5


      include ::LitaNexusHelper::Remote

      route(
        /^nexus\s+artifact\s+info\s+(\S+)\s*$/,
        :cmd_artifact_info,
        command: true,
        help: {
          t('help.cmd_artifact_info_key') => t('help.cmd_artifact_info_value')
        }
      )

      route(
        /^nexus\s+search\s+artifact\s+([\S:]+)(?>\s+limit\s+)?(\d+)?\s*$/,
        :cmd_search_artifact,
        command: true,
        help: {
          t('help.cmd_search_artifact_key') => t('help.cmd_search_artifact_value')
        }
      )

      route(
        /^nexus\s+license\s+info\s*$/,
        :cmd_license_info,
        command: true,
        help: {
          t('help.cmd_license_info_key') => t('help.cmd_license_info_value')
        }
      )

      route(
        /^nexus\s+repo\s+info\s+(\S+)\s*$/,
        :cmd_repo_info,
        command: true,
        help: {
          t('help.cmd_repo_info_key') => t('help.cmd_repo_info_value')
        }
      )

      route(
        /^nexus\s+delete\s+artifact\s+(\S+)\s*$/,
        :cmd_delete_artifact,
        command: true,
        help: {
          t('help.cmd_delete_artifact_key') => t('help.cmd_delete_artifact_value')
        }
      )

      route(
        /^nexus\s+show\s+current\s+repo\s*$/,
        :cmd_show_current_repository,
        command: true,
        help: {
          t('help.cmd_show_repo_key') => t('help.cmd_show_repo_value')
        }
      )

      route(
        /^nexus\s+set\s+current\s+repo\s+(\S+)\s*$/,
        :cmd_set_current_repository,
        command: true,
        help: {
          t('help.cmd_set_repo_key') => t('help.cmd_set_repo_value')
        }
      )

      route(
        /^nexus\s+get\s+artifact\s+versions\s+(\S+)\s*$/,
        :cmd_get_artifact_versions,
        command: true,
        help: {
          t('help.cmd_get_artifact_versions_key') => t('help.cmd_get_artifact_versions_value')
        }
      )

      def cmd_artifact_info(response)
        coordinate = response.matches[0][0]
        info = get_artifact_info(coordinate)
        response.reply info
      end

      def cmd_search_artifact(response)
        coordinate = response.matches[0][0]
        limit = response.matches[0][1]
        return_limit  = nil
        if !limit.nil? && ! limit.empty?
          return_limit = Integer(limit)
        end
        begin
          info = search_for_artifact(coordinate)
          # now parsing xml result
          dom = Nokogiri::XML(info)do |config|
            config.strict.nonet
          end
          total_count = dom.xpath('//totalCount').text
          data = dom.xpath('//artifact')
          all_versions = {}
          data.each do |artifact|
            version_str= artifact.xpath('version').text
            artifact_output = StringIO.open do |s|
              s.puts "[Coordinate] #{artifact.xpath('groupId').text}:#{artifact.xpath('artifactId').text}:#{artifact.xpath('version').text}:#{artifact.xpath('packaging').text}"
              s.puts "[Download URL] #{artifact.xpath('resourceURI').text}"
              s.puts "[Repository] #{artifact.xpath('repoId').text}(#{artifact.xpath('contextId').text})"
              s.string
            end
            all_versions[version_str]= artifact_output
          end

          response.reply "Artifact found: #{all_versions.size}, showing max #{return_limit||config.search_limit} of latest version"
          out_artifacts = []
          unless all_versions.empty?
            all_versions.sort_by {|k,v|
              Versionomy.parse(k)
            }
            tmp_artifacts = all_versions.values.reverse
            out_artifacts = tmp_artifacts.first(return_limit||config.search_limit)
          end
          index = 0
          out_artifacts.each do |artifact|
            index = index +1
            response.reply "Artifact #{index}:"
            response.reply artifact
          end
        rescue Exception =>e
          response.reply e.message
        end
      end

      def cmd_license_info(response)
        info = get_license_info
        response.reply info
      end

      def cmd_repo_info(response)
        repo_name = response.matches[0][0]
        info = get_repository_info repo_name
        response.reply info
      end

      def cmd_delete_artifact(response)
        coordinate = response.matches[0][0]
        begin
          delete_artifact(coordinate)
          response.reply "Artifact deleted successfully."
        rescue Exception => e
          response.reply e.message
        end
      end

      def cmd_set_current_repository(response)
        repo = response.matches[0][0]
        if repo && repo.strip.length >0
          config.current_repository = repo
        end
        response.reply "Success: current repository is changed to #{repo}."
      end

      def cmd_show_current_repository(response)
        current_repo = get_current_repo
        response.reply "Current repository is #{current_repo}"

      end

      def cmd_push_artifact(coordinate, file_path)
         push_artifact(coordinate, file_path)
      end

      def cmd_get_artifact_versions(response)
        coordinate = response.matches[0][0]
        begin
          info = search_for_artifact(coordinate)
          # now parsing xml result
          dom = Nokogiri::XML(info)do |config|
            config.strict.nonet
          end

          data = dom.xpath('//artifact/version')
          versions =[]
          data.each do |version|
            versions << version.text
          end
          versions.sort {|x,y|
            Versionomy.parse(x) <=> Versionomy.parse(y)
          }
          response.reply versions.to_s
        rescue Exception =>e
          response.reply e.message
        end

      end
      Lita.register_handler(self)
    end
  end
end
