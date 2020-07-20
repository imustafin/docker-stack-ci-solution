require_relative 'github_actions'
require_relative 'dockerfile_parser'


class DockerProcessor
  def initialize(dockerfile, args)
    @images = DockerfileParser.new(dockerfile).images
    @args = args
  end

  def targets
    kv = []

    @images.each do |image|
      base_image = image[:base_image]
      as = image[:as]
      tag_as = image[:tag_as]

      raise "Image FROM #{base_image} has no alias (AS)" unless as
      raise "Image FROM #{base_image} AS #{as} has no #tag-as inside" unless tag_as

      kv << [as, as + ':' + format_tag(tag_as)]
    end

    Hash[kv]
  end

  def format_tag(tag_as)
    values = tag_as.split(' ').map do |arg|
      if arg[0] == '$'
        @args[arg[1..-1]]
      else
        arg
      end
    end

    values.join('')
  end
end
