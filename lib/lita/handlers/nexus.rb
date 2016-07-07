module Lita
  module Handlers
    class Nexus < Handler

      namespace 'Nexus'

      # insert handler code here
      config :url, required: true, type: String
      config :username, required: true, type: String
      config :password_hash, required: true, type: String
      config :default_repository, required: false, type: String
      config :verify_ssl, required: false, type: [TrueClass,FalseClass], default: false
      config :rsa_private_key, required: true, type: String
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
      Lita.register_handler(self)
    end
  end
end
