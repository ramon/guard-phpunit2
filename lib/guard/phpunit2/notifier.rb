module Guard
  class PHPUnit2

    # The Guard::PHPUnit notifier displays a notification pop-up
    # with the tests results.
    #
    module Notifier
      class << self

        # Displays a system notification.
        #
        # @param [String] message the message to show
        # @param [Hash] options the notifier options
        #
        def notify(message, options)
          Compat::UI.notify(message, options)
        end

        # Displays a notification about the tests results.
        #
        # @param [Hash] test_results the parsed tests results
        # @option test_results [Integer] :tests tests count
        # @option test_results [Integer] :failures failures count
        # @option test_results [Integer] :errors count count
        # @option test_results [Integer] :pending pending tests count
        # @option test_results [Integer] :duration tests duration
        #
        def notify_results(test_results)
          notify(message(test_results), {
            :title => 'PHPUnit results',
            :image => image(test_results)
          })
        end 

        private

        # Formats the message for the tests results notifier.
        # 
        # @param (see .notify)
        # @return [String] the message
        #
        def message(results)
          message = "#{results[:tests]} tests, #{results[:failures]} failures"
          message << "\n#{results[:errors]} errors"    if results[:errors]  > 0
          message << " (#{results[:pending]} pending)" if results[:pending] > 0
          message << "\nin #{results[:duration].first} #{results[:duration].last}"
          message
        end

        # Returns the appropriate image for the tests results.
        # 
        # @param (see .notify)
        # @return [Symbol] the image symbol
        #
        def image(results)
          if results[:failures] + results[:errors] > 0
            :failed
          elsif results[:pending] > 0
            :pending
          else
            :success
          end
        end
      end
    end
  end
end
