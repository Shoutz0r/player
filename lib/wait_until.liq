def wait_until_callback(s) =
    s
end

# Start fadeout after the defined waittime has passed
#
# @param ~waittime      Time to wait until the fadeout starts
# @param ~duration      The duration the fadeout should take
# @param s              The source to apply it to
def wait_until(
        ~waittime=1.,
        ~on_done=wait_until_callback,
        s) =

    start_time = ref(-1.)
    has_run = ref(false)

    def check_time() =       
        if !start_time < 0. then
            start_time := source.time(s)
        end

        t = source.time(s) - !start_time
        if t > waittime then
            s = on_done(s)
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