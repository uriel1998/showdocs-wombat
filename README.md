# showdocs-wombat

The only cli document viewer with a wombat mascot.

![showdocs logo](https://raw.githubusercontent.com/uriel1998/showdocs-wombat/master/showdocs-wombat-open-graph.png "logo")
![mascot](https://github.com/uriel1998/showdocs-wombat/raw/master/128_senor_wombat.png "mascot")


## Contents
 1. [About](#1-about)
 2. [License](#2-license)
 3. [Prerequisites](#3-prerequisites)
 4. [Installation](#4-installation)
 5. [Usage](#6-usage)
 6. [TODO](#12-todo)

***

## 1. About

Very simply, this is a document viewer type version that plays a similar role 
as mailcap and other such utilities. It is VERY specific about focusing on 
documents (DOC,DOCX,md,CSV,sqlite,etc).  

It's currently VERY bespoke and I don't yet have all the helpers listed in the 
dependencies.  See TODO below for some things I'm working on.

Some inspiration taken from `mutt.octet.filter`.

## 2. License

This project is licensed under the MIT License. For the full license, see `LICENSE`.

## 3. Prerequisites 

This includes all of the helpers as well.

The following can be installed on Debian Buster or Bullseye (and probably Ubuntu) 
by typing 

`sudo apt update;sudo apt-get install fzf awk sed file mysql sqlite3 pandoc lynx wv unrtf pdftotext bat dtrx`

* fzf  
* awk  
* sed  
* file  
* mysql  
* sqlite3  
* pandoc  
* lynx  
* wvWare 
* unrtf  
* pdftotext  
* bat  
* dtrx 

These require a little more effort:

* [pspg](https://github.com/okbob/pspg) - You need version 3.1.4 or up, which is in [Debian Bullseye](https://packages.debian.org/source/bullseye/pspg)  
* [tabview](https://github.com/TabViewer/gtabview)  
* [epy](https://github.com/wustho/epy)  

These are *really* optional:

* wmctrl - `sudo apt install wmctrl`  
* [xseticon](https://sourceforge.net/projects/xseticon/)  
* [devour - from TDAB](https://uriel1998.github.io/tdab/)  

## 4. Installation

Clone or download the repo. If downloaded it, unarchive it into a 
directory, then make a symlink into your path.  

Examine `showdocs.sh` to determine if the "helpers" I use are the ones you wish 
to use. 

## 5. Usage


The most basic usage is to invoke 

`showdocs.sh [FILENAME]`

or 

`showdocs.sh mysql [MYSQL USERNAME] [MYSQL PASSWORD]`

for the mysql viewer.

If you invoke it under tmux and have [TDAB](https://uriel1998.github.io/tdab) 
installed, the `devour` script will automatically be invoked, creating a new 
maximized pane with your document in it.

The old way of calling this script from a GUI viewer (such as [Double Commander](https://doublecmd.sourceforge.io/)
which spawned a new window was something like: 

`xfce4-terminal --hide-menubar --geometry=80x43 -e "/home/steven/bin/showdocs %f"`

That will still work, but you can simplify (and enhance) the experience by using 
the -g switch, making the command something like this:

`/home/steven/bin/showdocs -g %f`

Not only will it launch a new xterm, but if you have `wmctrl` and `xseticon` set, 
it will decorate the window with the script's icon and name.

If you wish to colorize your output - particularly of sourcecode - you should 
use `.lessfilter`.  There's a good tutorial at [Miskatonic.org](https://www.miskatonic.org/2020/06/24/lessfilter/).

## 6. TODO

* View the files in the archive, not just the list of the files IN the archive
* Further set up database viewing for postgres
* Config for what helpers to use
* auto-check for binary defaults
* installation example for midnight commander
