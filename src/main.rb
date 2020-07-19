require_relative 'github_actions'

actions = GithubActions.new(ARGV)

pp actions.argv
