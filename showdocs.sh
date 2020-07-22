#!/bin/bash


# There are a lot of commandline converters... but few that do just about everything.
# This aims to standardize a LOT of them.
# Displayable/convertable files:
# PDF
# Markdown
# DOC
# DOCX
# RTF
# HTML

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

    if [ -f "$infile" ]; then
        filename=$(basename "$infile")
        #get extension, lowercase it
        extension=$(echo "${filename##*.}" | tr '[:upper:]' '[:lower:]')
        mimetype=$(file "$filename" | awk -F ':' '{ print $2 }') 
        case "$extension" in
            docx)  
                if [[ "$mimetype" == *"$docxstring"* ]];then
                    pandoc -f docx "$infile" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss
                fi
                ;;
                      
            odt)  
                if [[ "$mimetype" == *"$odtstring"* ]];then
                    pandoc -f odt "$infile" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss
                fi
                ;;

            doc)  
                if [[ "$mimetype" == *"$docstring"* ]];then
                    wvWare "$infile" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss 
                elif [[ "$mimetype" == *"$rtfstring"* ]];then
                    unrtf --html "$tmpfile" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss
                fi
                ;;
            rtf)
                if [[ "$mimetype" == *"$rtfstring"* ]];then
                    unrtf --html "$tmpfile" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss  
                fi
                ;;
            pdf) 
                if [[ "$mimetype" == *"$pdfstring"* ]];then
                    pdftotext -layout "$infile" "$tmpfile"; bat "$tmpfile"; rm "$tmpfile"
                fi
                ;;
            "md" | "mkd") 
                if [[ "$mimetype" == *"$utf8string"* ]] || [[ "$mimetype" == *"$txtstring"* ]];then
                    pandoc -s -f markdown -t html "$infile" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss
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
            ;;
                
        esac
    fi	

