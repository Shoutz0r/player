# Smoothly stretch a track based on the duration and ratio
#
# @param ~start_ratio   Start ratio
# @param ~target_ratio  Target ratio
# @param ~duration      The duration over which the ratio should be applied
# @param ~on_done       Function to execute when the fade is finished
# @param s              The source
def mkstretch(
        ~start_ratio=1.,
        ~target_ratio=1.,
        ~duration=3.,
        ~on_done={()},
        s) =

    start_time = ref(-1.)

    def stretch_over_time() =
        if !start_time < 0. then
            start_time := source.time(s)
        end

        t = source.time(s) - !start_time
        if t > duration then
            on_done ()
            target_ratio
        else
            if start_ratio <= target_ratio then
                start_ratio + (target_ratio / duration) * (target_ratio - start_ratio)
            else
                target_ratio + (1. - target_ratio / duration) * (start_ratio - target_ratio)
            end
        end
    end

    stretch_over_time
end

# Smoothly stretch a track (based on fade.out)
#
# @param ~id                Force the value of the source ID.
# @param ~start_ratio       Start value of the stretch ratio
# @param ~target_ratio      Target value of the stretch ratio
# @param ~duration          Duration of the stretching
# @param s                  The source
def smooth_stretch(
        ~id="smooth_stretch",
        ~start_ratio=1.,
        ~target_ratio=1.,
        ~duration=3.,
        s) =

    log = log(label=id)
    fn = ref(fun () -> 1.)
    duration = ref(duration)
    started = ref(false)

    def start_stretch()
        current_ratio = !fn

        # Check if the transition is completed, if so, mark as finished.
        if !started == true and current_ratio() == target_ratio then
            fn := fun () -> 1.
            started := false
        else
            log("Start stretching")

            fn := mkstretch(
                    start_ratio=start_ratio,
                    target_ratio=target_ratio,
                    duration=!duration,
                    s)

            started := true
        end
    end

    def apply() =
        fn = !fn
        fn()
    end

    log("calling start_stretch")
    start_stretch()

    log("applying stretch")
    
    stretch(
        id=id,
        ratio=apply(),
        s)
end