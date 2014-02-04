require 'json'
module Guard
  class PHPUnit2
    # Parses the --log-json output of PHPUnit
    #
    # @author Matt Burke <burkemd1+github@gmail.com>
    # @since 2014-01-30
    module LogReader
      class << self

        # Parses the output of --log-json
        #
        # @param [String] the file's contents
        # @return [Hash] with the following properties:
        #     :tests    => number of tests executed
        #     :failures => number of tests failing because of an assertion
        #                  not being met
        #     :errors   => number of tests failing because of an error (like
        #                  an Exception)
        #     :pending  => number of tests skipped or incomplete
        #     :duration => length of test with units
        def parse_output(output)
          log = JSON.parse(clean_output(output))

          tests    = 0
          passes   = 0
          errors   = 0
          failures = 0
          skips    = 0
          duration = 0

          # If we don't have an array of events then nothing really happened
          #
          if (log.first)
            tests = log.first['tests']
            log.each do |event|
              passes   += 1 if passed_test?(event)
              failures += 1 if failed_test?(event)
              skips    += 1 if skipped_test?(event)
              errors   += 1 if error_test?(event)

              duration += event['time'] if event['time']
            end
          end

          {
            :tests    => tests,
            :failures => failures,
            :errors   => errors,
            :pending  => skips,
            :duration => calculate_duration(duration)
          }
        end

        private

          # PHPUnit writes out the JSON log as a series of JSON objects
          # It is not serializable all as one object. We need to 
          # turn it into an array and add commas between subsequent objects
          #
          # @param [String] json log output from PPHUnit
          #  @return [String] properly-formed JSON string
          def clean_output(output)
            "[#{output.gsub(/^}{/, '},{')}]"
          end

          # Turns a float duration into a array of integer seconds and the 
          # string 'seconds'
          #
          # This is the format expected by Guard
          #
          # @param [Float] duration in fractions of a second
          # @return [Fixnum, String]
          def calculate_duration(duration)
            [duration.to_i, 'seconds']
          end

          # Determines if a PHPUnit event represents a skipped test
          #
          # Skipped and Incomplete tests are considered skipped
          # @param [Hash] json object for a single PHPUnit event
          # @return [Boolean]
          def skipped_test?(event)
            return false unless event['event'] == 'test' && event['status'] == 'error'

            !!event['message'].match(/Skipped|Incomplete/i)
          end

          # Determine if a PHPUnit event represents a test that errored out
          #
          # Errored tests are those that failed because of an error, for example
          # an exception. Assertion failures are not considered errors
          #
          # @param [Hash] json object for a single event
          # @return [Boolean]
          def error_test?(event)
            return false unless event['event'] == 'test' && event['status'] == 'error'

            !skipped_test?(event)
          end

          # Determine if a PHPUnit event represents a test that passed
          #
          # @param [Hash] json object for a single event
          # @return [Boolean]
          def passed_test?(event)
            event['event'] == 'test' && event['status'] == 'pass'
          end

          # Determine if a PHPUnit event represents a test that failed because an
          # assertion was not met.
          #
          # @param [Hash] JSON object for a single event
          # @return [Boolean]
          def failed_test?(event)
            event['event'] == 'test' && event['status'] == 'fail'
          end

      end
    end
  end
end
