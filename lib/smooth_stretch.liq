# Smoothly stretch a track based on the duration and ratio
#
# @param ~ratio    A value higher than 1 means slowing down
# @param ~duration The duration over which the ratio should be applied
# @param ~on_done  Function to execute when the fade is finished
# @param ~active   The active behavior is to keep ticking the child's clock when the
#                  operator is not streaming. Otherwise the child's clock is strictly
#                  based on what is streamed off the child source, which results in
#                  time-dependent active sources to be frozen when that source is
#                  stopped.
# @param s         The source
def smooth_stretch(
    ~ratio=1.,
    ~duration=3.,
    ~on_done={()},
    ~active=true,
    s) =

  start_time = ref(-1.)
  current_ratio = ref(1.)

  def stretch_over_time() =
    if !start_time < 0. then
      start_time := source.time(s)
    end

    t = source.time(s) - !start_time
    if t > duration then
      on_done ()
      stop
    else
      if start <= stop then
        current_ratio := start + (ratio/duration) * (stop-start)
      else
        current_ratio := stop + (1.-ratio/duration) * (start-stop)
      end

      # Apply the new stretch value
      stretch(
        active=active, 
        ratio=current_ratio,
        s)
    end
  end

  stretch_over_time
end