use strict;
use warnings;
use Tk;
use Tk::Dialog;
use Tk::FileSelect;
use Catmandu::Importer::MARC;
use Catmandu::Exporter::MARC;

# Create main window
my $mw = MainWindow->new;
$mw->title("MARC Converter");

# Frames
my $button_frame = $mw->Frame()->pack(-side => 'left', -fill => 'y');
my $display_frame = $mw->Frame()->pack(-side => 'right', -fill => 'both', -expand => 1);
my $output_frame = $mw->Frame()->pack(-side => 'right', -fill => 'both', -expand => 1);

# Text widgets for displaying file contents and output
my $file_display = $display_frame->Scrolled('Text', -width => 50, -height => 20)->pack(-fill => 'both', -expand => 1);
my $output_display = $output_frame->Scrolled('Text', -width => 50, -height => 20)->pack(-fill => 'both', -expand => 1);

# Buttons
$button_frame->Button(-text => "Choose file", -command => \&choose_file)->pack(-fill => 'x');
my $convert_to_aleph_btn = $button_frame->Button(-text => "Convert to Aleph Sequential", -state => 'disabled', -command => \&convert_to_aleph)->pack(-fill => 'x');
my $convert_to_xml_btn = $button_frame->Button(-text => "Convert Aleph to XML", -state => 'disabled', -command => \&convert_to_xml)->pack(-fill => 'x');
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
    $file_display->insert('end', read_file($file_path));
    if ($file_type eq 'mrc') {
        $convert_to_aleph_btn->configure(-state => 'normal');
    } else {
        $convert_to_aleph_btn->configure(-state => 'disabled');
    }
    if ($file_type eq 'sav') {
        $convert_to_xml_btn->configure(-state => 'normal');
    } else {
        $convert_to_xml_btn->configure(-state => 'disabled');
    }
}

sub read_file {
    my ($file_path) = @_;
    open my $fh, '<', $file_path or die "Cannot open file: $!";
    local $/ = undef;
    my $content = <$fh>;
    close $fh;
    return $content;
}

sub convert_to_aleph {
    $output_display->delete('1.0', 'end');
    my $importer = Catmandu::Importer::MARC->new(file => $file_path);
    my $exporter = Catmandu::Exporter::MARC->new(file => 'aleph.seq', type => 'ALEPHSEQ');
    $importer->each(sub {
        $exporter->add($_[0]);
    });
    $exporter->commit;
    $output_display->insert('end', read_file('aleph.seq'));
}

sub convert_to_xml {
    $output_display->delete('1.0', 'end');
    my $importer = Catmandu::Importer::MARC->new(file => $file_path, type => 'ALEPHSEQ');
    my $exporter = Catmandu::Exporter::MARC->new(file => 'output.xml', type => 'XML');
    $importer->each(sub {
        $exporter->add($_[0]);
    });
    $exporter->commit;
    $output_display->insert('end', read_file('output.xml'));
}

sub clear_output {
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
