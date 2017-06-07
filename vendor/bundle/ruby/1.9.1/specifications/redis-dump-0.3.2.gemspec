# -*- encoding: utf-8 -*-
# stub: redis-dump 0.3.2 ruby lib

Gem::Specification.new do |s|
  s.name = "redis-dump".freeze
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Delano Mandelbaum".freeze]
  s.date = "2012-01-05"
  s.description = "Backup and restore your Redis data to and from JSON.".freeze
  s.email = "delano@solutious.com".freeze
  s.executables = ["redis-dump".freeze, "redis-load".freeze, "redis-report".freeze]
  s.extra_rdoc_files = ["LICENSE.txt".freeze, "README.rdoc".freeze]
  s.files = ["LICENSE.txt".freeze, "README.rdoc".freeze, "bin/redis-dump".freeze, "bin/redis-load".freeze, "bin/redis-report".freeze]
  s.homepage = "http://github.com/delano/redis-dump".freeze
  s.rubyforge_project = "redis-dump".freeze
  s.rubygems_version = "2.6.12".freeze
  s.summary = "Backup and restore your Redis data to and from JSON.".freeze

  s.installed_by_version = "2.6.12" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<yajl-ruby>.freeze, [">= 0.1"])
      s.add_runtime_dependency(%q<redis>.freeze, [">= 2.0"])
      s.add_runtime_dependency(%q<uri-redis>.freeze, [">= 0.4.0"])
      s.add_runtime_dependency(%q<drydock>.freeze, [">= 0.6.9"])
    else
      s.add_dependency(%q<yajl-ruby>.freeze, [">= 0.1"])
      s.add_dependency(%q<redis>.freeze, [">= 2.0"])
      s.add_dependency(%q<uri-redis>.freeze, [">= 0.4.0"])
      s.add_dependency(%q<drydock>.freeze, [">= 0.6.9"])
    end
  else
    s.add_dependency(%q<yajl-ruby>.freeze, [">= 0.1"])
    s.add_dependency(%q<redis>.freeze, [">= 2.0"])
    s.add_dependency(%q<uri-redis>.freeze, [">= 0.4.0"])
    s.add_dependency(%q<drydock>.freeze, [">= 0.6.9"])
  end
end
