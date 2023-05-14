@tool
extends EditorPlugin


var FILESYSTEM = get_editor_interface().get_resource_filesystem()

var packages = []


func _enter_tree():
	#create cache folders
	if !DirAccess.dir_exists_absolute(".gdp_no_indexing"):
		DirAccess.make_dir_absolute(".gdp_no_indexing")
	if !DirAccess.dir_exists_absolute("gdp_vis"):
		DirAccess.make_dir_absolute("gdp_vis")
	FILESYSTEM.scan()
	#search for .gdp
	print_rich("[color=#6688ff]Crawling the filesystem for GDPackages...[/color]")
	_crawl_subdir("res://")
	#prepare the cache
	_build_cache()


func _crawl_subdir(this_dir_path):
	#display path
	var display_path = _get_display_path(this_dir_path)
	#open the dir
	var this_dir = DirAccess.open(this_dir_path)

	#check the files
	for file in this_dir.get_files():
		if file.ends_with(".gdp"):
			_package_notif(display_path, file)
			var opened_package = FileAccess.open_compressed(this_dir_path+"/"+file, FileAccess.READ)
			print(opened_package)
			packages.append(opened_package)
	#move on to the subdirs
	for dir in this_dir.get_directories():
		if not dir.begins_with(".") and dir != "gdp_vis":
			_directory_notif(display_path, dir)
			var new_path = this_dir_path+dir+"/"
			_crawl_subdir(new_path)

func _get_display_path(this_dir_path):
	var display_path = this_dir_path.right(this_dir_path.length()-6)
	if display_path.length() > 0:
		display_path = display_path.left(display_path.length()-1)
	else:
		display_path = "root"
	return display_path

func _package_notif(display_path, file):
	print_rich(" - [Package Notif] [from: " + display_path + "] [color=#66ff66]Found package: " + file.get_basename() + "[/color]")

func _directory_notif(display_path, dir):
	print_rich(" - [Dir Notif] [from: " + display_path + "] [color=#6688aa]Moving on to the next directory: " + dir + "...[/color]")

func _build_cache():
	print_rich("[color=#6688ff]Building cache...[/color]")
	for package in packages:
		print("Building cache for:", package)

func _exit_tree():
	pass
