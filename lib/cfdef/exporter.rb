class Cfdef::Exporter
  include Cfdef::Utils::Helper

  def initialize(client, options = {})
    @client = client
    @options = options
  end

  def export
    {
      distributions: export_distributions,
      # TODO:
      #streaming_distributions: export_streaming_distributions,
    }.sort_array!
  end

  private

  def export_distributions
    result = {}

    distribution_ids = @client.list_distributions.flat_map(&:distribution_list).flat_map(&:items).map(&:id)

    distribution_ids.each do |distribution_id|
      resp = @client.get_distribution_config(id: distribution_id)
      distribution = resp.distribution_config.to_h
      distribution.delete(:caller_reference)
      origin_ids = distribution.fetch(:origins).fetch(:items).map {|i| i[:id] }.sort
      next unless origin_ids.any?{|i| matched?(i) }
      result[distribution_id] = remove_status!(distribution)
    end

    result
  end

  def remove_status!(distribution)
    [:id, :status, :last_modified_time, :domain_name].each do |key|
      distribution.delete(key)
    end

    distribution
  end
end
