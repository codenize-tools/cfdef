class Cfdef::Driver
  include Cfdef::Utils::Helper
  include Cfdef::Logger::Helper

  def initialize(client, options = {})
    @client = client
    @options = options
  end

  def create_distribution(dist_id, distribution)
    log(:info, "Create Distribution `#{dist_id}`", color: :cyan)

    unless @options[:dry_run]
      caller_reference = "#{dist_id} #{SecureRandom.uuid}"

      params = {
        distribution_config: {
          caller_reference: caller_reference,
        }.merge(distribution),
      }

      resp = @client.create_distribution(params)

      log(:info, "Distribution `#{resp.distribution.id}` has been created", color: :cyan)
    end
  end

  def delete_distribution(dist_id)
    log(:info, "Delete Distribution `#{dist_id}`", color: :red)

    unless @options[:dry_run]
      etag = @client.get_distribution(id: dist_id).etag

      params = {
        id: dist_id,
        if_match: etag,
      }

      @client.delete_distribution(params)
    end
  end

  def update_distribution(dist_id, distribution, old_distribution)
    log(:info, "Update Distribution `#{dist_id}`", color: :green)
    log(:info, diff(old_distribution, distribution, color: @options[:color]), color: false)

    unless @options[:dry_run]
      resp = @client.get_distribution(id: dist_id)
      etag = resp.etag
      caller_reference = resp.distribution.distribution_config.caller_reference

      dist_conf = {
        caller_reference: caller_reference,
      }.merge(distribution)

      unless dist_conf[:default_root_object]
        dist_conf[:default_root_object] = ""
      end

      unless dist_conf[:logging]
        dist_conf[:logging] = {
          enabled: false,
          include_cookies: false,
          bucket: '',
          prefix: '',
        }
      end

      params = {
        distribution_config: dist_conf,
        id: dist_id,
        if_match: etag,
      }

      @client.update_distribution(params)
    end
  end
end
