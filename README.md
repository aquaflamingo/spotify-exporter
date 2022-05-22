# SpotifyExporter

Export or backup your Spotify playlists

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spotifyexporter'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install spotifyexporter

## Usage

You will need to authenticate the CLI before you can use it.

You can generate a Spotify API Key at: https://developer.spotify.com/dashboard/applications

After you have an API Key available, run the `auth` command and enter your credentials:

```bash

spotifyexporter auth

```

The CLI will persist these credentials on your file system within the `.config` directory.

Next, you can run the `export` command to get a full list of songs in each playlist for a particular user.

```bash

# Create an output directory
mkdir output_dir

# Run the export command for username "djkoze", generate playlists in .m3u format
spotifyexporter export -u djkoze -o output_dir -f m3u
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aquaflamingo/spotifyexporter.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
