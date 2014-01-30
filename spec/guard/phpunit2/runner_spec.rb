require 'spec_helper'

describe Guard::PHPUnit2::Runner do

  let(:formatter) { Guard::PHPUnit2::Formatter }
  let(:logreader) { Guard::PHPUnit2::LogReader }
  let(:notifier)  { Guard::PHPUnit2::Notifier  }
  let(:ui)        { Guard::UI                 }

  describe '#run' do
    before do
      FileUtils.stub(:ln_s)
      FileUtils.stub(:mkdir_p)

      subject.stub(:execute_command)
      subject.stub(:phpunit_exists?).and_return(true)
      notifier.stub(:notify_results)

      $?.stub(:success?).and_return(true)
    end

    context 'when passed an empty paths list' do
      it 'returns false' do
        subject.run([]).should be_false
      end
    end

    shared_examples_for 'paths list not empty' do
      it 'checks that phpunit is installed' do
        subject.should_receive(:phpunit_exists?)
        subject.run( ['tests'] )
      end

      it 'displays an error when phpunit is not installed' do
        subject.stub(:phpunit_exists?).and_return(false)
        ui.should_receive(:error).with('the provided php unit command is invalid or phpunit is not installed on your machine.', anything)

        subject.run( ['tests'] )
      end

      it 'notifies about running the tests' do
        subject.should_receive(:notify_start).with( ['tests'], anything )
        subject.run( ['tests'] )
      end

      it 'runs phpunit tests' do
        subject.should_receive(:execute_command).with(
          %r{^phpunit .+$}
        ).and_return(true)
        subject.run( ['tests'] )
      end

      it 'runs phpunit tests with provided command' do
        formatter_path = @project_path.join('lib', 'guard', 'phpunit', 'formatters', 'PHPUnit-Progress')
        subject.should_receive(:execute_command).with(
          %r{^/usr/local/bin/phpunit --include-path #{formatter_path} --printer PHPUnit_Extensions_Progress_ResultPrinter .+$}
        ).and_return(true)
        subject.run( ['tests'] , {:command => '/usr/local/bin/phpunit'} )
      end

      it 'prints the tests output to the console' do
          output = load_phpunit_output('passing')
          subject.stub(:notify_start)
          subject.stub(:execute_command).and_return(output)

          #ui.should_receive(:info).with(output)

          subject.run( ['tests'] )
      end

      context 'when PHPUnit executes the tests' do
        it 'parses the tests log output' do
          log    = load_phpunit_output('passing-json')
          subject.stub(:execute_phpunit).and_return(log)

          logreader.should_receive(:parse_output).with(log)

          subject.run( ['tests'] )
        end

        it 'notifies about the tests output' do
          log = load_phpunit_output('passing-json')
          subject.stub(:execute_phpunit).and_return(log)
          subject.should_receive(:notify_results).with(log, anything())

          subject.run( ['tests'] )
        end

        it 'notifies about the tests output even when they contain failures' do
          $?.stub(:success? => false, :exitstatus => 1)

          output = load_phpunit_output('failing')
          subject.stub(:execute_command).and_return(output)
          subject.should_receive(:notify_results).with(anything(), anything())

          subject.run( ['tests'] )
        end

        it 'notifies about the tests output even when they contain errors' do
          $?.stub(:success? => false, :exitstatus => 2)

          output = load_phpunit_output('errors')
          subject.stub(:execute_command).and_return(output)
          subject.should_receive(:notify_results).with(anything(), anything())

          subject.run( ['tests'] )
        end

        it 'does not notify about failures' do
          subject.should_receive(:execute_command)
          subject.should_not_receive(:notify_failure)
          subject.run( ['tests'] )
        end
      end

      context 'when PHPUnit fails to execute' do
        before do
          $?.stub(:success? => false, :exitstatus => 255)
          notifier.stub(:notify)
        end

        it 'notifies about the failure' do
          subject.should_receive(:execute_command)
          subject.should_receive(:notify_failure)
          subject.run( ['tests'] )
        end

        it 'does not notify about the tests output' do
          subject.should_not_receive(:notify_results)
          subject.run( ['tests'] )
        end
      end

      describe 'options' do
        describe ':cli' do
          it 'runs with CLI options passed to PHPUnit' do
            cli_options = '--colors --verbose'
            subject.should_receive(:execute_command).with(
              %r{^phpunit --include-path .* --printer .* #{cli_options} .+$}
            ).and_return(true)
            subject.run( ['tests'], :cli => cli_options )
          end
        end

        describe ':notification' do
          it 'does not notify about tests output with notification option set to false' do
            formatter.should_not_receive(:notify)
            subject.run( ['tests'], :notification => false )
          end
        end
      end
    end

    context 'when passed one path' do
      it_should_behave_like 'paths list not empty'

      it 'should not create a test folder' do
        Dir.should_not_receive(:mktmpdir)
        subject.run( ['spec/fixtures/sampleTest.php'] )
      end
    end

    context 'when passed multiple paths' do
      it_should_behave_like 'paths list not empty'

      it 'creates a tests folder (tmpdir)' do
        subject.should_receive(:create_tests_folder_for).with(instance_of(Array))
        subject.stub(:execute_phpunit).and_return(load_phpunit_output('passing-json'))
        subject.stub(:notify_results)
        subject.run( ['spec/fixtures/sampleTest.php', 'spec/fixtures/emptyTest.php'] )
      end

      it 'symlinks passed paths to the tests folder' do
        subject.should_receive(:symlink_paths_to_tests_folder).with(anything(), anything())
        subject.run( ['spec/fixtures/sampleTest.php', 'spec/fixtures/emptyTest.php'] )
      end
    end
  end
end
