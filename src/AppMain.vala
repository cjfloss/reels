class AppMain: Granite.Application {

	//about the app
	public string program_name;
	public string[] artists;
	public string[] authors;
	public string comments;
	public string bug_link;
	
	//the queue though which directories for scanning are recieved from the GUI thread
	public GLib.AsyncQueue<GLib.File> async_queue;
	
	AppMain() {
		this.program_name = "Reels";
		this.authors = {"Nishant George Agrwal"};
		this.comments = "A clean and simple application meant for browsing and watching local movie collections.";
		this.bug_link = "https://bugs.launchpad.net/reels";
	}
	
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
		
		controller.gui_controller.main_window.show_all();
				
		var mainloop_thread = new Thread<bool>("MainThread", () => {
        	Gdk.threads_enter();
        	Gtk.main();
	        stdout.printf("mainloop started\n");
        	Gdk.threads_leave();
        	return true;
        } );
        
		controller.load_cached_movies();
		
		/*
		if (dir_specified) {
			controller.rec_load_video_files(dir);
			controller.process_list();
			Gdk.threads_enter();
		    controller.gui_controller.main_window.show_all();
		    Gdk.threads_leave();
		}
		*/
		if (dir_specified) {
			controller.load_new_movies(dir);
		}
		
		// Init async queue from which dirs to scan for movies is recieved
		app.async_queue = new GLib.AsyncQueue<GLib.File>();
		
		// loop to check for messages from GUI thread
		while (controller.gui_controller.main_window != null) {
			GLib.File file = app.async_queue.try_pop();
			if (file != null) controller.load_new_movies(file);
		}
		
		if (mainloop_thread != null) mainloop_thread.join();
		
		return 0;
	
	}

}
