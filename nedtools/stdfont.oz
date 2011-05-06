%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                                      %%
%% TransDraw multi-user graphic editor                                  %%
%%                                                                      %%
%%  Copyright 1998 Walloon Region of Belgium.  All Rights Reserved.     %%
%%  The development of TransDraw is supported by the PIRATES project at %%
%%  the Université catholique de Louvain.  This file is subject to the  %%
%%  general TransDraw license.                                          %%
%%                                                                      %%
%%  Author: Donatien Grolaux                                            %%
%%                                                                      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


class Stdfont

   feat
      top42_01_011
      top42_01_02_03
      top42_01_02
      top42_01_02_05_07
      top42_01_02_08
      top42_017_020
      top42_01_011_016
      top42_01_011_014
      top42_01_02_05_06
      top42_017
      top42_01_02_08_09
      top42_01_011_012
      top42
      top42_017_019
      top42_01_02_08_010
      top42_01
      top42_01_011_015
      top42_01_011_can19
      top42_01_011_013
      top42_01_02_05
      top42_017_018
      top42_01_02_04

   meth init
      skip
   end

   meth top42(delete:Delproc <=proc{$} {self.top42 tkClose} end
                 ...) = M
      case {HasFeature M parent} then
         self.top42=M.parent
      else
         self.top42={New Tk.toplevel tkInit(delete:Delproc
          bg:'#AE00B200C300'
            )}
      end
      {Tk.send wm(focusmodel self.top42 passive)}
      {Tk.send wm(geometry self.top42 '524x330+180+211')}
      {Tk.send wm(maxsize self.top42 1265 994)}
      {Tk.send wm(minsize self.top42 1 1)}
      {Tk.send wm(overrideredirect self.top42 0)}
      {Tk.send wm(resizable self.top42 1 1)}
      {Tk.send wm(deiconify self.top42)}
      {Tk.send wm(title self.top42 "Select a Font")}
      self.top42_01={New Tk.frame tkInit(
         parent:self.top42
         background:'#AE00B200C300' borderwidth:2 height:75 relief:groove width:125)}
      self.top42_01_02={New Tk.frame tkInit(
         parent:self.top42_01
         background:'#AE00B200C300' borderwidth:2 height:100 width:125)}
      self.top42_01_02_03={New Tk.label tkInit(
         parent:self.top42_01_02
         background:'#AE00B200C300' borderwidth:1 font:'-dt-interface user-medium-r-normal-m*-*-*-*-*-*-*-*-*' foreground:'#000000000000' text:'Fonts')}
      self.top42_01_02_04={New Tk.label tkInit(
         parent:self.top42_01_02
         background:'#AE00B200C300' borderwidth:1 font:'-dt-interface user-medium-r-normal-m*-*-*-*-*-*-*-*-*' foreground:'#000000000000' text:'Size')}
      self.top42_01_02_05={New Tk.frame tkInit(
         parent:self.top42_01_02
         background:'#AE00B200C300' borderwidth:1 height:30 relief:raised width:30)}
      self.top42_01_02_05_06={New Tk.listbox tkInit(
         parent:self.top42_01_02_05
         background:'#AE00B200C300' font:'-Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-*' foreground:'#000000000000' )}
      self.top42_01_02_05_07={New Tk.scrollbar tkInit(
         parent:self.top42_01_02_05
         background:'#AE00B200C300' borderwidth:1 orient:vert width:10)}
      self.top42_01_02_08={New Tk.frame tkInit(
         parent:self.top42_01_02
         background:'#AE00B200C300' borderwidth:1 height:30 relief:raised width:30)}
      self.top42_01_02_08_09={New Tk.listbox tkInit(
         parent:self.top42_01_02_08
         background:'#AE00B200C300' font:'-Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-*' foreground:'#000000000000' width:8 )}
      self.top42_01_02_08_010={New Tk.scrollbar tkInit(
         parent:self.top42_01_02_08
         background:'#AE00B200C300' borderwidth:1 orient:vert width:10)}
      self.top42_01_011={New Tk.frame tkInit(
         parent:self.top42_01
         background:'#AE00B200C300' borderwidth:2 height:60 width:125)}
      self.top42_01_011_012={New Tk.label tkInit(
         parent:self.top42_01_011
         background:'#AE00B200C300' borderwidth:1 font:'-dt-interface user-medium-r-normal-m*-*-*-*-*-*-*-*-*' foreground:'#000000000000' text:'Sample')}
      self.top42_01_011_013={New Tk.checkbutton tkInit(
         parent:self.top42_01_011
         background:'#AE00B200C300' font:'-dt-interface user-medium-r-normal-m*-*-*-*-*-*-*-*-*' foreground:'#000000000000' highlightthickness:0 text:'Bold' variable:'che60')}
      self.top42_01_011_014={New Tk.checkbutton tkInit(
         parent:self.top42_01_011
         background:'#AE00B200C300' font:'-dt-interface user-medium-r-normal-m*-*-*-*-*-*-*-*-*' foreground:'#000000000000' highlightthickness:0 text:'Italic' variable:'che61')}
      self.top42_01_011_015={New Tk.checkbutton tkInit(
         parent:self.top42_01_011
         background:'#AE00B200C300' font:'-dt-interface user-medium-r-normal-m*-*-*-*-*-*-*-*-*' foreground:'#000000000000' highlightthickness:0 text:'Underline' variable:'che62')}
      self.top42_01_011_016={New Tk.canvas tkInit(
         parent:self.top42_01_011
         background:'#AE00B200C300' borderwidth:2 height:62 relief:ridge width:202)}
      self.top42_01_011_can19={New Tk.canvas tkInit(
         parent:self.top42_01_011
         background:'#AE00B200C300' borderwidth:2 height:20 highlightthickness:0 selectborderwidth:0 width:249)}
      self.top42_017={New Tk.frame tkInit(
         parent:self.top42
         background:'#AE00B200C300' borderwidth:2 height:75 width:125)}
      self.top42_017_018={New Tk.button tkInit(
         parent:self.top42_017
         background:'#AE00B200C300' font:'-dt-interface user-medium-r-normal-m*-*-*-*-*-*-*-*-*' foreground:'#000000000000' padx:11 pady:4 text:'Ok')}
      self.top42_017_019={New Tk.button tkInit(
         parent:self.top42_017
         background:'#AE00B200C300' font:'-dt-interface user-medium-r-normal-m*-*-*-*-*-*-*-*-*' foreground:'#000000000000' padx:11 pady:4 text:'Cancel')}
      self.top42_017_020={New Tk.button tkInit(
         parent:self.top42_017
         background:'#AE00B200C300' font:'-dt-interface user-medium-r-normal-m*-*-*-*-*-*-*-*-*' foreground:'#000000000000' padx:11 pady:4 text:'Unix')}
     {Tk.send pack(self.top42_01 'in':self.top42 anchor:center expand:1 fill:both side:left)}
     {Tk.send grid(columnconf self.top42_01 0 weight:1)}
     {Tk.send grid(rowconf self.top42_01 0 weight:1)}
     {Tk.send grid(rowconf self.top42_01 1 weight:1)}
     {Tk.send grid(self.top42_01_02 'in':self.top42_01 column:0 row:0 columnspan:1 rowspan:1 sticky:nesw)}
     {Tk.send grid(columnconf self.top42_01_02 0 weight:1)}
     {Tk.send grid(rowconf self.top42_01_02 1 weight:1)}
     {Tk.send grid(self.top42_01_02_03 'in':self.top42_01_02 column:0 row:0 columnspan:1 rowspan:1 padx:10 sticky:w)}
     {Tk.send grid(self.top42_01_02_04 'in':self.top42_01_02 column:1 row:0 columnspan:1 rowspan:1 padx:10 sticky:w)}
     {Tk.send grid(self.top42_01_02_05 'in':self.top42_01_02 column:0 row:1 columnspan:1 rowspan:1 padx:10 sticky:nesw)}
     {Tk.send grid(columnconf self.top42_01_02_05 0 weight:1)}
     {Tk.send grid(rowconf self.top42_01_02_05 0 weight:1)}
     {Tk.send grid(self.top42_01_02_05_06 'in':self.top42_01_02_05 column:0 row:0 columnspan:1 rowspan:1 sticky:nesw)}
     {Tk.send grid(self.top42_01_02_05_07 'in':self.top42_01_02_05 column:1 row:0 columnspan:1 rowspan:1 sticky:ns)}
     {Tk.send grid(self.top42_01_02_08 'in':self.top42_01_02 column:1 row:1 columnspan:1 rowspan:1 padx:10 sticky:nesw)}
     {Tk.send grid(columnconf self.top42_01_02_08 0 weight:1)}
     {Tk.send grid(rowconf self.top42_01_02_08 0 weight:1)}
     {Tk.send grid(self.top42_01_02_08_09 'in':self.top42_01_02_08 column:0 row:0 columnspan:1 rowspan:1 sticky:nesw)}
     {Tk.send grid(self.top42_01_02_08_010 'in':self.top42_01_02_08 column:1 row:0 columnspan:1 rowspan:1 sticky:ns)}
     {Tk.send grid(self.top42_01_011 'in':self.top42_01 column:0 row:1 columnspan:1 rowspan:1 pady:5 sticky:nesw)}
     {Tk.send grid(columnconf self.top42_01_011 1 weight:1)}
     {Tk.send grid(rowconf self.top42_01_011 3 weight:1)}
     {Tk.send grid(self.top42_01_011_012 'in':self.top42_01_011 column:1 row:0 columnspan:1 rowspan:1 padx:10 sticky:w)}
     {Tk.send grid(self.top42_01_011_013 'in':self.top42_01_011 column:0 row:1 columnspan:1 rowspan:1 padx:10 sticky:w)}
     {Tk.send grid(self.top42_01_011_014 'in':self.top42_01_011 column:0 row:2 columnspan:1 rowspan:1 padx:10 sticky:w)}
     {Tk.send grid(self.top42_01_011_015 'in':self.top42_01_011 column:0 row:3 columnspan:1 rowspan:1 padx:10 sticky:nw)}
     {Tk.send grid(self.top42_01_011_016 'in':self.top42_01_011 column:1 row:1 columnspan:1 rowspan:3 padx:10 sticky:nesw)}
     {Tk.send grid(self.top42_01_011_can19 'in':self.top42_01_011 column:0 row:4 columnspan:2 rowspan:1 padx:10 sticky:nesw)}
     {Tk.send pack(self.top42_017 'in':self.top42 anchor:center expand:0 fill:y side:right)}
     {Tk.send pack(self.top42_017_018 'in':self.top42_017 anchor:center expand:0 fill:x padx:5 pady:5 side:top)}
     {Tk.send pack(self.top42_017_019 'in':self.top42_017 anchor:center expand:0 fill:none padx:5 pady:5 side:top)}
     {Tk.send pack(self.top42_017_020 'in':self.top42_017 anchor:center expand:0 fill:x padx:5 pady:5 side:bottom)}
     {Tk.addYScrollbar self.top42_01_02_08_09 self.top42_01_02_08_010}
     {Tk.addYScrollbar self.top42_01_02_05_06 self.top42_01_02_05_07}
   end

end
