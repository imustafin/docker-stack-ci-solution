require 'json'

require_relative 'application'
require_relative 'github_actions'

actions = GithubActions.new(ARGV, '/action.yml')

inputs = actions.inputs

app = Application.new(
  args: JSON.parse(inputs['args']),
  dockerfile: inputs['dockerfile'],
  deploy_images: JSON.parse(inputs['deploy-images']),
  deploy_server_docker_sudo: inputs['deploy-server-docker-sudo'] == 'true',
  deploy_server_registry: inputs['deploy-server-registry'],
  context: inputs['context'],
  registry: inputs['registry']
)

outputs = app.run

actions.set_outputs(outputs)
