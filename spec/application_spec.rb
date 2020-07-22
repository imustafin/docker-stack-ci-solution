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

      it 'build-commands sets args only after the first stage where referenced' do
        RSpec::Matchers.define_negated_matcher :not_include, :include

        arg = '--build-arg CGO_ENABLED=0'
        expect(outputs['build-commands'].split("\n")).to include(
          include('--target dependencies').and(not_include(arg)),
          include('--target compilation').and(include(arg)),
          include('--target href_counter_app').and(include(arg))
        )
      end
    end
  end
end
