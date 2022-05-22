# frozen_string_literal: true

require "thor"
require "fileutils"
require "playlist"
require_relative "../config"
require_relative "../lib/spotify"

module SpotifyExporter
  class Playlists < Thor
    include ConfigDependant

    SUPPORTED_PLAYLIST_FORMATS = %w[m3u pls xspf txt yml].freeze

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
    option :format, required: false, aliases: "-f", default: "txt"
    def export
      FileUtils.mkdir_p(options.output_directory) unless Dir.exist? options.output_directory
      validate_format!(options.format)

      spotify_playlists = spotify.get_user_playlists(options.user)

      # For each playlist
      spotify_playlists.each do |spotify_pl|
        # Remove non-alphanumeric characters
        # Replace all spaces with underscores
        sanitized_name = spotify_pl.name.gsub(/[^[:alnum:]^[:space:]]/, "").chomp

        playlist = Playlist.new(
          title: sanitized_name,
          description: spotify_pl.description,
          creator: options.user,
          # Use the first image
          image: spotify_pl.images.first["url"]
        )

        # For each track in the Spotify playlist,
        # create a new playlist track with title and contributors, then
        # add it to the playlist.
        spotify_pl.tracks.each do |spotify_track|
          track = Playlist::Track.new(
            title: spotify_track.name,
            duration: spotify_track.duration_ms
          )

          spotify_track.artists.each do |artist|
            track.add_contributor(name: artist.name)
          end

          playlist.add_track(track)
        end

        # Write the playlist to disk
        save_playlist(playlist, options.format)
      end
    end

    private

    #
    # Saves the playlist in the requested format to disk
    #
    # @param playlist [Playlist]
    # @param format [String]
    #
    def save_playlist(playlist, format)
      # Sanitize the name for file system, remove spaces and
      # replace with underscores
      fname = playlist.title.gsub(/\s/, "_")

      suffix = format
      playlist_file_name = File.join(options.output_directory, "#{fname}.#{suffix}")

      # Create a file for the playlist
      File.open(playlist_file_name, "wb") do |f|
        # Use the provided format to generate a playlist

        generated_playlist_blob = case format.to_sym
                                  when :m3u
                                    Playlist::Format::M3U.generate(playlist)
                                  when :pls
                                    Playlist::Format::PLS.generate(playlist)
                                  when :xspf
                                    Playlist::Format::XSPF.generate(playlist)
                                  when :yml
                                    generate_yml_playlist(playlist)
                                  else
                                    # Use default generation
                                    generate_txt_playlist(playlist)
                                  end

        f.write generated_playlist_blob
      end
    end

    #
    # Creates a txt playlist blob
    #
    def generate_txt_playlist(playlist)
      <<~EOF
        Title: #{playlist.title}
        Creator: #{playlist.creator}
        Description: #{playlist.description}
        Image: #{playlist.image}

        ---

        #{playlist.tracks.map { |t| "#{t.artist} - #{t.title}" }.join("\n")}

      EOF
    end

    #
    # Creates a yaml playlist blob
    #
    # @param playlist [Playlist]
    # @return [YAML]
    #
    def generate_yml_playlist(playlist)
      tracks = playlist.tracks.map do |t|
        { artist: t.artist, title: t.title }
      end

      {
        title: playlist.title,
        creator: playlist.creator,
        description: playlist.description,
        image: playlist.image,
        tracks: tracks,
      }.to_yaml
    end

    #
    # Raises an error if invalid format supplied
    #
    # @raise ArgumentError
    #
    def validate_format!(format)
      err = "invalid playlist format: #{format}. Must be one of: #{SUPPORTED_PLAYLIST_FORMATS.join(", ")}"

      raise ArgumentError, err unless SUPPORTED_PLAYLIST_FORMATS.include?(format)
    end

    #
    # Client for Spotify Developer API
    #
    # @return [SpotifyClient]
    def spotify
      return @spotify unless @spotify.nil?

      @spotify = SpotifyClient.new(config)

      @spotify
    end
  end
end
