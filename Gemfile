source "http://rubygems.org"

# Specify your gem's dependencies in guard-phpunit2.gemspec
gemspec

gem 'rake'
gem 'pry', '0.9.12.2'

require 'rbconfig'

platforms :ruby do
  if RbConfig::CONFIG['target_os'] =~ /darwin/i
    gem 'rb-fsevent', '~> 0.9.1'
    gem 'growl',      '~> 1.0.3'
  end
  if RbConfig::CONFIG['target_os'] =~ /linux/i
    gem 'rb-inotify', '~> 0.8.8'
    gem 'libnotify',  '~> 0.7.3'
  end
end

platforms :jruby do
  if RbConfig::CONFIG['target_os'] =~ /darwin/i
    gem 'growl',      '~> 1.0.3'
  end
  if RbConfig::CONFIG['target_os'] =~ /linux/i
    gem 'rb-inotify', '~> 0.8.8'
    gem 'libnotify',  '~> 0.7.3'
  end
end
