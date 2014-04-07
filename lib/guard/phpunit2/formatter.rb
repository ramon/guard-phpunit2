module Guard
  class PHPUnit2

    # The Guard::PHPUnit formatter parses the output
    # of phpunit which gets printed by the progress
    # printer.
    #
    module Formatter
      class << self

        # Parses the tests output.
        #
        # @param [String] text the output of phpunit.
        # @return [Hash] the parsed results
        #
        def parse_output(text)
          results = {
            :tests    => look_for_words_in('(tests)',    text),
            :failures => look_for_words_in('failures', text),
            :errors   => look_for_words_in('errors', text),
            :pending  => look_for_words_in(['skipped', 'incomplete'], text),
            :duration => look_for_duration_in(text)
          }
          results.freeze
        end

        private

        # Searches for a list of strings in the tests output
        # and returns the total number assigned to these strings.
        #
        # @param [String, Array<String>] string_list the words
        # @param [String] text the tests output
        # @return [Integer] the total number assigned to the words
        #
        def look_for_words_in(strings_list, text)
          count = 0
          strings_list = Array(strings_list)
          
          strings_list.each do |s|
            text =~ %r{
              (\d+)   # count of what we are looking for
              \s+     # then a space
              #{s}    # then the string
              .*      # then whatever
              $      # start looking at the end of the text
            }x
            count += $1.to_i unless $1.nil?
          end
          
          count
        end

        # Searches for the duration in the tests output
        #
        # @param [String] text the tests output
        # @return [Integer] the duration
        #
        def look_for_duration_in(text)
          text      =~ %r{Time: (\d+)\s+(\w+)?.*$}
          time      = $1.nil? ? 0 : $1.to_i
          time_name = $2.nil? ? "sec" : $2

          return time, time_name
        end
      end
    end
  end
end
