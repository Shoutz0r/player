# Will check the source metadata to determine wether the source
# has a video stream or not.
# 
# NOT PRODUCTION READY!
#
# @param ~s    The source
def has_video(s) =

	log = log(label="has_video")
	result = ref("none")
	kind = s.metadata["kind"]

	# Remove the starting { and ending } characters
	kind = r/{|}/g.replace(kind)

	# Get a key/value array from the string
	kind_list = r/(?<key>[^=]+)=(?<value>[^,|}]+),?/.exec(kind)

	def find_video_info(item)
		if string_of(fst(item)) == "video" then
			log("matched video key")
			result := snd(item)
		end
	end
	
	list.iter(
		find_video_info, 
		kind_list)

	if !result == "none" then
		log("no video track found")
		false
	else
		log("video track found")
		true
	end
end
