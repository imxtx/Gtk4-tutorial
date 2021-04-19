# Gtk4 Tutorial for beginners

This tutorial illustrates how to write C programs with Gtk4 library.
It focuses on beginners so the contents are limited to basic things.
The table of contents are shown at the end of this abstract.

- Section 3 to 20 describes basics and the example is a simple editor `tfe` (Text File Editor).
- Section 21 to 23 describes GtkDrawingArea.
- Section 24 to 27 describes list model and list view (GtkListView, GtkGridView and GtkColumnView).
It also describes GtkExpression.

Please refer [Gnome API reference](https://developer.gnome.org/) for further topics.

This tutorial is under development and unstable.
Even though the  examples written in C language have been tested on gtk4 version 4.0,
there might exist bugs.
If you find any bugs, errors or mistakes in the tutorial and C examples,
please let me know.
You can post it to [github issues](https://github.com/ToshioCP/Gtk4-tutorial/issues).
The latest version of the tutorial is located at [Gtk4-tutorial github repository](https://github.com/ToshioCP/Gtk4-tutorial).
You can read it without download.

If you want to get a html or pdf version, you can make them with `rake`, which is a ruby version of make.
There is a [documentation](../doc/Readme_for_developers.md) how to make them.

If you have a question, feel free to post an issue.
Any question is helpful to make this tutorial get better.

## Table of contents


1. [Prerequisite and License](gfm/sec1.md)
1. [Installation of gtk4 to linux distributions](gfm/sec2.md)
1. [GtkApplication and GtkApplicationWindow](gfm/sec3.md)
1. [Widgets (1)](gfm/sec4.md)
1. [Widgets (2)](gfm/sec5.md)
1. [Widgets (3)](gfm/sec6.md)
1. [Define Child object](gfm/sec7.md)
1. [Ui file and GtkBuilder](gfm/sec8.md)
1. [Build system](gfm/sec9.md)
1. [Instance and class](gfm/sec10.md)
1. [Signals](gfm/sec11.md)
1. [Functions in TfeTextView](gfm/sec12.md)
1. [Functions in GtkNotebook](gfm/sec13.md)
1. [tfeapplication.c](gfm/sec14.md)
1. [tfe5 source files](gfm/sec15.md)
1. [Menu and action](gfm/sec16.md)
1. [Stateful action](gfm/sec17.md)
1. [Ui file for menu and action entries](gfm/sec18.md)
1. [GtkMenuButton, accelerators, font, pango and gsettings](gfm/sec19.md)
1. [Template XML](gfm/sec20.md)
1. [GtkDrawingArea and Cairo](gfm/sec21.md)
1. [Combine GtkDrawingArea and TfeTextView](gfm/sec22.md)
1. [Tiny turtle graphics interpreter](gfm/sec23.md)
1. [GtkListView](gfm/sec24.md)
1. [GtkGridView and activate signal](gfm/sec25.md)
1. [GtkExpression](gfm/sec26.md)
1. [GtkColumnView](gfm/sec27.md)
