class Controller {

	// Global movie list.
   	// We assume once a movie makes it to the global movie list, everything about it is perfect.
    private Gee.ArrayList<Movie> movie_list;
    
    private GLib.File config_dir;
    
    public GUIController gui_controller;
    
    public Controller(AppMain app) {
    
        this.movie_list = new Gee.ArrayList<Movie>(null);
        
        this.config_dir = File.new_for_path(GLib.Environment.get_user_config_dir()).get_child("Reels");
        if (!config_dir.query_exists()) {
            if (!config_dir.make_directory()) {print("Could not create ~/.config/Reels/"); return;}
        }
        
        this.gui_controller = new GUIController(app, this);
        
    }
    
    // recursively load video files from directory
    public Gee.ArrayList<Movie> rec_load_video_files(GLib.File dir) {
    
        // list to hold all newly scanned 
        var new_movie_list = new Gee.ArrayList<Movie>(null);
        
        var file_enum = dir.enumerate_children("standard::*", GLib.FileQueryInfoFlags.NONE, null);
        GLib.FileInfo file_info;
        
        while ((file_info = file_enum.next_file()) != null) {
        
            var filename = file_info.get_name();
            
            if (file_info.get_content_type() == "inode/directory") { //if found dir
            
                print("Directory found ------> " + filename + "\n");
                // get list from this directory and add it to ours
                new_movie_list.add_all( rec_load_video_files( dir.get_child(filename) ) );
                
            } else {
            
                print("  " + filename + "\n");
                print("   file type : " + file_info.get_content_type() + "\n");
                
                //check file type
                if ( (file_info.get_content_type() == "video/mp4") 
                	|| (file_info.get_content_type() == "video/x-matroska") 
                	|| (file_info.get_content_type() == "video/x-msvideo") ) {
                    
                    //iterate through global movie list to check for duplicate by file name
                    var iter = this.movie_list.list_iterator();
                    var dup = false;
                    while (iter.next() == true) {
                        if (dir.get_child(filename).get_path() == iter.get().video_file.get_path()) {
                        	dup = true; 
                        	break;
                        }
                    }
                     
                    if (dup == false) {
                        new_movie_list.add(new Movie(dir.get_child(filename), null, null));
                    } else 
                    	print("FOUND DUPLICATE: " + filename + "\n");
                    
                }
                
            }
        
        }
        
        return new_movie_list;
    
    }
    
    public void load_new_movies(GLib.File dir) {
    	
    	if (!dir.query_exists()) return;
    	
    	// get list of movies under dir
    	// at this point, these Movie objects hold GLib.File's for their video files
    	var new_movie_list = this.rec_load_video_files(dir);
    	
    	var iter = new_movie_list.list_iterator();
        Movie movie;
        
        this.gui_controller.prepare_to_add(new_movie_list.size, false);
        
        while (iter.next() == true) {
        
            movie = iter.get();
            print("processing " + movie.video_file.get_basename() + "\n");
        	
            if ((movie.info_file == null) || (movie.poster_file == null)) { 
                if (!get_and_save_info(movie)) {
                	// info not found == not a movie file
                	print(movie.video_file.get_basename() + " not found in online database\n");
                	// remove this Movie from our list
                	iter.remove();
                	continue;
                } 
            }
            
            //movie.load_info();
            
            // We now have the info for the movie, including title
            // We use the title to remove any duplicates in the global movie list
		    var iter_glob = this.movie_list.list_iterator();
		    bool dupe = false;
		    Movie movie_glob;
		    while (iter_glob.next()) {
		    	movie_glob = iter_glob.get();
		    	if (movie_glob.movie_info.id == movie.movie_info.id) {
		    		iter.remove();
		    		dupe = true;
                	break;
		    	}
		    }
		    
		    if (dupe)
		    	continue;
            
            this.gui_controller.add_movie_item(movie);
            
            this.movie_list.add(movie);
		}
		
        this.gui_controller.finalise_adding();
    
    }
    
    
    private bool get_and_save_info(Movie movie) {
    
    	if (!movie.get_info_from_db())
    		return false;
        
        // Init files for caching data
        var movie_dir = this.config_dir.get_child(movie.movie_info.title);
        if (!movie_dir.query_exists()) movie_dir.make_directory();
        movie.path_file = movie_dir.get_child("path");
        movie.info_file = movie_dir.get_child("info");
        movie.poster_file = movie_dir.get_child("poster.jpg");
        
        // save info to cache
        movie.save_info();
        
        return true;
        
    }
    
    //load movies cached in the config_dir. Supposed to be run before rec_load_video_files()
    public void load_cached_movies() {
    
        // iterate through config_dir
        var dir = this.config_dir; print("config_dir = %s\n", this.config_dir.get_path());
        var file_enum = dir.enumerate_children("standard::*", GLib.FileQueryInfoFlags.NONE, null);
        FileInfo file_info;
        while ((file_info = file_enum.next_file()) != null) {
        	
        	
            if (!(file_info.get_content_type() == "inode/directory"))
            	continue;
            var movie_dir = dir.get_child(file_info.get_name()); 
            print("found in cache: %s\n", movie_dir.get_basename());
            
            //look for path file and get path from file
            GLib.File pathfile = movie_dir.get_child("path");
            if (!pathfile.query_exists()) 
            	continue; // fuck it if no path file exists
            string path;
            GLib.FileUtils.get_contents(pathfile.get_path(), out path, null);
            
            
            // look for video file expected at path
            GLib.File video_file = GLib.File.new_for_path(path);
            if (!(video_file.query_exists()))
            	continue;
            
            
            // look for info file and poster file
            GLib.File infofile;
            GLib.File posterfile = null;
            if ((infofile = movie_dir.get_child("info")).query_exists() && (posterfile = movie_dir.get_child("poster.jpg")).query_exists()) {
                // init movie object with info and poster
                this.movie_list.add(new Movie(video_file, infofile, posterfile));
            } else {
            	continue;
            	/* TODO:
            		more thorough checks for cached data
            		implement retrieving details if cache is broken
            		implement refreshing movie data once every session
            	*/
            }
        	
        }

    	// We assume once a movie makes it to the global movie list, everything about it is perfect.
    	
    	// We iterate over the global list directly, it has just been filled for thee first time
    	var iter = this.movie_list.list_iterator();
        Movie movie;
        
        // Init progress bar and make movie objects insensitive.
        // This is done because scrolling becomes very laggy when new movie items are being constructed.
        this.gui_controller.prepare_to_add(this.movie_list.size, true);
        
        while (iter.next() == true) {
        	movie = iter.get();
        	print("Processing " + movie.video_file.get_basename() + "\n");
        	movie.load_info();
            this.gui_controller.add_movie_item(movie);
		}
		
        this.gui_controller.finalise_adding();
    	
    }
    
    public signal void batch_done();

}
