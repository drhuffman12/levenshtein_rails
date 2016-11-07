require 'rails_helper'
require './lib/loader'

RSpec.describe Loader, type: :model do

  let(:input_file) { './doc/input' }
  let(:preclean) { false }
  # let(:preclean) { true }
  let(:max_words_sizes) { [16] }
  # let(:max_words_sizes) { [83] }
  # let(:max_words_sizes) { [83*2] }
  let(:max_words) { max_words_sizes.last }
  let(:only_test) { true }
  let(:profile) { true }

  it '#initialize' do
    expect { Loader.new(input_file, max_words, preclean, only_test) }.not_to raise_exception
    # expect { Loader.new(input_file, max_words, preclean, only_test) }.not_to raise_exception(RuntimeError)
    # expect { Loader.new(input_file, max_words, preclean, only_test) }.not_to raise_exception(RuntimeError,'foo')
  end

  context '#run' do
    subject { Loader.new(input_file, max_words, preclean, only_test) }

    it 'should not raise for main input file' do
      expect { subject.run }.not_to raise_exception
    end

    it 'should call #remove_records' do
      expect(subject).to receive(:remove_records)
      subject.run
    end

    it 'should call #read_input_file' do
      expect(subject).to receive(:read_input_file)
      subject.run
    end

    it 'should call #find_hist_friends' do
      expect(subject).to receive(:find_hist_friends)
      subject.run
    end

    it 'should call #remove_records' do
      expect_any_instance_of(SocNetBuilder).to receive(:run)
      subject.run
    end
  end
end
