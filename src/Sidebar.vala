namespace Reels.Sidebar {

	class Sidebar : Gtk.ScrolledWindow {

		// Categories are implemented as separate TreeView's
		// This hash table holds them
		private GLib.HashTable<string, Gtk.TreeView> view_list;
	
		private Gtk.Box container;
	
		public Sidebar() {
	
			this.view_list = new GLib.HashTable<string, Gtk.TreeView>(str_hash, str_equal);
			this.container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			this.container.set_homogeneous(false);
			this.add_with_viewport(container);
		
		}
	
		public bool add_category(string name) {
	
			if (this.view_list.lookup(name) == null) {
		
				var store = new Gtk.TreeStore(1, typeof(string));
				var view = new Gtk.TreeView.with_model(store);
			
				// set selection mode
				var selection = view.get_selection();
				selection.set_mode(Gtk.SelectionMode.SINGLE);
				selection.set_select_function((selection, model, path, currently_selected) => {
					var _path = path;
					Gtk.TreeIter iterator;
					model.get_iter(out iterator, path);
					if (store.iter_depth(iterator) == 0) {
						if (!view.is_row_expanded(_path)) {
							view.expand_row(_path, false);
						} else {
							view.collapse_row(_path);
						}
						return false;
					}
					return true;
				});
				selection.changed.connect(this.on_changed);
			
				view.set_headers_visible(false);
			
				var renderer = new Gtk.CellRendererText();
				view.insert_column_with_attributes(-1, "hahaah", renderer, "text", 0);
			
				// set category name
				Gtk.TreeIter iter;
				store.append(out iter, null);
				store.set(iter, 0, name);
			
				this.view_list.insert(name, view);
			
				this.container.pack_start(view, false, false, 0);
			
				view.get_style_context().add_class("sidebar");
			
				return true;
			
			} else
			
				return false;
	
		}
	
		public bool add_item(string category, string name) {
	
			if (this.view_list.lookup(category) != null) {
				Gtk.TreeStore store = view_list.lookup(category).get_model() as Gtk.TreeStore;
				Gtk.TreeIter category_iter;
				Gtk.TreeIter iter;
			
				store.get_iter_first(out category_iter);
				store.append(out iter, category_iter); print ("halleluyiah\n");
				store.set(iter, 0, name);
				return true;
			} else {
				print ("That's how it is\n");
				return false;
			}
	
		}
	
		private bool get_iter_for_item(string category, string item, out Gtk.TreeIter iter, out Gtk.TreeStore store) {
	
			var view = this.view_list.lookup(category);
			if (view == null)
				return false;
			store = view.get_model() as Gtk.TreeStore;
			Gtk.TreeIter iter_parent;
			string val;
		
			store.get_iter_first(out iter_parent);
			if (store.iter_children(out iter, iter_parent)) {
				store.get(iter, 0, out val);
				if (val == item)
					return true;
				while(store.iter_next(ref iter)) {
					store.get(iter, 0, out val);
					if (val == item)
						return true;
				}	
			}
		
			return false;
		
		}
	
		public bool remove_item(string category, string item) {
	
			Gtk.TreeIter iter;
			Gtk.TreeStore store;
			if (this.get_iter_for_item(category, item, out iter, out store)) {
				store.remove(iter);
				return true;
			} else
				return false;
	
		}
	
		public bool remove_category(string category) {
	
			var view = this.view_list.lookup(category);
			if (view == null)
				return false;
			this.view_list.remove(category);
			this.container.remove(view);
			return true;
	
		}
	
		public delegate void foreach_func(string item);
	
		public void @foreach_in_category(string category, foreach_func func) {
	
			var view = this.view_list.lookup(category);
			var store = view.get_model();
			Gtk.TreeIter iter_parent;
			Gtk.TreeIter iter;
			string val;
		
			store.get_iter_first(out iter_parent);
			if (store.iter_children(out iter, iter_parent)) {
				store.get(iter, 0, out val);
				func(val);
				while(store.iter_next(ref iter)) {
					store.get(iter, 0, out val);
					func(val);
				}
			}
	
		}
		
		private void on_changed(Gtk.TreeSelection selection) {
		
			var view = selection.get_tree_view();
			var store = tree_view.get_model() as Gtk.TreeStore;
			Gtk.TreeIter iter;
			string category;
			string item;
			
			store.get_iter_first(out iter);
			store.get(iter, 0, out category);
			selection.get_selected(out store; out iter);
			this.item_selected(category, item);
			
		}
		
		public signal void item_selected(out string category, out string item)
	
	}

}
