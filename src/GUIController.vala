class GUIController: Object {

	
    public GUIController(Granite.Application app, Controller controller) {
        
        this.movie_list = new Gee.ArrayList<Movie>(null);
        
        // create window and initial contents
        this.init_base_ui();
        
        //attach main window to application
        this.main_window.set_application(app);
        
        this.main_window.show_all();
        
        stdout.printf("show_all called\n");
        
    }
    
    // reference to Controller object that created this object (used for connecing to signals)
    private Controller controller; 
    
    
    // ############## GUI Items ########################################################
    
    public Gtk.Window main_window; /*{
        get {return main_window;}
        set {main_window = value;}
    }*/
    public void show_window() {
    	this.main_window.show_all();
    	return;
    }
    
    private Gtk.Toolbar toolbar; /*{
        get {return toolbar;}
        set {toolbar = value;}
    }*/
	
    
    private Granite.Widgets.AppMenu app_menu; /*{
        get {return app_menu;}
        set {app_menu = value;}
    }*/
    
    
    private Gtk.Box movie_item_container;
    
    // ##################################################################################
    
    
    // list to hold all items currently shown
    private Gee.ArrayList<Movie> movie_list;
    
    
    public void init_base_ui() {
    
        main_window = new Gtk.Window();
        main_window.set_default_size(1200, 600);
        main_window.set_title("Reels");
        
        main_window.destroy.connect(Gtk.main_quit);
        main_window.set_icon_name("totem");
        
        toolbar = new Gtk.Toolbar();
        
        var button = new Gtk.ToolButton.from_stock(Gtk.Stock.OPEN);
        toolbar.insert(button, 0);
        
        var separator = new Gtk.ToolItem();
        separator.set_expand(true);
        toolbar.insert(separator, 1);
        
        var menu = new Gtk.Menu();
        var menu_item = new Gtk.MenuItem.with_label("An Option");
        menu.append(menu_item);
        app_menu = new Granite.Widgets.AppMenu(menu);
        toolbar.insert(app_menu, -1);
        
        var vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        vbox.pack_start(toolbar, false, false, 0);
        
        //var frame = new Gtk.Frame(null);
        var scrolled = new Gtk.ScrolledWindow(null, null);
        scrolled.name = "content_area";
        this.movie_item_container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        
        //frame.add(scrolled);
        this.movie_item_container.set_homogeneous(false);
        scrolled.add_with_viewport(movie_item_container);
        
        // SourceList
        var source_list = new Granite.Widgets.SourceList();
        var source_watched = new Granite.Widgets.SourceList.Item("Watched");
        var source_unwatched = new Granite.Widgets.SourceList.Item("Unwatched");
        //var source_empty = new Granite.Widgets.SourceList.Item("");
        var source_category_genres = new Granite.Widgets.SourceList.ExpandableItem("Genres");
        var source_genres_action = new Granite.Widgets.SourceList.Item("Action");
        source_category_genres.add(source_genres_action);
        var source_list_root = source_list.root;
        source_list_root.add(source_watched);
        source_list_root.add(source_unwatched);
        //source_list_root.add(source_empty);
        source_list_root.add(source_category_genres);
        
	    var pane = new Granite.Widgets.ThinPaned();
		pane.pack1(source_list, true, false);
		pane.pack2(scrolled, true, false);
        pane.set_position(100);
        
        vbox.pack_start(pane, true, true, 0);
        
        main_window.add(vbox);
        
        // Gtk theming
        
        var css_provider = new Gtk.CssProvider();
        this.movie_item_container.name = "movie_item_container";
        css_provider.load_from_data("""
        	
        	GtkScrolledWindow#content_area * {background-color: #ffffff;}
        	GtkFrame {
        		border-style: inset; 
        		border-top-width: 1px;
        		border-bottom-width: 1px;
        		border-top-color: #909090;
        		border-bottom-color: #909090;
        		
        	}
        """, -1);
        (new Gtk.StyleContext()).add_provider_for_screen(this.main_window.get_screen(), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        
    
    }
    
    public void add_movie_item(Movie movie) {
    
        stdout.printf("adding %s to GUI\n", movie.movie_info.title);
        
        //check for duplicate
        var iter = this.movie_list.list_iterator();
        Movie movie_in_list;
        while (iter.next()) {
        	movie_in_list = iter.get();
        	if (movie_in_list.movie_info.id == movie.movie_info.id) {
        		stdout.printf("%s already in GUI\n", movie.movie_info.title);
        		return;
        	}
        }
        
        var movie_item = create_item_for_movie(movie);
        var frame = new Gtk.Frame(null);
        frame.add(movie_item);
        this.movie_item_container.pack_start(frame, false, false, 0);
        
        this.movie_list.add(movie);
		
    }
    
    public Gtk.Box create_item_for_movie(Movie movie) {
    
        var movie_item = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        //
          var hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
          //
            Gtk.Image poster;
            //
            var vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            //
              var hbox_title = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			  //  
			    var label_title = new Gtk.Label(null);
			  //
			  var hbox_controls = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
			  //
			    var play_button = new Gtk.Button.with_label("Play");
			  //
			  var hbox_desc = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			  //
			    var label_desc = new Gtk.Label(movie.movie_info.description);
		      
        //init image
        var pixbuf = new Gdk.Pixbuf.from_file_at_size(movie.poster_file.get_path(), 154	, 231);
        poster = new Gtk.Image.from_pixbuf(pixbuf);
        
        //init label
        label_title.set_markup("<span font-size=\"x-large\" font-weight=\"bold\">" + movie.movie_info.title + "</span>");
        label_desc.set_line_wrap(true); 
        label_desc.set_justify(Gtk.Justification.LEFT);
        label_desc.set_alignment(0.0f, 0.0f);
        label_desc.ellipsize = Pango.EllipsizeMode.END;
        
        // connect play method
        play_button.clicked.connect(() => {
        	this.play(movie);
        });
        
        vbox.set_homogeneous(false);
        hbox.set_homogeneous(false);
        hbox_desc.set_homogeneous(false);
        hbox_title.pack_start(label_title, false, false, 0);
        hbox_desc.pack_start(label_desc, true, true, 0);
        hbox_controls.pack_start(play_button, false, false, 0);
        vbox.pack_start(hbox_title, false, false, 10);
        vbox.pack_start(hbox_controls, false, false, 10);
        vbox.pack_start(hbox_desc, true, true, 10);
        
        hbox.set_homogeneous(false);
        hbox.pack_start(poster, false, false, 0);
        hbox.pack_start(vbox, true, true, 20);
        
        movie_item.set_homogeneous(false);
        movie_item.pack_start(hbox, false, false, 2);
        
        movie_item.get_style_context().add_class("movie-item");
        
      return movie_item;

    }
    
    void play(Movie movie) {
    	
        stdout.printf("\n MOVIE NAME: %s\n\n", movie.movie_info.title);
        	
    	string[] child_args = {"vlc", movie.video_file.get_path()};
    	
    	this.main_window.hide();
    	
    	
    	
    	stdout.printf("HIDDEN\n");
    	
    	GLib.Pid child_pid;
    	
    	GLib.Process.spawn_async(null, child_args, null, GLib.SpawnFlags.SEARCH_PATH | GLib.SpawnFlags.STDOUT_TO_DEV_NULL | GLib.SpawnFlags.STDERR_TO_DEV_NULL | GLib.SpawnFlags.DO_NOT_REAP_CHILD, null, out child_pid);
    	
    	GLib.ChildWatch.add(child_pid, (pid, status) => {
    	
    		GLib.Process.close_pid(child_pid);
    		
    		this.main_window.present();
    	
    		stdout.printf("PRESENTED\n");
    	
    	});
    
    }
    
}
