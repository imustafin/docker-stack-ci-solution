require 'rspec'

require_relative '../src/dockerfile_parser'

RSpec.describe DockerfileParser do
  context 'with Dockerfile.args' do
    let(:dockerfile) { 'spec/inputs/Dockerfile.args' }
    subject(:parser) { described_class.new(dockerfile) }

    describe '#images' do
      it 'includes args' do
        expect(parser.images).to include(
          include(args: ['ARG1']),
          include(args: ['ARG2']),
          include(args: ['ARG3'])
        )
      end
    end
  end
end
