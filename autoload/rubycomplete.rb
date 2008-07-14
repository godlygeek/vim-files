require 'irb'
require 'irb/xmp'
module VimOmni
    class VimInputMethod < IRB::InputMethod
        attr_accessor:lines
        attr_accessor:max
        def initialize(arr,m)
            @lines = arr
            @max = m
        end
    end
      class StringInputMethod < IRB::InputMethod
          def initialize
              super
              @exps = []
          end

          def eof?
              @exps.empty?
          end

          def gets
              while l = @exps.shift
                  next if /^\s+$/ =~ l
                  l.concat "\n"
                  print @prompt, l
                  break
              end
              l
          end

          def puts(exps)
              @exps.concat exps.split(/\n/)
          end
      end
end

def VimOmni.start2(ap_path = nil)
    #$0 = File::basename(ap_path, ".rb") if ap_path

    IRB.setup(ap_path)
    irb = Irb.new(nil,StringInputMethod.new)

    #if @CONF[:SCRIPT]
    #  irb = Irb.new(nil, @CONF[:SCRIPT])
    #else
    #  irb = Irb.new
    #end

    @CONF[:IRB_RC].call(irb.context) if @CONF[:IRB_RC]
    @CONF[:MAIN_CONTEXT] = irb.context

    trap("SIGINT") do
      irb.signal_handle
    end
    
    catch(:IRB_EXIT) do
      irb.eval_input
    end
end
end
