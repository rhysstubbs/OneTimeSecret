# -*- encoding: utf-8 -*-
# stub: annoy 0.5.6 ruby lib

Gem::Specification.new do |s|
  s.name = "annoy".freeze
  s.version = "0.5.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Delano Mandelbaum".freeze]
  s.date = "2010-02-20"
  s.description = "Annoy: Like your annoying friend that asks you questions all the time.".freeze
  s.email = "delano@solutious.com".freeze
  s.extra_rdoc_files = ["README.rdoc".freeze, "LICENSE.txt".freeze]
  s.files = ["LICENSE.txt".freeze, "README.rdoc".freeze]
  s.homepage = "http://solutious.com/".freeze
  s.rdoc_options = ["--line-numbers".freeze, "--title".freeze, "Annoy: Like your annoying friend that asks you questions all the time.".freeze, "--main".freeze, "README.rdoc".freeze]
  s.rubyforge_project = "annoy".freeze
  s.rubygems_version = "2.6.12".freeze
  s.summary = "Annoy: Like your annoying friend that asks you questions all the time.".freeze

  s.installed_by_version = "2.6.12" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<highline>.freeze, [">= 1.5.0"])
    else
      s.add_dependency(%q<highline>.freeze, [">= 1.5.0"])
    end
  else
    s.add_dependency(%q<highline>.freeze, [">= 1.5.0"])
  end
end
