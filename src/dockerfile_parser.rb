class DockerfileParser
  IMAGE_NAME = '[a-z0-9:._/-]+'

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

    first, *rest = lines

    base_image, as = extract_from_as(first)
    image[:base_image] = base_image
    image[:as] = as

    image[:tag_as] = extract_tag_as(rest)
    image[:args] = extract_args(rest)

    image
  end

  def extract_from_as(line)
    from_as_regex = /^FROM (#{IMAGE_NAME})(?: AS (#{IMAGE_NAME}))?/

    from_as = line.match(from_as_regex)

    base_image = from_as[1]

    as = nil

    if from_as.length > 1
      as = from_as[2]
    end

    [base_image, as]
  end

  def extract_tag_as(lines)
    tag_as_command = '# tag-as'
    lines
      .filter { |s| s.start_with?(tag_as_command) }
      .map { |s| s.sub(tag_as_command, '').strip }
      .first
  end

  def extract_args(lines)
    arg_command = 'ARG '
    lines
      .filter { |s| s.start_with?(arg_command) }
      .map { |s| s.sub(arg_command, '') }
  end
end
