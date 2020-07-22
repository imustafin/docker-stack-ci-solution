require 'json'

require_relative 'docker_processor'

class Application
  def initialize(
    args:, dockerfile:, deploy_images:, deploy_server_docker_sudo:,
    deploy_server_registry:, context:, registry:
  )
    @args = args
    @dockerfile = dockerfile
    @deploy_images = deploy_images
    @context = context
    @registry = registry
    @deploy_server_registry = deploy_server_registry

    @local_docker = 'docker'
    @local_docker = "sudo #{docker}" if deploy_server_docker_sudo
  end

  def run
    processor = DockerProcessor.new(
      @dockerfile,
      @args
    )

    targets = processor.targets

    {
      'build-commands' => build_commands(targets).join("\n"),
      'push-to-local-registry' => push_to_local_registry(targets).join("\n"),
      'export-local-registry-names' => export_local_registry_names(targets).join("\n")
    }
  end

  def name_at_registry(registry, image)
    [registry, '/', image[:as], ':', image[:tag]].join('')
  end
  def remote_name(image)
    name_at_registry(@registry, image)
  end

  def local_name(image)
    name_at_registry(@deploy_server_registry, image)
  end

  def build_commands(images)
    cache_froms = []
    build_args = []

    commands = []

    images.each do |image|
      name = remote_name(image)

      commands << "docker pull #{name} || true"

      cache_froms << name

      build_args += image[:args].reject { |arg| build_args.include?(arg) }

      cache_froms_string = cache_froms.map { |s| "--cache-from #{s}" }.join(' ')
      build_args_string = build_args.map { |a| "--build-arg #{a}=#{@args[a]}" }.join(' ')

      build = [
        'docker build',
        '-f',
        @dockerfile,
        '--target',
        image[:as],
        '--tag',
        name,
        cache_froms_string,
        build_args_string,
        @context
      ]
      commands << build.join(' ')

      commands << "docker push #{name}"
    end

    commands
  end

  def push_to_local_registry(images)
    targets = images.filter { |i| @deploy_images.include?(i[:as]) }

    commands = []

    docker = @local_docker

    targets.each do |i|
      remote = remote_name(i)
      local = local_name(i)

      commands << "#{docker} pull #{remote}"
      commands << "#{docker} tag #{remote} #{local}"
      commands << "#{docker} push #{local}"
      commands << "#{docker} remove #{remote} || true"
      commands << "#{docker} remove #{local} || true"
    end

    commands
  end

  def export_local_registry_names(images)
    targets = images.filter { |i| @deploy_images.include?(i[:as]) }

    targets.map { |i| "export #{i[:as]}=#{local_name(i)}" }
  end
end
