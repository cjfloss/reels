class DetailView : Gtk.Box {

	private Movie movie;
	private MovieItem.play_func play;
	private MovieItem.info_func info;
	private back_func back_cb;
	private ReviewList reviews_container;
	private Gtk.Box cast_container;
	
	public Granite.Widgets.StaticNotebook static_notebook;

	public DetailView(Movie _movie, MovieItem.play_func _play, MovieItem.info_func _info, back_func _back_cb) {
	
		Object(orientation: Gtk.Orientation.VERTICAL);
	
		this.movie = _movie;
		this.play = _play;
		this.info = _info;
		this.back_cb = _back_cb;
		
		var vbox_container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		
		var movie_item = new MovieItem(movie, this.play, this.info);
		
		// Set up back button
		var button_back = new Gtk.Button();
		var back_icon = new Gtk.Image.from_icon_name("go-previous-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
		button_back.set_image(back_icon);
		button_back.get_style_context().add_class("control_button");
		button_back.clicked.connect(() => {
			this.back_cb();
		});
		
		// Exchange info button for back button
		movie_item.control_box.remove(movie_item.info_button);
		movie_item.control_box.pack_start(button_back, false, false, 5);
		
		// Set up static notebook
		this.static_notebook = new Granite.Widgets.StaticNotebook(true);
		this.reviews_container = new ReviewList(this.movie);
		this.cast_container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.static_notebook.append_page(this.cast_container, new Gtk.Label("Cast"));
		this.static_notebook.append_page(this.reviews_container, new Gtk.Label("Reviews"));
		this.static_notebook.name = "static";
		
		// Exchange separator for static notebook
		movie_item.remove(movie_item.separator);
		
		vbox_container.pack_start(movie_item, false, false, 0);
		vbox_container.pack_start(this.static_notebook, true, true, 0);
		
		var event_box = new Gtk.EventBox();
		event_box.name = "detail_view_container";
		event_box.add(vbox_container);
		
		this.pack_start(event_box, true, true, 0);
		
		this.static_notebook.page_changed.connect((widget, page_num) => {
			
			if (page_num == 1) {
				this.reviews_container.fill();
			}	
			
		});
		
	}
	
	public delegate void back_func ();
	
	

}
