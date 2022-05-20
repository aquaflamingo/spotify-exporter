# frozen_string_literal: true

require_relative "lib/spotifyexporter/version"

Gem::Specification.new do |spec|
  spec.name = "spotifyexporter"
  spec.version = SpotifyExporter::VERSION
  spec.authors = ["aquaflamingo"]
  spec.email = ["16901597+aquaflamingo@users.noreply.github.com"]

  spec.summary = "Export your Spotify playlists"
  spec.description = "Export your Spotify playlists"
  spec.homepage = "https://github.com/aquaflamingo/spotify-exporter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/aquaflamingo/spotify-exporter"
  spec.metadata["changelog_uri"] = "https://github.com/aquaflamingo/spotify-exporter/releases"
 
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rspotify", "~> 1.0"
  spec.add_dependency "tty-prompt", "~> 0.23.1"
  spec.add_dependency "thor", "~> 1.2.1"

  spec.add_development_dependency "pry"
end
