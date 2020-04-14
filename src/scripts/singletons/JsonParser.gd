extends Node

var debug = false

func parse_json_file(file_name):
	var f = File.new()
	if(f.file_exists(file_name)):
		f.open(file_name,File.READ)
		var f_text = f.get_as_text()
		f.close()
		print("file: " + str(f_text))
		var f_parsed = JSON.parse(f_text)
		if f_parsed.error == OK:
			return f_parsed.results
		else:
			if debug:
				print("err: json parse failed")
			return false
