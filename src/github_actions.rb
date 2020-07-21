require 'yaml'

class GithubActions
  attr_reader :argv, :inputs

  def initialize(argv, action_path)
    @argv = argv

    action_definition = YAML.load_file(action_path)

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

  def format_string(s)
    s.gsub("\n", '%0A')
  end

  def set_outputs(outputs = {})
    outputs.each do |k, v|
      puts "::set-output name=#{k}::#{format_string(v)}"
    end
  end
end
