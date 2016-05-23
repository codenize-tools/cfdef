class Cfdef::DSL::Converter
  include Cfdef::Utils::Helper

  def self.convert(exported, options = {})
    self.new(exported, options).convert
  end

  def initialize(exported, options = {})
    @exported = exported
    @options = options
  end

  def convert
    output_distributions(@exported.fetch(:distributions))

    # TODO:
    #output_streaming_distributions(@exported.fetch(:streaming_distributions))
  end

  private

  def output_distributions(distributions_by_id)
    distributions = []

    distributions_by_id.sort_by(&:first).each do |dist_id, distribution|
      distributions << output_distribution(dist_id, distribution)
    end

    distributions.join("\n")
  end

  def output_distribution(dist_id, distribution)
    dist_conf = Dslh.deval(distribution, initial_depth: 1, force_dump_braces: true).strip

    <<-EOS
distribution #{dist_id.inspect} do
  #{dist_conf}
end
    EOS
  end
end
