require 'rspec'
require 'json'

require_relative '../src/docker_processor'

RSpec.describe DockerProcessor do
  context 'with Dockerfile.multistage-build-tutorial' do
    let(:dockerfile) { 'spec/inputs/href-counter/Dockerfile.multistage-build-tutorial' }
    let(:args) { {
      'COMMIT' => '123hash',
      'CGO_ENABLED' => 0,
    } }
    subject(:processor) { described_class.new(dockerfile, args) }

    describe '#targets' do
      it 'gives targets with desired tags' do
        expect(processor.targets).to contain_exactly(
          include(as: 'dependencies', tag: 'go1.7.3'),
          include(as: 'compilation', tag: 'cgo-0_123hash'),
          include(as: 'href-counter-app', tag: 'final-hc-123hash')
        )
      end
    end
  end
end
