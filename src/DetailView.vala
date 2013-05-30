class DetailView : Gtk.Box {

	private Movie movie;
	private MovieItem.play_func play;
	private MovieItem.info_func info;
	private back_func back_cb;

	public DetailView(Movie _movie, MovieItem.play_func _play, MovieItem.info_func _info, back_func _back_cb) {
	
		Object(orientation: Gtk.Orientation.VERTICAL);
	
		
		this.movie = _movie;
		this.play = _play;
		this.info = _info;
		this.back_cb = _back_cb;
		
		/*
		var vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		  var hbox_main_info = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		    Gtk.Image image_poster;
		    var vbox_text = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		      var hbox_director = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		        var label_director = new Gtk.Label(null);
		      var hbox_title = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		  	    var label_title = new Gtk.Label(null);
		  	  var scrolled_desc = new Gtk.ScrolledWindow(null, null);
		  	    var label_desc = new Gtk.Label(null);
		  	var vbox_controls = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		  	  var button_back = new Gtk.Button();
		  	  var button_play = new Gtk.Button();
		  var static_notebook = new Granite.Widgets.StaticNotebook(true);
	
		var pixbuf = new Gdk.Pixbuf.from_file_at_size(movie.poster_file.get_path(), 154	, 231);
		image_poster = new Gtk.Image.from_pixbuf(pixbuf);
		
		label_title.set_markup("<span font-size=\"xx-large\" font-weight=\"bold\">" + this.movie.movie_info.title + "</span>");
		
		string director;
		if (this.movie.movie_info.get_director(out director)) {
			label_director.set_markup("<span font-size=\"medium\" font-weight=\"normal\" color=\"black\"> Directed by " + director + "</span>");
			print(director);
		}
		
		label_desc.set_markup("<span font-size=\"large\" font-weight=\"normal\">" + this.movie.movie_info.description + "</span>");
		label_desc.set_line_wrap(true);
		label_desc.set_justify(Gtk.Justification.LEFT);
        label_desc.set_alignment(0.0f, 0.0f);
		
		var back_icon = new Gtk.Image.from_icon_name("go-previous-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
		button_back.set_image(back_icon);
		button_back.clicked.connect(() => {
			this.back_cb();
		});
		
		var play_icon = new Gtk.Image.from_icon_name("media-playback-start-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
		button_play.set_image(play_icon);
		
		vbox.pack_start(hbox_main_info, false, false, 10);
		  hbox_main_info.pack_start(image_poster, false, false, 10);
		  hbox_main_info.pack_start(vbox_text, true, true, 10);
		    vbox_text.pack_start(hbox_title, false, false, 5);
		      hbox_title.pack_start(label_title, false, false, 5);
		    vbox_text.pack_start(hbox_director, false, false, 5);
		      hbox_director.pack_start(label_director, false, false, 10);
		    vbox_text.pack_start(scrolled_desc, true, true, 20);
		      scrolled_desc.add_with_viewport(label_desc);
		  hbox_main_info.pack_start(vbox_controls, false, false, 10);
		    vbox_controls.pack_start(button_back, false, false, 5);
		    vbox_controls.pack_start(button_play, false, false, 5);
		vbox.pack_start(static_notebook, true, true, 0);
		
		this.pack_start(vbox, true, true, 0);
		
		this.get_style_context().add_class("detail_view");
		*/
		
		var movie_item = new MovieItem(movie, this.play, this.info);
		
		var button_back = new Gtk.Button();
		
		var back_icon = new Gtk.Image.from_icon_name("go-previous-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
		button_back.set_image(back_icon);
		button_back.clicked.connect(() => {
			this.back_cb();
		});
		
		movie_item.control_box.remove(movie_item.info_button);
		
		movie_item.control_box.pack_start(button_back, false, false, 5);
		
		this.pack_start(movie_item, false, false, 0);
		
		
	
	}
	
	public delegate void back_func ();
	
	

}
