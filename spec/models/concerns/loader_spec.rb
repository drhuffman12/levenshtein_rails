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

      context 'input.21.txt' do
        let(:max_words_sizes) { [21] }
        let(:input_file)               { './spec/models/concerns/input.21.txt' }
        let(:expected_report_file)     { './spec/models/concerns/report.21.txt' }
        let(:generated_report_file)     { './spec/models/concerns/report.21.out.txt' }
        let(:expected_report_contents) { File.read(expected_report_file) }
        it 'returns expected content ' do
          subject.run
          content = subject.report_content
          File.open(generated_report_file, 'w') do |f|
            f.write(content)
          end

          expect(subject.report_content).to eq(expected_report_contents) # .split("\n").sort.join("\n")
        end
      end

      context 'input.42.txt' do
        let(:max_words_sizes) { [42] }
        let(:input_file)               { './spec/models/concerns/input.42.txt' }
        let(:expected_report_file)     { './spec/models/concerns/report.42.txt' }
        let(:generated_report_file)     { './spec/models/concerns/report.42.out.txt' }
        let(:expected_report_contents) { File.read(expected_report_file) }
        it 'returns expected content ' do
          subject.run
          content = subject.report_content
          File.open(generated_report_file, 'w') do |f|
            f.write(content)
          end

          expect(subject.report_content).to eq(expected_report_contents) # .split("\n").sort.join("\n")
        end
      end

      context 'input.83.txt' do
        let(:max_words_sizes) { [83] }
        let(:input_file)               { './spec/models/concerns/input.83.txt' }
        let(:expected_report_file)     { './spec/models/concerns/report.83.txt' }
        let(:generated_report_file)     { './spec/models/concerns/report.83.out.txt' }
        let(:expected_report_contents) { File.read(expected_report_file) }
        it 'returns expected content ' do
          subject.run
          content = subject.report_content
          File.open(generated_report_file, 'w') do |f|
            f.write(content)
          end

          expect(subject.report_content).to eq(expected_report_contents) # .split("\n").sort.join("\n")
        end
      end
    end
  end
end