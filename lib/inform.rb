require "inform/version"

class Inform

  CLEAR      = "\e[0m"

  BOLD       = "\e[1m"
  UNDERLINE  = "\e[4m"

  BLACK      = "\e[30m"
  RED        = "\e[31m"
  GREEN      = "\e[32m"
  YELLOW     = "\e[33m"
  BLUE       = "\e[34m"
  MAGENTA    = "\e[35m"
  CYAN       = "\e[36m"
  WHITE      = "\e[37m"

  DEFAULT_LOG_LEVEL = :info
  LOG_LEVELS = [:debug, :info, :warning, :error]

  class << self

    def level
      @level.nil? ? DEFAULT_LOG_LEVEL : @level
    end

    def level= _level
      raise "Unrecognized log level #{_level} (should be one of #{LOG_LEVELS.join(', ')})" unless LOG_LEVELS.include?(_level)
      @level = _level
    end

    def debug(message, args=nil)
      log(:debug, "    " + color_args(message, args, CYAN))
    end

    def info(message, args=nil)
      if block_given?
        log(:info, ">>> " + color_args(message, args, BLUE) + " :", :no_newline => true)
        ret = yield
        log(:info, color('Done.', BLUE), :continue_line => true, :prefix => '>>> ')
        ret
      else
        log(:info, "*** " + color_args(message, args, GREEN))
      end
    end

    def warning(message, args=nil)
      log(:warning, color('WARNING', YELLOW, BOLD) + ': ' + color_args(message, args, YELLOW))
    end

    def error(message, args=nil)
      log(:error, color('ERROR', RED, BOLD) + ': ' + color_args(message, args, RED))
    end

    private

    def log message_level, message, opts={}
      if LOG_LEVELS.index(level) <= LOG_LEVELS.index(message_level)
        end_with_newline = true
        if @need_newline && !opts[:continue_line]
          message = "\n" + message
        end
        if opts[:continue_line] && !@need_newline
          message = opts[:prefix] + message
        end
        if opts[:no_newline]
          end_with_newline = false
          @need_newline = true
        else
          @need_newline = false
        end
        message += "\n" if end_with_newline
        $stdout.print message
        $stdout.flush
      end
    end

    def color_args(message, args, *colours)
      colours = colours.join("")
      message = colours + message
      if args
        args.each do |k, v|
          v = "#{BOLD}#{v}#{CLEAR}#{colours}"
          message.gsub!(/%\{#{k}\}/, v)
        end
      end
      message + CLEAR
    end

    def color(message, *colours)
      colours.join("") + message + CLEAR
    end
  end
end
