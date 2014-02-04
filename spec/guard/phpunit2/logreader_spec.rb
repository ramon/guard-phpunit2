require 'spec_helper'

describe Guard::PHPUnit2::LogReader do

  describe '.parse_output' do
    context 'when all tests pass' do
      it 'returns a hash containing the results' do
        output = load_phpunit_output('passing-json')
        subject.parse_output(output).should == {
          :tests => 2, :failures => 0,
          :errors => 0, :pending => 0,
          :duration => [0, 'seconds']
        }
      end
    end

    context 'when all tests fail' do
      it 'returns a hash containing the tests result' do
        output = load_phpunit_output('failing-json')
        subject.parse_output(output).should == {
          :tests  => 2, :failures => 2,
          :errors => 0, :pending  => 0,
          :duration => [0, "seconds"]
        }
      end
    end

    context 'when tests are skipped or incomplete' do
      it 'returns a hash containing the tests result' do
        output = load_phpunit_output('skipped_and_incomplete-json')
        subject.parse_output(output).should == {
          :tests  => 3, :failures => 0,
          :errors => 0, :pending  => 3,
          :duration => [0, "seconds"]
        }
      end
    end

    context 'when tests have mixed statuses' do
      it 'returns a hash containing the tests result' do
        output = load_phpunit_output('mixed-json')
        subject.parse_output(output).should == {
          :tests  => 5, :failures => 1,
          :errors => 1, :pending  => 2,
          :duration => [0, "seconds"]
        }
      end
    end

    context 'multiple test classes' do
      it 'retuns the correct total sum of tests ran' do
        output = load_phpunit_output('multiple-test-cases-json')
        subject.parse_output(output).should == {
          :tests => 14, :failures => 4,
          :errors => 1, :pending => 5,
          :duration => [0, 'seconds']
        }
      end
    end

  end
end
