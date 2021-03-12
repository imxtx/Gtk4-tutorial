# lib_src2md.rb
require 'pathname'

# The method 'src2md' converts .src.md file into .md file.
# The outputed .md file is fit for the final format, which is one of markdown, html and latex.
# - Links to relative URL are removed for latex. Otherwise, it remains.
#   See "Hyperref and relative link" below for further explanation.
# - Width and height for images are removed for markdown and html. it remains for latex.
#    ![sample](sample_image){width=10cm height=5cm} => ![sample](sample_image)    for markdown and html

# ---- Hyperref and relative link ----
# Hyperref package makes internal link possible.
# The target of the link is made with '\hypertarget' command.
# And the link is made with '\hyperlink' command.
# For example,
#  (sec11.tex)
#   \hyperlink{tfeapplication.c}{Section 13}
#   ... ...
#  (sec13.tex)
#   \hypertarget{tfeapplication.c}{%
#   \section{tfeapplication.c}\label{tfeapplication.c}}
# If you click the text 'Section 13' in sec11.tex, then you can move to '13 tfeapplication.c' ("13 " is automatically added by latex), which is section 13 in sec13.tex.

# The following lines are the original one in sec11.md and the result in sec11.tex, which is generated by pandoc.
#  (sec11.md)
#   All the source files are listed in [Section 13](sec13.tex).
#  (sec11.tex)
#   All the source files are listed in \href{sec13.tex}{Section 13}.
# Therefore, if you want to correct the link in sec11.tex, you need to do the followings.
# 1. Look at the first line of sec13.md and get the section heading (tfeapplication.c).
# 2. substitute "\hyperlink{tfeapplication.c}{Section 13}" for "\href{sec13.tex}{Section 13}".

# The following lines are another conversion case by pandoc.
#  (sec7.md)
#   The source code of `tfe3.c` is stored in [src/tfe](../src/tfe) directory.
#  (sec7.tex)
#   The source code of \texttt{tfe3.c} is stored in \href{../src/tfe}{src/tfe} directory.
# The pdf file generated by pdflatex recognizes that the link 'href{../src/tfe}' points a pdf file '../src/tfe.pdf'.
# To avoid generating such incorrect links, it is good to remove the links from the original markdown file.

# If the target is full URL, which means absolute URL begins with "http", no problem happens.

# This script just remove the links if its target is relative URL if the target is latex.
# If you want to revive the link with relative URL, refer the description above.

# This script uses "fenced code blocks" for verbatim lines.
# It is available in GFM and pandoc's markdown but not in original markdown.
# Two characters backtick (`) and tilde (~) are possible for fences.
# This script uses tilde because info string cannot contain any backticks for the backtick code fence.
# Info string follows opening fence and it is usually a language name.

# GFM has fence code block as follows.
# ~~~C
# int main (int argc, char **argv) {
# ........
# ~~~
# Then the contents are highlighted based on C language syntax.
# This script finds the language by the suffix of the file name.
# .c => C, .h => C, .rb => ruby, Rakefile, => ruby, .xml => xml, .ui => xml, .y => bison, .lex => lex, .build => meson, .md => markdown
# Makefile => makefile

# Pandoc's markdown is a bit different.
# ~~~{.C .numberLines}
# int main (int argc, char **argv) {
# ........
# ~~~
# Then the contents are highlighted based on C language syntax and line numbers are added.
# Pandoc supports C, ruby, xml, bison, lex, markdown and makefile languages, but doesn't meson.
#
# After a markdown file is converted to a latex file, listings package is used by lualatex to convert it to a pdf file.
# Listings package supports only C, ruby, xml and make.
# Bison, lex, markdown and meson aren't supported.

def src2md srcmd, md, type="gfm"
# parameters:
#  srcmd: .src.md file's path. source
#  md:    .md file's path. destination
  src_buf = IO.readlines srcmd
  src_dir = File.dirname srcmd
  md_dir = File.dirname md
  type_dir = File.basename md_dir # type of the target. gfm, html or latex
  if type_dir == "gfm" || type_dir == "html" || type_dir == "latex"
    type = type_dir
  end

# phase 1
# @@@if - @@@elif - @@@else - @@@end
  md_buf = []
  if_stat = 0
  src_buf.each do |line|
    if line =~ /^@@@if *(\w+)/ && if_stat == 0
      if_stat = type == $1 ? 1 : -1
    elsif line =~ /^@@@elif *(\w+)/
      if if_stat == 1
        if_stat = -2
      elsif if_stat == -1
        if_stat = type == $1 ? 3 : -3
      elsif if_stat == -2
        # if_stat is kept to be -2
      elsif if_stat == 3
        if_stat = -2
      elsif if_stat == -3
        if_stat = type == $1 ? 3 : -3
      end
    elsif line =~ /^@@@else/
      if if_stat == 1
        if_stat = -2
      elsif if_stat == -1
        if_stat = 2
      elsif if_stat == -2
        # if_stat is kept to be -2
      elsif if_stat == 3
        if_stat = -2
      elsif if_stat == -3
        if_stat = 2
      end
    elsif line =~ /^@@@end/
      if_stat = 0
    elsif if_stat >= 0
      md_buf << line
    end
  end

# phase 2
# @@@include and @@@shell
  src_buf = md_buf
  md_buf = []
  include_flag = ""
  shell_flag = false
  src_buf.each do |line|
    if include_flag == "-N" || include_flag == "-n"
      if line == "@@@\n"
        include_flag = ""
      elsif line =~ /^\s*(\S*)\s*(.*)$/
        c_file = $1
        c_functions = $2.strip.split(" ")
        if c_file =~ /^\// # absolute path
          c_file_buf = File.readlines(c_file)
        else #relative path
          c_file_buf = File.readlines(src_dir+"/"+c_file)
        end
        if c_functions.empty? # no functions are specified
          tmp_buf = c_file_buf
        else
          tmp_buf = []
          spc = false
          c_functions.each do |c_function|
            from = c_file_buf.find_index { |line| line =~ /^#{c_function} *\(/ }
            if ! from
              warn "lib_src2md: ERROR in #{srcmd}: Didn't find #{c_function} in #{c_file}."
              break
            end
            to = from
            while to < c_file_buf.size do
              if c_file_buf[to] == "}\n"
                break
              end
              to += 1
            end
            if to >= c_file_buf.size
              warn "lib_src2md: ERROR in #{srcmd}: function #{c_function} didn't end in #{c_file}."
              break
            end
            n = from-1
            if spc
              tmp_buf << "\n"
            else
              spc = true
            end
            while n <= to do
              tmp_buf << c_file_buf[n]
              n += 1
            end
          end
        end
        if type == "gfm"
          md_buf << "~~~#{lang(c_file, "gfm")}\n"
        elsif type == "html"
          language = lang(c_file, "pandoc")
          if include_flag == "-n"
            if language != ""
              md_buf << "~~~{.#{language} .numberLines}\n"
            else
              md_buf << "~~~{.numberLines}\n"
            end
          else
            if lang(c_file, "pandoc") != ""
              md_buf << "~~~{.#{language}}\n"
            else
              md_buf << "~~~\n"
            end
          end
        elsif type =="latex"
          language = lang(c_file, "pandoc")
          if include_flag == "-n"
            if language == "C" || language == "ruby" || language == "xml" || language == "makefile"
              md_buf << "~~~{.#{language} .numberLines}\n"
            else
              md_buf << "~~~{.numberLines}\n"
            end
          else
            if language == "C" || language == "ruby" || language == "xml" || language == "makefile"
              md_buf << "~~~{.#{language}}\n"
            else
              md_buf << "~~~\n"
            end
          end
        else
          md_buf << "~~~\n"
        end
        ln_width = tmp_buf.size.to_s.length
        n = 1
        tmp_buf.each do |l|
          if type == "gfm" && include_flag == "-n"
            l = sprintf("%#{ln_width}d %s", n, l)
          end
          md_buf << l
          n += 1
        end
        md_buf << "~~~\n"
      end
    elsif shell_flag
      if line == "@@@\n"
        md_buf << "~~~\n"
        shell_flag = false
      else
        md_buf << "$ #{line}"
        `cd #{src_dir}; #{line.chomp}`.each_line do |l|
            md_buf << l
        end
      end
    elsif line == "@@@include\n" || line =~ /^@@@include *-n/
      include_flag = "-n"
    elsif line =~ /^@@@include *-N/
      include_flag = "-N"
    elsif line == "@@@shell\n"
      md_buf << "~~~\n"
      shell_flag = true
    else
      line = change_rel_link(line, src_dir, md_dir)
      if type == "latex" # remove relative link
        line.gsub!(/(^|[^!])\[([^\]]*)\]\((?~http)\)/,"\\1\\2")
      else # type == "gfm" or "html", then remove size option from link to image files.
        line.gsub!(/(!\[[^\]]*\]\([^\)]*\)) *{width *= *\d*(|\.\d*)cm *height *= *\d*(|\.\d*)cm}/,"\\1")
      end
      md_buf << line
    end
  end
  IO.write(md,md_buf.join)
end

# Change the base of relative links from org_dir to new_dir
def change_rel_link line, org_dir, new_dir
  p_new_dir = Pathname.new new_dir
  left = ""
  right = line
  while right =~ /(!?\[[^\]]*\])\(([^\)]*)\)/
    left += $`
    right = $'
    name = $1
    link = $2
    if name =~ /\[(S|s)ection (\d+)\]/
      link = "sec#{$2}.md"
    elsif ! (link =~ /^(http|\/)/)
      p_link = Pathname.new "#{org_dir}/#{link}"
      link = p_link.relative_path_from(p_new_dir).to_s
    end
    left += "#{name}(#{link})"
  end
  left + right
end

def lang file, type_of_md
  tbl = {".c" => "C", ".h" => "C", ".rb" => "ruby", ".xml" => "xml", ".ui" => "xml",
         ".y" => "bison", ".lex" => "lex", ".build" => "meson", ".md" => "markdown" }
  name = File.basename file
  if name == "Makefile"
    return "makefile"
  elsif name == "Rakefile"
    return "ruby"
  else
    suffix = File.extname name
    tbl.each do |key, val|
      if suffix == key
        return val if type_of_md == "gfm"
        return val if type_of_md == "pandoc" && val != "meson"
      end
    end
  end
  return ""
end
