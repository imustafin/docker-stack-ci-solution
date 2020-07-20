require 'yaml'

class GithubActions
  attr_reader :argv, :inputs

  def initialize(argv)
    @argv = argv

    action_definition = YAML.load_file('action.yml')

    @inputs = extract_inputs(action_definition, argv)
  end

  def extract_inputs(action_definition, argv)
    args = action_definition['runs']['args']

    kv = args.zip(argv).map do |expr, arg|
      name_match = expr.match(/\${{\s+inputs\.(.+)\s+}}/)

      raise "in runs.args, #{expr} did not reference inputs" unless name_match

      [name_match[1], arg]
    end

    Hash[kv]
  end

  def set_outputs(outputs = {})
    outputs.each do |k, v|
      puts "::set-output name=#{k}::#{v}"
    end
  end
end
