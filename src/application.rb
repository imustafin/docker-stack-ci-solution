require 'json'

require_relative 'github_actions'
require_relative 'docker_processor'

class Application
  def run(argv_string)
    actions = GithubActions.new(argv_string)

    processor = DockerProcessor.new(
      actions.inputs['dockerfile'],
      JSON.parse(actions.inputs['args'])
    )

    targets = processor.targets

    cache_froms = targets
      .map { |img, tag| "#{img}=#{tag}" }
      .sort
      .join(' ')

    actions.set_outputs(
      'image-names' => cache_froms
    )
  end
end
