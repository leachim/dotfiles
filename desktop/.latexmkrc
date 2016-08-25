############

## pdflatex
# The name of the LaTeX program that produces PDF files by default
$pdflatex = "lualatex %O %S";
#$pdflatex = "pdflatex --shell-escape %O %S";
#$pdflatex = "xelatex %O %S";
$pdf_mode = 1; $postscript_mode = $dvi_mode = 0;

# If nonzero, continue processing past minor LaTeX errors.  This option is made nonzero if the -pvc command line option is used.
$force_mode = 1;

# Use if -pvc ($preview_continuous_mode) is NOT active, so that terminal can launch previewer.  Otherwise, a conflict exists.
#$preview_mode = 1;
# -pvc equivalent.  If nonzero, run a previewer to view the document and keep the DVI file up to date.
$preview_continuous_mode = 1;

# Extra file extensions to remove when cleaning
$clean_ext = 'synctex.gz synctex.gz(busy) %R.synctex.gz acn acr alg aux %R.aux bbl bcf blg brf d fdb_latexmk glg glo gls glsdefs idx ilg ind ist lof log lot lox nav nlo nls out run.xml toc dvi bbl rel snm vrb';

# The command to invoke a PDF previewer
$pdf_previewer = 'evince'
#$pdf_previewer 'acroread'

# $pdf_previewer = 'open -a /Applications/Adobe\ Acrobat\ 9\ Pro/Adobe\ Acrobat\ Pro.app';
# $pdf_previewer = '"C:\Program Files\SumatraPDF\SumatraPDF.exe" %O %S'; # windows
# $pdf_previewer = "start open -a preview %O %S";
# $pdf_previewer = 'open -a skim'; # MacOS

