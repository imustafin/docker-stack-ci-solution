class GithubActions
  attr_reader argv

  def initialize(argv)
    @argv = argv

    action_definition = IO.read('action.yml')

    pp action_definition
  end
end
