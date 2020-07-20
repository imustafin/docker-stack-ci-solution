class DockerfileParser
  IMAGE_NAME = '[a-z0-9:._-]+'

  def initialize(dockerfile)
    @lines = IO.readlines(dockerfile).map(&:strip)
  end

  def images
    lines = @lines

    lines = lines.drop_while { |s| !s.start_with?('FROM ') }

    ans = []

    while not lines.empty?
      image_lines = [lines[0]] + lines.drop(1).take_while { |s| !s.start_with?('FROM ') }
      lines = lines.drop(image_lines.length)

      ans << parse_image(image_lines)
    end

    ans
  end

  def parse_image(lines)
    image = {}

    # Parse FROM [AS]
    from_as_regex = /^FROM (#{IMAGE_NAME})(?: AS (#{IMAGE_NAME}))?/

    from_as = lines[0].match(from_as_regex)

    image[:base_image] = from_as[1]

    if from_as.length > 1
      image[:as] = from_as[2]
    end

    # Parse other lines
    lines.drop(1).each do |line|
      if line.start_with?('# tag-as')
        image[:tag_as] = line.sub('# tag-as', '')
      end
    end

    image
  end
end
