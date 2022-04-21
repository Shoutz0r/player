# Crossover function for track switching
# will attempt to use AutoDJ logic to smoothen transitions between
# the tracks by mixing them. Otherwise will fallback to smart crossfade.
#
# @param ~start_next         When to start the crossover
# @param ~max_bpm_adjust     Max BPM difference between tracks for
#                            the smart-mix logic to be enabled.
#                            Will otherwise use smart crossfade.
# @param source_input        The input source.
def autodj_mix (
        ~start_next=8.,
        ~max_bpm_adjust=50.,
        source_input) =

    log = log(label="autodj_mix")

    def autodj_transition(a,b) =

        # Debugging
        list.iter(fun(item) -> log("META A: #{string_of(item)}"), a.metadata)
        list.iter(fun(item) -> log("META B: #{string_of(item)}"), b.metadata)

        log("Volume track A: #{string_of(a.db_level)}")
        log("Volume track B: #{string_of(b.db_level)}")

        # Get the BPM from both sources
        bpm_a = float_of_string(a.metadata["tempo"])
        bpm_b = float_of_string(b.metadata["tempo"])

        log("BPM track A: #{string_of(bpm_a)}")
        log("BPM track B: #{string_of(bpm_b)}")

        # Calculate the BPM difference ratio
        # Where: 
        # 1 is same speed.
        # > 1 means the next track is slower
        # < 1 means the next track is faster
        bpm_diff_ratio = bpm_b / bpm_a
        bpm_diff = abs(bpm_b - bpm_a)

        source_a = a.source
        source_b = b.source

        ratio = ref(1.)

        # Change the speed of the current playing song to match the next track
        def stretch_ratio() =
            ratio = !ratio
            log("Current stretch: #{string_of(ratio)}")
            ratio
        end

        #
        # Transition logic
        #

        # If the BPM difference is too large, or if the BPM was unable to be detected
        # we cannot match the BPM between songs
        let source_b = if 
            bpm_diff > max_bpm_adjust or
            bpm_a == 0. or
            bpm_b == 0.
        then
            log("BPM difference is too large, or failed to detect BPM.")
            (source_b:source)
        else
            log("BPM difference is within range. Matching BPM")

            # 1. Use CUE point to sync up the beats
            # 2. adjust BPM of upcoming track to match upcoming track
            # 3. Crossfade (keeping in mind the possible volume difference)
            # 4. After crossfade is complete, restore the tempo slowly back to the original speed

            ratio := bpm_diff_ratio

            # Stretch stops working once cross is finished.. gotta figure out how to deal with that.
            # Call external function?

            source_b = stretch(
               ratio=stretch_ratio,
               source_b)

            start_time = ref(-1.)

            def ratio_changer() =
                let duration = 4.
                let start = bpm_diff_ratio
                let stop = 1.

                if !start_time < 0. then
                    log("Ratio Changer started")
                    start_time := source.time(source_b)
                end

                t = source.time(source_b) - !start_time

                if t > duration + 2.0 then
                    log("Ratio Changer finished")
                    -1.
                else
                    log("Ratio Changer running")

                    let new_ratio = if t >= duration then
                      stop
                    else
                      if start <= stop then
                        start + (t/duration) * (stop-start)
                      else
                        stop + (1.-t/duration) * (start-stop)
                      end
                    end

                    log("New value: #{string_of(new_ratio)}")

                    ratio := new_ratio

                    0.1
                end
            end

            # Slowly restore tempo after the crossfade is complete
            thread.run.recurrent(delay=8., ratio_changer)

            (source_b:source)
        end

        # Next up, determine what kind of fade to use based on volume differences

        # Volume is similar (within 4dB difference)
        let (source_a, source_b) = if 
            abs(a.db_level - b.db_level) <= 4.
        then
            log("Volume is similar")
            log("Transition: crossed, fade-in, fade-out.")

            (fade.out(duration=start_next, source_a), fade.in(duration=start_next, source_b))

        # B is louder than A
        elsif b.db_level >= a.db_level
        then
            log("New source is significantly louder than old one.")
            log("Transition: crossed, quick-fadeout + fade-in.")

            (fade.out(duration=3., source_a), fade.in(duration=start_next, source_b))

        # A is louder than B
        else
            log("Old source is significantly louder than new one.")
            log("Transition: crossed, fade-out + quick-fadein")
            (fade.out(duration=start_next, source_a), fade.in(duration=3., source_b))
        end

        add(normalize=false, [ source_a, source_b ])
    end #/def

    # Trigger our code when {start_next} seconds of the current track is remaining
    cross(
        width=start_next,
        duration=start_next + 6.,
        conservative=false,
        autodj_transition,
        source_input)
end #/def
