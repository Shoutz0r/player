# Start fadeout after the defined waittime has passed
#
# @param ~waittime      Time to wait until the fadeout starts
# @param ~duration      The duration the fadeout should take
# @param s              The source to apply it to
def fadeout_after(
        ~waittime=1.,
        ~duration=3.,
        s) =

    start_time = ref(-1.)
    has_run = ref(false)

    def check_time() =       
        if !start_time < 0. then
            start_time := source.time(s)
        end

        t = source.time(s) - !start_time
        if t > waittime then
            s = fade.out(
                duration=duration,
                s)
            has_run := true
        end
        
        s
    end

    if !has_run == true then
        s
    else
        check_time()
    end
end