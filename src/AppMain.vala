class AppMain: Granite.Application {

	//about the app
	public string program_name;
	public string[] artists;
	public string[] authors;
	public string comments;
	public string bug_link;
	
	//the queue though which directories for scanning are recieved from the GUI thread
	public GLib.AsyncQueue<AsyncMessage> async_queue;
	
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
        	print("mainloop started\n");
        	Gdk.threads_enter();
        	Gtk.main();
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
		
		print("DONE\n");
		
		// Init async queue from which dirs to scan for movies is recieved
		app.async_queue = new GLib.AsyncQueue<AsyncMessage>();
		
		// loop to check for messages from GUI thread
		while (true) {
			GLib.Thread.usleep(500000);
			var message = app.async_queue.try_pop();
			if (message != null) {
				if (message.command == "scandir") {
					GLib.File file = (GLib.File*)(message.data);
					controller.load_new_movies(file);
				} else if (message.command == "exit") {
					break;
				}
			}
		}
		
		return 0;
	
	}

}


