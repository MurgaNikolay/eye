module Eye::Dsl::Main
  attr_accessor :parsed_config, :parsed_filename, :parsed_default_app

  def application(name, &block)
    Eye::Dsl.check_name(name)
    name = name.to_s

    Eye::Dsl.debug "=> app: #{name}"

    if name == '__default__'
      @parsed_default_app ||= Eye::Dsl::ApplicationOpts.new(name)
      @parsed_default_app.instance_eval(&block)
    else
      opts = Eye::Dsl::ApplicationOpts.new(name, @parsed_default_app)
      opts.instance_eval(&block)
      @parsed_config.applications[name] = opts.config if opts.config
    end

    Eye::Dsl.debug "<= app: #{name}"
  end

  alias project application
  alias app application

  def load(glob = '')
    return if glob.blank?

    Eye::Dsl::Opts.with_parsed_file(glob) do |mask|
      Dir[mask].each do |path|
        Eye::Dsl.debug "=> load #{path}"
        Eye.parsed_filename = path
        res = Kernel.load(path)
        Eye.info "load: subload #{path} (#{res})"
        Eye::Dsl.debug "<= load #{path}"
      end
    end
  end

  def config(&block)
    Eye::Dsl.debug '=> config'

    opts = Eye::Dsl::ConfigOpts.new
    opts.instance_eval(&block)
    @parsed_config.settings.merge!(opts.config)

    Eye::Dsl.debug '<= config'
  end

  alias settings config

end
