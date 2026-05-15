#!/usr/bin/env bash

# DEFINE
PROGNAME="txt2latex"
PROGVERSION="0.2.0"
SHORTDESCRIPTION="Converts text to LaTeX."
HOMEPAGE="https://github.com/MilanSkocic/txt2latex"
LICENSE="MIT"
AUTHOR="M. Skocic"
MANSECTION="1"
RED="\e[31m"
BLACK="\e[0m"
GREEN="\e[32m"


help () {
cat << EOT
NAME
  $PROGNAME - convert flat ASCII text to LaTeX.

SYNOPSIS
  $PROGNAME [OPTION...] FILE 

DESCRIPTION
  $PROGNAME converts the input text into LaTeX. 

  $PROGNAME is also able to recognize and format sections, paragraphs,
  lists (itemize, enumerate, description) and verbatim blocks.

  If input file FILE is omitted, standard input is used. 
  Result is displayed on standard output. 

  Here is how text patterns are recognized and processed:
  Sections    These headers are defined by a line in upper case, starting
              column 1. 
              Optionally, the Section name can be preceded by a blank line. 
              This is useful for a better visualization of the source 
              text to be used to generate the LaTeX source code.
  Paragraphs  They must be separated by a blank line, and left aligned.
              Alternatively two blank spaces can be used to produce the
              same result. This option will provide a better visualization
              of the source text to be used to generate the LaTeX source code.
  Description list  
              The item definition is separated from the item description
              by at least 2 blank spaces, even before a new line, if
              definition is too long.
  Bullet list  
              Bullet list items are defined by the first word being "-",
              "*" or "o".
  Enumerated list  
              The first word must be a number followed by a dot or a rounded bracket.
  Verbatim blocks  
              This paragraph type is used to display unmodified text,
              for example source code. It must be separated by a blank
              line and be indented by a TAB. It is primarily used to format
              unmodified source code. It will be printed using verbatim environment.
  Mathematics  
              Inline mathematics must be enclosed with a simple $ sign
              and equations must be enclosed with double $ signs.

OPTIONS
  -v, --version   Display version.
  -h, --help      Display help.
  -d date         Set date. Defaults to current date.
  -t mytitle      Set the title. If the title is set, txt2latex will 
                  automatically add the preambule and markups for the document
  -a author       Set the author.
  -s shift        Shift heading level by 0 (section), 1 (subsection), or 2 (subsection).
                  Defaults to 0.
  -I txt          Italicize txt in output. Can be specified more than once.
  -B txt          Emphasize (bold) txt in output. Can be specified more than once.
  -P package      Add packages or LateX commands in the preambule.
  -X              Compile output with pdflatex.

EXAMPLES
  Simple conversion

    $ $PROGNAME FILE > FILE.tex
  
  Conversion with document title

    $ $PROGNAME -t "title" -a "author" -I "word" FILE > FILE.tex

  Conversion with custom packages and direct rendering with pdflatex

    $ $PROGNAME -t "title" -a "author" -I "word" -P "\\\\usepackage{ccfonts}" -X FILE

SEE ALSO
  txt2man(1)
EOT
}


version () {
echo "PROGRAM:      $PROGNAME                          "
echo "DESCRIPTION:  $SHORTDESCRIPTION                  "
echo "VERSION:      $PROGVERSION                       "
echo "AUTHOR:       $AUTHOR                            "
echo "LICENSE:      $LICENSE                           "
}

title=
author=
date=${date:-$(date +'%d %B %Y')}
itxt=
btxt=
post=cat
shiftsec=0

args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      args+=("-h")
      shift
      ;;
    --version)
      args+=("-v")
      shift
      ;;
    --) # end of options
      shift
      break
      ;;
    -*)
      args+=("$1")
      shift
      ;;
    *)
      break
      ;;
  esac
done

# Restore positional parameters
set -- "${args[@]}" "$@"

while getopts :vhd:t:a:I:B:P:X opt
do
	case $opt in
	(d) date=$OPTARG;;
	(t) title=$OPTARG;;
	(a) author=$OPTARG;;
    (s) shiftsec=$OPTARG;;
	(I) itxt="$OPTARG§$itxt";;
	(B) btxt="$OPTARG§$btxt";;
	(P) ptxt="$OPTARG§$ptxt";;
    (X) post="pdflatex";;
	(h) help; exit;;
	(v) version; exit;;
    :) echo "Option -$OPTARG requires an argument"; exit 1;;
#    \?) echo "Invalid option: -$OPTARG"; exit 1;;
    *) exit;;
	esac
done
shift $(($OPTIND - 1))


if [[ ${#@} == 0 ]];then
    if [[ -t 0 ]]; then
        echo "No input from stdin or from file."
        exit 1;
    fi
fi

expand $@ | 
awk -v title="$title" -v author="$author" -v date="$date" \
 -v itxt="$itxt" \
 -v btxt="$btxt" \
 -v ptxt="$ptxt" \
 -v shiftsec=$shiftsec '
BEGIN {
in_list = 0
in_enum = 0
in_desc = 0
in_verb = 0
in_math = 0

tag = ""

pbl   = 0         # previous blank line
ls    = 0		# line start index
pls   = 0		# previous line start index
pnzls = 0	# previous non zero line start index
eoff  = 0

shift = 0

levels[1] = "n"
levels[2] = "n"
levels[3] = "n"
levels[4] = "n"
levels[5] = "n"


print "\%Text automatically generated by txt2latex"

    if (title != "") {
        start_article(title, author, date); 
        start_document()
    }
}

# SECTIONS
/^[[:upper:][:digit:]]+[[:upper:][:space:][:digit:][:punct:]]+$/ {
    
    if(in_verb==1){
        in_verb=0
        print "\\end{verbatim}"
    }
    while (lind()>0){
        in_list=end_list(in_list,"")
    }
    
    levels[1] = "n"
    levels[2] = "n"
    levels[3] = "n"
    levels[4] = "n"
    levels[5] = "n"

    ls = 0		# line start index
    pls = 0		# previous line start index
    pnzls = 0	# previous non zero line start index
    
    $0 = fmtmath($0)
    if (shiftsec == 1) {
        print "\\subsection{"$0"}"
    }else if (shiftsec == 2){
        print "\\subsubsection{"$0"}"
    }else{
        print "\\section{"$0"}"
    }
    next
}


# DESCRIPTIONS
/[^ ]  +/ {
    if (in_verb == 0) {
        cind()
        if (lind() == 0 || ls>pls){
            in_desc=start_list(in_desc,"description")
        }
        if (lind()>1 && ls<pls){in_list=end_list(in_list,"")}
        match($0, /[^ ]  +/)
        tag = substr($0, 1, RSTART)
        desc = substr($0, RSTART+1)
        # sub(/[\-\*o]/,"", tag)
        sub(/^ +/,"", tag)
        sub(/^ +/,"", desc)
        print "\\item["fmtmath(tag)"] "fmtmath(desc)
        next
    }
}

# LISTS
/^[[:space:]]*[\-\*o][[:space:]].+/ {
    if (in_verb == 0) {
        cind()
        if (lind() == 0 || ls>pls){
            in_list=start_list(in_list,"itemize")
        }
        if (lind()>1 && ls<pls){in_list=end_list(in_list,"")}
        sub(/[\-\*o]/,"")
        sub(/^ +/,"")
        print "\\item "fmtmath($0)
        next
    }
}

# ENUMERATE
/^[[:space:]]*[0-9]+[\)\.][[:space:]].+/ {
    if (in_verb == 0) {
        cind()
        if (lind() == 0 || ls>pls){
            in_enum=start_list(in_enum,"enumerate")
        }
        if (lind()>1 && ls<pls){in_list=end_list(in_list,"")}
        sub(/[0-9]+\./,"")
        sub(/[0-9]+\)/,"")
        sub(/^ +/,"")
        print "\\item "fmtmath($0)
        next
    }
}

# multiline items

# All other lines which are paragraphs
{
#-----------------------------------------------------------------------
    # CHECK IF BLANK LINE
    if(NF == 0) {
        cind()
        pbl = 1
        while(lind()>0){in_list=end_list("","")}
        print $0
        next
    }
#-----------------------------------------------------------------------
    # INLINE MATH
    if (match($0,/.*\\\(.*\\\).*/)>0) {
        gsub(/\\\(/,"\$", $0)
        gsub(/\\\)/,"\$", $0)
    }
#-----------------------------------------------------------------------
    # EQUATION ENVIRONMENT
    if (match($0,/.*\\\[.*\\\].*/)>0) {
        gsub(/\\\[/,"\$\$", $0)
        gsub(/\\\]/,"\$\$", $0)
    }
#-----------------------------------------------------------------------
    # EQUATION: DO NOT CHANGE ANYTHING, ONLY REMOVE LEADING SPACES  
    if(match($0,/[[:space:]].*\$\$.*\$\$/)>0) {
        sub(/^ +/,"", $0) # Remove leading spaces
        print $0
        next
    }
#-----------------------------------------------------------------------
    # COMPUTE INDENTS WHEN NO EMPTY LINE
    cind()
#-----------------------------------------------------------------------
    # START DISPLAY BLOCK IF PREVIOUS BLANK LINE
    if (pbl == 1 && pls==0 && pnzls > 0 && ls > pnzls && in_verb==0) {
        in_verb=1
        print "\\begin{verbatim}"
        eoff = ls
    }
#-----------------------------------------------------------------------
    # END DISPLAY BLOCK
    if (ls != 0 && ls < eoff && in_verb==1){
        in_verb=0
        print "\\end{verbatim}"

    }
#-----------------------------------------------------------------------
    # HANDLE ALL LINES EXCEPT DISPLAY BLOCKS
    if (in_verb == 0){
        sub(/^ +/,"", $0) # Remove leading spaces
        $0 = fmtmath($0) # Escape all special characters except for inline math 

        # Multiline items, start with spaces
        if (match($0,/[[:space:]].*/)>0) {
            n = lind()
            if (n>0){
                sub(/^ +/,"") # Remove leading spaces
                if (levels[n]=="description"){
                    x=length(tag)+2+5+1
                    printf "%*s%s\n", x, "", $0
                }else{
                    x=5+1
                    printf "%*s%s\n", x, "", $0
                }
                next
            }
        }
    
        split(itxt, tt, "§")
            for (i in tt)
                if (tt[i] != "")
                    sub(tt[i], "\\textit{"tt[i]"}")
        split(btxt, tt, "§")
            for (i in tt)
                if (tt[i] != "")
                    sub(tt[i], "\\textbf{"tt[i]"}")
    }
#-----------------------------------------------------------------------
    print $0
}

END{
    if(in_verb==1){
        in_verb=0
        print "\\end{verbatim}"
    }
    while (lind()>0){
        in_list=end_list(in_list,"")
    }
    if (title != "") {
        end_document()
    }
}

function escape (s){
    gsub(/\\/, "\\textbackslash\\", s)
    gsub(/#/,"\\#", s)
    gsub(/\$/,"\\$", s)
    gsub(/%/,"\\%", s)
    gsub(/&/,"\\\\&", s)
    gsub(/{/, "\\{", s)
    gsub(/}/, "\\}", s)
    gsub(/_/, "\\\_", s)
    gsub(/\^/, "\\^\\", s)
    gsub(/>/,"$>$", s)
    gsub(/</,"$<$", s)
    return s
}

function fmtmath (s){
    line = s
    math=""
    text=""
    sout=""
    i=0
    in_math = 0
    while (match(line, /\$([^$]*)\$/, m)) {
        in_math=1
        math = m[0]
        text = substr(line, i, i+RSTART-1)
        line = substr(line, RSTART + RLENGTH)
        text = escape(text)
        sout = sout text math
    }
    if (in_math == 1) {
        line = escape(line)
        sout = sout line
    }else{
        sout = escape(line)
    }

    return sout
}

function cind(){
    pls = ls
    if (ls != 0) { pnzls = ls }
    match($0, /[^ ]/)
    ls = RSTART
}

function lind (){
    n=0
    for (i in levels){
        if(levels[i] != "n"){
            n++
        }
    }
    return n
}

function end_list(s, env){
    n = lind()
    e=""
    if (n > 0){
        if (levels[n] == "description"){
            e = "description"
        }else if(levels[n] == "itemize"){
            e = "itemize"
        }else if(levels[n] == "enumerate"){
            e = "enumerate"
        }
        levels[n] = "n"
        print "\\end{"e"}"
    }
    return 0
}

function start_list(s, env){
    n = lind()
    levels[n+1] = env
    print "\\begin{"env"}"
    return 1
}

function start_article(title,author,date) { 
    print "\\documentclass[10pt,notitlepage]{article}" 
    split(ptxt, tt, "§")
        for (i in tt)
            if (tt[i] != "")
                print tt[i]
    print "\\title{"title"}"
    print "\\author{"author"}"
    print "\\date{"date"}"
}

function start_document() { print "\\begin{document}\n\\maketitle\n" }

function end_document() { print "\\end{document}" }
' | eval $post
