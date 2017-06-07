# -*- encoding: utf-8 -*-
# stub: mustache 0.99.3 ruby lib

Gem::Specification.new do |s|
  s.name = "mustache".freeze
  s.version = "0.99.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Chris Wanstrath".freeze, "Magnus Holm".freeze, "Pieter van de Bruggen".freeze]
  s.date = "2011-03-19"
  s.description = "Inspired by ctemplate, Mustache is a framework-agnostic way to render\nlogic-free views.\n\nAs ctemplates says, \"It emphasizes separating logic from presentation:\nit is impossible to embed application logic in this template\nlanguage.\n\nThink of Mustache as a replacement for your views. Instead of views\nconsisting of ERB or HAML with random helpers and arbitrary logic,\nyour views are broken into two parts: a Ruby class and an HTML\ntemplate.\n".freeze
  s.email = "chris@ozmm.org".freeze
  s.executables = ["mustache".freeze]
  s.files = ["bin/mustache".freeze]
  s.homepage = "http://github.com/defunkt/mustache".freeze
  s.rubygems_version = "2.6.12".freeze
  s.summary = "Mustache is a framework-agnostic way to render logic-free views.".freeze

  s.installed_by_version = "2.6.12" if s.respond_to? :installed_by_version
end
