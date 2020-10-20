#!/bin/bash

##############################################################################
#  showdocs-wombat 
#  (c) Steven Saus 2020
#  Licensed under the MIT license
#
##############################################################################


# There are a lot of commandline converters... but few that do just about everything.
# This aims to standardize a LOT of them.
# It's also bespoke as heck; edit to use the programs you prefer
# PDF
# Markdown
# DOC
# DOCX
# RTF
# HTML
# CSV

tmpfile=$(mktemp)
Gui=""
InTmux=""
# Referring to my devour script
DevourBinary=$(which devour)
TerminalBinary=$(which xterm)

#get installation directory
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

#This will be built by the script at runtime; do not alter!
CommandString=""

##############################################################################
# Mimetype Strings
##############################################################################
docxstring="Microsoft Word 2007+"
pystring="Python script"  # Do we want to have syntax highlighting? 
txtstring="ASCII text"
odtstring="OpenDocument Text"
docstring="Composite Document File V2 Document"  #NOTE IS SAME AS XLS
pdfstring="PDF document"
rtfstring="Rich Text Format"
utf8string="UTF-8 Unicode text"
htmlstring="HTML document"
xmlstring="XML 1.0 document"
phpstring="PHP script"
plstring="Perl script"
sqlite="SQLite 3.x database"

##############################################################################
# Displaying functions
#
# This is the bit to edit if you wish to change the viewers 
#
##############################################################################

show_archive (){
    dtrx -l "${infile}" | bat
}

show_sqlite (){
    bobarray=( $(sqlite3 "$infile" '.tables') )
    tablechoice=$(for d in "${bobarray[@]}"; do echo "$d" ; done | fzf)
    sqlite3 -csv -header "$infile" "select * from ${tablechoice}" | pspg --csv --csv-header=on --double-header
}

show_docx (){
    pandoc -f docx "$infile" | sed "s@href=\"@href=\"file://localhost$indir/@g" | sed "s@file://localhost$indir/http@http@g" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss
}

show_doc (){
    if [[ "$mimetype" == *"$docstring"* ]];then
        wvWare "$infile" | sed "s@href=\"@href=\"file://localhost$indir/@g" | sed "s@file://localhost$indir/http@http@g" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss 
    elif [[ "$mimetype" == *"$rtfstring"* ]];then
        unrtf --html "$infile" | sed "s@href=\"@href=\"file://localhost$indir/@g" | sed "s@file://localhost$indir/http@http@g" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss
    fi
}

show_odt (){
    pandoc -f odt "$infile" | sed "s@href=\"@href=\"file://localhost$indir/@g" | sed "s@file://localhost$indir/http@http@g" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss
}

show_rtf (){
    unrtf --html "$infile" | sed "s@href=\"@href=\"file://localhost$indir/@g" | sed "s@file://localhost$indir/http@http@g" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss
}

show_pdf (){
    pdftotext -layout "$infile" "$tmpfile"; bat "$tmpfile"; rm "$tmpfile"
}

show_csv (){
    tabview "$infile"
}

show_epub (){
    epy "$infile"
}

show_html (){
    lynx "$infile" -lss=/home/steven/.lynx/lynx.lss
}

show_markdown (){
    pandoc -s -f markdown -t html "$infile" | sed "s@href=\"@href=\"file://localhost$indir/@g" | sed "s@file://localhost$indir/http@http@g" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss
}

show_text (){
    bat "$infile" 
}


function xterm_setup() {
    
    if [ $(which xseticon) ] && [ -f ${SCRIPTDIR}/showdocs-wombat-xterm-icon.png ];then
        CommandString=$(printf "%s %s" "${CommandString}" 'snark=$(echo $WINDOWID);')
        CommandString=$(printf "%s %s %s" "${CommandString}" 'xseticon -id $snark ' "${SCRIPTDIR}/showdocs-wombat-xterm-icon.png;")
    if [ $(which wmctrl) ];then
        CommandString=$(printf "%s %s" "${CommandString}" 'snark=$(echo $WINDOWID);')
        CommandString=$(printf "%s %s %s" "${CommandString}" 'wmctrl -i -r $snark -T ShowDocs-Wombat;')
    if
}

##############################################################################
# Show help
##############################################################################

function show_help() {
    echo "Usage: showdoc.sh $filename"
    echo "  -h = show this help"
    echo "  -g = implies called from a GUI, launch terminal first"
    echo "  To view mysql, showdoc.sh mysql [USERNAME] [PASSWORD}"   
}


##############################################################################
# Show mysql
##############################################################################

function parse_mysql() {

    mysqldbarray=( $(mysql -u${MYSQLU} -p${MYSQLP} -B -e "SHOW DATABASES" | tail -n +2 ) )
    mysqldbchoice=$(for d in "${mysqldbarray[@]}"; do echo "$d" ; done | fzf)
    mysqltablearray=( $(mysql -u${MYSQLU} -p${MYSQLP} -B -e "SHOW tables IN ${mysqldbchoice}" | tail -n +2 ) )
    mysqltablearray+=(echo "Show keys of selected table (multiselect)")
    tablechoice=$(for d in "${mysqldbarray[@]}"; do echo "$d" ; done | fzf --multi )
    KeySelector=$(echo "${tablechoice}" | -c grep "Show keys of selected table" )
    
    if [ ${KeySelector} -eq 0 ];then
        # Show table desc
        mysql -u${MYSQLU} -p${MYSQLP} -B -e "desc ${tablechoice}" ${mysqldbchoice} | pspg --tsv --csv-header=on
    else
        # SHOW THOSE KEYS
        mysql -u${MYSQLU} -p${MYSQLP} -B -e "show keys from ${tablechoice}" ${mysqldbchoice} | pspg --tsv --csv-header=on
    fi
}

##############################################################################
# Main Function
##############################################################################
if [ "$1" == "-h" ];then
    show_help
    exit
fi    

if [ "$1" == "-g" ];then
    Gui=1
    shift
fi

c_tmux=$(env | grep -c TMUX)
if [ $c_tmux -gt 0 ];then
    InTmux=1
fi

if [ "$1" == "mysql" ];then
    MYSQLU="$2"
    MYSQLP="$3"
    if [ -z "$2" ] || [ -z "$3" ];then
        show_help
    else
        parse_mysql
        exit
    fi
fi


infile=$(realpath "$@")
indir=$(dirname "$infile")

    if [ -f "$infile" ]; then
        filename=$(basename "$infile")
        #get extension, lowercase it
        extension=$(echo "${filename##*.}" | tr '[:upper:]' '[:lower:]')
        mimetype=$(file "$filename" | awk -F ':' '{ print $2 }') 

        # Match extension first, since DOCX and XLSX give the same mimetype
        case "$extension" in
            tgz|bz2|gz|zip|arj|rar) show_archive ;;
            deb|rpm) show_archive ;;
            sqlite) show_sqlite ;;
            csv) show_csv ;;
            epub) show_epub ;;
            docx) show_docx ;;          
            odt) show_odt ;; 
            doc) show_doc ;;
            rtf) show_rtf ;;
            pdf) show_pdf ;; 
            "md" | "mkd") show_markdown ;; 
            "xhtml" | "htm" | "html" ) show_html ;;
            py) show_text ;;
            xml) show_text ;;
            pl) show_text ;;
            rc|txt|sh|conf) show_text ;;
            *)
                case "$mimetype" in
                *Word*2007* ) show_docx ;;
                *OpenDocument*Text*) show_odt ;;
                *PDF*document*) show_pdf ;;
                *Rich*Text*Format*) show_rtf ;;
                *HTML*document* ) show_html ;;
                *XML*document* ) show_text ;;
                *SQLite*database* ) show_sqlite ;;
                *tar*archive*gzip* ) show_archive ;;
                *tar*archive*      ) show_archive ;;
                *gzip*             ) show_archive ;;
                *ARJ*archive*data* ) show_archive ;;
                *zip*archive*file* ) show_archive ;;
                *                  ) show_text ;;
                esac 
            ;;
        esac
    fi	
