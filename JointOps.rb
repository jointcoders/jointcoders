#!/usr/bin/env ruby

require 'etc'
require 'net/http'
require 'gtk2'
require 'socket'

$connected = 0

#
# As a start, we should be able to choose
# the role of client or server, so with that
# we need to specify a port to listen to or to connect
# to and we should mention somewhere in the program that
# you are or aren't connected to anyone and if you are
# then to whom, and maybe build an address book like thing
# so you can store a few users and/or locations to connect to

def server_start (listen_port=2000)
  server = TCPServer.open(listen_port)


  client = server.accept # wait for the client to connect
    $connected = 1
  client.close # disconnect from client
    $connected = 0


# Not sure how to write it yet, but need to put in a way to communicate
# back here that you are connected, $connected = 1, or disconnected, $connect = 0
# and to do something to secure the connection by some means
end

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

#
# Method to allow connecting to another machine
#
# (as of now still very broken)

def client_connect (listen_port=2000)
  connect_window = Gtk::Window.new( "Connect to Client Machine to iniatate Joint Ops" )
  connect_window.set_size_request( 400, 200 )

  # containers
  connect_vbox0 = Gtk::VBox.new( false, 5 )
  connect_hbox0 = Gtk::HBox.new( false, 0 )

  connect_vbox0.pack_start( connect_hbox0, false, false, 0 )

  connect_window.add( connect_vbox0 )
  
  connect_window.show_all
  puts "client_connect script being called"
end

# program should have a window both users can edit(main project)
# program should have chat window
# program should text box

# might want to append current file name to window title
# long variable name can be changed
currentsourcecode = 'Test.txt'

def insert_text(ent, txtvu)
  mark = txtvu.buffer.selection_bound
  iter = txtvu.buffer.get_iter_at_mark(mark)
  txtvu.buffer.insert(iter, "#{$username.capitalize}: " )
  txtvu.buffer.insert(iter, ent.text )
# return chr
  txtvu.buffer.insert(iter, 10.chr )
#   ent
  ent.text = ''
end

Gtk.init
window = Gtk::Window.new( "Joint Ops #{currentsourcecode}" )
window.set_size_request( 600, 400 )
window.signal_connect( 'destroy') {
  Gtk.main_quit
}

#
# Menu
#
file_menu = Gtk::Menu.new
  file_connect = Gtk::MenuItem.new( 'Connect' )  #{ client_connect } putting this here didn't work, don't know why
    file_connect.signal_connect "activate" do
      client_connect
      puts "connect script finished"
    end
  file_listen = Gtk::MenuItem.new( 'Listen' )
  file_open = Gtk::MenuItem.new( 'Open' )
    file_open.signal_connect "activate" do
      open_dialog
    end
  file_save = Gtk::MenuItem.new( 'Save' )
  file_exit = Gtk::MenuItem.new( 'Exit' )
  file_exit.signal_connect( 'activate' ) { Gtk.main_quit }
  file_menu.add( file_connect ).add( file_listen ).add( file_open ).add( file_save ).add( file_exit )
  
menu_file = Gtk::MenuItem.new( '_File' )
  menu_file.set_submenu( file_menu )

menu_ip = Gtk::MenuItem.new( local_ip )
  menu_ip.right_justified = true

menu_bar = Gtk::MenuBar.new
  menu_bar.add( menu_file )
  menu_bar.add( menu_ip )

#
# Open Dialog
# Dialog box will allow filtering of file
# by type, take the file chosen and load it
# into the Main Code Box.

def open_dialog

  dialog =  Gtk::FileChooserDialog.new( "Gtk::FileChooser sample", nil,
                                         Gtk::FileChooser::ACTION_OPEN,
                                         "gnome-vfs",
                                         [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT],
                                         [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL]
                                       )
  filter_all = Gtk::FileFilter.new
  filter_all.name = "*.*"
  filter_all.add_pattern("*.*")
  dialog.add_filter(filter_all)

  filter_c = Gtk::FileFilter.new
  filter_c.name = "C sources"
  filter_c.add_pattern("*.[c|h]")
  dialog.add_filter(filter_c)

  filter_rb = Gtk::FileFilter.new
  filter_rb.name = "Ruby Scripts"
  filter_rb.add_pattern("*.rb")
  filter_rb.add_pattern("*.rbw")
  dialog.add_filter(filter_rb)

  dialog.add_shortcut_folder("/tmp")

  if dialog.run == Gtk::Dialog::RESPONSE_ACCEPT
    #puts "filename = #{dialog.filename}"
    #puts "uri = #{dialog.uri}"
    file_name = dialog.filename
    file_content = IO.readlines(file_name)
    puts file_content
    #textbox.buffer.text = file_content.to_s
  end

  if dialog.run == Gtk::Dialog::RESPONSE_CANCEL
    dialog.destroy
  end

end


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
chat.cursor_visible = false
scrollch = Gtk::ScrolledWindow.new
scrollch.add( chat )

#
# Text Box for Chat Window
#
message = Gtk::Entry.new
# get message to accept keypress
window.add_events( Gdk::Event::KEY_PRESS )
message.signal_connect( 'key-press-event' ) { |w,e|
  if ( message.text =~ /[a-zA-Z0-9]+/ ) then
    if ( e.keyval == 65293 ) || ( e.keyval == 65421 ) then
      insert_text( message, chat )
    end
  else
  
  end
}

#
# Text Box send button
send = Gtk::Button.new( 'Send' )
send.signal_connect( 'clicked' ) {
  if ( message.text =~ /[a-zA-Z0-9]+/ ) then
    insert_text( message, chat )
  else
    
  end
}
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
table = Gtk::Table.new( 4, 4, true )
table.attach_defaults( scrolltb, 0, 3, 0, 4 )
table.attach_defaults( scrollch, 3, 4, 0, 4 )

hbox1.pack_start( userlbl, false, false, 0 )
hbox1.pack_start( message, true, true, 0 )
hbox1.pack_start( send, false, false, 0 )

vbox0.pack_start( menu_bar, false, false, 0 )
vbox0.pack_start( table, true, true, 0 )

vbox0.pack_start( hbox1, false, false, 0 )

window.add( vbox0 )

# show it all
window.show_all

Gtk.main
