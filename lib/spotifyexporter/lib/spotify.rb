# frozen_string_literal: true

require "rspotify"

class SpotifyClient
  def initialize(conf)
    RSpotify.authenticate(
      conf.spotify_client_id,
      conf.spotify_client_secret
    )
  end

  #
  # GETs a user
  #
  # @param uname [String]
  #
  def get_user(uname)
    RSpotify::User.find(uname)
  end

  #
  # GETs all playlists for a user
  #
  # @param uname [String]
  #
  def get_user_playlists(uname)
    u = get_user(uname)

    playlists = []
    offset = 0
    last_pull_count = 0

    # You can only pull from API in increments of 50
    # if the last pull count is a multiple of 50
    # we know we can keep pulling, if not, stop
    while (last_pull_count % 50).zero?
      p = u.playlists(limit: 50, offset: offset)

      playlists << p

      offset += 50

      last_pull_count = p.count
    end

    playlists.compact.flatten
  end
end
