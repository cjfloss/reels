class Movie {

    // name user for searching for movie info
    public string search_title;
    
    // year used for searching for movie info
    public string search_year;
    
    // video file of movie
    public GLib.File video_file;
    
    /* class holding the actual movie info
       setting this will stop the controller from trying to retrieve info about this movie */
    public MovieInfo movie_info;
    
    // image file used as poster for movie
    public GLib.File poster_file;
    
    // local file holding cached movie info
    public GLib.File info_file;
    
    public Movie(GLib.File video_file, GLib.File? info_file = null, GLib.File? poster_file = null) {
    
        this.video_file = video_file;
        if ((info_file != null) && (info_file.query_exists())) this.info_file = info_file;
        if ((poster_file != null) && (poster_file.query_exists())) this.poster_file = poster_file;
        this.movie_info = new MovieInfo();
    
    }
    
    
    // use filename to get the title and year of the movie
    public bool infer_title_and_year() {
    
        string str = this.video_file.get_basename().delimit(".", ' ');
        
        var regex = new GLib.Regex("""\b([A-Za-z0-9 ]+?)\b[() .\[\]]*((?:19|20)\d\d)""", GLib.RegexCompileFlags.CASELESS, 0);
        
        var regex2 = new GLib.Regex("""\b([A-Za-z0-9 ]+?)\b[() .\[\]]*(dvdrip|brrip|bdrip|scr|dvdscr|bluray|blu-ray|blu-ray rip|screenrip|unrated|xvid|x264|720p|480p|1080p)""", GLib.RegexCompileFlags.CASELESS, 0);
        
        var regex_sample = new GLib.Regex("""sample""", GLib.RegexCompileFlags.CASELESS, 0);
        
        GLib.MatchInfo match_info;
        
        if (regex_sample.match(str, 0, out match_info)) {
        	stdout.printf("Found sample file");
        	return false;
        } else if (regex.match(str, 0, out match_info)) {
            this.search_title = match_info.fetch(1);
            this.search_year = match_info.fetch(2);
            return true;
        } else if (regex2.match(str, 0, out match_info)) {
            this.search_title = match_info.fetch(1);
            //this.search_year = match_info.fetch(2);
            return true;
        } else {
            stdout.printf("Couldn't infer title or year from filename for " + this.video_file.get_basename() + "\n");
            return false;
        }
        
    }
    
    // load movie info from file specified by info_file
    public void load_info() {
    
    	print("----loading info\n");
        var parser = new Json.Parser();
        parser.load_from_file(this.info_file.get_path());
        var root =  parser.get_root().get_object();
        this.movie_info.id = root.get_int_member("id");
        this.movie_info.title = root.get_string_member("title");
        this.movie_info.description = root.get_string_member("description");
        this.movie_info.tagline = root.get_string_member("tagline");
        
        var genres = root.get_array_member("genres");
        this.movie_info.genres = new string[genres.get_length()];
        for (uint iii = 0; iii < genres.get_length(); iii++) {
        	this.movie_info.genres[iii] = genres.get_element(iii).get_string();
        }
        return;
    
    }
    
    public bool save_info() {
    
    	var builder = new Json.Builder();
	    builder.begin_object();
	    builder.set_member_name("id");
	    builder.add_int_value(this.movie_info.id);
	    builder.set_member_name("title");
	    builder.add_string_value(this.movie_info.title);
	    builder.set_member_name("description");
	    builder.add_string_value(this.movie_info.description);
	    builder.set_member_name("tagline");
	    builder.add_string_value(this.movie_info.tagline);
	    builder.set_member_name("genres");
	    builder.begin_array();
	    for (uint index = 0; index < this.movie_info.genres.length; index++) {
			builder.add_string_value(movie_info.genres[index]);
	    }
	    builder.end_array();
	    builder.set_member_name("cast");
	    builder.begin_array();
	    for (uint index = 0; index < this.movie_info.cast.length; index++) {
			builder.begin_object();
			builder.set_member_name("id");
			builder.add_int_value(this.movie_info.cast[index].id);
			builder.set_member_name("name");
			builder.add_string_value(this.movie_info.cast[index].name);
			builder.set_member_name("character");
			builder.add_string_value(this.movie_info.cast[index].character);
			builder.set_member_name("order");
			builder.add_int_value(this.movie_info.cast[index].order);
			builder.set_member_name("profile_path");
			builder.add_string_value(this.movie_info.cast[index].profile_path);
			builder.end_object();
	    }
	    builder.end_array();
	    builder.set_member_name("crew");
	    builder.begin_array();
	    for (uint index = 0; index < this.movie_info.crew.length; index++) {
			builder.begin_object();
			builder.set_member_name("id");
			builder.add_int_value(this.movie_info.crew[index].id);
			builder.set_member_name("name");
			builder.add_string_value(this.movie_info.crew[index].name);
			builder.set_member_name("department");
			builder.add_string_value(this.movie_info.crew[index].department);
			builder.set_member_name("job");
			builder.add_string_value(this.movie_info.crew[index].job);
			builder.set_member_name("profile_path");
			builder.add_string_value(this.movie_info.crew[index].profile_path);
			builder.end_object();
	    }
	    builder.end_array();
	    builder.end_object();
	    var gen = new Json.Generator();
	    gen.set_pretty(true);
	    gen.set_root(builder.get_root());
	    if (gen.to_file(this.info_file.get_path()))
	    	return true;
	    else
	    	return false;
    
    }

}
