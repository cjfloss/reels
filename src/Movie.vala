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
        return;
    
    }

}
