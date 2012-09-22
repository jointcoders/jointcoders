#!/usr/bin/env ruby

require 'etc'
require 'net/http'
require 'gtk2'
require 'socket'




# Since this application is going to begin with
# a client-server relationship, I figure it would
# be useful to have the local IP made readily available
def local_ip
  orig = Socket.do_not_reverse_lookup  
  Socket.do_not_reverse_lookup =true # turn off reverse DNS resolution temporarily
  begin #make sure lack of internet connection doesn't kill the script
    UDPSocket.open do |s|
      s.connect '64.233.187.99', 1 #google
      s.addr.last
    end
    rescue Errno::ENETUNREACH #If you can't route to google, it will return this
      return "No network connection"
    ensure
      Socket.do_not_reverse_lookup = orig
  end
end

# program should have a window both users can edit(main project)
# program should have chat window
# program should text box
# might want to append current file name to window title
Gtk.init
window = Gtk::Window.new( 'Joint Ops' )
window.set_default_size( 600, 400 )
window.signal_connect( 'destroy') {
  Gtk.main_quit
}

#
# Menu
#
file_menu = Gtk::Menu.new
  file_open = Gtk::MenuItem.new( 'Open' )
  file_exit = Gtk::MenuItem.new( 'Exit' )
  file_exit.signal_connect( 'activate' ) { Gtk.main_quit }
  file_menu.add( file_open ).add( file_exit )
  
menu_file = Gtk::MenuItem.new( '_File' )
  menu_file.set_submenu( file_menu )

menu_ip = Gtk::MenuItem.new( local_ip )
  menu_ip.right_justified = true

menu_bar = Gtk::MenuBar.new
  menu_bar.add( menu_file )
  menu_bar.add( menu_ip )


#
# Main Code Box
# needs to be linked to some type of variable
# should be able to be edited by both users
# in real time
textbox = Gtk::TextView.new
textbox.wrap_mode = Gtk::TextTag::WRAP_WORD
scrolltb = Gtk::ScrolledWindow.new
scrolltb.add( textbox )

#
# Chat Window
# editable should be false
# should have it's text buffer 
# linked to the message box text buffer
# method should be in place to clear the text and send the value
# of it to both users' screens
# top section is to determine the username of the user
# and then use that as a username for the chat...
# comment the raise to allow the script to be run as root
$username = Etc.getlogin
raise 'Must not run as root' unless Process.uid != 0
chat = Gtk::TextView.new
chat.wrap_mode = Gtk::TextTag::WRAP_WORD
chat.editable = false
scrollch = Gtk::ScrolledWindow.new
scrollch.add( chat )
#
# Text Box for Chat Window
#
message = Gtk::Entry.new
#
# Text Box send button
send = Gtk::Button.new( 'Send' )
# some function to add the text in the message box
# into the textbox
userlbl = Gtk::Label.new ( $username )

# containers
vbox0 = Gtk::VBox.new( false, 5 )
hbox0 = Gtk::HBox.new( false, 0 )
hbox1 = Gtk::HBox.new( false, 0 )

# should control the size of the code and chat windows
# should make the code window 3/4 of give space
# should make the chat window 1/4 of give space
# size0 = Gtk::Alignment.new( 0, 0, 0.75, 1 )


# packing
# size0.add( hbox0 )


hbox0.pack_start( scrolltb, true, true, 0 )
hbox0.pack_start( scrollch, true, true, 0 )
hbox1.pack_start( userlbl, false, false, 0 )
hbox1.pack_start( message, true, true, 0 )
hbox1.pack_start( send, false, false, 0 )

vbox0.pack_start( menu_bar, false, false, 0 )
vbox0.pack_start( hbox0, true, true, 0 )

vbox0.pack_start( hbox1, false, false, 0 )

window.add( vbox0 )

# show it all
window.show_all

Gtk.main