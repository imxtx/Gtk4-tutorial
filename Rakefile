require 'rake/clean'

require_relative 'lib/lib_sec_file.rb'
require_relative 'lib/lib_src2md.rb'


srcfiles = []
FileList['src/*.src.md'].each do |file|
  srcfiles << Sec_file.new(file)
end
srcfiles = Sec_files.new srcfiles
srcfiles.renum

mdfilenames = srcfiles.map {|srcfile| srcfile.to_md}
htmlfilenames = srcfiles.map {|srcfile| "html/"+srcfile.to_html}
texfilenames = srcfiles.map {|srcfile| "latex/"+srcfile.to_tex}

CLEAN.append(*mdfilenames)
CLEAN << "Readme.md"

# Headers or a tail which is necessary for html files.
header=<<'EOS'
<!doctype html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

<style type="text/css">
<!--
    body {width: 1080px; margin: 0 auto; font-size: large;}
    h2 {padding: 10px; background-color: #d0f0d0; }
    pre { margin: 10px; padding: 16px 10px 8px 10px; border: 2px solid silver; background-color: ghostwhite; overflow-x:scroll}
-->
</style>

    <title>gtk4 tutorial</title>
</head>
<body>
EOS

tail=<<'EOS'
</body>
</html>
EOS

file_index =<<'EOS'
<!doctype html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

<style type="text/css">
<!--
    body {width: 1080px; margin: 0px auto; font-size: large;}
    h1 {padding: 10px 20px 10px 20px; background-color: #e0f0f0}
    li {margin: 10px 0px 10px 0px; font-size: x-large; list-style: decimal}
-->
</style>

    <title>gtk4 tutorial</title>
</head>
<body>
<h1>Gtk4 Tutorial for beginners</h1>
<p>
This tutorial is under development and unstable.
You should be careful because there exists bugs, errors or mistakes.
</p>
<ul>
EOS

# tasks

task default: :md

task md: mdfilenames+["Readme.md"]

file "Readme.md" do
  buf = [ "# Gtk4 Tutorial for beginners\n", "\n" ]
  buf << "This tutorial is under development and unstable.\n"
  buf << "You should be careful because there exists bugs, errors or mistakes.\n"
  buf << "\n"
  0.upto(srcfiles.size-1) do |i|
    h = File.open(srcfiles[i].path) { |file| file.readline }
    h = h.gsub(/^#* */,"").chomp
    buf << "- [#{h}](#{srcfiles[i].to_md})\n"
  end
  File.write("Readme.md", buf.join)
end

0.upto(srcfiles.size - 1) do |i|
  file srcfiles[i].to_md => (srcfiles[i].c_files << srcfiles[i].path) do
    src2md srcfiles[i].path, srcfiles[i].to_md
    if srcfiles.size == 1
      nav = "Up: [Readme.md](Readme.md)\n"
    elsif i == 0
      nav = "Up: [Readme.md](Readme.md),  Next: [Section 2](#{srcfiles[1].to_md})\n"
    elsif i == srcfiles.size - 1
      nav = "Up: [Readme.md](Readme.md),  Prev: [Section #{i}](#{srcfiles[i-1].to_md})\n"
    else
      nav = "Up: [Readme.md](Readme.md),  Prev: [Section #{i}](#{srcfiles[i-1].to_md}), Next: [Section #{i+2}](#{srcfiles[i+1].to_md})\n"
    end
    buf = IO.readlines srcfiles[i].to_md
    buf.insert(0, nav, "\n")
    buf.append("\n", nav)
    IO.write srcfiles[i].to_md, buf.join
  end
end

task html: htmlfilenames+["html/index.html"]

file "html/index.html" do
  0.upto(srcfiles.size-1) do |i|
    h = File.open(srcfiles[i].path) { |file| file.readline }
    h = h.gsub(/^#* */,"").chomp
    file_index = file_index + "<li> <a href=\"#{srcfiles[i].to_html}\">#{h}</a> </li>\n"
  end
  file_index += ("</ul>\n" + tail)
  IO.write("html/index.html",file_index)
end

0.upto(srcfiles.size - 1) do |i|
  file "html/"+srcfiles[i].to_html => (srcfiles[i].c_files << srcfiles[i].path) do
    src2md srcfiles[i].path, "html/"+srcfiles[i].to_md
    sh "pandoc -o html/#{srcfiles[i].to_html} html/#{srcfiles[i].to_md}"
    File.delete("html/#{srcfiles[i].to_md}")
    if srcfiles.size == 1
      nav = "Up: <a href=\"index.html\">index.html</a>\n"
    elsif i == 0
      nav = "Up: <a href=\"index.html\">index.html</a>,  "
      nav += "Next: <a href=\"sec2.html\">Section 2</a>\n"
    elsif i == srcfiles.size - 1
      nav = "Up: <a href=\"index.html\">index.html</a>,  "
      nav += "Prev: <a href=\"#{srcfiles[i-1].to_html}\">Section #{i}</a>\n"
    else
      nav = "Up: <a href=\"index.html\">index.html</a>,  "
      nav += "Prev: <a href=\"#{srcfiles[i-1].to_html}\">Section #{i}</a>, "
      nav += "Next: <a href=\"#{srcfiles[i+1].to_html}\">Section #{i+2}</a>\n"
    end
    buf = IO.readlines "html/"+srcfiles[i].to_html
    buf.insert(0, header, nav, "\n")
    buf.append("\n", nav, "\n", tail)
    IO.write "html/"+srcfiles[i].to_html, buf.join
  end
end

task :clean
task :cleanhtml do
  sh "rm html/*"
end
