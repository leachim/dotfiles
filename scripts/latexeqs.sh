#!/bin/bash

#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see .

# This program was written by Dominic Hosler 
# There is a description of how it works on my blog https://dominichosler.wordpress.com
# Please ask on the blog if you have any questions, thank you.

# Script to take an input file containing LaTeX code for an equation.
# It takes one optional argument, -v, to output the equations as vector graphics
# (pdf) or -i, to output as raster (png).
# The script will then remove the files it created (apart from the output file).

#Create temporary files for latex file
echo "Constructing LaTeX file"

echo "\documentclass{article}
\usepackage{amsmath,amssymb,bm,amsthm,bbold}
\usepackage{latexsym}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{mathrsfs}
\begin{document}
\pagestyle{empty}
\begin{equation*}" > part1_32813829813.temp

echo "\end{equation*}
\end{document}
" > part3_32813829813.temp

cat part1_32813829813.temp $1 part3_32813829813.temp > full_32813829813.temp.tex

echo "Process the LaTeX file"
lualatex -interaction=batchmode full_32813829813.temp.tex


#Test if the user has input the -v option (for vector) or -b (for bitmap)
# while getopts "vb" OPTION
# do
# case $OPTION in
# v) #In the case of vector graphics, just crop the pdf with a small margin and output to correct filename.
echo "Output set to vector graphics, pdf."
pdfcrop --margins 5 full_32813829813.temp.pdf ${1%.*}.pdf
# ;;
# b) #In the case of bitmap graphics, crop the pdf with margin
  # echo "Output set to bitmap graphics, png."
  # pdfcrop --margins 5 full.temp.pdf full.temp.cropped.pdf
  # #Then convert to a png with a high resolution for rasterisation.
  # convert -density 500 full.temp.cropped.pdf ${2%\.*}.png
  # rm full.temp.cropped.pdf
# ;;
# \?) exit 1;;
# esac
# done

#Cleanup temp files
echo "Cleanup temporary files"

rm -f part1_32813829813.temp part3_32813829813.temp full_32813829813.temp.tex full_32813829813.temp.aux full_32813829813.temp.log full_32813829813.temp.pdf
