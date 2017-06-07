require 'optparse'
require 'ostruct'

require 'stringio'

module Drydock
  require 'drydock/mixins'
  
  autoload :Screen, 'drydock/screen'
  autoload :Console, 'drydock/console'
  
  class FancyArray < Array #:nodoc:
    attr_reader :fields
    def add_field(n)
      @fields ||= []
      field_name = n
      eval <<-RUBY, binding, '(Drydock::FancyArray)', 1
      def #{n}
        if self.size > @fields.size && '#{n}'.to_sym == @fields.last
          self[#{@fields.size}..-1]
        else
          self[#{@fields.size}]
        end
      end
      def #{n}=(val)
        if self.size > @fields.size && '#{n}'.to_sym == @fields.last
          self[#{@fields.size}..-1] = val
        else
          self[#{@fields.size}] = val
        end
      end
      RUBY
      @fields << n
      n
    end
    def fields=(*args)
      args.flatten.each do |field|
        add_field(field)
      end
    end
  end
  
  class ArgError < RuntimeError
    attr_reader :arg, :cmd, :msg
    def initialize(*args)
      @msg = args.shift if args.size == 1
      @arg, @cmd, @msg = *args
      @cmd ||= 'COMMAND'
      @msg = nil if @msg && @msg.empty?
    end
    def message; @msg || "Error: No #{@arg} provided"; end
    def usage; "See: #{$0} #{@cmd} -h"; end
  end
  class OptError < ArgError
    def message; @msg || "Error: No #{@arg} provided"; end
  end
  
  # The base class for all command objects. There is an instance of this class
  # for every command defined. Global and command-specific options are added
  # as attributes to this class dynamically. 
  # 
  #     i.e. "example -v select --location kumamoto"
  #
  #     global :v, :verbose, "I want mooooore!"
  #     option :l, :location, String, "Source location"
  #     command :select do |obj|
  #       puts obj.global.verbose   #=> true
  #       puts obj.option.location  #=> "kumamoto"
  #     end
  #
  # You can sub-class it to create your own: 
  #
  #     class Malpeque < Drydock::Command
  #       # ... sea to it
  #     end
  #
  # And then specify your class in the command definition:
  #
  #     command :eat => Malpeque do |obj|
  #       # ... do stuff with your obj
  #     end
  #
  class Command
    VERSION = "0.6.9"
      # The canonical name of the command (the one used in the command definition). If you 
      # inherit from this class and add a method named +cmd+, you can leave omit the block
      # in the command definition. That method will be called instead. See bin/examples.
    attr_reader :cmd
      # The name used to evoke this command (it's either the canonical name or the alias used).
    attr_reader :alias
      # The block that will be executed when this command is evoked. If the block is nil
      # it will check if there is a method named +cmd+. If so, that will be executed.
    attr_reader :b
      # An OpenStruct object containing the command options specified at run-time.
    attr_reader :option
      # An OpenStruct object containing the global options specified at run-time.
    attr_reader :global
      # A friendly description of the command. 
    attr_accessor :desc
      # An array of action names specified in the command definition
    attr_accessor :actions
      # An instance of Drydock::FancyArray. Acts like an array of unnamed arguments
      # but also allows field names if supplied. 
    attr_accessor :argv  
      # Either an IO handle to STDIN or the output of the Drydock#stdin handler. 
    attr_reader :stdin
      # The basename of the executable or script: File.basename($0)
    attr_reader :executable
    
    # The default constructor sets the short name of the command
    # and stores a reference to the block (if supplied).
    # You don't need to override this method to add functionality 
    # to your custom Command classes. Define an +init+ method instead.
    # It will be called just before the block is executed. 
    # +cmd+ is the short name of this command.
    # +b+ is the block associated to this command.
    def initialize(cmd, &b)
      @cmd = (cmd.kind_of?(Symbol)) ? cmd : cmd.to_sym
      @b = b
      @actions = []
      @argv = Drydock::FancyArray.new # an array with field names
      @stdin = STDIN
      @option = OpenStruct.new
      @global = OpenStruct.new
      @executable = File.basename($0)
      @global.verbose = 0
      @global.quiet = false
    end
    
    # Returns the command name (not the alias)
    def name
      @cmd
    end
    
    # Prepare this command object to be called. 
    # 
    # Calls self.init after setting attributes (if the method exists). You can 
    # implement an init method in your subclasses of Drydock::Command to handle
    # your own initialization stuff.
    #
    # <li>+cmd_str+ is the short name used to evoke this command. It will equal @cmd
    # unless an alias was used used to evoke this command.</li>
    # <li>+argv+ an array of unnamed arguments. If ignore :options was declared this</li>
    # will contain the arguments exactly as they were defined on the command-line.</li>
    # <li>+stdin+ contains the output of stdin do; ...; end otherwise it's a STDIN IO handle.</li>
    # <li>+global_options+ a hash of the global options specified on the command-line</li>
    # <li>+options+ a hash of the command-specific options specific on the command-line.</li>
    def prepare(cmd_str=nil, argv=[], stdin=[], global_options={}, options={})
      @alias = cmd_str.nil? ? @cmd : cmd_str

      global_options.each_pair do |n,v|
        self.global.send("#{n}=", v)    # Populate the object's globals
      end
      
      options.each_pair do |n,v|
        self.option.send("#{n}=", v)    # ... and also the command options
      end
      
      @argv << argv    # TODO: Using += returns an Array instead of FancyArray
      @argv.flatten!   # NOTE: << creates @argv[[]]
      @stdin = stdin
      
      self.init         if self.respond_to? :init     # Must be called first!
      
    end
    
    # Calls the command in the following order:
    # 
    # * print_header
    # * validation (if methodname_valid? exists)
    # * command block (@b)
    # * print_footer
    #
    def call  
      self.print_header if self.respond_to? :print_header
      
      # Execute the command block if it exists
      if @b 
        run_validation
        @b.call(self) 
      
      # Otherwise check to see if an action was specified
      elsif !(chosen = find_action(self.option)).empty?
        raise "Only one action at a time please! I can't #{chosen.join(' AND ')}." if chosen.size > 1
        criteria = [[@cmd, chosen.first], [chosen.first, @cmd]]
        meth = name = nil
        # Try command_action, then action_command
        criteria.each do |tuple|
          name = tuple.join('_')
          meth = name if self.respond_to?(name)  
        end
        
        raise "#{self.class} needs a #{name} method!" unless meth
        
        run_validation(meth)
        self.send(meth)
        
      # No block and no action. We'll try for the method name in the Drydock::Command class. 
      elsif self.respond_to? @cmd.to_sym
        run_validation(@cmd)
        self.send(@cmd)
        
      # Well, then I have no idea what you want me to do!
      else
        raise "The command #{@alias} has no block and #{self.class} has no #{@cmd} method!"
      end
      
      self.print_footer if respond_to? :print_footer
    end
    
    # <li>+meth+ The method name used to determine the name of the validation method.
    # If not supplied, the validation method is "valid?" otherwise it's "meth_valid?"</li>
    # If the command class doesn't have the given validation method, we'll just continue
    # on our way.
    #
    # Recognized validation methods are:
    #
    #     def valid?                  # if we're executing a command block
    #     def command_valid?          # if we're executing an object method
    #     def command_action_valid?   # if the main meth is command_action
    #     def action_command_valid?   # if the main meth is action_command
    #
    # This method raises a generic exception when the validation method returns false. 
    # However, <strong>it's more appropriate for the validation methods to raise 
    # detailed exceptions</strong>. 
    #
    def run_validation(meth=nil)
      vmeth = meth ? [meth, 'valid?'].join('_') : 'valid?'
      is_valid = self.respond_to?(vmeth) ? self.send(vmeth) : true
      raise "Your request is not valid. See #{$0} #{@cmd} -h" unless is_valid
    end
    private :run_validation
    
    # Compares the list of known actions to the list of boolean switches supplied
    # on the command line (if any). 
    # <li>+options+ is a hash of the named command line arguments (created by 
    # OptionParser#getopts)</li>
    # Returns an array of action names (empty if no action was supplied)
    def find_action(options)
      options = options.marshal_dump if options.is_a?(OpenStruct)
      boolkeys = options.keys.select { |n| options[n] == true } || []
      boolkeys = boolkeys.collect { |n| n.to_s } # @agents contains Strings. 
      # Returns the elements in @actions that are also found in boolkeys
      (@actions || []) & boolkeys 
    end
    private :find_action
    
    # Print the list of available commands to STDOUT. This is used as the 
    # "default" command unless another default commands is supplied. You 
    # can also write your own Drydock::Command#show_commands to override
    # this default behaviour. 
    #
    # The output was worked on here:
    # http://etherpad.com/SXjqQGRr8M
    #
    def show_commands
      project = " for #{Drydock.project}" if Drydock.project?
      cmds = {}
      Drydock.commands.keys.each do |cmd|
        next if cmd == :show_commands
        pretty = Drydock.decanonize(cmd)
        # Out to sea
        cmds[Drydock.commands[cmd].cmd] ||= {}
        unless cmd === Drydock.commands[cmd].cmd
          (cmds[Drydock.commands[cmd].cmd][:aliases] ||= []) << pretty
          next
        end
        cmds[cmd][:desc] = Drydock.commands[cmd].desc
        cmds[cmd][:desc] = nil if cmds[cmd][:desc] && cmds[cmd][:desc].empty?
        cmds[cmd][:pretty] = pretty
      end
    
      cmd_names_sorted = cmds.keys.sort{ |a,b| a.to_s <=> b.to_s }
      
      if @global.quiet
        puts "Commands: "
        line = []
        cmd_names_sorted.each_with_index do |cmd,i|
          line << cmd
          if (line.size % 4 == 0) || i == (cmd_names_sorted.size - 1)
            puts "  %s" % line.join(', ')
            line.clear
          end
        end
        return
      end
      
      puts "%5s: %s" % ["Usage", "#{@executable} [global options] COMMAND [command options]"]
      puts "%5s: %s" % ["Try", "#{@executable} -h"] 
      puts "%5s  %s" % ["", "#{@executable} COMMAND -h"]
      puts
      
      puts "Commands: "
      if @global.verbose > 0
        puts # empty line
        cmd_names_sorted.each do |cmd|
          puts "$ %s" % [@executable] if Drydock.default?(cmd)
          puts "$ %s %s" % [@executable, cmds[cmd][:pretty]]
          puts "%10s: %s" % ["About", cmds[cmd][:desc]] if cmds[cmd][:desc]
          if cmds[cmd][:aliases]
            cmds[cmd][:aliases].sort!{ |a,b| a.size <=> b.size }
            puts "%10s: %s" % ["Aliases", cmds[cmd][:aliases].join(', ')]
          end
          puts
        end

      else
        cmd_names_sorted.each do |cmd|
          aliases = cmds[cmd][:aliases] || []
          aliases.sort!{ |a,b| a.size <=> b.size }
          aliases = aliases.empty? ? '' : "(aliases: #{aliases.join(', ')})"
          pattern = Drydock.default?(cmd) ? "* %-16s %s" : "  %-16s %s"
          puts pattern % [cmds[cmd][:pretty], aliases]
        end
      end
    end
    
    # The name of the command
    def to_s
      @cmd.to_s
    end
  end
end

module Drydock
  class UnknownCommand < RuntimeError
    attr_reader :name
    def initialize(name)
      @name = name || :unknown
    end
    def message
      "Unknown command: #{@name}"
    end
  end
  class NoCommandsDefined < RuntimeError
    def message
      "No commands defined"
    end
  end
  class InvalidArgument < RuntimeError
    attr_accessor :args
    def initialize(args)
      @args = args || []
    end
    def message
      "Unknown option: #{@args.join(", ")}"
    end
  end
  class MissingArgument < InvalidArgument
    def message
      "Option requires a value: #{@args.join(", ")}"
    end
  end
end

# Drydock is a DSL for command-line apps. 
# See bin/example for usage examples. 
module Drydock
  extend self
  
  VERSION = 0.6
  
  @@project = nil
  
  @@debug = false
  @@has_run = false
  @@run = true
  
  @@global_opts_parser = OptionParser.new
  @@global_option_names = []

  @@command_opts_parser = []
  @@command_option_names = []
  @@command_actions = []
  
  @@default_command = nil
  @@default_command_with_args = false
  
  @@commands = {}
  @@command_descriptions = []
  @@command_index = 0
  @@command_index_map = {}
  @@command_argv_names = []  # an array of names for values of argv
  
  @@capture = nil            # contains one of :stdout, :stderr
  @@captured = nil
  
  @@trawler = nil
  
 public
  # Enable or disable debug output.
  #
  #     debug :on
  #     debug :off
  #
  # Calling without :on or :off will toggle the value. 
  #
  def debug(toggle=false)
    if toggle.is_a? Symbol
      @@debug = true if toggle == :on
      @@debug = false if toggle == :off
    else
      @@debug = (!@@debug)
    end
  end
  
  # Returns true if debug output is enabled. 
  def debug?
    @@debug
  end
  
  # Provide names for CLI arguments, in the order they appear. 
  #
  #     $ yourscript sample malpeque zinqy
  #     argv :name, :flavour
  #     command :sample do |obj|
  #       obj.argv.name        # => malpeque
  #       obj.argv.flavour     # => zinqy
  #     end
  #
  def argv(*args)
    @@command_argv_names[@@command_index] ||= []
    @@command_argv_names[@@command_index] += args.flatten
  end
  
  # The project name. This is currently only used when printing
  # list of commands (see: Drydock::Command#show_commands). It may be 
  # used elsewhere in the future. 
  def project(txt=nil)
    
    return @@project unless txt
    
    #begin
    #  require txt.downcase
    #rescue LoadError => ex
    #  Drydock.run = false  # Prevent execution at_exit
    #  abort "Problem during require: #{ex.message}"
    #end
    @@project = txt
  end
  
  # Has the project been set?
  def project?
    (defined?(@@project) && !@@project.nil?)
  end
  
  # Define a default command. You can specify a command name that has 
  # been or will be defined in your script:
  #
  #     default :task
  #
  # Or you can supply a block which will be used as the default command:
  #
  #     default do |obj|            # This command will be named "default"
  #       # ...
  #     end
  #
  #     default :hullinspector do   # This one will be named "hullinspector"
  #       # ...
  #     end
  #
  # If +with_args+ is specified, the default command will receive all unknown
  # values as arguments. This is necessary to define explicitly because drydock
  # parses arguments expecting a command name. If the default command accepts
  # arguments and with_args is not specified, drydock will raise an unknown
  # command exception for the first argument.
  #
  def default(cmd=nil, with_args=false, &b)
    raise "Calling default requires a command name or a block" unless cmd || b
    # Creates the command and returns the name or just stores given name
    @@default_command = (b) ? command(cmd || :default, &b).cmd : canonize(cmd)
    # IDEA: refactor out the argument parser to support different types of CLI
    @@default_command_with_args = with_args ? true : false
    @@default_command
  end
  
  # Is +cmd+ the default command?
  def default?(cmd)
    return false if @@default_command.nil?
    (@@default_command == canonize(cmd))
  end
  
  # 
  def default_with_args?; @@default_command_with_args; end
  
  
  # Define a block for processing STDIN before the command is called. 
  # The command block receives the return value of this block as obj.stdin:
  #
  #     command :task do |obj|; 
  #       obj.stdin   # => ...
  #     end
  #
  # If a stdin block isn't defined, +stdin+ above will be the STDIN IO handle. 
  def stdin(&b)
    @@stdin_block = b
  end
  
  # Define a block to be called before the command. 
  # This is useful for opening database connections, etc...
  def before(&b)
    @@before_block = b
  end
  
  # Define a block to be called after the command. 
  # This is useful for stopping, closing, etc... the stuff in the before block. 
  def after(&b)
    @@after_block = b
  end
  
  # Define the default global usage banner. This is displayed
  # with "script -h". 
  def global_usage(msg)
    @@global_opts_parser.banner = "USAGE: #{msg}"
  end
  
  # Define a command-specific usage banner. This is displayed
  # with "script command -h"
  def usage(msg)
    # The default value given by OptionParser starts with "Usage". That's how
    # we know we can clear it. 
    get_current_option_parser.banner = "" if get_current_option_parser.banner =~ /^Usage:/
    get_current_option_parser.banner << "USAGE: #{msg}" << $/
  end
  
  # Tell the Drydock parser to ignore something. 
  # Drydock will currently only listen to you if you tell it to "ignore :options", 
  # otherwise it will ignore you!
  # 
  # +what+ the thing to ignore. When it equals :options Drydock will not parse
  # the command-specific arguments. It will pass the arguments directly to the
  # Command object. This is useful when you want to parse the arguments in some a way
  # that's too crazy, dangerous for Drydock to handle automatically.  
  def ignore(what=:nothing)
    @@command_opts_parser[@@command_index] = :ignore if what == :options || what == :all
  end
  
  # Define a global option. See +option+ for more info. 
  def global_option(*args, &b)
    args.unshift(@@global_opts_parser)
    @@global_option_names << option_parser(args, &b)
  end
  alias :global :global_option
  
  # Define a command-specific option. 
  # 
  # +args+ is passed directly to OptionParser.on so it can contain anything
  # that's valid to that method. If a class is included, it will tell 
  # OptionParser to expect a value otherwise it assumes a boolean value. 
  # Some examples:
  #
  #     option :h, :help, "Displays this message"
  #     option '-l x,y,z', '--lang=x,y,z', Array, "Requested languages"
  #
  #     You can also supply a block to fiddle with the values. The final 
  #     value becomes the option's value:
  #
  #     option :m, :max, Integer, "Maximum threshold" do |v|
  #       v = 100 if v > 100
  #       v
  #     end
  #
  # All calls to +option+ must come before the command they're associated
  # to. Example:
  # 
  #     option :t, :tasty,          "A boolean switch"
  #     option     :reason, String, "Requires a parameter"
  #     command :task do |obj|; 
  #       obj.options.tasty       # => true
  #       obj.options.reason      # => I made the sandwich!
  #     end
  #
  # When calling your script with a specific command-line option, the value
  # is available via obj.longname inside the command block. 
  #
  def option(*args, &b)
    args.unshift(get_current_option_parser)
    current_command_option_names << option_parser(args, &b)
  end
  
  # Define a command-specific action.
  #
  # This is functionally very similar to option, but with an exciting and buoyant twist:
  # Drydock keeps track of actions for each command (in addition to treating it like an option).
  # When an action is specified on the command line Drydock looks for command_action or 
  # action_command methods in the command class. 
  #
  #     action :E, :eat, "Eat something"
  #     command :oysters => Fresh::Oysters
  #
  #     # Drydock will look for Fresh::Oysters#eat_oysters and Fresh::Oysters#oysters_eat.
  #
  def action(*args, &b)
    ret = option(*args, &b) # returns an array of all the current option names
    current_command_action << ret.last # the most recent is last
  end
    
  # Define a command. 
  # 
  #     command :task do
  #       ...
  #     end
  # 
  # A custom command class can be specified using Hash syntax. The class
  # must inherit from Drydock::Command (class CustomeClass < Drydock::Command)
  #
  #     command :task => CustomCommand do
  #       ...
  #     end
  #
  def command(*cmds, &b)
    cmd = cmds.shift # Should we accept aliases here?
    
    if cmd.is_a? Hash
      klass = cmd.values.first
      names = cmd.keys.first
      if names.is_a? Array
        cmd, cmds = names.shift, [names].flatten.compact
      else
        cmd = names
      end
      raise "#{klass} is not a subclass of Drydock::Command" unless klass.ancestors.member?(Drydock::Command)
      c = klass.new(cmd, &b)          # A custom class was specified
    else
      c = Drydock::Command.new(cmd, &b)
    end
    
    @@command_descriptions[@@command_index] ||= ""
    @@command_actions[@@command_index] ||= []
    @@command_argv_names[@@command_index] ||= []
    
    c.desc = @@command_descriptions[@@command_index]
    c.actions = @@command_actions[@@command_index]
    c.argv.fields = @@command_argv_names[@@command_index]
    
    # Default Usage Banner. 
    # Without this, there's no help displayed for the command. 
    option_parser = get_option_parser(@@command_index)
    if option_parser.is_a?(OptionParser) && option_parser.banner !~ /^USAGE/
      usage "#{c.executable} #{c.cmd}"
    end
    
    @@commands[c.cmd] = c
    @@command_index_map[c.cmd] = @@command_index
    @@command_index += 1 # This will point to the next command
    
    # Created aliases to the command using any additional command names 
    # i.e. command :something, :sumpin => Something
    cmds.each { |aliaz| command_alias(cmd, aliaz); } unless cmds.empty?
    
    c  # Return the Command object
  end
  
  # Used to create an alias to a defined command. 
  # Here's an example:
  #
  #    command :task do; ...; end
  #    alias_command :pointer, :task
  #
  # Either name can be used on the command-line:
  #
  #    $ yourscript task [options]
  #    $ yourscript pointer [options]
  #
  # Inside of the command definition, you have access to the
  # command name that was used via obj.alias. 
  def alias_command(aliaz, cmd)
    return unless commands.has_key? cmd
    commands[canonize(aliaz)] = commands[cmd]
  end
  
  # Identical to +alias_command+ with reversed arguments. 
  # For whatever reason I forget the order so Drydock supports both. 
  # Tip: the argument order matches the method name. 
  def command_alias(cmd, aliaz)
    return unless commands.has_key? cmd
    commands[canonize(aliaz)] = commands[cmd]
  end
  
  # A hash of the currently defined Drydock::Command objects
  def commands
    @@commands
  end
  
  # An array of the currently defined commands names
  def command_names
    @@commands.keys.collect { |cmd| decanonize(cmd); }
  end
  
  # The trawler catches any and all unknown commands that pass through
  # Drydock. It's like the captain of aliases. 
  # +cmd+ is the name of the command to direct unknowns to. 
  #
  #     trawler :command_name
  #
  def trawler(cmd)
    @@trawler = cmd
  end
  
  # Has the trawler been set?
  def trawler?
    !@@trawler.nil? && !@@trawler.to_s.empty?
  end
  
  # Provide a description for a command
  def about(txt)
    @@command_descriptions += [txt]
    return if get_current_option_parser.is_a?(Symbol)
    get_current_option_parser.on "ABOUT: #{txt}"
  end
  # Deprecated. Use about.
  def desc(txt)
    STDERR.puts "'desc' is deprecated. Please use 'about' instead."
    about(txt) 
  end
  
  # Returns true if automatic execution is enabled. 
  def run?
    @@run && has_run? == false
  end
  
  # Disable automatic execution (enabled by default)
  #
  #     Drydock.run = false
  def run=(v)
    @@run = (v.is_a?(TrueClass)) ? true : false 
  end
  
  # Return true if a command has been executed.
  def has_run?
    @@has_run
  end
  
  # Execute the given command.
  # By default, Drydock automatically executes itself and provides handlers for known errors.
  # You can override this functionality by calling +Drydock.run!+ yourself. Drydock
  # will only call +run!+ once. 
  def run!(argv=[], stdin=STDIN)
    return if has_run?
    @@has_run = true
    raise NoCommandsDefined.new if commands.empty?
    
    global_options, cmd_name, command_options, argv = process_arguments(argv)
    stdin = (defined? @@stdin_block) ? @@stdin_block.call(stdin, []) : stdin
    
    command_obj = get_command(cmd_name)
    command_obj.prepare(cmd_name, argv, stdin, global_options, command_options)
    
    # Execute before block
    @@before_block.call(command_obj) if defined? @@before_block
    
    # Execute the requested command. We'll capture STDERR or STDOUT if desired. 
    @@captured = capture? ? capture_io(@@capture) { command_obj.call } : command_obj.call
        
    # Execute after block
    @@after_block.call(command_obj) if defined? @@after_block
    
  rescue OptionParser::InvalidOption => ex
    raise Drydock::InvalidArgument.new(ex.args)
  rescue OptionParser::MissingArgument => ex
    raise Drydock::MissingArgument.new(ex.args)
  end
  
  def capture(io)
    @@capture = io
  end
  
  def captured
    @@captured
  end
  
  def capture?
    !@@capture.nil?
  end
  
  # Returns true if a command with the name +cmd+ has been defined. 
  def command?(cmd)
    name = canonize(cmd)
    @@commands.has_key? name
  end
  
  # Canonizes a string (+cmd+) to the symbol for command names
  # '-' is replaced with '_'
  def canonize(cmd)
    return unless cmd
    return cmd if cmd.kind_of?(Symbol)
    cmd.to_s.tr('-', '_').to_sym
  end
  
  # Returns a string version of +cmd+, decanonized.
  # Lowercase, '_' is replaced with '-'
  def decanonize(cmd)
    return unless cmd
    cmd.to_s.tr('_', '-')
  end
  
  # Capture STDOUT or STDERR to prevent it from being printed. 
  #
  #    capture(:stdout) do
  #      ...
  #    end
  #
  def capture_io(stream, &block)
    raise "We can only capture STDOUT or STDERR" unless stream == :stdout || stream == :stderr
    begin
      eval "$#{stream} = StringIO.new"
      block.call
      eval("$#{stream}").rewind                  # Otherwise we'll get nil 
      result = eval("$#{stream}").read
    ensure
      eval "$#{stream} = #{stream.to_s.upcase}"  # Put it back!
    end
  end
  
 private 
  
  # Returns the Drydock::Command object with the name +cmd+
  def get_command(cmd)
    return unless command?(cmd)
    @@commands[canonize(cmd)]
  end 
  
  # Processes calls to option and global_option. Symbols are converted into 
  # OptionParser style strings (:h and :help become '-h' and '--help'). 
  def option_parser(args=[], &b)
    return if args.empty?
    opts_parser = args.shift
    
    arg_name = ''
    symbol_switches = []
    args.each_with_index do |arg, index|
      if arg.is_a? Symbol
        arg_name = arg.to_s if arg.to_s.size > arg_name.size
        args[index] = (arg.to_s.length == 1) ? "-#{arg.to_s}" : "--#{arg.to_s}"
        symbol_switches << args[index]
      elsif arg.kind_of?(Class)
        symbol_switches.each do |arg|
          arg << "=S"
        end
      end
    end
    
    if args.size == 1
      opts_parser.on(args.shift)
    else
      opts_parser.on(*args) do |v|
        block_args = [v, opts_parser]
        result = (b.nil?) ? v : b.call(*block_args[0..(b.arity-1)])
      end
    end
    
    arg_name
  end
  
  
  # Split the +argv+ array into global args and command args and 
  # find the command name. 
  # i.e. ./script -H push -f (-H is a global arg, push is the command, -f is a command arg)
  # returns [global_options, cmd, command_options, argv]
  def process_arguments(argv=[])
    global_options = command_options = {}
    cmd = nil     
    
    argv_copy = argv.clone # See: @@default_command_with_args below
    
    global_options = @@global_opts_parser.getopts(argv)
    cmd_name = (argv.empty?) ? @@default_command : argv.shift
    
    unless command?(cmd_name)
      # If requested, send all unknown arguments to the default command
      if @@default_command_with_args
        cmd_name = @@default_command
        argv = argv_copy
      else
        raise UnknownCommand.new(cmd_name)  unless trawler?
        raise UnknownCommand.new(@@trawler) unless command?(@@trawler)
        command_alias(@@trawler, cmd_name)
      end
    end
    
    cmd = get_command(cmd_name) 
    
    command_parser = @@command_opts_parser[get_command_index(cmd.cmd)]
    command_options = {}
    
    # We only need to parse the options out of the arguments when
    # there are args available, there is a valid parser, and 
    # we weren't requested to ignore the options. 
    if !argv.empty? && command_parser && command_parser != :ignore
      command_options = command_parser.getopts(argv)
    end
    
    [global_options, cmd_name, command_options, argv]
  end
  

  # Grab the current list of command-specific option names. This is a list of the
  # long names. 
  def current_command_option_names
    (@@command_option_names[@@command_index] ||= [])
  end
  
  def current_command_action
    (@@command_actions[@@command_index] ||= [])
  end
  
  def get_command_index(cmd)
    @@command_index_map[canonize(cmd)] || -1
  end
  
  # Grab the options parser for the current command or create it if it doesn't exist.
  # Returns an instance of OptionParser.
  def get_current_option_parser
    (@@command_opts_parser[@@command_index] ||= OptionParser.new)
  end
  
  # Grabs the options parser for the given command. 
  # +arg+ can be an index or command name.
  # Returns an instance of OptionParser.
  def get_option_parser(arg)
    index = arg.is_a?(String) ? get_command_index(arg) : arg
    (@@command_opts_parser[index] ||= OptionParser.new)
  end
  
  #
  # These are the "reel" defaults
  #
  @@global_opts_parser.banner = "  Try: #{$0} show-commands"
  @@global_opts_parser.on "Usage: #{$0} [global options] COMMAND [command options] #{$/}"
  @@command_descriptions = ["Display available commands with descriptions"]
  @@default_command = Drydock.command(:show_commands).cmd
  
end

__END__
  
at_exit {
  begin
    if $@
      puts $@ if Drydock.debug?
      exit 1
    end 
    Drydock.run!(ARGV, STDIN) if Drydock.run? && !Drydock.has_run?
  rescue Drydock::ArgError, Drydock::OptError=> ex
    STDERR.puts ex.message
    STDERR.puts ex.usage
  rescue Drydock::UnknownCommand => ex  
    STDERR.puts ex.message
    STDERR.puts ex.backtrace if Drydock.debug?
  rescue => ex
    STDERR.puts "ERROR (#{ex.class.to_s}): #{ex.message}"
    STDERR.puts ex.backtrace if Drydock.debug?
  rescue Interrupt
    puts "#{$/}Exiting... "
    exit 1
  rescue SystemExit
    # Don't balk
  end
}

  
