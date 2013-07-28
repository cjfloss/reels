/* This class represents items in the main list that holds info about
 * which movies are visible after applying filters and other such info.
 * This list is used by the different views to update themselves.
 */
 
class MovieListItem {
 
    public Movie movie;
    
    // Whether the currently applied filters allow this movie to be shown or not
    public bool visible;
    
    public MovieListItem(Movie _movie) {
    
        this.movie = _movie;
        this.visible = false;
    
    }
 
}
