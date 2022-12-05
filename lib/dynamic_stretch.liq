def dynamic_stretch(
    ~start_ratio=1.,
    ~target_ratio=1.,
    ~duration=1.,
    ~start_delay=0.,
    source_input) =

    ratio = ref(start_ratio)

    # Change the speed of the current playing song to match the next track
    def stretch_ratio() =
        ratio = !ratio
        log("Current stretch: #{string_of(ratio)}")
        ratio
    end

    source_input = stretch(
        ratio=stretch_ratio,
        source_input)

    source_input = buffer(
        buffer=1., 
        start=true, 
        source_input)

    start_time = ref(-1.)

    # Add the function that will dynamically change the ratio
    def ratio_changer() =
        if !start_time < 0. then
            log("Ratio Changer started")
            start_time := source.time(source_input)
        end

        t = source.time(source_input) - !start_time

        if t > duration + 2.0 then
            log("Ratio Changer finished")
            -1.
        else
            log("Ratio Changer running")

            let new_ratio = if t >= duration then
                target_ratio
            else
                if start_ratio <= target_ratio then
                start_ratio + (t/duration) * (target_ratio-start_ratio)
                else
                target_ratio + (1.-t/duration) * (start_ratio-target_ratio)
                end
            end

            log("New value: #{string_of(new_ratio)}")

            ratio := new_ratio

            0.1
        end
    end

    # Trigger the dynamic ratio changing
    thread.run.recurrent(delay=start_delay, ratio_changer)

    # Return the source
    (source_input:source)
end