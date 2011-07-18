Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  s.name              = 'ircd_campf'
  s.version           = '0.0.1'
  s.date              = '2010-06-08'
  s.rubyforge_project = 'ircd_campf'

  s.summary     = "Campfire - IRC bridge"
  s.description = "If you are an IRC user you'll often miss the comfort of your IRC client. ircd_campf exists so you can use your favorite IRC client to chat in campfire."

  s.authors  = ["Emmanuel Oga"]
  s.email    = 'EmmanuelOga@gmail.com'
  s.homepage = 'http://github.com/emmanueloga'

  s.require_paths = %w[lib]

  # s.require_paths << 'ext'
  # s.extensions = %w[ext/extconf.rb]

  # s.executables = ["name"]
  # s.default_executable = 'name'

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README LICENSE]

  # s.add_dependency('DEPNAME', [">= 1.1.0", "< 2.0.0"])

  s.add_development_dependency('rspec', [">= 1.3.0", "< 2.0.0"])

  # = MANIFEST =
  s.files = %w[
    LICENSE
    Rakefile
    ircd_campf.gemspec
    lib/ircd_campf.rb
    spec/spec_helper.rb
  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^spec\/.+/ }
end
