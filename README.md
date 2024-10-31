# MARC Converter

This is a Perl Tk GUI application for converting MARC 21 files to Aleph Sequential format and vice versa. It supports displaying and converting files with Hebrew, Arabic, extended Latin scripts, and CJK characters.

## Features

- Choose a file (TXT, SAV, MRC, MRK, XML) and display its contents.
- Convert MARC 21 files to Aleph Sequential format.
- Convert Aleph Sequential files to MARC XML format.
- Clear displayed content.
- Save output to a file.
- Display help information.

## Prerequisites

Ensure you have Perl installed on your system. You can download and install Perl from Strawberry Perl for Windows.

## Installation

Install the required Perl modules using CPAN:

```sh
cpan Tk
cpan Catmandu::Importer::MARC
cpan Catmandu::Exporter::MARC
cpan XML::LibXML
cpan Encode
cpan PAR::Packer

## Usage
Run the script using Perl:

perl marc_converter.pl

## Creating a Windows Executable
To create a standalone Windows executable, use PAR::Packer:

Open your command prompt.
Navigate to the directory containing your Perl script:
cd path\to\your\script

Create the executable with the following command:
pp -o marc_converter.exe -gui -c -z 9 marc_converter.pl

Might be also - simpler:
pp -o marc_converter_001.exe -gui  aaa_perltk_canman_00001.pl
pp -o marc_converter_002.exe -gui  aaa_perltk_canman_00002.pl


