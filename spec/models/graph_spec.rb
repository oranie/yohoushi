require 'spec_helper'

describe Graph do
  describe "#find_or_create" do
    context "auto_tagging" do
      let(:path) { 'a/b/c' }
      subject { described_class.find_or_create(path: path) }
      it { expect(subject.tag_list).to eq path.split('/') }
    end

    context "additional auto_tagging" do
      let(:path) { 'a/b/c' }
      let(:tag) { 'foo' }
      subject { described_class.find_or_create(path: path, tag_list: tag) }
      it { expect(subject.tag_list).to eq ([tag] + path.split('/')) }
    end
  end

  describe "#find_diff" do
    let(:paths) { [ 'a/b/to_be_added', 'a/b/to_be_kept' ] }
    before {
      described_class.find_or_create(path: 'a/b/to_be_kept')
      described_class.find_or_create(path: 'a/b/to_be_removed')
    }
    before { @plus, @minus = described_class.find_diff(paths) }
    it { expect(@plus).to  eq ['a/b/to_be_added'] }
    it { expect(@minus).to eq ['a/b/to_be_removed'] }
  end
end
