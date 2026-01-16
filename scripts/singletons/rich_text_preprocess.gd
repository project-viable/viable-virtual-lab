extends Node


func process_custom_tag(command: String, arg: String) -> String:
	match command:
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

		# Headers.
		"h1":
			return "[font_size=28][b]%s[/b][/font_size]" % [arg]
		"h2":
			return "[font_size=18][b]%s[/b][/font_size]" % [arg]

	# We've only reached this spot if the above match didn't return (i.e, there's an error).
	return "[color=red](invalid)[/color]"
