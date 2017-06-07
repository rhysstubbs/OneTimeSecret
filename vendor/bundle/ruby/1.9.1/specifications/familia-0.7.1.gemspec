# -*- encoding: utf-8 -*-
# stub: familia 0.7.1 ruby lib

Gem::Specification.new do |s|
  s.name = "familia".freeze
  s.version = "0.7.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Delano Mandelbaum".freeze]
  s.date = "2011-04-11"
  s.description = "Organize and store ruby objects in Redis".freeze
  s.email = "delano@solutious.com".freeze
  s.extra_rdoc_files = ["LICENSE.txt".freeze, "README.rdoc".freeze]
  s.files = ["LICENSE.txt".freeze, "README.rdoc".freeze]
  s.homepage = "http://github.com/delano/familia".freeze
  s.rdoc_options = ["--charset=UTF-8".freeze]
  s.rubyforge_project = "familia".freeze
  s.rubygems_version = "2.6.12".freeze
  s.summary = "Organize and store ruby objects in Redis".freeze

  s.installed_by_version = "2.6.12" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<redis>.freeze, [">= 2.1.0"])
      s.add_runtime_dependency(%q<uri-redis>.freeze, [">= 0.4.2"])
      s.add_runtime_dependency(%q<gibbler>.freeze, [">= 0.8.6"])
      s.add_runtime_dependency(%q<storable>.freeze, [">= 0.8.6"])
      s.add_runtime_dependency(%q<multi_json>.freeze, [">= 0.0.5"])
    else
      s.add_dependency(%q<redis>.freeze, [">= 2.1.0"])
      s.add_dependency(%q<uri-redis>.freeze, [">= 0.4.2"])
      s.add_dependency(%q<gibbler>.freeze, [">= 0.8.6"])
      s.add_dependency(%q<storable>.freeze, [">= 0.8.6"])
      s.add_dependency(%q<multi_json>.freeze, [">= 0.0.5"])
    end
  else
    s.add_dependency(%q<redis>.freeze, [">= 2.1.0"])
    s.add_dependency(%q<uri-redis>.freeze, [">= 0.4.2"])
    s.add_dependency(%q<gibbler>.freeze, [">= 0.8.6"])
    s.add_dependency(%q<storable>.freeze, [">= 0.8.6"])
    s.add_dependency(%q<multi_json>.freeze, [">= 0.0.5"])
  end
end
