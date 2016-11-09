require 'rails_helper'
# require './lib/loader'

RSpec.describe Loader, type: :model do

  # let(:input_file) { './doc/input' }
  let(:input_file) { './spec/models/concerns/input1.txt' }
  let(:preclean) { false }
  # let(:preclean) { true }
  let(:max_words_sizes) { [16] }
  # let(:max_words_sizes) { [83] }
  # let(:max_words_sizes) { [83*2] }
  let(:max_words) { max_words_sizes.last }
  let(:only_test) { true }

  it '#initialize' do
    expect { Loader.new(input_file, max_words, only_test) }.not_to raise_exception

    # expect { Loader.new(input_file, max_words, preclean, only_test) }.not_to raise_exception(RuntimeError)
    # expect { Loader.new(input_file, max_words, preclean, only_test) }.not_to raise_exception(RuntimeError,'foo')
  end

  context '#run' do
    subject { Loader.new(input_file, max_words, only_test) }

    it 'should not raise for main input file' do
      expect { subject.run }.not_to raise_exception
    end

    it 'should call #read_input_file' do
      expect(subject).to receive(:read_input_file)
      subject.run
    end

    it 'should call #find_hist_friends' do
      expect(subject).to receive(:find_hist_friends)
      subject.run
    end

    it 'should call #find_word_friends' do
      expect(subject).to receive(:find_word_friends)
      subject.run
    end

    it 'should call SocNetBuilder#run' do
      expect_any_instance_of(SocNetBuilder).to receive(:run)
      subject.run
    end
  end

  context '#report_content' do
    context 'given' do
      subject { Loader.new(input_file, max_words, only_test) }

      context 'input1.txt' do
        let(:input_file) { './spec/models/concerns/input1.txt' }
        let(:expected_report_contents) { ["abc,2","abcd,2","abd,2","xyz,0"].sort }

        it 'returns expected content ' do
          subject.run
          expect(subject.report_content.split("\n").sort).to eq(expected_report_contents)
        end
      end

      context 'input2.txt' do
        let(:input_file) { './spec/models/concerns/input2.txt' }
        let(:expected_report_contents) { ["abc,3","abcd,3","abd,3","ab'd,3","abcde,3","xyz,0","x-y z,0"].sort }

        it 'returns expected content ' do
          subject.run
          expect(subject.report_content.split("\n").sort).to eq(expected_report_contents)
        end
      end

      context 'input3.txt' do
        let(:input_file) { './spec/models/concerns/input3.txt' }
        let(:expected_report_contents) { ["horrid,0",
                                          "basement,0",
                                          "abbey,0",
                                          "recursiveness,0",
                                          "elastic,0",
                                          "macrographies,0",
                                          "a,0",
                                          "aardvark,1",
                                          "aardvark's,1",
                                          "aardvarks,1",
                                          "abaci,1",
                                          "aback,1",
                                          "abacus,2",
                                          "abacus's,2",
                                          "abacuses,2",
                                          "abaft,0",
                                          "abalone,1",
                                          "abalone's,1",
                                          "abalones,1",
                                          "abandon,0"].sort.join("\n") }
        it 'returns expected content ' do
          subject.run
          expect(subject.report_content.split("\n").sort.join("\n")).to eq(expected_report_contents)
        end
      end
    end
  end
end