# -*- encoding: utf-8 -*-
# stub: httparty 0.7.7 ruby lib

Gem::Specification.new do |s|
  s.name = "httparty"
  s.version = "0.7.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["John Nunemaker", "Sandro Turriate"]
  s.date = "2011-04-20"
  s.description = "Makes http fun! Also, makes consuming restful web services dead easy."
  s.email = ["nunemaker@gmail.com"]
  s.executables = ["httparty"]
  s.files = ["bin/httparty"]
  s.homepage = "http://httparty.rubyforge.org/"
  s.post_install_message = "When you HTTParty, you must party hard!"
  s.rubygems_version = "2.5.1"
  s.summary = "Makes http fun! Also, makes consuming restful web services dead easy."

  s.installed_by_version = "2.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<crack>, ["= 0.1.8"])
      s.add_development_dependency(%q<activesupport>, ["~> 2.3"])
      s.add_development_dependency(%q<cucumber>, ["~> 0.7"])
      s.add_development_dependency(%q<fakeweb>, ["~> 1.2"])
      s.add_development_dependency(%q<rspec>, ["~> 1.3"])
      s.add_development_dependency(%q<mongrel>, ["= 1.2.0.pre2"])
    else
      s.add_dependency(%q<crack>, ["= 0.1.8"])
      s.add_dependency(%q<activesupport>, ["~> 2.3"])
      s.add_dependency(%q<cucumber>, ["~> 0.7"])
      s.add_dependency(%q<fakeweb>, ["~> 1.2"])
      s.add_dependency(%q<rspec>, ["~> 1.3"])
      s.add_dependency(%q<mongrel>, ["= 1.2.0.pre2"])
    end
  else
    s.add_dependency(%q<crack>, ["= 0.1.8"])
    s.add_dependency(%q<activesupport>, ["~> 2.3"])
    s.add_dependency(%q<cucumber>, ["~> 0.7"])
    s.add_dependency(%q<fakeweb>, ["~> 1.2"])
    s.add_dependency(%q<rspec>, ["~> 1.3"])
    s.add_dependency(%q<mongrel>, ["= 1.2.0.pre2"])
  end
end
