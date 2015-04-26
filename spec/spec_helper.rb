require 'rspec'
require 'guard/notifier'
require 'guard/compat/test/helper'
require 'guard/phpunit2'

RSpec.configure do |config|

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.color = true
  config.raise_errors_for_deprecations!
  config.filter_run :focus

  config.before(:each) do
    ENV['GUARD_ENV'] = 'test'
    @project_path    = Pathname.new(File.expand_path('../../', __FILE__))
  end

  config.after(:each) do
    ENV['GUARD_ENV'] = nil
  end

end

def load_phpunit_output(name)
  File.read(File.expand_path("fixtures/results/#{name}.txt", File.dirname(__FILE__)))
end
