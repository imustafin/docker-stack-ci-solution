require 'rspec'
require 'json'

require_relative '../src/docker_processor'

RSpec.describe DockerProcessor do
  context 'with Dockerfile.multistage-build-tutorial' do
    let(:dockerfile) { 'spec/inputs/Dockerfile.multistage-build-tutorial' }
    let(:args) { { 'COMMIT' => '123hash' } }
    subject(:processor) { described_class.new(dockerfile, args) }

    describe '#targets' do
      it 'gives targets with desired tags' do
        expect(processor.targets).to eq(
          'compilation' => 'compilation:123hash',
          'app' => 'app:123hash'
        )
      end
    end
  end
end
