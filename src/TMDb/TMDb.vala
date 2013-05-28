namespace TMDb {

	class TMDb {
	
		// global session object for network activity
		private Soup.SessionSync session;
		private string SEARCH_URL;
		private string MOVIE_INFO_URL;
		private string API_KEY;
		private string IMAGE_BASE_URL;
		private string CAST_URL;
		private Json.Array movie_search_results;
		
		public TMDb(string api_key) {
	
			this.API_KEY = api_key;
			this.session = new Soup.SessionSync ();
			this.SEARCH_URL = "http://api.themoviedb.org/3/search/movie?api_key=%s&query=".printf(API_KEY);
			this.MOVIE_INFO_URL = "http://api.themoviedb.org/3/movie/%s?api_key=" + API_KEY;
			this.IMAGE_BASE_URL = "http://d3gtl9l2a4fn1j.cloudfront.net/t/p/";
			this.CAST_URL = "http://api.themoviedb.org/3/movie/%s/casts?api_key=" + API_KEY;
			
		}
		
		public bool search_movies(string query) {
		
			var uri = SEARCH_URL + query;
			var message = new Soup.Message ("GET", uri);
		    message.request_headers.append("Accept", "application/json");
		    session.send_message (message);
		    string reply = (string) message.response_body.flatten ().data;
		    
			// parse response data
		    var parser = new Json.Parser ();
		    parser.load_from_data (reply, -1);
		    var root_object = parser.get_root ().get_object ();
		    var results = root_object.get_array_member("results");
		    if (results.get_length() == 0)
		    	return false;
		    this.movie_search_results = results;
		    return true;
		
		}
		
		public bool get_info_for_search_result(int index, out MovieInfo movie_info) {
		
			int64 id = this.get_id_for_search_result(index);
			if (this.get_movie_info(id, out movie_info))
				return true;
			else
				return false;
		
		}
		
		public void get_info_and_json_for_search_result(int index, out MovieInfo movie_info, out string json) {
		
			int64 id = this.get_id_for_search_result(index);
			this.get_movie_info_as_json(id, out json, out movie_info);
		
		}
		
		private int64 get_id_for_search_result(int index) {
		
			var result = this.movie_search_results.get_element(0);
			int64 id = result.get_object().get_int_member("id");
			return id;
		
		}
		
		//request detailed movie info using id
		public bool get_movie_info(int64 id, out MovieInfo movie_info) {
		
			Json.Object root_object;
			
			if (!(this.query_movie_info(id, out root_object)))
				return false;
		    
		    movie_info = new MovieInfo();
		    
		    var genres = root_object.get_array_member("genres");
		    movie_info.genres = new string[genres.get_length()];
		    for (uint index = 0; index < genres.get_length(); index++) {
		    	movie_info.genres[index] = genres.get_object_element(index).get_string_member("name");
		    }
		    
		    movie_info.id = id;
		    movie_info.title = root_object.get_string_member("title");
		    movie_info.description = root_object.get_string_member("overview");
		    movie_info.tagline = root_object.get_string_member("tagline");
		    movie_info.poster_path = root_object.get_string_member("poster_path");
		    
		    print(movie_info.title);
		    
		    return true;
		   
		}
		
		// save required info to file and assign to movie object
		public bool get_movie_info_as_json(int64 id, out string json_movie_info, out MovieInfo movie_info = null) {
		
			if (!(this.get_movie_info(id, out movie_info)))
				return false;
			
			var builder = new Json.Builder();
		    builder.begin_object();
		    builder.set_member_name("id");
		    builder.add_int_value(movie_info.id);
		    builder.set_member_name("title");
		    builder.add_string_value(movie_info.title);
		    builder.set_member_name("description");
		    builder.add_string_value(movie_info.description);
		    builder.set_member_name("tagline");
		    builder.add_string_value(movie_info.tagline);
		    builder.set_member_name("genres");
		    builder.begin_array();
		    for (uint index = 0; index < movie_info.genres.length; index++) {
				builder.add_string_value(movie_info.genres[index]);
		    }
		    builder.end_array();
		    builder.end_object();
		    var gen = new Json.Generator();
		    gen.set_pretty(true);
		    gen.set_root(builder.get_root());
		    size_t size;
		    json_movie_info = gen.to_data(out size);
		    
		    return true;
		
		}
		
		private bool query_movie_info(int64 id, out Json.Object result) {
		
			var uri = this.MOVIE_INFO_URL.printf(id.to_string());
		    if (this.query(uri, out result))
		    	return true;
		    else
		    	return false;
		
		}
		
		private bool query(string uri, out Json.Object result) {
		
			var message = new Soup.Message ("GET", uri);
		    message.request_headers.append("Accept", "application/json");
		    session.send_message (message);
		    string reply = (string) message.response_body.flatten ().data;
		    
		    // TODO: check for failure
		    
		    var parser = new Json.Parser ();
		    if (!parser.load_from_data (reply, -1)) {
		    	result = null;
		    	return false;
		    }
		    var root_object = parser.get_root ().get_object ();
		    result = root_object;
		    return true;
		
		}
		
		public bool get_image(string size, string image_path, GLib.File local_file) {
		
			GLib.File remote_image_file = GLib.File.new_for_uri(this.IMAGE_BASE_URL + size + image_path);
			return remote_image_file.copy(local_file, GLib.FileCopyFlags.OVERWRITE, null, null);
		
		}
		
		public bool get_cast_and_crew(int64 movie_id, out Actor[] cast, out CrewMember[] crew) {
		
			var uri = this.CAST_URL.printf(movie_id.to_string());
			Json.Object root;
			if (!this.query(uri, out root))
				return false;
			
			var cast_json = root.get_array_member("cast");
			var crew_json = root.get_array_member("crew");
			cast = new Actor[cast_json.get_length()];
			crew = new CrewMember[crew_json.get_length()];
			Json.Object iter;
			
			for (uint index = 0; index < cast_json.get_length(); index++) {
				cast[index] = new Actor();
		    	iter = cast_json.get_object_element(index);
		    	cast[index].id = iter.get_int_member("id");
		    	cast[index].name = iter.get_string_member("name");
		    	cast[index].character = iter.get_string_member("character");
		    	cast[index].order = iter.get_int_member("order");
		    	cast[index].profile_path = iter.get_string_member("profile_path");
		    }
		    
		    for (uint index = 0; index < crew_json.get_length(); index++) {
		    	crew[index] = new CrewMember();
		    	iter = crew_json.get_object_element(index);
		    	crew[index].id = iter.get_int_member("id");
		    	crew[index].name = iter.get_string_member("name");
		    	crew[index].department = iter.get_string_member("department");
		    	crew[index].job = iter.get_string_member("job");
		    	crew[index].profile_path = iter.get_string_member("profile_path");
		    }
		    
		    return true;
		
		}
	
	}

}
