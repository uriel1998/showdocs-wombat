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

## 2. License

This project is licensed under the MIT License. For the full license, see `LICENSE`.

## 3. Prerequisites 

This includes all of the helpers as well.

* pspg (tested with version 3.1.4, the version in debian stable doesn't work with CSV natively)
* fzf
* awk
* sed
* file
* mysql
* sqlite3
* tabview
* epy 
* pandoc
* lynx
* wvWare
* unrtf
* pdftotext
* bat

## 4. Installation

Copy the script into your `$PATH`.  Make sure the helpers are defined.

## 5. Usage

Simply invoke the script as  

`showdocs.sh [FILENAME]`

or 

`showdocs.sh mysql [MYSQL USERNAME] [MYSQL PASSWORD]`

for the mysql viewer.

If you use tmux, [TDAB](https://uriel1998.github.io/tdab) may be useful.

Using a GUI viewer (such as [Double Commander](https://doublecmd.sourceforge.io/), 
you may wish to invoke it as a terminal application.  For example, my definition 
for "View" for markdown files is:

`xfce4-terminal --hide-menubar --geometry=80x43 -e "/home/steven/bin/showdocs %f"`

## 6. TODO

* Further set up database viewing for postgres
* determine by mimetype if extension not found (maybe move crap to functions?)
* Config for what helpers to use
* Detect tmux environment and use devour if possible
* auto-check for binary defaults
* use less/lessfilter/etc as a fallback, see https://www.miskatonic.org/2020/06/24/lessfilter/
* installation example for midnight commander
