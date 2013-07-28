class ReviewList: Gtk.Box {

	private Movie movie;
	private Gtk.Box v_container;
	private Gtk.Box h_container;
	private Gtk.ScrolledWindow scrolled;
	private Gtk.Box review_container;
	
	private bool filled;

	public ReviewList(Movie _movie) {
	
		Object(orientation: Gtk.Orientation.VERTICAL);
	
		this.movie = _movie;
		
		this.v_container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.h_container = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		this.scrolled = new Gtk.ScrolledWindow(null, null);
		this.scrolled.name = "review_scrolled";
		this.review_container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		
		this.pack_start(this.v_container, true, true, 0);
		  this.v_container.pack_start(this.scrolled, true, true, 10);
		    this.scrolled.add_with_viewport(h_container);
		      this.h_container.pack_start(this.review_container, true, true, 30);
		      
		this.filled = false;
		
	
	}
	
	public void fill() {
	
		
		if (this.filled)
			return;
			
		this.filled = true;
		
		if (!this.movie.get_reviews_from_db()) {
			this.say_no();
			return;
		}
	
		for (int index = 0; index < this.movie.movie_info.reviews.length; index++)	{
			
			string author = this.movie.movie_info.reviews[index].author;
			string content = this.movie.movie_info.reviews[index].content;
			
			var label = new Gtk.Label(null);
			label.set_markup(
				"""<span font-size="xx-large" font-weight="bold">" </span>""" + content + """<span font-size="xx-large" font-weight="bold"> "</span>"""
			);
			label.set_line_wrap(true);
			
			this.review_container.pack_start(label, false, false, 20);
			
			this.show_all();
			
		}
		
		return;
	
	}
	
	private void say_no() {
	
		var label = new Gtk.Label(null);
		label.set_markup(
			"""<span font-size="large" font-weight="bold">There are no reviews for this movie :(</span>"""
		);
		
		this.review_container.pack_start(label, true, true, 0);
		
		this.show_all();
		
		return;
	
	}

}
