
package provide pdtk_text 0.1

# these procs are currently all in the global namespace because all of them
# are used by 'pd' and therefore need to be in the global namespace.

# create a new text object (ie. obj, msg, comment)
# the initializing string ends in an extra space.  This is done in case
# the last character should have been a backslash ('\') which would have
# had the effect of escaping the closing brace.  We trim off the last
# character in the string to compensate via [string range].
proc pdtk_text_new {tkcanvas tags x y text font_size color} {
    set text [subst -nocommands -novariables $text]
    $tkcanvas create text $x $y -tags $tags \
        -text [string range $text 0 end-1] \
            -fill $color -anchor nw -font [get_font_for_size $font_size]
    set mytag [lindex $tags 0]
    $tkcanvas bind $mytag <Home> "$tkcanvas icursor $mytag 0"
    $tkcanvas bind $mytag <End>  "$tkcanvas icursor $mytag end"
    # select all
    $tkcanvas bind $mytag <Triple-ButtonRelease-1>  \
        "pdtk_text_selectall $tkcanvas $mytag"
    if {$::windowingsystem eq "aqua"} { # emacs bindings for Mac OS X
        $tkcanvas bind $mytag <Control-a> "$tkcanvas icursor $mytag 0"
        $tkcanvas bind $mytag <Control-e> "$tkcanvas icursor $mytag end"
    }
}

# change the text in an existing text box
proc pdtk_text_set {tkcanvas tag text} {
    set text [subst -nocommands -novariables $text]
    $tkcanvas itemconfig $tag -text [string range $text 0 end-1]
}

# paste into an existing text box by literally "typing" the contents of the
# clipboard, i.e. send the contents one character at a time via 'pd key'
proc pdtk_pastetext {tkcanvas} {
    if { [catch {set pdtk_pastebuffer [clipboard get]}] } {
        # no selection... do nothing
    } else {
        for {set i 0} {$i < [string length $pdtk_pastebuffer]} {incr i 1} {
            set cha [string index $pdtk_pastebuffer $i]
            scan $cha %c keynum
            pdsend "[winfo toplevel $tkcanvas] key 1 $keynum 0"
        }
    }
}

# select all of the text in an existing text box
proc pdtk_text_selectall {tkcanvas mytag} {
    if {$::editmode([winfo toplevel $tkcanvas])} {
        $tkcanvas select from $mytag 0
        $tkcanvas select to $mytag end
    }
}

# de/activate a text box for editing based on $editing flag
proc pdtk_text_editing {mytoplevel tag editing} {
    set tkcanvas [tkcanvas_name $mytoplevel]
    if {$editing == 0} {selection clear $tkcanvas}
    $tkcanvas focus $tag
    set ::editingtext($mytoplevel) $editing
}
