extends Node


func process_custom_tag(command: String, arg: String) -> String:
	match command:
		"favicon":
			return "[img %s]favicon.png[/img]" % [arg]
		"prompt":
			var args := arg.split(",", true, 1)

			# We use a default height of 32 pixels unless custom options are provided.
			var img_opts := " height=32"
			if len(args) == 2:
				img_opts = args[1]
				# We want to keep the lack of space before "=" because it's required for certain
				# image options, but other options need extra space.
				if not img_opts.begins_with("="): img_opts = " " + img_opts

			var path: String = InteractPromptTextureGenerator.get_texture_for_action_prompt(args[0]).resource_path
			return "[img%s]%s[/img]" % [img_opts, path]

	# We've only reached this spot if the above match didn't return (i.e, there's an error).
	return "[color=red](invalid)[/color]"
