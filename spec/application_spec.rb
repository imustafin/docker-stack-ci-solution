require 'rspec'

require_relative '../src/application'

RSpec.describe Application do
  context 'with Dockerfile.multistage-build-tutorial' do
    subject(:application) { Application.new(
      dockerfile: 'spec/inputs/href-counter/Dockerfile.multistage-build-tutorial',
      context: 'spec/inputs-href-counter',
      args: {
        'COMMIT' => 'COMMIT_HASH',
        'CGO_ENABLED' => 0
      },
      registry: 'docker.pkg.github.com/repo',
      deploy_images: ['href_counter_app'],
      deploy_server_registry: 'localhost:5000',
      deploy_server_docker_sudo: nil,
    ) }

    describe '#run' do
      let(:outputs) { application.run }

      it 'gives push-to-local-registry commands for deploy_images' do
        remote = 'docker.pkg.github.com/repo/href_counter_app:final-hc-COMMIT_HASH'
        local = 'localhost:5000/href_counter_app:final-hc-COMMIT_HASH'

        expect(outputs['push-to-local-registry'].split("\n")).to contain_exactly(
          "docker pull #{remote}",
          "docker tag #{remote} #{local}",
          "docker push #{local}",
          "docker remove #{remote} || true",
          "docker remove #{local} || true"
        )
      end
    end
  end
end
