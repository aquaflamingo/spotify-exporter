require "thor"
require "fileutils"
require_relative '../config.rb'
require_relative '../lib/spotify.rb'

module SpotifyExporter
  class Playlists < Thor
    include ConfigDependant

    desc "ls", "Lists playlist"
    option :user, required: true, aliases: "-u"
    option :url, required: false, aliases: "-l"
    def ls 
      pl = spotify.get_user_playlists(options.user)

      results = pl.map do |p| 
        r = p.name

        r << " | #{p.external_urls["spotify"]}" unless options.url.nil?

        r
      end

      puts results
    end

    desc "export", "Exports playlists"
    option :user, required: true, aliases: "-u"
    option :output_directory, required: true, aliases: "-o"
    option :all, required: false, aliases: "-a"
    def export 
      FileUtils.mkdir_p(options.output_directory) unless Dir.exist? options.output_directory

      pl = spotify.get_user_playlists(options.user)

      # For each playlist 
      pl.each do |p|
        # Remove non-alphanumeric characters
        sanitized_name = p.name.gsub(/[^[:alnum:]]/, "")
        playlist_file_name = File.join(options.output_directory, sanitized_name)

        # Create a file for the playlist 
        File.open(playlist_file_name, "w") do |f|

          # Write the name of each artist and song 
          p.tracks.each do |t| 
            artists = t.artists.map(&:name).join(", ")

            f.puts "#{artists} - #{t.name}"
          end
        end
      end
    end

    private
    #
    # SpotifyClient
    #
    def spotify
      return @spotify unless @spotify.nil?

      @spotify = SpotifyClient.new(config)

      @spotify
    end
  end
end
