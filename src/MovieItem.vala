class MovieItem : Gtk.Box {

	public Movie movie {get; set construct;}
	public string title {get; set construct;}
	private play_func play;

	public MovieItem(Movie _movie, play_func _play) {
	
		Object(orientation : Gtk.Orientation.VERTICAL);
		
		this.movie = _movie;
		this.title = movie.movie_info.title;
		this.play = _play;
		
		// GUI elements shown in tree heirarchy
		var hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            Gtk.Image poster;
            var vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
              var hbox_title = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			    var label_title = new Gtk.Label(null);
			  var hbox_controls = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
			    var play_button = new Gtk.Button.with_label("Play");
			  var hbox_desc = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
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
        hbox.pack_start(poster, false, false, 5);
        hbox.pack_start(vbox, true, true, 20);
        
        this.set_homogeneous(false);
        this.pack_start(hbox, false, false, 5);
        this.pack_start(new Gtk.Separator(Gtk.Orientation.HORIZONTAL), false, false, 0);
        
        this.get_style_context().add_class("movie-item");

		
	}
	
	public delegate void play_func(Movie movie);
	
}
