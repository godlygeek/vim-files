
require "irb"
require "irb/frame"
require "irb/completion"
module VimOmni
    class RubyIrb < IRB::Irb
        def initialize (w,i)
            super(w,i)
        end
        def eval_input
            @scanner.set_prompt do
                |ltype, indent, continue, line_no|
            end
       
      @scanner.set_input(@context.io) do
	signal_status(:IN_INPUT) do
	  if l = @context.io.gets
	    print l if @context.verbose?
	  else
	  #  if @context.ignore_eof? and @context.io.readable_atfer_eof?
	  #    l = "\n"
	  #    if @context.verbose?
	  #      printf "Use \"exit\" to leave %s\n", @context.ap_name
	  #    end
	  #  end
	  end
          puts l
	  l
	end
      end

      @scanner.each_top_level_statement do |line, line_no|
	signal_status(:IN_EVAL) do
	  begin
            line.untaint
	    @context.evaluate(line, line_no)
	    output_value if @context.echo?
	  rescue StandardError, ScriptError, Abort
	    $! = RuntimeError.new("unknown exception raised") unless $!
	    print $!.class, ": ", $!, "\n"
	    if  $@[0] =~ /irb(2)?(\/.*|-.*|\.rb)?:/ && $!.class.to_s !~ /^IRB/
	      irb_bug = true 
	    else
	      irb_bug = false
	    end
	    
	    messages = []
	    lasts = []
	    levels = 0
	    for m in $@
	      m = @context.workspace.filter_backtrace(m) unless irb_bug
	      if m
	        if messages.size < @context.back_trace_limit
	          messages.push "\tfrom "+m
	        else
	          lasts.push "\tfrom "+m
	          if lasts.size > @context.back_trace_limit
	            lasts.shift 
	            levels += 1
	          end
	        end
	      end
	    end
	    print messages.join("\n"), "\n"
	    unless lasts.empty?
	      printf "... %d levels...\n", levels if levels > 0
	      print lasts.join("\n")
	    end
	    print "Maybe IRB bug!!\n" if irb_bug
	  end
          if $SAFE > 2
            warn "Error: irb does not work for $SAFE level higher than 2"
            exit 1
          end
	end
      end

        end
    end
    class RubyOmni
        @RCS_ID='-$Id: xmp.rb,v 1.3 2002/07/09 11:17:16 keiju Exp $-'
        def initialize(buf,max,ap_path= "./")
            #IRB.init_config(nil)
            IRB.setup(ap_path)
            #IRB.parse_opts
            #IRB.load_modules

            IRB.conf[:PROMPT_MODE] = :NULL

            @io = VimInputMethod.new(buf,max)
            @irb = IRB::Irb.new(nil, @io)
            #@irb = RubyIrb.new(nil, @io)
            @irb.context.ignore_sigint = false

            IRB.conf[:IRB_RC].call(@irb.context) if IRB.conf[:IRB_RC]
            IRB.conf[:MAIN_CONTEXT] = @irb.context
        end

        def show_omni(exps)
            if @irb.context.ignore_sigint
                begin
                    trap_proc_b = trap("SIGINT"){@irb.signal_handle}
                    catch(:IRB_EXIT) do
                        @irb.eval_input
                    end
                ensure
                    trap("SIGINT", trap_proc_b)
                end
            else
                catch(:IRB_EXIT) do
                    @irb.eval_input
                end
            end
            IRB::InputCompletor::CompletionProc.call(exps)
        end

        class VimInputMethod < IRB::InputMethod
            attr_accessor:buffer
            attr_accessor:max
            attr_accessor:index
            def initialize(c,m)
                super("line")
                @buffer=c
                @max=m
                @index = 0
            end
            def eof?
                @index<=@max
            end
            def gets
                return nil if @index>@max
                @index += 1
                @buffer[@index-1]+"\n"
            end
        end
    end
    def VimOmni.omni_ruby(file,max,str)
        f = File.open(file,"r")
        rubyomni = VimOmni::RubyOmni.new(f.readlines,max,"./")
        str = rubyomni.show_omni(str)
        str.each { |str1|
            puts str1 if str1
        }
        f.close
    end
end
if $*.length==3
    VimOmni.omni_ruby($*[0],$*[1].to_i,$*[2])
end
#arr=["abc='abc2'","def2=['dddd']"]
#    rubyomni = VimOmni::RubyOmni.new(arr,1,"./")
#    str = rubyomni.show_omni("def2.")
#    puts str
#    arr.each { |str1|
#        puts str1 if str1
#    }
#def xmp2(exps, bind = nil)
#  #bind = IRB::Frame.top(1) unless bind
#  xmp = XMP2.new(nil)
#  xmp.puts exps
#  #xmp
#  end
#str = xmp2 <<EOF
#abc="wangfc"
#def2=["abc","hello"]
#EOF
#
#puts str
