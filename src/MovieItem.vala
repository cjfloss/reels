class MovieItem : Gtk.Box {

	public Movie movie {get; set construct;}
	private play_func play;

	public MovieItem(Movie _movie, play_func _play) {
	
		Object(orientation : Gtk.Orientation.VERTICAL);
		
		this.movie = _movie;
		this.play = _play;
		
		// GUI elements shown in tree heirarchy
		var hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            Gtk.Image poster;
            var vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
              var hbox_title = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			    var label_title = new Gtk.Label(null);
			  var hbox_desc = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			    var label_desc = new Gtk.Label(null);
			var vbox_controls = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			  var vbox_controls_inner = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			    var play_button = new Gtk.Button();
			    var info_button = new Gtk.Button();
		
		// set up play button TODO: is there a simpler way of setting the icon?	  
		
		var pixbuf = play_button.render_icon_pixbuf(Gtk.Stock.MEDIA_PLAY, (Gtk.IconSize.INVALID) - 1);
		var play_image = new Gtk.Image.from_icon_name("media-playback-start", Gtk.IconSize.LARGE_TOOLBAR);
		play_button.set_image(play_image);
		play_button.get_style_context().add_class("control_button");
		play_button.set_focus_on_click(false);
		play_button.clicked.connect(() => {
        	this.play(movie);
        });
		
		// set up info button
		/*var iconsource = new Gtk.IconSource();
        iconsource.set_icon_name("help-info-symbolic");
        var iconset = new Gtk.IconSet();
        iconset.add_source(iconsource);
        var iconfac = new Gtk.IconFactory();
        iconfac.add("help-info-symbolic", iconset);
        iconfac.add_default();
		pixbuf = info_button.render_icon_pixbuf("help-info-symbolic", (Gtk.IconSize.INVALID) - 1);
		var info_image = new Gtk.Image.from_pixbuf(pixbuf);*/
		var info_image = new Gtk.Image.from_icon_name("help-info-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
		info_button.set_image(info_image);
		info_button.get_style_context().add_class("control_button");
		info_button.set_focus_on_click(false);
		      
        //init image
        pixbuf = new Gdk.Pixbuf.from_file_at_size(movie.poster_file.get_path(), 154	, 231);
        poster = new Gtk.Image.from_pixbuf(pixbuf);
        
        //init label
        label_title.set_markup("<span font-size=\"xx-large\" font-weight=\"bold\">" + movie.movie_info.title + "</span>");
        label_desc.set_markup("<span font-size=\"large\" font-weight=\"normal\">" + movie.movie_info.description + "</span>");
        label_desc.set_line_wrap(true); 
        label_desc.set_justify(Gtk.Justification.LEFT);
        label_desc.set_alignment(0.0f, 0.0f);
        label_desc.ellipsize = Pango.EllipsizeMode.END;
        
        vbox.set_homogeneous(false);
        hbox.set_homogeneous(false);
        hbox_desc.set_homogeneous(false);
        hbox_title.pack_start(label_title, false, false, 0);
        hbox_desc.pack_start(label_desc, true, true, 10);
        vbox_controls.set_homogeneous(false);
        vbox_controls_inner.pack_start(play_button, false, false, 5);
        vbox_controls_inner.pack_start(info_button, false, false, 5);
        vbox_controls.pack_start(vbox_controls_inner, true, false, 0);
        vbox.pack_start(hbox_title, false, false, 10);
        //vbox.pack_start(hbox_controls, false, false, 10);
        vbox.pack_start(hbox_desc, true, true, 10);
        
        hbox.set_homogeneous(false);
        hbox.pack_start(poster, false, false, 10);
        hbox.pack_start(vbox, true, true, 10);
        hbox.pack_start(vbox_controls, false, false, 10);
        //play_button.set_size_request(100, -1);
        
        this.set_homogeneous(false);
        this.pack_start(hbox, false, false, 10);
        this.pack_start(new Gtk.Separator(Gtk.Orientation.HORIZONTAL), false, false, 0);
        
        this.get_style_context().add_class("movie-item");

		
	}
	
	public delegate void play_func(Movie movie);
	
}
