require 'rspec'
require 'json'

RSpec.describe 'github integration' do
  subject(:results) { ENV['NAMES'].split(' ') }

  let(:args) { JSON.parse(ENV['ARGS']) }

  it 'includes compilation image with tag of COMMIT only' do
    expect(results).to include("compilation=compilation:#{args['COMMIT']}")
  end

  it 'includes app image with tag of COMMIT only' do
    expect(results).to include("app=app:#{args['COMMIT']}")
  end
end
