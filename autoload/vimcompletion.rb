
require "irb"
require "irb/frame"
require "irb/completion"
module VimOmni
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
            @irb.context.ignore_sigint = false

            IRB.conf[:IRB_RC].call(@irb.context) if IRB.conf[:IRB_RC]
            IRB.conf[:MAIN_CONTEXT] = @irb.context
        end

        def puts(exps)
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
                super
                @buffer=c
                @max=m
                @index = 0
            end
            def eof?
                @index<max
            end
            def gets
                @index += 1
                @buffer[@index-1]
            end
        end
    end
end

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
