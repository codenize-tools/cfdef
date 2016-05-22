class Cfdef::DSL::Context
  def self.eval(dsl, path, options = {})
    self.new(path, options) {
      eval(dsl, binding, path)
    }
  end

  def result
    @result.sort_array!
  end

  def initialize(path, options = {}, &block)
    @path = path
    @options = options

    @result = {
      distributions: {},
      # TODO:
      #streaming_distributions: {},
    }

    instance_eval(&block)
  end

  private

  def require(file)
    cf_file = (file =~ %r|\A/|) ? file : File.expand_path(File.join(File.dirname(@path), file))

    if File.exist?(cf_file)
      instance_eval(File.read(cf_file), cf_file)
    elsif File.exist?(cf_file + '.rb')
      instance_eval(File.read(cf_file + '.rb'), cf_file + '.rb')
    else
      Kernel.require(file)
    end
  end

  def distribution(dist_id = nil, &block)
    dist_conf = Dslh.eval(key_conv: :to_sym.to_proc, &block)

    if dist_id
      dist_id = dist_id.to_s
    else
      dist_id = dist_conf.fetch(:origins).fetch(:items).map {|i| i[:id].to_s }.sort
    end

    if @result[dist_id]
      raise "Distribution `#{dist_id}` is already defined"
    end

    @result[:distributions][dist_id] = dist_conf
  end

  # TODO:
  #def streaming_distributions
  #end
end
