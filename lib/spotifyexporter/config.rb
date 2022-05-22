# frozen_string_literal: true

require "fileutils"
require "yaml"
require "singleton"
require "pry"
require_relative "./lib/injectable"

module SpotifyExporter
  module ConfigDependant
    include Injectable

    inject :config, -> { ConfigManager.instance.config }
  end

  class AppConfig
    attr_accessor :spotify_client_id, :spotify_client_secret

    def initialize(id, secret)
      @spotify_client_id = id
      @spotify_client_secret = secret
    end

    def to_yaml
      to_h.to_yaml
    end

    def credentials?
      !@spotify_client_secret.nil? && !@spotify_client_id.nil?
    end

    def self.new_empty
      new("", "")
    end

    private

    def to_h
      { spotify_client_id: @spotify_client_id, spotify_client_secret: @spotify_client_secret }
    end
  end

  class ConfigManager
    include Singleton

    attr_reader :config_path

    DEFAULT_CONFIG_DIR = ".config/spotifyexporter"

    FILE_CLI_CONFIG = "config.yml"

    #
    # Loads and saves the credentials to the main configuration
    #
    # @return [Boolean]
    #
    def save_credentials(client_id:, secret:)
      load_config_file unless config_loaded?

      @app_config.spotify_client_id = client_id
      @app_config.spotify_client_secret = secret

      save_config!
    end

    #
    # Retrieves the AppConfig
    #
    # @return [AppConfig]
    #
    def config
      load_config_file unless config_loaded?

      @app_config
    end

    private

    #
    # Saves the currently in-memory configuration
    #
    # @return success [Boolean]
    #
    def save_config!
      File.open(config_file_path, "w") do |f|
        f.puts @app_config.to_yaml
      end

      true
    end

    def config_loaded?
      !@app_config.nil?
    end

    def config_dir_path
      @config_dir_path ||= File.join Dir.home, DEFAULT_CONFIG_DIR
    end

    def config_file_path
      @config_file_path ||= File.join(config_dir_path, FILE_CLI_CONFIG)
    end

    #
    # Reads the user file system configurations into the in-memory AppConfig
    #
    def load_config_file
      initialize_config_file unless config_file_exists?

      config_yaml = YAML.load_file(config_file_path)

      @app_config = if config_yaml.nil?
                      AppConfig.new_empty
                    else
                      AppConfig.new(config_yaml[:spotify_client_id], config_yaml[:spotify_client_secret])
                    end
    end

    def config_file_exists?
      return false unless File.exist? config_file_path
    end

    #
    # Initializes the configuration directory if non exists
    #
    def initialize_config_file
      FileUtils.mkdir_p(config_dir_path) unless Dir.exist? config_dir_path

      FileUtils.touch(config_file_path) unless File.exist? config_file_path
    end
  end
end
