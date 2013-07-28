/* The ViewManager controls and organises the different views. */

class ViewManager {

    private MovieListView list_view;
    
    Gee.ArrayList<MovieListItem> movie_list;
    
    private MovieActions movie_actions;
    
    private enum ViewType {
        LIST,
        GRID
    }
    
    private ViewType active_view;
    
    public ViewManager(Gee.ArrayList<MovieListItem> _movie_list, Gtk.Box view_container) {
    
        this.movie_list = _movie_list;
        this.list_view = new MovieListView(this.movie_list);
        this.list_view.play_movie.connect((obj, movie) => {
        	this.play_movie(movie);
        });
        
        this.item_added.connect(this.on_item_added);
        this.item_visibility_changed.connect(this.on_item_visibility_changed);
        
        view_container.pack_start(this.list_view, true, true, 0);
    
    }
    
    
    public void show_items() {
    
    	this.list_view.show_all();
    
    }
    
    
    // Contructs the new item created.
    private void on_item_added(MovieListItem movie_list_item) {
    
        this.list_view.create_item(movie_list_item.movie);
        
    }
    
    // Shows/hides the item whose visibility has changed
    private void on_item_visibility_changed(MovieListItem movie_list_item) {
    
        if (movie_list_item.visible == true) {
        	this.list_view.show_item(movie_list_item.movie);
        } else {
        	this.list_view.hide_item(movie_list_item.movie);
        }
    
    }
    
    // Swaps the current view for a DetailView
    private void on_show_detail_view() {
    
    
    
    }
    
    // Signals the views to construct their respective items.
    public signal void item_added(MovieListItem movie_list_item);
    
    // Signals the views to show/hide their respective items.
    public signal void item_visibility_changed(MovieListItem movie_list_item);
    
    // propagates the play command to the GUIController
    public signal void play_movie(Movie movie);
    
    public signal void show_detail_view(Movie movie);
    
}

delegate void movie_action_func(Movie movie);

struct MovieActions {

    public movie_action_func play_func;
    public movie_action_func info_func;

}
