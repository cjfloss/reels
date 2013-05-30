class MovieInfo {

		public int64 id;

		public string title;
		
		public string release_date;
		
		public string description;
		
		public string tagline;
		
		public string[] genres;
		
		public string poster_path;
		
		public TMDb.Actor[] cast;
		
		public TMDb.CrewMember[] crew;
		
		public bool get_director(out string director) {
		
			if (this.crew.length == 0)
				return false;
		
			for (int iii = 0; iii < this.crew.length; iii++) {
			
				if (this.crew[iii].job == "Director") {
					director = this.crew[iii].name;
					return true;
				}
			
			}
			
			return false;
		
		}
		
		public bool get_nth_cast_member(int num, out string actor) {
		
			if (this.cast.length == 0)
				return false;
		
			for (int iii = 0; iii < this.cast.length; iii++) {
			
				if (this.cast[iii].order == num) {
					actor = this.cast[iii].name;
					return true;
				}
			
			}
			
			return false;
		
		}
		
}
