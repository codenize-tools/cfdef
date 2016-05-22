class Cfdef::Client
  include Cfdef::Utils::Helper
  include Cfdef::Logger::Helper

  def initialize(options = {})
    @options = options
    @client = @options[:client] || Aws::CloudFront::Client.new
    @driver = Cfdef::Driver.new(@client, @options)
    @exporter = Cfdef::Exporter.new(@client, @options)
  end

  def export
    @exporter.export
  end

  def apply(file)
    walk(file)
  end

  private

  def walk(file)
    expected = load_file(file)
    actual = @exporter.export

    updated = walk_distributions(
      expected.fetch(:distributions),
      actual.fetch(:distributions))

    # TODO:
    #updated = walk_streaming_distributions(
    #  expected.fetch(:streaming_distributions),
    #  actual.fetch(:streaming_distributions)) || updated

    if @options[:dry_run]
      false
    else
      updated
    end
  end

  def walk_distributions(expected, actual)
    updated = false

    expected.each do |dist_id,  expected_distribution|
      origin_ids = expected_distribution.fetch(:origins).fetch(:items).map {|i| i[:id] }.sort
      next unless origin_ids.any?{|i| matched?(i) }

      if dist_id.is_a?(Array)
        actual_dist_id, actual_distribution = actual.find do |_, dist|
          actual_origin_ids = dist.fetch(:origins).fetch(:items).map {|i| i[:id] }.sort
          actual_origin_ids == dist_id
        end

        if actual_dist_id
          actual.delete(actual_dist_id)
          dist_id = actual_dist_id
        end
      else
        actual_distribution = actual.delete(dist_id)
      end

      if actual_distribution
        updated = walk_distribution(dist_id, expected_distribution, actual_distribution) || updated
      else
        @driver.create_distribution(dist_id, expected_distribution)
        updated = true
      end
    end

    actual.each do |dist_id, _|
      @driver.delete_distribution(dist_id)
      updated = true
    end

    updated
  end

  def walk_distribution(dist_id, expected, actual)
    updated = false

    if expected != actual
      @driver.update_distribution(dist_id, expected, actual)
      updated = true
    end

    updated
  end

  def load_file(file)
    if file.kind_of?(String)
      open(file) do |f|
        Cfdef::DSL.parse(f.read, file)
      end
    elsif file.respond_to?(:read)
      Cfdef::DSL.parse(file.read, file.path)
    else
      raise TypeError, "can't convert #{file} into File"
    end
  end
end
