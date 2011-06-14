require "inform/version"
require 'highline/import'

class Inform
  class << self
    DEFAULT_LOG_LEVEL = :info
    LOG_LEVELS = [:debug, :info, :warning, :error]

    # Highline colours at http://highline.rubyforge.org/doc/classes/HighLine.html

    def level
      @level.nil? ? DEFAULT_LOG_LEVEL : @level
    end

    def level= _level
      raise "Unrecognized log level #{_level} (should be one of #{LOG_LEVELS.join(', ')})" unless LOG_LEVELS.include?(_level)
      @level = _level
    end

    def debug(message, args=nil)
      # log(:debug, message)
      log(:debug, "    <%= color(#{color_args(message, args, :cyan)}, :cyan) %>")
    end

    def info(message, args=nil)
      if block_given?
        log(:info, ">>> <%= color(#{color_args(message, args, :blue)}, :blue) %> :", :no_newline => true)
        ret = yield
        log(:info, "<%= color('Done.', :blue) %>", :continue_line => true, :prefix => '>>> ')
        ret
      else
        log(:info, "*** <%= color(#{color_args(message, args, :green)}, :green) %>")
      end
    end

    def warning(message, args=nil)
      log(:warning, "<%= color('WARNING', :yellow, :bold) %>: <%= color(#{color_args(message, args, :yellow)}, :yellow) %>")
    end

    def error(message, args=nil)
      log :error, "<%= color('ERROR', :red, :bold) %>: <%= color(#{color_args(message, args, :red)}, :red) %>"
    end

    private

    def log message_level, message, opts={}
      if LOG_LEVELS.index(level) <= LOG_LEVELS.index(message_level)
        if @need_newline && !opts[:continue_line]
          message = "\n" + message
        end
        if opts[:continue_line] && !@need_newline
          message = opts[:prefix] + message
        end
        if opts[:no_newline]
          message += ' ' # say magic
          @need_newline = true
        else
          @need_newline = false
        end
        say message
      end
    end

    def color_args(message, args, c)
      message = message % args.inject({}) { |h,(k,v)| h[k] = "#{$terminal.color(v, c, :bold)}#{$terminal.class.const_get(c.to_s.upcase)}" ; h } if args
      message.inspect
    end
  end
end

class String
  # Work around Ruby 1.8.x not supporting % args
  alias_method :percentage, :%
  def %(arg)
    arg.is_a?(Hash) ? arg.inject(self) { |res,(k,v)| res.gsub(/%\{#{k}\}/, v) } : self.percentage(arg)
  end
end
