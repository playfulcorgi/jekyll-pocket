require_relative 'lib/jekyll_pocket_links/version'

Gem::Specification.new do |spec|
  spec.name = "jekyll-pocket-links"
  spec.version = Jekyll::Pocket::VERSION
  spec.authors = ["playfulcorgi"]
  spec.email = ["unrulybeardedweekend@gmail.com"]
  spec.homepage = "https://github.com/playfulcorgi/jekyll-pocket-links"
  spec.license = "MIT"
  spec.summary = "Fetch and render Pocket links in Jekyll."
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.5.0"
  spec.add_runtime_dependency "jekyll", ">= 4.0.0"
end
