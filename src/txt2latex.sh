#!/usr/bin/env bash

########################################################################
# Copyright (C) 2026  Milan Skocic
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# SPDX-License-Identifier:  GPL-3.0-or-later
########################################################################


# DEFINE
PROGNAME="txt2latex"
PROGVERSION="0.6.0"
SHORTDESCRIPTION="Converts text to LaTeX."
HOMEPAGE="https://github.com/MilanSkocic/txt2latex"
LICENSE="MIT"
AUTHOR="M. Skocic"
MANSECTION="1"
RED="\e[31m"
BLACK="\e[0m"
GREEN="\e[32m"

version () {
#{{{
cat << EOT
$PROGNAME $PROGVERSION 

Copyright (C) 2026 Milan Skocic.
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Milan Skocic.
EOT
#}}}
}

usage () {
cat << EOT 
Usage: $PROGNAME [-d date] [-t mytitle] [-a author] [-s shift] 
                 [-I txt] [-B txt] [-M txt] [-E txt] 
                 [-P package] 
                 [-m, --man] [-n, --num] 
                 [-u, --usage] [-v, --version] [-h, --help]
EOT
}


help () {
#{{{
cat << EOT
Usage: $PROGNAME [OPTION...] FILE 
$PROGNAME - convert flat ASCII text to LaTeX.

  -d date         Set date. Defaults to current date.
  -t mytitle      Set the title. If the title is set, txt2latex will 
                  automatically add all the markups necessary to 
                  create a standalone latex document that can be compiled 
                  with pdflatex. Xelatex and lualatex are not supported. 
  -a author       Set the author.
  -s shift        Shift heading level by 0 (section), 1 (subsection), or 2 (subsection).
                  Defaults to 0.
  -I txt          Italic txt in output. Can be specified more than once.
  -B txt          Bold txt in output. Can be specified more than once.
  -M txt          Monospace txt in output. Can be specified more than once.
  -E txt          Emphasize txt in output. Can be specified more than once.
  -P package      Add packages or LaTeX or TeX commands in the preambule.
  -m, --man       Apply some special formatting for man pages.
  -n, --num       Unnumbered sections. By default, sections are not numbered.
  -u, --usage     Display synopsis.
  -v, --version   Display version.
  -h, --help      Display help.

See the man-page $PROGNAME(1) for more details.

Report bugs at <https://github.com/MilanSkocic/txt2latex/issues>.
EOT
#}}}
}



title=
author=
date=${date:-$(date +'%d %B %Y')}
itxt=
btxt=
mtxt=
etxt=
post=cat
shiftsec=0
manstyle=0
numbered=0

args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --usage)
        args+=("-u")
        shift
        ;;
    --help)
      args+=("-h")
      shift
      ;;
    --version)
      args+=("-v")
      shift
      ;;
    --man)
      args+=("-m")
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
      args+=("$1")
      shift
      ;;
  esac
done
# Restore positional parameters
set -- "${args[@]}"

while getopts :d:t:a:s:I:B:M:E:UP:mnuhv opt
do
	case $opt in
	(d) date=$OPTARG;;
	(t) title=$OPTARG;;
	(a) author=$OPTARG;;
    (s) shiftsec=$OPTARG;;
	(I) itxt="$OPTARG§$itxt";;
	(B) btxt="$OPTARG§$btxt";;
	(M) mtxt="$OPTARG§$mtxt";;
	(E) etxt="$OPTARG§$etxt";;
	(P) ptxt="$OPTARG§$ptxt";;
    (m) manstyle=1;;
    (n) numbered=1;; 
    (u) usage; exit;;
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
 -v manstyle="$manstyle" \
 -v numbered="$numbered" \
 -v itxt="$itxt" \
 -v btxt="$btxt" \
 -v mtxt="$mtxt" \
 -v etxt="$etxt" \
 -v ptxt="$ptxt" \
 -v shiftsec=$shiftsec '
BEGIN {

in_verb = 0  # Flag indicating if in display block

pbl   = 0  # previous blank line
ls    = 0  # line start index
pls   = 0  # previous line start index
pnzls = 0  # previous non zero line start index
eoff  = 0

# Levels of nested list-like environments
levels[1] = "n"
levels[2] = "n"
levels[3] = "n"
levels[4] = "n"
levels[5] = "n"

NUMBERED SECTIONS
# UNNUMBERED FOR MAN PAGE
if(manstyle==1){
    secnum="*"
}else{
    if (numbered==1){
        secnum=""
    }else{
        secnum="*"
    }
}


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
    while (lind()>0){end_list()}

    # IF PRECEDING SECTION WAS SYNOPSIS THEN CLOSE TEXTTT ENV
    if(manstyle==1 && section == "SYNOPSIS"){print "}"}
    
    # Reset all counters
    levels[1] = "n"
    levels[2] = "n"
    levels[3] = "n"
    levels[4] = "n"
    levels[5] = "n"

    ls = 0		# line start index
    pls = 0		# previous line start index
    pnzls = 0	# previous non zero line start index
   
    # ESCAPE ALL SPECIALS CHARACTERS
    $0 = fmtmath($0)

    # SHIFT SECTION LEVEL
    if (shiftsec == 1) {
        print "\\subsection"secnum"{"$0"}"
    }else if (shiftsec == 2){
        print "\\subsubsection"secnum"{"$0"}"
    }else{
        print "\\section"secnum"{"$0"}"
    }

    # FORMAT SYNOPSIS AS MONOSPACE FONT FOR MAN PAGE
    sub(/^ +/,"", $0) # Remove leading spaces
    sub(/ +$/,"",$0)     # Remove trailing spaces
    section=$0
    if(manstyle==1 && section == "SYNOPSIS"){print "{\\ttfamily"}
    next
}


# DESCRIPTIONS
/[^ ]  +/ {
    if (in_verb == 0) {
        cind()
        if (lind() == 0 || ls>pls){
            start_list("description")
        }
        if (lind()>1 && ls<pls){end_list()}
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
            start_list("itemize")
        }
        if (lind()>1 && ls<pls){end_list()}
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
            start_list("enumerate")
        }
        if (lind()>1 && ls<pls){end_list()}
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
        while(lind()>0){end_list()}
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
        end_list()
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
    gsub(/TeX/, "\\TeX\\ ", s)
    gsub(/La\\TeX\\/, "\\LaTeX\\ ", s)
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
    
    pattern = "https?:\/\/([^ ]+)"
    if (match(line, pattern, m)>0){
        line = sout
        sout = ""
        text=""
        while (match(line, pattern, m)) {
            url = m[0]
            label = m[1]
            text = substr(line, i, i+RSTART-1)
            line = substr(line, RSTART + RLENGTH)
            sub(/\.$/,"",url)
            sub(/)$/,"",url)
            text = ibme(text)
            url = "\\href{"url"}{"label"} "
            sout = sout text url
        }
        sout = sout line
    }
    else{
        sout = ibme(sout)
    }

    return sout
}

function ibme(s)
{
    split(itxt, tt, "§")
        for (i in tt)
            if (tt[i] != "")
                gsub(tt[i], "\\textit{&}", s)
    split(btxt, tt, "§")
        for (i in tt)
            if (tt[i] != "")
                gsub(tt[i], "\\textbf{&}", s)
    split(mtxt, tt, "§")
        for (i in tt)
            if (tt[i] != "")
                gsub(tt[i], "\\texttt{&}", s)
    split(etxt, tt, "§")
        for (i in tt)
            if (tt[i] != "")
                gsub(tt[i], "\\emph{&}", s)
    return s
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

function end_list(){
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
}

function start_list(env){
    n = lind()
    levels[n+1] = env
    print "\\begin{"env"}"
}

function start_article(title,author,date) { 
    print "\\documentclass[10pt,notitlepage]{article}" 
    print "\\usepackage[utf8]{inputenc}"
    print "\\usepackage[T1]{fontenc}"
    print "\\usepackage{url}"
    print "\\usepackage{hyperref}"
    split(ptxt, tt, "§")
        for (i in tt)
            if (tt[i] != "")
                print tt[i]
    print "\\title{"title"}"
    print "\\author{"author"}"
    print "\\date{"date"}"
    if (manstyle == 1){
        print "\\usepackage[margin=2cm]{geometry}"
        print "\\usepackage{titlesec}"
        print "\\usepackage{enumitem}"
        print "\\usepackage{times}"
        print "\\setlength{\\parskip}{0.5\\baselineskip}"
        print "\\setlength{\\parindent}{0pt}"
        print "\\setlength{\\leftskip}{3.5em}"
        print "\\titlespacing*{\\section}{0pt}{\\baselineskip}{-0.2\\baselineskip}"

        print "\\setlist[itemize]{leftmargin=7em, labelsep=0.5em}"
        print "\\setlist[enumerate]{leftmargin=7em, labelsep=0.5em}"
        print "\\setlist[description]{labelindent=3.5em, leftmargin=7em, labelsep=1em, itemsep=0em,}"
    }
}

function start_document() { print "\\begin{document}\n\\maketitle\n" }

function end_document() { print "\\end{document}" }
' | eval $post
