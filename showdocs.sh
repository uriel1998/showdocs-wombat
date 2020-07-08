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
#configfile needs put in here
Action=""


function read_variables() {

    if [ -f "$ConfigFile" ];then
        bob=$(cat "$ConfigFile") 
    fi
    # If there's no config file or a line is malformed or missing, sub in the default value
    #if [[ `echo "$bob" | grep -c -e "^musicdir="` > 0 ]];then MPDBASE=$(echo "$bob" | grep -e "^musicdir=" | cut -d = -f 2- );else MPDBASE="$HOME/Music";fi
    #if [[ `echo "$bob" | grep -c -e "^mpdserver="` > 0 ]];then MPD_HOST=$(echo "$bob" | grep -e "^mpdserver=" | cut -d = -f 2- );else MPD_HOST="localhost";fi    
    #if [[ `echo "$bob" | grep -c -e "^mpdport="` > 0 ]];then MPD_PORT=$(echo "$bob" | grep -e "^mpdport=" | cut -d = -f 2- );else MPD_PORT="6600";fi
    #if [[ `echo "$bob" | grep -c -e "^mpdpass="` > 0 ]];then MPD_PASS=$(echo "$bob" | grep -e "^mpdpass=" | cut -d = -f 2- );else MPD_PASS="";fi
    #if [[ `echo "$bob" | grep -c -e "^queuesize="` > 0 ]];then PLAYLIST_TRIGGER=$(echo "$bob" | grep -e "^queuesize=" | cut -d = -f 2- );else PLAYLIST_TRIGGER="10";fi
    #if [[ `echo "$bob" | grep -c -e "^hours="` > 0 ]];then SONGAGE=$(echo "$bob" | grep -e "^hours=" | cut -d = -f 2- );else SONGAGE="8";fi

    #pull in the utilities to be used here, and args, also maybe whether terminal or not later on.

}

function show_help() {

    echo "Usage: showdoc.sh [-e | -v] filename"
	echo " 	-e = edit file"
    echo "	-v = view file"
    echo "  -h = show this help"   
}


##############################################################################
# Determine what type of file we're looking at.
# Yes, you have to check both ways; sometimes RTF/DOC/DOCX misrepresent
##############################################################################


function determine_file_type () {
    

    if [ -f "$infile" ]; then
        filename=$(basename "$infile")
        #get extension, lowercase it
        extension=echo "${filename##*.}" | tr '[:upper:]' '[:lower:]'
        case extension in
            docx)
            odt)
            doc)
            rtf)
            pdf)
            "md" | "mkd")
            "xhtml" | "htm" | "html")
            xml)
            py)
            pl)
            rc
            txt
            sh
            conf
                    
                    # Checking mimetype. 
                    # This is necessary because apparently the .doc extension is really a type of RTF, or at least sometimes is!
                    mimetype=$(file "$rawfile" | grep -c "Rich Text Format")
                    # a match is $? = 0 no match is 1
                    if [ "$mimetype" != "0" ]; then
                        extension="rtf"
                    fi
                    mimetype=$(file "$rawfile" | grep -i -F -e "Zip archive" | grep -i -F -e "docx" )
                    if [ "$mimetype" != "" ]; then
                        extension="docx"
                    fi
                    #TODO
                    #  HAVE TWO MATCHES - one for extension, one for mimetype - if they 
                    # don't match, offer to rename like irfanview does, maybe? 
                    # ! PUT SANITY CHECK FOR EXTENSION HERE INSTEAD OF MAKING IT A BIG IF BLOCK

                        "docx" | "DOCX" ) /home/steven/bin/antiwordxp < "$tmpfile" | pandoc -f markdown -t html  | lynx -stdin -lss=/home/steven/.lynx/lynx.lss	;;
                        "odt" | "ODT" ) /home/steven/bin/antiodtxp < "$tmpfile" | pandoc -f markdown -t html  | lynx -stdin -lss=/home/steven/.lynx/lynx.lss	;;
                        "doc" | "DOC" ) antiword -x db "$tmpfile" | pandoc -f docbook -t html | lynx -stdin -lss=/home/steven/.lynx/lynx.lss ;;
                        "rtf" | "RTF" )	unrtf --html "$tmpfile" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss ;; 
                        "pdf" | "PDF" ) pdftotext -layout "$tmpfile" "$tmpfile"; less "$tmpfile" ;;
                        "md" | "mkd" ) mdless "$2" ;;
                        #"md" | "mkd" ) pandoc -s -f markdown -t html "$tmpfile" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss ;;
                        "xhtml" | "htm" | "html" ) lynx "$tmpfile" -lss=/home/steven/.lynx/lynx.lss ;;			

        esac
    fi	

    
    
}

################################################################################
# Parse arguments
################################################################################


while [ $# -gt 0 ]; do
option="$1"
    case $option in
        -e) 
            Action="Edit"
            #edit with #EDITOR
            Action="View"
            shift
            InstructionFile="$1"
            shift
            ;;      
        -v) 
            Action="View"
            shift
            InstructionFile="$1"
            shift
            ;;      
        -h)  
            show_help
            exit
            ;;   
    esac    
done




	
################################################################################
# Determine what to call and how to call it.
# Should probably export these all out to a config file and have sane defaults
# hardcoded
################################################################################
	
	case "$1" in
		"-v")
		case $extension in
            #wvWare [file] | lynx -stdin -lss=/home/steven/.lynx/lynx.lss 
			"docx" | "DOCX" ) /home/steven/bin/antiwordxp < "$tmpfile" | pandoc -f markdown -t html  | lynx -stdin -lss=/home/steven/.lynx/lynx.lss	;;
			"odt" | "ODT" ) /home/steven/bin/antiodtxp < "$tmpfile" | pandoc -f markdown -t html  | lynx -stdin -lss=/home/steven/.lynx/lynx.lss	;;
			"doc" | "DOC" ) antiword -x db "$tmpfile" | pandoc -f docbook -t html | lynx -stdin -lss=/home/steven/.lynx/lynx.lss ;;
			"rtf" | "RTF" )	unrtf --html "$tmpfile" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss ;; 
			"pdf" | "PDF" ) pdftotext -layout "$tmpfile" "$tmpfile"; less "$tmpfile" ;;
            "md" | "mkd" ) mdless "$2" ;;
			#"md" | "mkd" ) pandoc -s -f markdown -t html "$tmpfile" | lynx -stdin -lss=/home/steven/.lynx/lynx.lss ;;
			"xhtml" | "htm" | "html" ) lynx "$tmpfile" -lss=/home/steven/.lynx/lynx.lss ;;			
			"*") notify-send --icon=file-roller "don't know how to do this $extension" ;;
		esac
		;;
		"-tv")
		case $extension in
			"docx" | "DOCX" ) antiwordxp.rb "$2" > "$tmpfile"; mcview "$tmpfile" ;;
			"doc" | "DOC" ) antiword -f "$2" > "$tmpfile"; mcview "$tmpfile"  ;;
			"rtf" | "RTF" )	catdoc "$2" > "$tmpfile"; mcview "$tmpfile" ;; 
			"pdf" | "PDF" ) pdftotext -layout "$2" "$tmpfile"; mcview "$tmpfile" ;;
			#"md" | "md" ) pandoc -s -f markdown -t html "$2" "$tmpfile"; lynx "$tmpfile" ;;			
            "md" | "mkd" ) mdless "$tmpfile" ;;
			"*") notify-send --icon=file-roller "don't know how to do this $extension" ;;
		esac
		;;
	esac

