# showdocs-wombat


## Contents
 1. [About](#1-about)
 2. [License](#2-license)
 3. [Prerequisites](#3-prerequisites)
 4. [Installation](#4-installation)
 5. [Setup](#5-setup)
 6. [Usage](#6-usage)
 7. [TODO](#12-todo)

***

## 1. About

Very simply, this is a document viewer type version that plays a similar role 
as mailcap and other such utilities. It is VERY specific about focusing on 
documents (DOC,DOCX,md,CSV,etc).  

It's currently VERY bespoke and I don't yet have all the helpers listed in the 
dependencies.  See TODO below for some things I'm working on.

## 2. License

This project is licensed under the MIT License. For the full license, see `LICENSE`.

## 3. Prerequisites


## 4. Installation

Copy the script into your $PATH.  Make sure the helpers are defined.

## 5. Setup

## 6. Usage

Need to note sidebar and devour (particularly devour!) and example scripts

xfce4-terminal --hide-menubar --geometry=80x43 -e "/home/steven/bin/showdocs %f"

## 7. TODO

* Config for what helpers to use
* Detect tmux environment and use devour if possible
* auto-check for binary defaults
* use less/lessfilter/etc as a fallback, see https://www.miskatonic.org/2020/06/24/lessfilter/
