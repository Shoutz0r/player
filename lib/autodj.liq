# Crossover function for track switching
# will attempt to use AutoDJ logic to smoothen transitions between
# the tracks by mixing them. Otherwise will fallback to smart crossfade.
#
# @param ~cross_duration         When to start the crossover
# @param ~max_bpm_adjust     Max BPM difference between tracks for
#                            the smart-mix logic to be enabled.
#                            Will otherwise use smart crossfade.
# @param source_input        The input source.
def autodj_mix (
        ~cross_duration=8.,
        ~max_bpm_adjust=10.,
        source_input) =

    def log(x) = log(label="autodj_mix", x) end

    def autodj_transition(a,b) =

        # Debugging
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

        #
        # Transition logic
        #

        
        # Temporarely disabled. Doesn't really work as intended.

#        # If the BPM difference is too large, or if the BPM was unable to be detected
#        # we cannot match the BPM between songs
#        let source_b = if 
#            bpm_diff > max_bpm_adjust or
#            bpm_a == 0. or
#            bpm_b == 0.
#        then
#            log("BPM difference is too large, or failed to detect BPM.")
#            (source_b:source)
#        else
#            log("BPM difference is within range. Matching BPM")
#
#            # 1. Use CUE point to sync up the beats
#            # 2. adjust BPM of upcoming track to match upcoming track
#            # 3. Crossfade (keeping in mind the possible volume difference)
#            # 4. After crossfade is complete, restore the tempo slowly back to the original speed
#
#            source_b = dynamic_stretch(
#                start_ratio=bpm_diff_ratio,
#                target_ratio=1.,
#                duration=cross_duration,
#                source_b)
#
#            (source_b:source)
#        end

        # Next up, determine what kind of fade to use based on volume differences

        # Volume is similar (within 4dB difference)
        let (source_a, source_b) = if 
            abs(a.db_level - b.db_level) <= 4.
        then
            log("Volume is similar")
            log("Transition: crossed, fade-in, fade-out.")

            (fade.out(duration=cross_duration, source_a), fade.in(duration=cross_duration, source_b))

        # B is louder than A
        elsif b.db_level >= a.db_level
        then
            log("New source is significantly louder than old one.")
            log("Transition: crossed, quick-fadeout + fade-in.")

            (fade.out(duration=cross_duration / 2., source_a), fade.in(duration=cross_duration, source_b))

        # A is louder than B
        else
            log("Old source is significantly louder than new one.")
            log("Transition: crossed, fade-out + quick-fadein")
            (fade.out(duration=cross_duration, source_a), fade.in(duration=cross_duration / 2., source_b))
        end

        add(normalize=false, [ source_a, source_b ])
    end #/def

    # Trigger our code when {cross_duration} seconds of the current track is remaining
    cross(
        width=cross_duration,
        duration=cross_duration,
        conservative=false,
        autodj_transition,
        source_input)
end #/def
