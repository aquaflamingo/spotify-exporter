# frozen_string_literal: true

require "thor"
require_relative "version"
require_relative "command/playlists"
require_relative "auth"

module SpotifyExporter
  #
  # The CLI spotify exporter
  #
  class CLI < Thor
    package_name "spotifyexporter"

    # Returns exit with non zero status when an exception occurs
    def self.exit_on_failure?
      true
    end

    #
    # Returns version of the cli
    #
    desc "version", "Prints the current version"
    def version
      puts SpotifyExporter::VERSION
    end

    desc "auth", "Authorizes the CLI with Spotify API"
    def auth
      workflow = AuthWorkflow.new
      workflow.start
    end

    desc "playlists", "List playlists"
    subcommand "playlists", Playlists
  end
end
