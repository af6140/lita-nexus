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
        /^nexus\s+search\s+artifact\s+(\S+)\s*$/,
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


      def cmd_artifact_info(response)
        coordinate = response.matches[0][0]
        puts "coordinate  = #{coordinate}"
        info = get_artifact_info(coordinate)
        response.reply info
      end

      def cmd_search_artifact(response)
        coordinate = response.matches[0][0]
        puts "coordinate  = #{coordinate}"
        info = search_for_artifact(coordinate)
        response.reply info
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
        response.reply "Current repository is changed to #{repo}."
      end

      def cmd_show_current_repository(response)
        current_repo = get_current_repo
        response.reply "Current repository is #{current_repo}"

      end

      Lita.register_handler(self)
    end
  end
end
