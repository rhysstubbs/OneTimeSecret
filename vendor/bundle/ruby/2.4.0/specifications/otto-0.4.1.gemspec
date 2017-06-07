# -*- encoding: utf-8 -*-
# stub: otto 0.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "otto".freeze
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Delano Mandelbaum".freeze]
  s.date = "2015-04-07"
  s.description = "Auto-define your rack-apps in plaintext.".freeze
  s.email = "delano@solutious.com".freeze
  s.extra_rdoc_files = ["LICENSE.txt".freeze, "README.md".freeze]
  s.files = ["LICENSE.txt".freeze, "README.md".freeze]
  s.homepage = "http://github.com/delano/otto".freeze
  s.rubyforge_project = "otto".freeze
  s.rubygems_version = "2.6.12".freeze
  s.summary = "Auto-define your rack-apps in plaintext.".freeze

  s.installed_by_version = "2.6.12" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>.freeze, [">= 1.2.1"])
      s.add_runtime_dependency(%q<addressable>.freeze, [">= 2.2.6"])
    else
      s.add_dependency(%q<rack>.freeze, [">= 1.2.1"])
      s.add_dependency(%q<addressable>.freeze, [">= 2.2.6"])
    end
  else
    s.add_dependency(%q<rack>.freeze, [">= 1.2.1"])
    s.add_dependency(%q<addressable>.freeze, [">= 2.2.6"])
  end
end
