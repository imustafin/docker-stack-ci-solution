require_relative 'github_actions'

# From https://regexr.com/3bsog
DOCKER_IMAGE_REGEX = /[a-z0-9]+(?:[._-]{1,2}[a-z0-9]+)*/

TAG_AS_PREFIX = '# tag-as '
class DockerProcessor
  def initialize(dockerfile, args)
    @lines = IO.readlines(dockerfile).map(&:strip)
    @args = args
  end

  def tagged_images
    from_image_as = Regexp.new(DOCKER_IMAGE_REGEX.source + ' AS ')

    @lines.zip(@lines.drop(1)).filter do |first, second|
      first.start_with?(TAG_AS_PREFIX) && from_image_as =~ second
    end
  end

  def targets
    kv = tagged_images.map do |tag_as, from_as|
      base_name = from_as.split(' AS ').last

      tag_part_args = tag_as.sub(TAG_AS_PREFIX, '').split(' ')
      tag_part_with_values = tag_part_args.map do |arg|
        if arg[0] == '$'
          @args[arg[1..-1]]
        else
          arg
        end
      end

      [base_name, base_name + ':' + tag_part_with_values.join('')]
    end

    Hash[kv]
  end
end
