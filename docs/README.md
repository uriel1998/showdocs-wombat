# showdocs-wombat

The only cli document viewer with a wombat in a sombrero as a mascot.

![showdocs logo](https://raw.githubusercontent.com/uriel1998/showdocs-wombat/master/showdocs-wombat-open-graph.png "logo")

![mascot](https://github.com/uriel1998/showdocs-wombat/raw/master/128_senor_wombat.png "mascot")

Demo on YouTube:  

[![Demo](https://img.youtube.com/vi/06JgZT1eP0E/0.jpg)](https://www.youtube.com/watch?v=06JgZT1eP0E)

## Contents
 1. [About](#1-about)
 2. [Features](#2-features)
 2. [License](#2-license)
 3. [Prerequisites](#3-prerequisites)
 4. [Installation](#4-installation)
 5. [Usage](#6-usage)
 6. [TODO](#12-todo)

***

## 1. About

Very simply, this is a document viewer type version that plays a similar role 
as mailcap and other such utilities. Its focus is on displaying documents quickly 
in a terminal (or a popup terminal). 

Inspiration taken from `mutt.octet.filter` for how to best match mimetypes.

## 2. Features

Why should you use this instead of another mailcap type solution?

1. As written with the full helper list, it is set up to render Word (DOC & DOCX), 
Excel (XLS and XLSX), Open/LibreOffice (ODS/ODT), RTF, PDF, markdown, JSON, and HTML 
and will pretty much gladly take any text file (XML, etc) and colorize it.

2. If it runs across an undefined filetype, it can pass it on to any *other* mailcap 
style program, and is set up to use my fork of gotbletu's [URLPortal](https://github.com/uriel1998/newsbeuter-dangerzone/blob/master/urlportal.sh) by default.

3. It can call and *decorate* its own xterm window if called from a GUI file manager.

4. With [TDAB](https://uriel1998.github.io/tdab/) installed, when called in TMUX it will automatically show the document in a new zoomed pane.

5. It has a wombat in a sombrero as a mascot.

Why should you **not** use this script?

1. While there's a few "fallback" checks if helpers aren't installed, if you want 
to use different helpers to render and display things, you'll have to edit the script 
directly.  Which is an issue with *any* mailcap style solution, so...

2. You're happy with what you have. Hey, that's cool! 

## 2. License

This project is licensed under the MIT License. For the full license, see `LICENSE`.

## 3. Prerequisites 

This includes all of the helpers as well; the "core" first four are for the 
script itself and are probably already installed on your system.  Installing all 
the helpers is obviously not necessary; however, doing so will result in everything 
working out of the box.

### Apt install

The following can be installed on Debian Buster or Bullseye (and probably Ubuntu) 
by typing 

`sudo apt update;sudo apt-get install fzf awk sed file mysql sqlite3 pandoc lynx wv unrtf pdftotext bat dtrx csvtool`

* fzf  
* awk  
* sed  
* file  
* lynx  
* bat  
* mysql 
* sqlite3 
* pandoc 
* wvWare 
* unrtf 
* pdftotext 
* dtrx 
* csvtool
* gnumeric
* w3m

### Install via Apt, but check the version.

* [pspg](https://github.com/okbob/pspg) - A tish more work needs to be done with pspg - you need version 3.1.4 or up, which is in [Debian Bullseye](https://packages.debian.org/source/bullseye/pspg).  

### Via pip

These can be installed (if you have python and pip installed, naturally) by typing:

`sudo pip3 install -r requirements.txt` 

`sudo pip3 install git+https://github.com/wustho/epy`

* csvkit (provides in2csv )
* xlsx2csv
* [tabview](https://github.com/TabViewer/gtabview)  
* [epy](https://github.com/wustho/epy)  

These are *really* optional, but are nice:

* wmctrl - `sudo apt install wmctrl`  
* [xseticon](https://sourceforge.net/projects/xseticon/)  
* [devour - from TDAB](https://uriel1998.github.io/tdab/)  
* [URLPortal - from newsbeuter-dangerzone](https://github.com/uriel1998/newsbeuter-dangerzone/blob/master/urlportal.sh)

## 4. Installation

Clone or download the repo. If you downloaded it, unarchive it into a 
directory, then make a symlink into your path.  Place `lynx.lss` in `$HOME/.lynx

Examine `showdocs.sh` to determine if the "helpers" I use are the ones you wish 
to use. 

## 5. Usage

The most basic usage is to invoke 

`showdocs.sh [FILENAME]`

The program can handle *most* unescaped filenames - see the demo - but some special 
characters (such as #) must still be escaped, like so:

`showdocs.sh "[FILENAME]"`

Occasionally a different viewer is invoked - such as when the `devour` function 
is used inside `tmux`.  That is usually for aesthetic reasons (such as line wrapping).

### Viewing MySQL

To invoke the MySQL viewer, the command should be:

`showdocs.sh mysql [MYSQL USERNAME] [MYSQL PASSWORD]`

### From TMUX

If you invoke it under tmux and have [TDAB](https://uriel1998.github.io/tdab) 
installed, the `devour` script will automatically be invoked, creating a new 
maximized pane with your document in it.

### From a GUI File Manager

The old way of calling this script from a GUI viewer (such as [Double Commander](https://doublecmd.sourceforge.io/)
which spawned a new window was something like: 

`xfce4-terminal --hide-menubar --geometry=80x43 -e "/home/steven/bin/showdocs %f"`

That will still work, but you can simplify (and enhance) the experience by using 
the -g switch, making the command something like this:

`/home/steven/bin/showdocs -g %f`

Not only will it launch a new xterm, but if you have `wmctrl` and `xseticon` set, 
it will decorate the window with the script's icon and name.

### Colorizing Output

If you wish to colorize your output - particularly of sourcecode - you should 
use `.lessfilter`.  There's a good tutorial at [Miskatonic.org](https://www.miskatonic.org/2020/06/24/lessfilter/).

### Other File Types

If it cannot find a match, and you have the URLPortal script from [newsbeuter-dangerzone](https://uriel1998.github.io/newsbeuter-dangerzone/) in $PATH - 
see [this file](https://github.com/uriel1998/newsbeuter-dangerzone/blob/master/urlportal.sh) if you don't 
care about the rest of the repository - it will then hand everything off to that 
program.  In that way, it can handle a lot of other datatypes as well without 
getting too complicated.  Feel free to substitute your own "mailcap" style 
solution instead.

## 6. TODO

* View the files in the archive, not just the list of the files IN the archive
* Further set up database viewing for postgres
* installation example for midnight commander
