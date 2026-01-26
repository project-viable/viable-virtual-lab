extends Node
## Tools for preprocessing, mainly for use with [PreprocessedRichTextLabel].
##
## Use [method process_text] to preprocess special tags in the string. Tags are in the form
## [code]#{<command>:<arg>}#[/code], where [code]<command>[/code] is the tag type, and
## [code]<arg>[/code] is the argument that the tag will use.
##
## The [code]prompt[/code] command will display a button prompt image for [code]<arg>[/code], taken
## as the name of an input action. For example, [code]#{prompt:ui_accept}#[/code] will show a
## [kbd]space[/kbd] button prompt.
##
## The [code]h1[/code] and [code]h2[/code] commands will show the contents of [code]<arg>[/code] as
## headings.


const H1_SCALE := 28.0 / 16.0
const H2_SCALE := 18.0 / 16.0
const PROMPT_SCALE := 24.0 / 16.0


# Used to find custom tags.
var _regex := RegEx.create_from_string(r"#\{\s*(\w+)\s*(:(.*?))?\}#")


func process_custom_tag(command: String, arg: String, context: Context) -> String:
	match command:
		"prompt":
			var args := arg.split(",", true, 1)

			# We use a default height of 32 pixels unless custom options are provided.
			var img_opts := " height=%s" % [context.base_font_size * PROMPT_SCALE]
			if len(args) == 2:
				img_opts = args[1]
				# We want to keep the lack of space before "=" because it's required for certain
				# image options, but other options need extra space.
				if not img_opts.begins_with("="): img_opts = " " + img_opts

			var path: String = InteractPromptTextureGenerator.get_texture_for_action_prompt(args[0]).resource_path
			return "[img%s]%s[/img]" % [img_opts, path]

		# Headers.
		"h1":
			return "[font_size=%s][b]%s[/b][/font_size]" % [round(context.base_font_size * H1_SCALE), arg]
		"h2":
			return "[font_size=%s][b]%s[/b][/font_size]" % [round(context.base_font_size * H2_SCALE), arg]

	# We've only reached this spot if the above match didn't return (i.e, there's an error).
	return "[color=red](invalid)[/color]"

## Process custom tags in [param s].
func process_text(s: String, context: Context) -> String:
	var processed_text := ""

	var idx := 0
	for m in _regex.search_all(s):
		var command := m.get_string(1)
		var args := m.get_string(3)

		processed_text += s.substr(idx, m.get_start() - idx)
		processed_text += RichTextPreprocess.process_custom_tag(command, args, context)

		idx = m.get_end()
	processed_text += s.substr(idx)

	return processed_text


## Contains information about the context of the text being processed (like font size).
class Context:
	## Base normal font size of the label. Button prompts and headings are scaled relative to this.
	var base_font_size: int = 16
