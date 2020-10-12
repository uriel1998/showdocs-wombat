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

InTmux=""


function show_help() {

    echo "Usage: showdoc.sh $filename"
    echo "  -h = show this help"   
}

##############################################################################
# Determine what type of file we're looking at.
# Yes, you have to check both ways; sometimes RTF/DOC/DOCX misrepresent
##############################################################################
if [ "$1" == "-h" ];then
    show_help
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
                echo "HERE"
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
            rc) 
                if [[ "$mimetype" == *"$utf8string"* ]] || [[ "$mimetype" == *"$txtstring"* ]];then
                    bat "$infile" 
                fi
                ;;
            txt) 
                if [[ "$mimetype" == *"$utf8string"* ]] || [[ "$mimetype" == *"$txtstring"* ]];then
                    bat "$infile" 
                fi
                ;;
            sh) 
                if [[ "$mimetype" == *"$utf8string"* ]] || [[ "$mimetype" == *"$txtstring"* ]];then
                    bat "$infile" 
                fi
                ;;
            conf) 
                if [[ "$mimetype" == *"$utf8string"* ]] || [[ "$mimetype" == *"$txtstring"* ]];then
                    bat "$infile" 
                fi
                ;;
            *)
                bat "$infile" 
            ;;
                
        esac
    fi	

