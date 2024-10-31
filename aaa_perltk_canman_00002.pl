use strict;
use warnings;
use Tk;
use Tk::Dialog;
use Tk::FileSelect;
use Catmandu::Importer::MARC;
use Catmandu::Exporter::MARC;
use XML::LibXML;
use Encode qw(decode encode find_encoding);

# Create main window
my $mw = MainWindow->new;
$mw->title("MARC Converter");

# Top frame with bold text
my $top_frame = $mw->Frame()->pack(-side => 'top', -fill => 'x');
$top_frame->Label(-text => "USE ONLY UTF-8", -font => ['Helvetica', 16, 'bold'])->pack;

# Frames
my $button_frame = $mw->Frame()->pack(-side => 'left', -fill => 'y');
my $display_frame = $mw->Frame()->pack(-side => 'left', -fill => 'both', -expand => 1);
my $output_frame = $mw->Frame()->pack(-side => 'left', -fill => 'both', -expand => 1);

# Text widgets for displaying file contents and output
my $file_display = $display_frame->Scrolled('Text', -width => 50, -height => 20, -wrap => 'word')->pack(-fill => 'both', -expand => 1);
my $output_display = $output_frame->Scrolled('Text', -width => 50, -height => 20, -wrap => 'word')->pack(-fill => 'both', -expand => 1);

# Buttons
$button_frame->Button(-text => "Choose file", -command => \&choose_file)->pack(-fill => 'x');
my $convert_to_aleph_btn = $button_frame->Button(-text => "Convert to Aleph Sequential", -state => 'disabled', -command => \&convert_to_aleph, -font => 'bold')->pack(-fill => 'x');
my $convert_to_xml_btn = $button_frame->Button(-text => "Convert Aleph to XML", -state => 'disabled', -command => \&convert_to_xml, -font => 'bold')->pack(-fill => 'x');
$button_frame->Button(-text => "Clear", -command => \&clear_output)->pack(-fill => 'x');
$button_frame->Button(-text => "Save output", -command => \&save_output)->pack(-fill => 'x');
$button_frame->Button(-text => "Exit", -command => sub { exit })->pack(-fill => 'x');
$button_frame->Button(-text => "Help", -command => \&show_help)->pack(-fill => 'x');

# Variables to store file paths and types
my $file_path;
my $file_type;

# Subroutines
sub choose_file {
    my $file = $mw->getOpenFile(-filetypes => [['All Files', '*'], ['Text Files', '.txt'], ['SAV Files', '.sav'], ['MARC Files', '.mrc'], ['MRK Files', '.mrk'], ['XML Files', '.xml']]);
    return unless $file;
    $file_path = $file;
    $file_type = (split(/\./, $file))[-1];
    $file_display->delete('1.0', 'end');
    my $content = read_file($file_path);
    $file_display->insert('end', $content);
    if ($file_type eq 'mrc') {
        $convert_to_aleph_btn->configure(-state => 'normal', -font => 'bold');
    } else {
        $convert_to_aleph_btn->configure(-state => 'disabled', -font => 'normal');
    }
    if ($file_type eq 'sav') {
        $convert_to_xml_btn->configure(-state => 'normal', -font => 'bold');
    } else {
        $convert_to_xml_btn->configure(-state => 'disabled', -font => 'normal');
    }
}

sub read_file {
    my ($file_path) = @_;
    open my $fh, '<:raw', $file_path or die "Cannot open file: $!";
    local $/ = undef;
    my $content = <$fh>;
    close $fh;
    my $decoded_content = decode('UTF-8', $content, Encode::FB_DEFAULT);
    if ($decoded_content =~ /�/) { # Check for replacement character indicating decoding issues
        my $enc = find_encoding('cp1255') || die "Encoding not found";
        $decoded_content = $enc->decode($content); # Assuming Hebrew files might be in Windows-1255 encoding
        $decoded_content = encode('UTF-8', $decoded_content);
    }
    return $decoded_content;
}

sub convert_to_aleph {
    $output_display->delete('1.0', 'end');
    my $importer = Catmandu::Importer::MARC->new(file => $file_path);
    my $exporter = Catmandu::Exporter::MARC->new(file => 'aleph.seq', type => 'ALEPHSEQ');
    $importer->each(sub {
        $exporter->add($_[0]);
    });
    $exporter->commit;
    my $content = read_file('aleph.seq');
    $output_display->insert('end', $content);
}

sub convert_to_xml {
    $output_display->delete('1.0', 'end');
    my $importer = Catmandu::Importer::MARC->new(file => $file_path, type => 'ALEPHSEQ');
    my $exporter = Catmandu::Exporter::MARC->new(file => 'output.xml', type => 'XML');
    $importer->each(sub {
        $exporter->add($_[0]);
    });
    $exporter->commit;
    my $xml_content = read_file('output.xml');
    my $pretty_xml = pretty_print_xml($xml_content);
    $output_display->insert('end', $pretty_xml);
}

sub pretty_print_xml {
    my ($xml_content) = @_;
    my $parser = XML::LibXML->new();
    my $doc = $parser->parse_string($xml_content);
    return $doc->toString(1); # 1 indicates pretty print with indents
}

sub clear_output {
    $file_display->delete('1.0', 'end');
    $output_display->delete('1.0', 'end');
}

sub save_output {
    my $save_path = $mw->getSaveFile();
    return unless $save_path;
    open my $fh, '>', $save_path or die "Cannot open file: $!";
    print $fh $output_display->get('1.0', 'end');
    close $fh;
}

sub show_help {
    $mw->messageBox(-message => "Help: \n1. Choose a file to display its contents.\n2. Convert to Aleph Sequential or XML if applicable.\n3. Clear or save the output.\n4. Exit the application.");
}

MainLoop;
