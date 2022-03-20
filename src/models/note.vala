/* note.vala
 *
 * Copyright 2022 Benjamin Quinn
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


namespace Notes.Models {
    public class Notebook : Object {
        public string name { get; set; }
    }

    public class Note : Object {
        private unowned AppState state;

        public Notebook? notebook { get; set; }
        // Deleted at determines if a note should be in the trash.
        public DateTime? deleted_at { get; set; }
        public DateTime updated_at { get; set; default = new DateTime.now_local(); }
        public bool is_pinned { get; set; default = false; }
        public string title { get; set; default = ""; }
        public Gtk.TextBuffer body_buffer { get; set; default = new Gtk.TextBuffer(null); }
        public string body_preview { 
            owned get {
                Gtk.TextIter start;
                Gtk.TextIter end;
                body_buffer.get_start_iter(out start);
                body_buffer.get_iter_at_offset(out end, 75);
                return body_buffer.get_text(start, end, false);
            } 
        }

        public Note(AppState state) {
            this.state = state;

            this.notify["is-pinned"].connect(() => {
                state.note_moved();
            });
            this.notify["deleted-at"].connect(() => {
                state.note_moved();
            });
            this.notify["notebook"].connect(() => {
                state.note_moved();
            });
        }
        // TODO: debounce updating of preview.

        public string updated_at_formatted() {
            var now = new DateTime.now_local();
            var midnight = new DateTime(now.get_timezone(), now.get_year(), now.get_month(), now.get_day_of_month(), 0, 0, 0);

            if (updated_at.compare(midnight) > 0)
                //  return updated_at.format("%l:%M");
                return updated_at.format("%X");
            
            if (updated_at.get_year() < now.get_year())
                return updated_at.get_year().to_string();

            return updated_at.format("%b %e");
        }
    }
}
