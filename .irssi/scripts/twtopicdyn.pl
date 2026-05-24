#modified version of armin's dynamic width mod
use strict;
use vars qw($VERSION %IRSSI);
use Irssi;
use Irssi::Irc;
use Irssi::TextUI;

$VERSION = '1.04';
%IRSSI = (
   authors	=> 'John Engelbrecht',
   contact	=> 'jengelbr@yahoo.com',
   name	        => 'twtopic.pl',
   description	=> 'Animated Topic bar (dynamic width).',
   sbitems      => 'twtopic',
   license	=> 'Public Domain',
   changed	=> '2018-09-08',
   url		=> 'http://irssi.darktalker.net'."\n",
);

my $instrut = 
  ".--------------------------------------------------.\n".
  "| 1.) shell> mkdir ~/.irssi/scripts                |\n".
  "| 2.) shell> cp twtopic.pl ~/.irssi/scripts/       |\n".
  "| 3.) shell> mkdir ~/.irssi/scripts/autorun        |\n".
  "| 4.) shell> ln -s ~/.irssi/scripts/twtopic.pl \\   |\n".
  "|            ~/.irssi/scripts/autorun/twtopic.pl   |\n".
  "| 5.) /sbar topic remove topic                     |\n".
  "| 6.) /sbar topic remove topic_empty               |\n".
  "| 7.) /sbar topic add -after topicbarstart         |\n".
  "|        -priority 100 -alignment left twtopic     |\n".
  "| 9.) /toggle twtopic_instruct and last /save      |\n".
  "|--------------------------------------------------|\n".
  "|  Options:                               Default: |\n".
  "|  /set twtopic_refresh <speed>              150   |\n".
  "|  /toggle twtopic_instruct |Startup instructions  |\n".
  "\`--------------------------------------------------'";

my $timeout=0;
my $start_pos=0;
my $flipflop=0;
my $size;
my $topic;
my @mirc_color_arr = ("\0031","\0035","\0033","\0037","\0032","\0036","\00310","\0030","\00314","\0034","\0039","\0038","\00312","\00313","\00311","\00315","\017");

# Setup timer
sub setup {
   my $time = Irssi::settings_get_int('twtopic_refresh');
   Irssi::timeout_remove($timeout) if ($timeout != 0);

   if ($time < 10) {
      print "Warning: 'twtopic_refresh' must be >= 10";
      $time=150;
      Irssi::settings_set_int('twtopic_refresh',$time);
   }
   $timeout = Irssi::timeout_add($time, 'reload' , undef);
}

# Status bar show handler
sub show {
   my ($item, $get_size_only) = @_;
   $topic = get_topic($item);
   $topic = " $topic%n";
   $item->default_handler($get_size_only,$topic, undef, 1);
}

sub get_topic {
    my $win = Irssi::active_win();
    # get the width of the full active window, not $item->{window}
    $size = Irssi::active_win()->{width} - 3;
    my $active = $win->{active};
    unless($active) {
	    $start_pos=$size/2+11;
	    $topic="(status)";
    }

    # handle QUERY windows
    if ($active->{type} eq "QUERY") {
        $topic="You are now talking to ..... ".$active->{name};
	$start_pos=$size/2+21;
    }

    # handle CHANNEL windows
    if ($active->{type} eq "CHANNEL") {
        # use active server
        my $server = Irssi::active_server();
	unless($server){
		$topic="[no server]";
		$start_pos=$size/2+10;
	}

        my $chan = $server->channel_find($active->{name});
        $topic = $chan ? $chan->{topic} : "";

        # remove mIRC color codes
        $topic =~ s/(\003\d{1,2}|\002|\001)//g;
	scrolltopic($start_pos,$size,$topic);
    }
    showtopic($start_pos,$size,$topic);
}

sub showtopic {
    $topic = "[-=-=-=-=-=-=-= No Topic =-=-=-=-=-=-=-]" if $topic eq "";
    my $extra_str = " " x ($size * 2);   # extra padding for scrolling
    $topic=substr($extra_str, 0, $size) . $topic . $extra_str;

    $topic = substr($topic, $start_pos, $size);
    return $topic;
}

sub scrolltopic {
    my @str_arr = split //, $topic;
    my $total = $#str_arr;
    if ($start_pos > $total + $size) { $start_pos = 0; }

   if (!$flipflop) { $flipflop = 1; return $topic; }
    $start_pos++;
    $flipflop = 0;
}

# Redraw status bar
sub reload { Irssi::statusbar_items_redraw('twtopic'); }

# Register status bar item
Irssi::statusbar_item_register('twtopic', '$0', 'show');
Irssi::signal_add('setup changed', 'setup');
Irssi::settings_add_int('tech_addon', 'twtopic_refresh', 150);
Irssi::settings_add_bool('tech_addon', 'twtopic_instruct', 1);

setup();

if(Irssi::settings_get_bool('twtopic_instruct')) {
   print $instrut;
}
