require 'tty-prompt'
require_relative '../config.rb'

module SpotifyExporter
  class AuthWorkflow 
    def start
      auth = prompt_for_auth

      ConfigManager.instance.save_auth(
        client_id: auth[:spotify_client_id], 
        secret: auth[:spotify_client_secret]
      )
    end

    private
    # Creates an interactive prompt for user input
    #
    # @returns [Hash]
    def prompt_for_auth
      prompt = TTY::Prompt.new

      prompt.collect do |_p|
        # Project name
        key(:spotify_client_id).ask("Enter Spotify Client ID: ") do |q|
          q.required true
        end

        # Project description
        key(:spotify_client_secret).ask("Enter Spotify Client Secret: ") do |q|
          q.required true
        end
      end
    end
  end
end
