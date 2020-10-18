#!/bin/bash


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
# Strings correlating to mimetypes for sanity check.
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

InTmux=""


function show_help() {

    echo "Usage: showdoc.sh $filename"
    echo "  -h = show this help"   
}

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
# Determine what type of file we're looking at.
# Yes, you have to check both ways; sometimes RTF/DOC/DOCX misrepresent
##############################################################################
if [ "$1" == "-h" ];then
    show_help
    exit
fi    

if [ "$1" == "mysql" ];then
    MYSQLU="$2"
    MYSQLP="$3"
    parse_mysql
    exit
fi


infile=$(realpath "$@")
indir=$(dirname "$infile")

    if [ -f "$infile" ]; then
        filename=$(basename "$infile")
        #get extension, lowercase it
        extension=$(echo "${filename##*.}" | tr '[:upper:]' '[:lower:]')
        mimetype=$(file "$filename" | awk -F ':' '{ print $2 }') 
        case "$extension" in
            
             tgz|bz2|gz|zip|arj|rar)
                dtrx -l "${infile}" | bat
                ;;
            deb|rpm)
                dtrx -l "${infile}" | bat
                ;;
            sqlite)
                bobarray=( $(sqlite3 "$infile" '.tables') )
                tablechoice=$(for d in "${bobarray[@]}"; do echo "$d" ; done | fzf)
                sqlite3 -csv -header "$infile" "select * from ${tablechoice}" | pspg --csv --csv-header=on --double-header
                ;;
            csv)
                tabview "$infile"
                #pspg -s 11 --csv -f "$infile"
                ;;
            epub)
                epy "$infile"
                ;;
            docx)  
                if [[ "$mimetype" == *"$docxstring"* ]];then
                    pandoc -f docx "$infile" | sed "s@href=\"@href=\"file://localhost$indir/@g" | sed "s@file://localhost$indir/http@http@g" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss
                fi
                ;;                      
            odt)  
                if [[ "$mimetype" == *"$odtstring"* ]];then
                    pandoc -f odt "$infile" | sed "s@href=\"@href=\"file://localhost$indir/@g" | sed "s@file://localhost$indir/http@http@g" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss
                fi
                ;;
            doc)  
                if [[ "$mimetype" == *"$docstring"* ]];then
                    wvWare "$infile" | sed "s@href=\"@href=\"file://localhost$indir/@g" | sed "s@file://localhost$indir/http@http@g" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss 
                elif [[ "$mimetype" == *"$rtfstring"* ]];then
                    unrtf --html "$infile" | sed "s@href=\"@href=\"file://localhost$indir/@g" | sed "s@file://localhost$indir/http@http@g" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss
                fi
                ;;
            rtf)
                if [[ "$mimetype" == *"$rtfstring"* ]];then
                    unrtf --html "$infile" | sed "s@href=\"@href=\"file://localhost$indir/@g" | sed "s@file://localhost$indir/http@http@g" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss  
                fi
                ;;
            pdf) 
                if [[ "$mimetype" == *"$pdfstring"* ]];then
                    pdftotext -layout "$infile" "$tmpfile"; bat "$tmpfile"; rm "$tmpfile"
                fi
                ;;
            "md" | "mkd") 
                if [[ "$mimetype" == *"$utf8string"* ]] || [[ "$mimetype" == *"$txtstring"* ]];then
                    pandoc -s -f markdown -t html "$infile" | sed "s@href=\"@href=\"file://localhost$indir/@g" | sed "s@file://localhost$indir/http@http@g" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss
                fi
                ;;
            "xhtml" | "htm" | "html" | "xml" ) 
                if [[ "$mimetype" == *"$htmlstring"* ]];then
                    lynx "$infile" -lss=/home/steven/.lynx/lynx.lss 
                fi
                ;;
            py) 
                if [[ "$mimetype" == *"$pystring"* ]];then
                    bat "$infile" 
                fi
                ;;
            pl) 
                if [[ "$mimetype" == *"$plstring"* ]];then
                    bat "$infile" 
                fi
                ;;
            rc|txt|sh|conf) 
                if [[ "$mimetype" == *"$utf8string"* ]] || [[ "$mimetype" == *"$txtstring"* ]];then
                    bat "$infile" 
                fi
                ;;
            *)
                bat "$infile" 
            ;;
                
        esac
    fi	

