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
inettmp=$(mktemp /tmp/showdocs-wombatXXXXXXXXXXXXXXXXXXX)

# Referring to my devour script
DevourBinary=$(which devour)
if [ -z "$DevourBinary" ];then
    DevourBinary=$(which devour.sh)
fi

MunaBinary=$(which muna.sh)
# For unredirecting URLs

TerminalBinary=$(which xterm)

#get installation directory
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

#This will be built by the script at runtime; do not alter!
CommandString=""
GUI="" #This is used if needed for URLPORTAL
TMUX="" #This is used if needed to determine what web browser to use
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
    dtrx -l "${infile}" | bat --paging=always 
}

show_sqlite (){
    bobarray=( $(sqlite3 "$infile" '.tables') )
    tablechoice=$(for d in "${bobarray[@]}"; do echo "$d" ; done | fzf)
    sqlite3 -csv -header "$infile" "select * from ${tablechoice}" | pspg --csv --csv-header=on --double-header
}

show_docx (){
    pandoc -f docx "$infile" | sed "s@href=\"@href=\"file://localhost$indir/@g" | sed "s@file://localhost$indir/http@http@g" | eval "$browsercommand"
}

show_doc (){
    if [[ "$mimetype" == *"$docstring"* ]];then        
        wvWare "$infile" | sed "s@href=\"@href=\"file://localhost$indir/@g" | sed "s@file://localhost$indir/http@http@g" | eval "$browsercommand"
    elif [[ "$mimetype" == *"$rtfstring"* ]];then
        unrtf --html "$infile" | sed "s@href=\"@href=\"file://localhost$indir/@g" | sed "s@file://localhost$indir/http@http@g" | eval "$browsercommand"
    else
        show_text
    fi
}

show_odt (){
    pandoc -f odt "$infile" | sed "s@href=\"@href=\"file://localhost$indir/@g" | sed "s@file://localhost$indir/http@http@g" | eval "$browsercommand"
}

show_rtf (){
    unrtf --html "$infile" | sed "s@href=\"@href=\"file://localhost$indir/@g" | sed "s@file://localhost$indir/http@http@g" | eval "$browsercommand"
}

show_pdf (){
    
    pdftotext -nopgbrk -layout -nodiag "$infile" "$tmpfile"

    # If it is not in its own xterm, why do any of this?
    if [ "$GUI" == "1" ];then
        MaxWidth=$(wc -L "$tmpfile" | awk '{print $1}')
        if [ "$MaxWidth" -gt "$COLUMNS" ];then
            if [ $(which wmctrl) ];then
                CommandString=$(printf "%s %s" "${CommandString}" 'snark=$(echo $WINDOWID);')
                CommandString=$(printf "%s %s %s" "${CommandString}" 'wmctrl -i -r $snark -e '0,-1,-1,1200,-1';')
                eval ${CommandString}
            fi
        fi
    fi

    bat --decorations never "$tmpfile"; rm "$tmpfile"

#TODO- use this to look for spaces (and therefore columns) in pdf output
# grep -o ' ' | wc -l 
# but need to find matches PER line, it's teh wrong grep output for that.
    
}

show_ods (){
    
    tmpfile2=""
    if [ $(which ssconvert) ];then
        tmpfile2=$(mktemp /tmp/showdocs-wombat.XXXXXXXXXXXXXXXXXXX.csv)
        #gnumeric is quickest
        ssconvert "$infile" "$tmpfile2" > /dev/null
    elif [ $(which soffice) ];then
        tmpfile2=$(mktemp /tmp/showdocs-wombat.XXXXXXXXXXXXXXXXXXX.csv)
        #libreoffice headless also works
        soffice --headless --convert-to csv "$infile" "$tmpfile2"
    fi
    if [ ! -z "$tmpfile2" ];then
        tabview "$tmpfile2"
        rm "$tmpfile2"
    fi
}

show_json () {

    echo "[$(cat "$infile")]" | in2csv -I -f json | csvtool transpose - | tabview -
}

show_excel (){

    tmpfile2=""
    if [ $(which in2csv) ];then
        in2csv "$infile" | tabview -    
        return
    elif [ $(which xlsx2csv) ];then
        xlsx2csv "$infile" --all | tabview -
        return    
    elif [ $(which ssconvert) ];then
        tmpfile2=$(mktemp /tmp/showdocs-wombat.XXXXXXXXXXXXXXXXXXX.csv)
        #gnumeric is quickest
        ssconvert "$infile" "$tmpfile2"
    elif [ $(which soffice) ];then
        tmpfile2=$(mktemp /tmp/showdocs-wombat.XXXXXXXXXXXXXXXXXXX.csv)
        #libreoffice headless also works
        soffice --headless --convert-to csv "$infile" "$tmpfile2"
    fi
    if [ ! -z "$tmpfile2" ];then
        tabview "$tmpfile2"
        rm "$tmpfile2"
    fi    
}

show_csv (){
    tabview "$infile"
}

show_epub (){
    epy "$infile"
}

show_html (){
    cat "${infile}" | eval "$browsercommand"
}

show_markdown (){
    pandoc -s -f markdown -t html "$infile" | sed "s@href=\"@href=\"file://localhost$indir/@g" | sed "s@file://localhost$indir/http@http@g" | eval "$browsercommand"
}

show_text (){
    bat --paging=always "$infile" 
}

show_ansiart (){
    if [ "$GUI" == "1" ];then
        tmpfile3=$(mktemp /tmp/showdocs-wombat.XXXXXXXXXXXX.${extension})
        ansilove -o ${tmpfile3} ${infile}
        feh ${tmpfile3} -x -B black -g --insecure --geometry=800x600+15+60
        rm ${tmpfile3}
    else
        # If you care about simulating baud rates
        #iconv -f 437 "$infile" | pv --quiet --rate-limit 7000
        iconv -f 437 "$infile"
    fi
}

show_xbart (){
    tmpfile3=$(mktemp /tmp/showdocs-wombat.XXXXXXXXXXXX.${extension})
    ansilove -o ${tmpfile3} ${infile}
    if [ "$GUI" == "1" ];then
        feh ${tmpfile3} -x -B black -g --insecure --geometry=600x600+15+60
    else
        chafa ${tmpfile3}
    fi    
    rm ${tmpfile3}
}


function xterm_setup() {
    echo "${SCRIPT_DIR}"
    if [ $(which xseticon) ] && [ -f ${SCRIPT_DIR}/showdocs-wombat-xterm-icon.png ];then
        CommandString=$(printf "%s %s" "${CommandString}" 'snark=$(echo $WINDOWID);')
        CommandString=$(printf "%s %s %s" "${CommandString}" 'xseticon -id $snark ' "${SCRIPT_DIR}/showdocs-wombat-xterm-icon.png;")
    fi
    if [ $(which wmctrl) ];then
        CommandString=$(printf "%s %s" "${CommandString}" 'snark=$(echo $WINDOWID);')
        CommandString=$(printf "%s %s %s" "${CommandString}" 'wmctrl -i -r $snark -T ShowDocs-Wombat;')
    fi
    eval ${CommandString}
}

##############################################################################
# Show help
##############################################################################

function show_help() {
    echo "Usage: showdoc.sh $filename"
    echo "  -h = show this help"
    echo "  -g = implies called from a GUI, will launch own terminal"
    echo "  Will also use devour script if available."
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
    tablechoice=$(for d in "${mysqltablearray[@]}"; do echo "$d" ; done | fzf --multi )
    KeySelector=$(echo "$tablechoice" | grep -c "Show keys of selected table" )
    RealTableChoice=$(echo "$tablechoice" | grep -v "Show keys of selected table")
    if [ ${KeySelector} -eq 0 ];then
        # Show table desc
        mysql -u${MYSQLU} -p${MYSQLP} -B -e "desc ${RealTableChoice}" ${mysqldbchoice} | pspg --tsv --csv-header=on
    else
        # SHOW THOSE KEYS
        mysql -u${MYSQLU} -p${MYSQLP} -B -e "show keys from ${RealTableChoice}" ${mysqldbchoice} | pspg --tsv --csv-header=on
    fi
}

##############################################################################
# Main Function
##############################################################################
if [ "$1" == "-h" ];then
    show_help
    exit
fi    

# If it's going to be a spawned terminal, we want to start setting it up now.
# calling the process again in an xterm
if [ "$1" == "-g" ];then
    shift
    FunkyPath=$(echo "$@" | sed 's/#/\\#/g')
    xterm -e "$SCRIPT_DIR/showdocs.sh -+- $SCRIPT_DIR $FunkyPath" &
    exit
fi


# We've been called in an xterm
if [ "$1" == "-+-" ];then
    GUI=1  # storing in case we need to pass it to URLportal
    shift
    SCRIPT_DIR="$1"
    shift
    xterm_setup
fi

browsercommand=$(echo "lynx -stdin -lss=$HOME/.lynx/lynx.lss")

if [ -z "$GUI" ];then
    # The other variables should have already been used up 
    if [ "$1" == "+-+" ];then #already in tmux, already re-called, and devour exists
        browsercommand=$(echo "w3m -T text/html")
        shift
    else
        c_tmux=$(env | grep -c TMUX)  # Are we in tmux?
        if [ $c_tmux -gt 0 ] && [ ! -z "$DevourBinary" ];then #does devour exist?
            FunkyPath=$(echo "$@" | sed 's/#/\\#/g')
            "$DevourBinary" "$SCRIPT_DIR/showdocs.sh +-+ $FunkyPath"  # re-call it in devour
            exit
        fi
    fi
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


# This is necessary so that if a filename is unescaped, it'll get fixed.
FunkyPath=$(echo "$@")

#If it is a URL, download it, identify it, and then run through showdocs/URLPortal
if [[ "$FunkyPath" =~ "https://" ]] || [[ "$FunkyPath" =~ "http://" ]];then
    if [ ! -z "$MunaBinary" ];then
        source "$MunaBinary"
        url="${FunkyPath}"
        unredirector
        FunkyPath="${url}"
    fi
    DINFO=$(wget --spider "$FunkyPath" 2>&1)
    mimetype=$(echo "$DINFO"|egrep -e '^Length:'|awk -F "[" '{print $2}'|awk -F "]" '{print $1}')
    mainmimetype=$(echo "$mimetype"|awk -F "/" '{print $1}')
    fileurl=$(echo "$DINFO"|egrep -e '^--'|awk -F " " '{print $3}')
    file=$(basename $fileurl)
    #######
    # If the URL already has a filename with extension, then use that.
    #######
    if [[ "$file" =~ "." ]];then  #does it have an extension already?
        ext=${file##*.}
        FunkyPath=$(echo "$inettmp.$ext")  # bringing us back in line with the rest of the flow
        wget -q "${fileurl}" -O "$FunkyPath"
    else
        #######
        # URL without extension, so we'll have to download it and find the mimetype
        #######
        ext=""
        wget -q "${FunkyPath}" -O "$inettmp"
        if [ -f "$inettmp" ];then
            mt="$(mimetype -bM "$inettmp")"
            ext="${mt##*/}"            # Most things have a minor mimetype that is similar ENOUGH to the extension to "just work"
            ext="${ext##*/x-}"         # for mimetypes that have x- variations, like audio/midi and audio/x-midi
            case "$mt" in              # for mimetypes that are both audio and video, like mpeg
                audio/mpeg*)
                    ext=$(echo "mp3")  
                    ;;
                video*)                 # left here for when I get these sorted
                    ;;
            esac
            case "$ext" in
                vnd.ms-asf) ext="wmv";;
                msvideo) ext="avi";;
                matroska) ext="mp4";;
                quicktime) ext="mov" ;;
            esac
            mv -v "$inettmp" "$inettmp.$ext"
            FunkyPath=$(echo "$inettmp.$ext")  # bringing us back in line with the rest of the flow
        
        else
            exit 2
        fi
    fi
fi

cmdstring=$(printf "realpath \"%s\"" "$FunkyPath")
infile=$(eval "$cmdstring")
indir=$(dirname "$infile")

    
if [ -f "$infile" ]; then
    filename=$(basename "$infile")
    #get extension, lowercase it
    extension=$(echo "${filename##*.}" | tr '[:upper:]' '[:lower:]')
    mimetype=$(file "$filename" | awk -F ':' '{ print $2 }') 
    
    # Match extension first, since DOC and XLS give the same mimetype
    case "$extension" in
        ans|asc|nfo|qqdiz|ans|mnu) show_ansiart;;
        xb) show_xbart;;  # xb is supported by ansilove, but the iconv trick doesn't work
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
        xls|xlsx ) show_excel ;;
        ods ) show_ods ;;
        "md" | "mkd") show_markdown ;; 
        "xhtml" | "htm" | "html" ) show_html ;;
        py) show_text ;;
        xml) show_text ;;
        pl) show_text ;;
        rc|txt|sh|conf|ini) show_text ;;
        *)
            # Try to match by mimetype instead
            case "$mimetype" in     
            *text*with*escape*sequences) show_ansiart ;;
            *Python*script* )          show_text ;;
            *PHP*script* )          show_text ;;
            *Perl*script* )         show_text ;;
            *Word*2007* )           show_docx ;;
            *OpenDocument*Text*)    show_odt ;;
            *PDF*document*)         show_pdf ;;
            *Composite*Document*File*V2*) show_doc ;;
            *Rich*Text*Format*)     show_rtf ;;
            *HTML*document* )       show_html ;;
            *XML*document* )        show_text ;;
            *SQLite*database* )     show_sqlite ;;
            *ASCII*text* )          show_text ;;
            *UTF-8*Unicode*text*)   show_text ;;
            *tar*archive*gzip* )    show_archive ;;
            *tar*archive*      )    show_archive ;;
            *gzip*             )    show_archive ;;
            *ARJ*archive*data* )    show_archive ;;
            *zip*archive*file* )    show_archive ;;
            *                  )    # Tossing anything else to URLportal
                                    UPBinary=$(which urlportal)
                                    if [ -z "$UPBinary" ];then
                                        UPBinary=$(which urlportal.sh)
                                    fi
                                    
                                    if [ -f "$UPBinary" ];then
                                        if [ -f ${infile} ];then  #URLPortal is really more meant to handle URLs
                                            infile=$(echo "file://${infile}")
                                        fi
                                        if [ -z $GUI ];then
                                            CommandString=$(printf "%s %s" "${UPBinary}" "-c ${infile}")
                                        else
                                            CommandString=$(printf "%s %s" "${UPBinary}" "-g ${infile}")
                                        fi
                                        nohup ${CommandString} > /dev/null
                                    fi
                                    ;;
            esac 
        ;;
    esac
fi
