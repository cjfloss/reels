class AppMain: Granite.Application {

	static int main(string[] args) {
	
		bool dir_specified = false;
		GLib.File dir = null;
		
		if (!(args.length < 2)) {
			dir = GLib.File.new_for_commandline_arg(args[1]);
			if (dir.query_exists())	dir_specified = true;
		}
		
		Gtk.init(ref args);
		
		var app = new AppMain();
		
		var controller = new Controller(app);
		
		controller.load_cached_movies();
		
		if (dir_specified) {
			controller.rec_load_video_files(dir);
		}
		
		controller.process_list();
		
		Gtk.main();
		
		return 0;
	
	}

}
