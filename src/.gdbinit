# -*- sh -*-
# CLISP .gdbinit

define base
       file lisp.run
       set args -B . -M lispinit.mem -q -norc
end
document base
         debug the base linking set
end

define full
       file full/lisp.run
       set args -B . -M full/lispinit.mem -q -norc -i clx/new-clx/demos/clx-demos -p CLX-DEMOS
       break my_standard_type_error
       break closed_display_error
end
document full
         debug the full linking set
end

# usually we are debugging the base set
base

define zout
        output object_out($arg0)
        echo \n
end
document zout
        print the specified object with PRIN1
end

define stack
       set $idx = $arg1
       while $idx >= $arg0
         echo ***** STACK_
         output $idx
         echo \ *****\n
         output object_out(STACK[-1-$idx])
         echo \n
         set $idx = $idx-1
       end
end
document stack
         print the section of STACK
end

break funcall
commands
        zout fun
end

break apply
commands
        zout fun
end

break eval
commands
        zout form
end

break gar_col
break fehler_notreached
break SP_ueber
break STACK_ueber

# disable breaks in funcall, apply, eval and gar_col
disable 1 2 3 4

watch back_trace
commands
        p back_trace_out(0,0)
        continue
end
disable 8

info break

# these should come last:
# without GENERATIONAL_GC there is no sigsegv_handler_failed(),
# so the next `break' command will fail,
# thus the two last `handle' commands will not be executed,
# thus we _will_ see the backtrace
# ergo: `break sigsegv_handler_failed' must come _before_
#       `handle SIG*'
#ifdef GENERATIONAL_GC
break sigsegv_handler_failed
handle SIGSEGV noprint nostop
handle SIGBUS noprint nostop
#endif
