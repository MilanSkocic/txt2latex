<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="" xml:lang="">
<head>
  <meta charset="utf-8" />
  <meta name="generator" content="pandoc" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
  <title>t002.txt</title>
  <style>
    html {
      color: #1a1a1a;
      background-color: #fdfdfd;
    }
    body {
      margin: 0 auto;
      max-width: 36em;
      padding-left: 50px;
      padding-right: 50px;
      padding-top: 50px;
      padding-bottom: 50px;
      hyphens: auto;
      overflow-wrap: break-word;
      text-rendering: optimizeLegibility;
      font-kerning: normal;
    }
    @media (max-width: 600px) {
      body {
        font-size: 0.9em;
        padding: 12px;
      }
      h1 {
        font-size: 1.8em;
      }
    }
    @media print {
      html {
        background-color: white;
      }
      body {
        background-color: transparent;
        color: black;
        font-size: 12pt;
      }
      p, h2, h3 {
        orphans: 3;
        widows: 3;
      }
      h2, h3, h4 {
        page-break-after: avoid;
      }
    }
    p {
      margin: 1em 0;
    }
    a {
      color: #1a1a1a;
    }
    a:visited {
      color: #1a1a1a;
    }
    img {
      max-width: 100%;
    }
    svg {
      height: auto;
      max-width: 100%;
    }
    h1, h2, h3, h4, h5, h6 {
      margin-top: 1.4em;
    }
    h5, h6 {
      font-size: 1em;
      font-style: italic;
    }
    h6 {
      font-weight: normal;
    }
    ol, ul {
      padding-left: 1.7em;
      margin-top: 1em;
    }
    li > ol, li > ul {
      margin-top: 0;
    }
    blockquote {
      margin: 1em 0 1em 1.7em;
      padding-left: 1em;
      border-left: 2px solid #e6e6e6;
      color: #606060;
    }
    code {
      font-family: Menlo, Monaco, Consolas, 'Lucida Console', monospace;
      font-size: 85%;
      margin: 0;
      hyphens: manual;
    }
    pre {
      margin: 1em 0;
      overflow: auto;
    }
    pre code {
      padding: 0;
      overflow: visible;
      overflow-wrap: normal;
    }
    .sourceCode {
     background-color: transparent;
     overflow: visible;
    }
    hr {
      background-color: #1a1a1a;
      border: none;
      height: 1px;
      margin: 1em 0;
    }
    table {
      margin: 1em 0;
      border-collapse: collapse;
      width: 100%;
      overflow-x: auto;
      display: block;
      font-variant-numeric: lining-nums tabular-nums;
    }
    table caption {
      margin-bottom: 0.75em;
    }
    tbody {
      margin-top: 0.5em;
      border-top: 1px solid #1a1a1a;
      border-bottom: 1px solid #1a1a1a;
    }
    th {
      border-top: 1px solid #1a1a1a;
      padding: 0.25em 0.5em 0.25em 0.5em;
    }
    td {
      padding: 0.125em 0.5em 0.25em 0.5em;
    }
    header {
      margin-bottom: 4em;
      text-align: center;
    }
    #TOC li {
      list-style: none;
    }
    #TOC ul {
      padding-left: 1.3em;
    }
    #TOC > ul {
      padding-left: 0;
    }
    #TOC a:not(:hover) {
      text-decoration: none;
    }
    code{white-space: pre-wrap;}
    span.smallcaps{font-variant: small-caps;}
    div.columns{display: flex; gap: min(4vw, 1.5em);}
    div.column{flex: auto; overflow-x: auto;}
    div.hanging-indent{margin-left: 1.5em; text-indent: -1.5em;}
    /* The extra [class] is a hack that increases specificity enough to
       override a similar rule in reveal.js */
    ul.task-list[class]{list-style: none;}
    ul.task-list li input[type="checkbox"] {
      font-size: inherit;
      width: 0.8em;
      margin: 0 0.8em 0.2em -1.6em;
      vertical-align: middle;
    }
    .display.math{display: block; text-align: center; margin: 0.5rem auto;}
  </style>
</head>
<body>
<h1 id="name">NAME</h1>
<p>txt2latex - convert flat ASCII text to LaTeX.</p>
<h1 id="synopsis">SYNOPSIS</h1>
<p>txt2latex [OPTION...] FILE</p>
<h1 id="description">DESCRIPTION</h1>
<p>txt2latex converts the input text into LaTeX.</p>
<p>txt2latex is also able to recognize and format sections, paragraphs,
lists (itemize, enumerate, description) and verbatim blocks.</p>
<p>If input file FILE is omitted, standard input is used. Result is
displayed on standard output.</p>
<p>Here is how text patterns are recognized and processed:</p>
<dl>
<dt>Sections</dt>
<dd>
<p>These headers are defined by a line in upper case, starting column 1.
Optionally, the Section name can be preceded by a blank line. This is
useful for a better visualization of the source text to be used to
generate the LaTeXsource code.</p>
</dd>
<dt>Paragraphs</dt>
<dd>
<p>They must be separated by a blank line, and left aligned.
Alternatively two blank spaces can be used to produce the same result.
This option will provide a better visualization of the source text to be
used to generate the LaTeXsource code.</p>
</dd>
<dt>Description list</dt>
<dd>
<p>The item definition is separated from the item description by at
least 2 blank spaces, even before a new line, if definition is too
long.</p>
</dd>
<dt>Bullet list</dt>
<dd>
<p>Bullet list items are defined by the first word being "-", "*" or
"o".</p>
</dd>
<dt>Enumerated list</dt>
<dd>
<p>The first word must be a number followed by a dot or a rounded
bracket.</p>
</dd>
<dt>Verbatim blocks</dt>
<dd>
<p>This paragraph type is used to display unmodified text, for example
source code. It must be separated by a blank line and be indented by a
TAB. It is primarily used to format unmodified source code. It will be
printed using verbatim environment.</p>
</dd>
<dt>Mathematics</dt>
<dd>
<p>Inline mathematics must be enclosed with a simple $ sign and
equations must be enclosed with double $ signs.</p>
</dd>
</dl>
<p>For example, <span
class="math inline"><em>E</em> = <em>m</em><em>c</em><sup>2</sup></span>
is rendered as an inline math whereas <span
class="math display"><em>E</em> = <em>m</em><em>c</em><sup>2</sup></span>
is rendered in a simple equation environment.</p>
<h1 id="options">OPTIONS</h1>
<dl>
<dt>-v, –version</dt>
<dd>
<p>Display version.</p>
</dd>
<dt>-h, –help</dt>
<dd>
<p>Display help.</p>
</dd>
<dt>-d date</dt>
<dd>
<p>Set date. Defaults to current date.</p>
</dd>
<dt>-t mytitle</dt>
<dd>
<p>Set the title. If the title is set, txt2latex will automatically add
the preambule and markups for the document</p>
</dd>
<dt>-a author</dt>
<dd>
<p>Set the author.</p>
</dd>
<dt>-s shift</dt>
<dd>
<p>Shift heading level by 0 (section), 1 (subsection), or 2
(subsection). Defaults to 0.</p>
</dd>
<dt>-I txt</dt>
<dd>
<p>Italicize txt in output. Can be specified more than once.</p>
</dd>
<dt>-B txt</dt>
<dd>
<p>Emphasize (bold) txt in output. Can be specified more than once.</p>
</dd>
<dt>-P package</dt>
<dd>
<p>Add packages or LateX commands in the preambule.</p>
</dd>
<dt>-X</dt>
<dd>
<p>Compile output with pdflatex.</p>
</dd>
</dl>
<h1 id="notes">NOTES</h1>
<p>The formatting rules are heavily inspired from txt2man(1). The
special treatment for sections NAME and SYNOPSIS performed automatically
by txt2man(1) is not done by txt2latex. Nonetheless, the objective of
txt2latex is not to parse on man-formatted plain text but to convert any
plain text to LaTeX.</p>
<p>Using the options -B and -I, you can easily format your text as it
would be done by txt2man.</p>
<h1 id="examples">EXAMPLES</h1>
<p>Simple conversion</p>
<pre><code>    $ txt2latex FILE &gt; FILE.tex
  </code></pre>
<p>Conversion with document title</p>
<pre><code>    $ txt2latex -t &quot;title&quot; -a &quot;author&quot; -I &quot;word&quot; FILE &gt; FILE.tex
</code></pre>
<p>Conversion with custom packages and direct rendering with
pdflatex</p>
<pre><code>    $ txt2latex -t &quot;title&quot; -a &quot;author&quot; -I &quot;word&quot; -P &quot;\\usepackage{ccfonts}&quot; -X FILE
</code></pre>
<h1 id="see-also">SEE ALSO</h1>
<p>txt2man(1)</p>
</body>
</html>
