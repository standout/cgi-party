
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cgi_party/version"

Gem::Specification.new do |spec|
  spec.name          = "cgi_party"
  spec.version       = CGIParty::VERSION
  spec.authors       = ["Emric","Stavros"]
  spec.email         = ["w.e.w@live.se","stavros.gemitzoglou@standout.se"]

  spec.summary       = %q{Makes CGI Group GRP integration a party! <3}
  spec.homepage      = "https://github.com/standout/cgi-party"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "savon", "~> 2.0"

  spec.add_development_dependency "bundler", "~> 1.17.3"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "timecop"
end
