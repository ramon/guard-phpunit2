require 'tmpdir'
require 'fileutils'

module Guard
  class PHPUnit2

    # The Guard::PHPUnit runner handles running the tests, displaying
    # their output and notifying the user about the results.
    #
    module Runner
      class << self

        # The exittcode phpunit returns when the tests contain failures
        #
        PHPUNIT_FAILURES_EXITCODE = 1

        # The exittcode phpunit returns when the tests contain errors
        #
        PHPUNIT_ERRORS_EXITCODE   = 2

        # Runs the PHPUnit tests and displays notifications
        # about the results.
        #
        # @param [Array<Strings>] path to the tests files.
        # @param (see PHPUnit#initialize)
        # @return [Boolean] whether the tests were run successfully
        #
        def run(paths, options = {})
          paths = Array(paths)

          return false if paths.empty?

          unless phpunit_exists?(options)
            UI.error('the provided php unit command is invalid or phpunit is not installed on your machine.', :reset => true)
            return false
          end

          run_tests(paths, options)
        end

        private

        # Checks that phpunit is installed on the user's
        # machine.
        #
        # @return [Boolean] The status of phpunit
        #
        def phpunit_exists?(options)
          command = "phpunit"
          command = options[:command] if options[:command]

          `#{command} --version`
          true
        rescue Errno::ENOENT
          false
        end

        # Executes the testing command on the tests
        # and returns the status of this process.
        #
        # @param (see #run)
        # @param (see #run)
        #
        def run_tests(paths, options)

          notify_start(paths, options)

          if paths.length == 1
            tests_path = paths.first
            log = execute_phpunit(tests_path, options)
          else
            create_tests_folder_for(paths) do |tests_folder|
              log = execute_phpunit(tests_folder, options)
            end
          end
          
          # return false in case the system call fails with no status!
          return false if $?.nil?

          # capture success so that if notifications alter the status stored in $? we still return the correct value
          success = $?.success?

          if success or tests_contain_failures? or tests_contain_errors?
            notify_results(log, options)
          else
            notify_failure(options)
          end

          success
        end

        # Displays the start testing notification.
        #
        # @param (see #run)
        # @param (see #run)
        #
        def notify_start(paths, options)
          message = options[:message] || "Running: #{paths.join(' ')}"
          UI.info(message, :reset => true)
        end

        # Displays a notification about the tests results.
        #
        # @param [String] output the tests output
        # @param (see #run)
        #
        def notify_results(log, options)
          results = LogReader.parse_output(log)
          Notifier.notify_results(results)
        end

        # Displays a notification about failing to run the tests
        #
        # @param (see #run)
        #
        def notify_failure(options)
          Notifier.notify('Failed! Check the console', :title => 'PHPUnit results', :image => :failed)
        end

        # Checks the exitstatus of the phpunit command
        # for a sign of failures in the tests.
        #
        # @return [Boolean] whether the tests contain failures or not
        #
        def tests_contain_failures?
          $?.exitstatus == PHPUNIT_FAILURES_EXITCODE
        end

        # Checks the exitstatus of the phpunit command
        # for a sign of errors in the tests.
        #
        # @return [Boolean] whether the tests contain errors or not
        #
        def tests_contain_errors?
          $?.exitstatus == PHPUNIT_ERRORS_EXITCODE
        end

        # Creates a temporary folder which has links to
        # the tests paths. This method is used because PHPUnit
        # can't run multiple tests files at the same time and generate
        # one result for them.
        #
        # @param (see #run)
        # @yield [String] d the temporary dir for the tests
        #
        def create_tests_folder_for(paths)
          Dir.mktmpdir('guard_phpunit') do |d|
            symlink_paths_to_tests_folder(paths, d)
            yield d
          end
        end

        # Creates symbolic links inside the folder pointing
        # back to the paths.
        #
        # @see #create_tests_folder_for
        #
        # @param (see #run)
        # @param [String] the folder in which the links must be made
        #
        def symlink_paths_to_tests_folder(paths, folder)
          paths.each do |p|
            FileUtils.mkdir_p( File.join(folder, File.dirname(p) ) ) unless File.dirname(p) == '.'
            FileUtils.ln_s(Pathname.new(p).realpath, File.join(folder, p))
          end
        end

        # Generates the phpunit command for the tests paths.
        #
        # @param (see #run)
        # @param (see #run)
        # @see #run_tests
        #
        def phpunit_command(path, options, logfile)
          formatter_path = File.expand_path( File.join( File.dirname(__FILE__), '..', 'phpunit', 'formatters', 'PHPUnit-Progress') )
          
          command = "phpunit"
          command = options[:command] if options[:command]

          cmd_parts = []
          cmd_parts << command
          cmd_parts << "--include-path #{formatter_path}"
          cmd_parts << "--printer PHPUnit_Extensions_Progress_ResultPrinter"
          cmd_parts << "--log-json #{logfile}"
          cmd_parts << options[:cli] if options[:cli]
          cmd_parts << path

          cmd_parts.join(' ')
        end

        # Executes a system command and returns the output.
        #
        # @param [String] command the command to be run
        # @return [String] the output of the executed command
        #
        def execute_command(command)
          %x{#{command}}
        end

        def execute_phpunit(tests_path, options)
          log_file = Tempfile.new "guard-phpunit2"
          output = execute_command(phpunit_command(tests_path, options, log_file.path))
          puts output

          log = log_file.read
          log_file.close
          log_file.unlink

          log
        end
      end
    end
  end
end
