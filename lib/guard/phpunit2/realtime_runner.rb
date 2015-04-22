require 'tmpdir'
require 'fileutils'

module Guard
  class PHPUnit2

    # The Guard::PHPUnit runner handles running the tests, displaying
    # their output and notifying the user about the results.
    #
    class RealtimeRunner < Runner

      def self.run(paths, options)
        self.new.run(paths, options)
      end

        protected

        def parse_output(log)
          LogReader.parse_output(log)
        end

        # Generates the phpunit command for the tests paths.
        #
        # @param (see #run)
        # @param (see #run)
        # @see #run_tests
        #
        def phpunit_command(path, options, logfile)
          super(path, options) do |cmd_parts|
            cmd_parts << "--log-json #{logfile}"
          end
        end

        # Executes a system command but does not return the output
        #
        # @param [String] command the command to be run
        #
        def execute_command(command)
          system(command)
        end

        def execute_phpunit(tests_folder, options)
	  require 'tempfile'
          log_file = Tempfile.new "guard-phpunit2"
          execute_command(phpunit_command(tests_folder, options, log_file.path))

          log = log_file.read
          log_file.close
          log_file.unlink

          log
        end
    end
  end
end
