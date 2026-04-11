#!/usr/bin/env bash

# DEFINE
PROGNAME="$APP_NAME"
PROGVERSION="0.1"
SHORTDESCRIPTION="Converts text to LaTeX."
HOMEPAGE=""
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
  $PROGNAME [OPTIONS]... FILE 

DESCRIPTION
  $PROGNAME converts the input text into LaTeX. The conversion procedure
  is strongly inspired by txt2man.

  $PROGNAME is also able to recognize and format sections, paragraphs,
  lists (standard, numbered, description, nested), literal display blocks.

  If input file FILE is omitted, standard input is used. 
  Result is displayed on standard output. 

  Here is how text patterns are recognized and processed:
  Sections    These headers are defined by a line in upper case, starting
              column 1. If there is one or more leading spaces, a
              sub-section will be generated instead. Optionally, the
              Section name can be preceded by a blank line. This is useful
              for a better visualization of the source text to be used to
              generate the LaTeX source code.
  Paragraphs  They must be separated by a blank line, and left aligned.
              Alternatively two blank spaces can be used to produce the
              same result. This option will provide a better visualization
              of the source text to be used to generate the LaTeX source code.
  Description list
              The item definition is separated from the item description
              by at least 2 blank spaces, even before a new line, if
              definition is too long. Definition will be emphasized
              by default.
  Bullet list  
              Bullet list items are defined by the first word being "-"
              or "*" or "o".
  Enumerated list  
              The first word must be a number followed by a dot.
  Literal display blocks  
              This paragraph type is used to display unmodified text,
              for example source code. It must be separated by a blank
              line and be indented by a TAB. It is primarily used to format
              unmodified source code. It will be printed using fixed font
              using verbatim environment.

OPTIONS
  -v   Display version.
  -h      Display help.
  -d date     Set date. Defaults to current date.
  -t mytitle  Set the title.
  -a author   Set the author.
  -I txt      Italicize txt in output. Can be specified more than once.
  -B txt      Emphasize (bold) txt in output. Can be specified more than once.
  -X          Compile output with pdflatex.

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


while getopts :vhd:t:a:I:B:X opt
do
	case $opt in
	(d) date=$OPTARG;;
	(t) title=$OPTARG;;
	(a) author=$OPTARG;;
	(I) itxt="$OPTARG§$itxt";;
	(B) btxt="$OPTARG§$btxt";;
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
awk -v title="$title" -v author="$author" -v date="$date" -v itxt="$itxt" -v btxt="$btxt" '
BEGIN {
in_list=0
in_enum=0
in_desc=0
is_item=0
if (title != "") {start_article(title, author, date); start_document()}
}

END{if (title != "") {end_document()}}

# SECTIONS
/^[[:upper:][:digit:]]+[[:upper:][:space:][:digit:][:punct:]]+$/ {
    in_list=end_list(in_list,"itemize")
    in_desc=end_list(in_desc,"description")
    in_enum=end_list(in_enum,"enumerate")
    print "\\section{"$0"}"
    next
}


# DESCRIPTIONS
/[^ ]  +/ {
    if (match($0, /[^ ]  +/) > 0){
        in_desc=start_list(in_desc,"description")
        tag = substr($0, 1, RSTART)
        desc = substr($0, RSTART+1)
        sub(/[\-\*o]/,"", tag)
        sub(/^ +/,"", tag)
        sub(/^ +/,"", desc)
        print "\\item["tag"] "desc
        is_item=1
    }
    next
}



# LISTS
/^[[:space:]]*[\-\*o][[:space:]].+/ {
    in_list=start_list(in_list,"itemize")
    sub(/[\-\*o]/,"")
    sub(/^ +/,"")
    print "\\item "$0
    is_item=1
    next
}

# ENUMERATE
/^[[:space:]]*[0-9]+\.[[:space:]].+/ {
    in_enum=start_list(in_enum,"enumerate")
    sub(/[0-9]+\./,"")
    sub(/^ +/,"")
    print "\\item "$0
    is_item=1
    next
}

# multiline items
/[[:space:]].*/ {
    print $0
    next
}

# ALL
{
	# to avoid some side effects in regexp
	gsub(/\.\.\./, "\\.\\.\\.")
	# remove spaces in empty lines
	sub(/^ +$/,"")
	sub(/^ +/,"") # Remove leading spaces
    
    in_list=end_list(in_list,"itemize")
    in_desc=end_list(in_desc,"description")
    in_enum=end_list(in_enum,"enumerate")

    split(itxt, tt, "§")
		for (i in tt)
			if (tt[i] != "")
                sub(tt[i], "\\textit{"tt[i]"}")
    split(btxt, tt, "§")
		for (i in tt)
			if (tt[i] != "")
                sub(tt[i], "\\textbf{"tt[i]"}")

    print $0
}




function end_list(s, env)
{
    if ((s+0)==1){
        print "\\end{"env"}"
    }
    return 0
}
function start_list(s, env)
{
    if ((s+0)==0){
        print "\\begin{"env"}"
    }
    return 1
}
function start_article(title,author,date) { 
    print "\\documentclass[10pt,notitlepage]{article}" 
    print "\\title{"title"}"
    print "\\author{"author"}"
    #print "\\date{"date"}"
}
function start_document() { print "\\begin{document}\n\\maketitle\n" }
function end_document() { print "\\end{document}" }
' | eval $post
