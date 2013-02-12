class AppMain: Granite.Application {

	static int main(string[] args) {
	
		bool dir_specified = false;
		GLib.File dir = null;
		
		if (!(args.length < 2)) {
			dir = GLib.File.new_for_commandline_arg(args[1]);
			if (dir.query_exists())	dir_specified = true;
		}
		
		Gdk.threads_init();
		
		Gtk.init(ref args);
		
		var app = new AppMain();
		
		var controller = new Controller(app);
		
		controller.load_cached_movies();
		
		controller.process_list();
		
        controller.gui_controller.main_window.show_all();
		
		var mainloop_thread = new Thread<bool>("MainThread", () => {
        	Gdk.threads_enter();
        	Gtk.main();
        	Gdk.threads_leave();
        	return true;} );
        	
        stdout.printf("mainloop started\n");
        
		
		if (dir_specified) {
			controller.rec_load_video_files(dir);
			controller.process_list();
			Gdk.threads_enter();
		    controller.gui_controller.main_window.show_all();
		    Gdk.threads_leave();
		}
		
		mainloop_thread.join();
		
		return 0;
	
	}

}
