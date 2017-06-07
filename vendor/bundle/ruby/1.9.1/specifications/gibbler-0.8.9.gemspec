# -*- encoding: utf-8 -*-
# stub: gibbler 0.8.9 ruby lib

Gem::Specification.new do |s|
  s.name = "gibbler".freeze
  s.version = "0.8.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Delano Mandelbaum".freeze]
  s.date = "2011-02-11"
  s.description = "Gibbler: Git-like hashes for Ruby objects".freeze
  s.email = "delano@solutious.com".freeze
  s.extra_rdoc_files = ["LICENSE.txt".freeze, "README.rdoc".freeze]
  s.files = ["LICENSE.txt".freeze, "README.rdoc".freeze]
  s.homepage = "http://github.com/delano/gibbler".freeze
  s.rdoc_options = ["--charset=UTF-8".freeze]
  s.rubyforge_project = "gibbler".freeze
  s.rubygems_version = "2.6.12".freeze
  s.summary = "Gibbler: Git-like hashes for Ruby objects".freeze

  s.installed_by_version = "2.6.12" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<attic>.freeze, [">= 0.4.0"])
    else
      s.add_dependency(%q<attic>.freeze, [">= 0.4.0"])
    end
  else
    s.add_dependency(%q<attic>.freeze, [">= 0.4.0"])
  end
end
