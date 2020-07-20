require 'json'

require_relative 'github_actions'
require_relative 'docker_processor'

class Application
  def initialize(argv_string)
    @actions = GithubActions.new(argv_string)
  end

  def run
    args = JSON.parse(@actions.inputs['args'])

    processor = DockerProcessor.new(
      @actions.inputs['dockerfile'],
      args
    )

    targets = processor.targets

    cache_froms = targets
      .map { |image| "#{image[:as]}=#{image[:as]}:#{image[:tag]}" }
      .sort
      .join(' ')

    build = build_commands(targets, args).join("\n")

    @actions.set_outputs(
      'image-names' => cache_froms,
      'build-commands' => build
    )
  end

  def full_name(image)
    [@actions.inputs['registry'], image[:as], ':', image[:tag]].join('')
  end

  def build_commands(images, args)
    cache_froms = []
    build_args = []

    commands = []

    images.each do |image|
      name = full_name(image)

      commands << "docker pull #{name} || true"

      cache_froms << name

      new_args = image[:args].reject { |arg| build_args.include?(arg) }

      cache_froms_string = cache_froms.map { |s| "--cache-from #{s}" }.join(' ')
      build_args_string = build_args.map { |a| "--build-arg #{a}=#{args[a]}" }.join(' ')

      build = [
        'docker build',
        '-f',
        @actions.inputs['dockerfile'],
        '--target',
        image[:as],
        '--tag',
        name,
        cache_froms_string,
        build_args_string,
        @actions.inputs['context']
      ]
      commands << build.join(' ')

      commands << "docker push #{name}"
    end

    commands
  end
end
