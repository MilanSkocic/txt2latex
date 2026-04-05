#!/usr/bin/env bash

# DEFINE
PROGNAME="$APP_NAME"
PROGVERSION="0.1"
SHORTDESCRIPTION="Converts text to LaTeX."
HOMEPAGE=""
LICENSE="MIT"
MANSECTION="1"
RED="\e[31m"
BLACK="\e[0m"
GREEN="\e[32m"


help () {
cat << EOT
NAME
  $PROGNAME - convert flat ASCII text to LaTeX.

SYNOPSIS
  $PROGNAME [OPTIONS]... FILE" 

DESCRIPTION
  $PROGNAME converts the input text into LaTeX. The conversion procedure
  is strongly inspired by txt2man.

  $PROGNAME is also able to recognize and format sections, paragraphs,
  lists (standard, numbered, description, nested), literal display blocks.
  If input file FILE is omitted, standard input is used. 
  Result is displayed on standard output. 

OPTIONS
  --version, -v   Display version.
  --verbose, -V   Increase verbosity.
  --help, -h      Display help.

SEE ALSO
  txt2man(1)
EOT
}


version () {
echo "PROGRAM:      $PROGNAME                          "
echo "DESCRIPTION:  $SHORTDESCRIPTION                  "
echo "VERSION:      $PROGVERSION                       "
echo "AUTHOR:       M. Skocic                          "
echo "LICENSE:      $LICENSE                           "
}

args=$*
for i in $args; do
    case $i in
        "-V"|"--verbose")
            FLAG_VERBOSE=1
            ;;
        *)
            ;;
    esac
done

case $1 in
    "--help"|"-h")
        help 
        exit 0
        ;;
    "--version"|"-v")
        version
        exit 0
        ;;
    *)
        ;;
esac

expand $@ | awk '
BEGIN {
in_list=0
}
# SECTIONS
/^[[:upper:][:digit:]]+[[:upper:][:space:][:digit:][:punct:]]+$/ {
    end_itemize(in_list)
    print "\\section{"$0"}"
    next
}
# LISTS
/^[[:space:]]*[-*+][[:space:]].+/ {
    in_list=start_itemize(in_list,"itemize")
    sub(/[-*+]/,"")
    print "\\item"$0
    next
}
#

/^$/{
    in_list=end_itemize(in_list, "itemize")
}
{
    in_list=end_itemize(in_list, "itemize")
    print $0
}

function end_itemize(s, env)
{
    if ((s+0)==1){
        print "\\end{"env"}"
    }
    return 0
}
function start_itemize(s, env)
{
    if ((s+0)==0){
        print "\\begin{"env"}"
    }
    return 1
}
'
