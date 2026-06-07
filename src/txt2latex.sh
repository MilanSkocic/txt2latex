#!/usr/bin/env bash

# DEFINE
PROGNAME="txt2latex"
PROGVERSION="0.3.0"
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

  If the input file FILE is omitted, standard input is used. 
  The result is displayed on standard output. 

  $PROGNAME is also able to recognize sections, paragraphs,
  lists (itemize, enumerate, description), verbatim blocks, as well as
  inline math and equations.
  
  The formatting rules are heavily inspired by txt2man(1) to maximize
  compatibility with plain text written as man pages. 
  The same source text can be directly converted to 
  LaTeX without relying on intermediary conversion steps.
  Nonetheless, the main objective of $PROGNAME is not to parse man-formatted
  plain text but to convert any plain text to LaTeX. 

  The rules for processing the text patterns are defined as following:
  Sections    They are defined by a line in upper case starting at column 1.
              Preceding blank lines are allowed for better visualization.
  Paragraphs  They must be left aligned and preceded by a blank line.
              Blank spaces at the beginning of the paragraphs are allowed
              and there is no restriction on line alignement in a paragraph.
              Nonetheless, identical alignment provides a better visualization
              of the plain ASCII text. 
  Description list  
              Labels of the items are separated from the definitions
              by at least 2 blank spaces, even before a new line, if
              definition is too long.
  Itemize (bullet) list  
              Bullet list items are defined by the first character being "-",
              "*" or "o" followed by a space.
  Enumerated list  
              Enumerated lists are defined by the first character being 
              a number followed by a dot or a rounded bracket.
  Nested lists  
              Nested and mixed lists are allowed.
  Verbatim block  
              Verbatim block is used to display unmodified text such as 
              quotes of source code.
              They must be separated by a blank line and be indented 
              with respect to the previuous line.
              It will be printed using the verbatim environment.
  Mathematics  
              Inline mathematics must be enclosed with a simple $ sign
              and equations must be enclosed with double $ signs.
              For example, \$E=mc^2\$ is rendered as an inline math whereas 
                                \$\$ E=mc^2 \$\$
              is rendered in a simple equation environment.
  Tables  
              There is no support for tables.
              The workaround is put them in a verbatim block.

  Special characters #, $, %, &, _, {, }, ^, \ are protected i.e. escaped.

  Symbols such as <, >, <=, >= are converted to inline math.

  Special words such as LaTeX and TeX are turned into their equivalent 
  commands in latex.
   
OPTIONS
  -d date         Set date. Defaults to current date.
  -t mytitle      Set the title. If the title is set, txt2latex will 
                  automatically add all the markups necessary to 
                  create a standalone latex document that can be compiled 
                  with pdflatex. Xelatex and lualatex are not supported. 
  -a author       Set the author.
  -s shift        Shift heading level by 0 (section), 1 (subsection), or 2 (subsection).
                  Defaults to 0.
  -m, --man       Apply some special formatting for man pages. See NOTES.
  -I txt          Italicize txt in output. Can be specified more than once.
  -B txt          Emphasize (bold) txt in output. Can be specified more than once.
  -M txt          Monospace txt in output. Can be specified more than once.
  -P package      Add packages or LaTeX or TeX commands in the preambule.
  -v, --version   Display version.
  -h, --help      Display help.

NOTES
  The option -m is an alpha feature and fully implemented. 
  The formatting is done by applying the adequate preambule in a 
  standalone document for matching the rendering of man -Tpdf.
  For now:
    - SYNOPSIS section is formatted as monospaced text.
    - Set font to times.
    - Set correct paragraph indentation.

EXAMPLES
  Simple conversion

    $ $PROGNAME FILE > FILE.tex
  
  Conversion with document title

    $ $PROGNAME -t "title" -a "author" -I "word" FILE > FILE.tex

  Conversion with custom packages and direct rendering with pdflatex

    $ $PROGNAME -t "title" -a "author" -I "word" -P "\\\\usepackage{ccfonts}" | pdflatex -jobname="txt2latex"

  Try this command to format this text itself and to produce a pdf:

    $ txt2latex -h 2>&1 | txt2latex -t "txt2latex(1)" -a "User commands" --man | pdflatex -jobname="txt2latex"

  Compare it to the man page generated by txt2man(1):

    $ txt2latex -h 2>&1 | txt2man -s 1 -t txt2latex -v "User commands" -r $PROGVERSION | man -l -Tpdf -

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
mtxt=
post=cat
shiftsec=0
manstyle=0

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

while getopts :d:t:a:s:mI:B:M:P:hv opt
do
	case $opt in
	(d) date=$OPTARG;;
	(t) title=$OPTARG;;
	(a) author=$OPTARG;;
    (s) shiftsec=$OPTARG;;
    (m) manstyle=1;;
	(I) itxt="$OPTARG§$itxt";;
	(B) btxt="$OPTARG§$btxt";;
	(M) mtxt="$OPTARG§$mtxt";;
	(P) ptxt="$OPTARG§$ptxt";;
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
 -v itxt="$itxt" \
 -v btxt="$btxt" \
 -v mtxt="$mtxt" \
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

# UNNUMBERED FOR MAN PAGE
if(manstyle==1){
    secnum="*"
}else{
    secnum=""
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
    
        split(itxt, tt, "§")
            for (i in tt)
                if (tt[i] != "")
                    gsub(tt[i], "\\textit{&}")
        split(btxt, tt, "§")
            for (i in tt)
                if (tt[i] != "")
                    gsub(tt[i], "\\textbf{&}")
        split(mtxt, tt, "§")
            for (i in tt)
                if (tt[i] != "")
                    gsub(tt[i], "\\texttt{&}")
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
