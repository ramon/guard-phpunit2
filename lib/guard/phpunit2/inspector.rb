module Guard
  class PHPUnit2

    # The Guard::PHPUnit inspector verfies that the changed paths
    # are valid for Guard::PHPUnit.
    #
    module Inspector
      class << self

        attr_accessor :tests_path

        # Clean the changed paths and return only valid
        # PHPUnit tests files.
        #
        # @param [Array<String>] paths the changed paths
        # @return [Array<String>] the valid tests files
        #
        def clean(paths)
          paths.uniq!
          paths.compact!
          #populate_test_files()
		  tests_files
          paths = paths.select { |p| test_file?(p) }
          clear_tests_files_list
          paths
        end

        private


        def tests_files
        #def populate_test_files()
          @tests_files ||= []

          _files = []

          if @tests_files == []
            if tests_path.is_a? String
              _files = _files.concat(phpunit_glob(tests_path))
            elsif tests_path.is_a? Array
              tests_path.each { |path| _files.concat(phpunit_glob(path)) }
            end
          end

          @tests_files = _files
        end

        def phpunit_glob(path)
          Dir.glob( File.join(path, '**', '*Test.php') )
        end

        # Checks if the paths is a valid test file.
        #
        # @param [String] path the test path
        # @return [Boolean] whether the path a valid test or not
        #
        def test_file?(path)
          @tests_files.include?(path)
        end

        # Scans the tests path and keeps a list of all
        # tests paths.
        #
        #def tests_files
          #Uses the current path for tests_path when unset.
          #@tests_files ||= Dir.glob( File.join(tests_path, '**', '*Test.php') )
          #populate_test_files()
		  #@tests_files
        #end

        # Clears the list of PHPUnit tests.
        #
        # @see #clean
        #
        def clear_tests_files_list
          @tests_files = nil
        end
      end
    end
  end
end
