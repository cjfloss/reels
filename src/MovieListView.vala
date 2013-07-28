/* This is the view that shows movie items in a vertical list
 * along with descriptions and cast info.
 */
 
class MovieListView : Gtk.ScrolledWindow {

    // This hashtable is used for maintaining references to each item in the view.
    // The key is the ID of the movie, and the value is the item object.
    private GLib.HashTable<int64?, MovieListViewItem> item_list;
    
    // This is a reference to the main movie list which tells us which movies are to be shown in the views.
    private Gee.ArrayList<MovieListItem> movie_list;
    
    private Gtk.Box item_container;
    
    public MovieListView(Gee.ArrayList<MovieListItem> _movie_list) {
    
        Object(hadjustment:null, vadjustment:null);
        
        this.movie_list = _movie_list;
        
        this.item_list = new GLib.HashTable<int64?, MovieListViewItem> (GLib.int64_hash, GLib.int64_equal);
        
        this.item_container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        this.add_with_viewport(this.item_container);
        
        this.get_style_context().add_class("list-view");
    
    }

    // Constructs movie item and add it to the hash table.
    // This does NOT show the movie in the list yet.
    public void create_item(Movie movie) {
    
        var list_view_item = new MovieListViewItem(movie);
        //list_view_item.pack_end(new Gtk.Separator(Gtk.Orientation.HORIZONTAL), false, false, 0);
        this.item_list.set(movie.movie_info.id, list_view_item);
    
    }
    
    public void show_item(Movie movie) {
    
    	var item = this.item_list.get(movie.movie_info.id);
    	this.item_container.pack_start(item, false, false, 0);
    
    }
    
    public void hide_item(Movie movie) {
    
    	var item = this.item_list.get(movie.movie_info.id);
    	this.item_container.remove(item);
    
    }
    
    
    // propagates the play command to the ViewManager
    public signal void play_movie(Movie movie);
    
    // propagates the show detail view command to the ViewManager
    public signal void show_detail_view(Movie movie);
    
}
