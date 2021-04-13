# Smoothly stretch a track based on the duration and ratio
#
# @param ~ratio    A value higher than 1 means slowing down
# @param ~duration The duration over which the ratio should be applied
# @param ~on_done  Function to execute when the fade is finished
# @param s         The source
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
# @param ~track_sensitive   Be track sensitive (if `false` stretch only once at the beginning of the track).
def smooth_stretch(
        ~id="smooth_stretch",
        ~start_ratio=1.,
        ~target_ratio=1.,
        ~duration=3.,
        s) =

    log = log(label=source.id(s),level=4)
    fn = ref(fun () -> 1.)
    duration = ref(duration)
    start_time = ref(-1.)
    started = ref(false)

    def start_stretch(d, _) =
        log("Start stretching")
        start_time := source.time(s)
        duration = if d < !duration then d else !duration end

        fn := mkstretch(
                start_ratio=start_ratio,
                target_ratio=target_ratio,
                duration=duration,
                s)

        started := true
    end

    def apply() =
        fn = !fn
        fn()
    end

    def stop_stretch(_) =
        if !started then
            log("Stopping stretching")

            fn := fun () -> 1.
            started := false
        end
    end

    start_stretch(!duration, [])
    source.on_track(s, stop_stretch)

    stretch(
        id=id,
        ratio=apply,
        s)
end