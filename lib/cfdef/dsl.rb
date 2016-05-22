class Cfdef::DSL
  class << self
    def convert(exported, options = {})
      Cfdef::DSL::Converter.convert(exported, options)
    end

    def parse(dsl, path, options = {})
      Cfdef::DSL::Context.eval(dsl, path, options).result
    end
  end # of class methods
end
