module Deploy

  class Config

    def self.config
      @@config ||= {}
      @@config[:default] ||= {}
      @@config[:clazz] ||= {}
      @@config
    end

    def self.set(key, value)
      self.config[:default][key.to_sym] = value
    end

    def self.get(key)
      self.config[:default][key.to_sym]
    end

    def self.set_clazz(key, value)
      self.config[:clazz][key.to_sym] = value
    end

    def self.get_clazz(key)
      self.config[:clazz][key.to_sym]
    end

  end

end

