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
        ~max_bpm_adjust=12.,
        source_input) =

    log = log(label="autodj_cross")

    def autodj_transition(
            volume_a,
            volume_b,
            meta_source_a,
            meta_source_b,
            source_a,
            source_b) =

        # Debugging
        list.iter(fun(item) -> log("META A: #{string_of(item)}"), meta_source_a)
        list.iter(fun(item) -> log("META B: #{string_of(item)}"), meta_source_b)

        log("Volume track A: #{string_of(volume_a)}")
        log("Volume track B: #{string_of(volume_b)}")

        bpm_a = 0.
        bpm_b = 0.

        # Get the BPM from both sources
        bpm_b = float_of_string(meta_source_a["tempo"])
        bpm_a = float_of_string(meta_source_b["tempo"])

        log("BPM track A: #{string_of(bpm_a)}")
        log("BPM track B: #{string_of(bpm_b)}")

        # Calculate the BPM difference ratio
        # Where: 
        # 1 is same speed.
        # > 1 means the next track is slower
        # < 1 means the next track is faster
        bpm_diff_ratio = bpm_b / bpm_a
        bpm_diff = abs(bpm_b - bpm_a)

        #
        # Transition logic
        #

        # If the BPM difference is too large, or if the BPM was unable to be detected
        # we cannot transition with a smart mix.
        if 
            bpm_diff > max_bpm_adjust or
            bpm_a == 0. or
            bpm_b == 0.
        then
            log("BPM difference is too large, or failed to detect BPM. Using regular crossfade.")

            add([fade.out(source_a),fade.in(source_b)])

            #crossfade(
            #    duration=start_next,
            #    fade_in=5.,
            #    fade_out=3.,
            #    smart=true,
            #    width=3.,
            #    source_input)
        else
            log("BPM difference is within range. Using smart-mix logic")

            # 1. Use CUE point to sync up the beats
            # 2. adjust BPM of current track slowly to match upcoming track
            # 3. Crossfade
            # - Start fadein track B: 3 seconds
            # - after 2 seconds start fadeout track A, 3 seconds.

            # DISABLED : Right now an OCAML issue will occur when "stretch" is used
            # Progress can be tracked at: https://github.com/savonet/liquidsoap/issues/1572
            #
            # Change the speed of the current playing song to match the next track
            #source_a = smooth_stretch(
            #    target_ratio=bpm_diff_ratio,
            #    duration=5.,
            #    source_a)

            # Start fade in of track B
            source_b = fade.in(
                duration=3.,
                source_b)

            # Wait for 2 seconds, then start fadeout
            source_a = fadeout_after(
                waittime=2.,
                duration=3.,
                source_a)
            
            # Return our processed source output 
            add(
                normalize=false,
                [
                    source_a,
                    source_b
                ])
        end #/if
    end #/def

    # Trigger our code when {start_next} seconds of the current track is remaining
    cross(
        width=start_next,
        duration=start_next,
        conservative=false,
        autodj_transition,
        source_input)
end #/def
