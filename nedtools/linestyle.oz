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


class Linestyle

   feat
      top32_fra36_lab42
      top32_fra37_fra46_01
      top32_fra36_lab41
      top32_fra36_fra64
      top32_fra36
      top32_fra36_fra64_sca65
      top32
      top32_can52
      top32_fra36_fra43_01
      top32_fra36_fra43
      top32_fra37_fra47_02
      top32_fra37_fra47_01
      top32_fra38_can50
      top32_fra37_fra47
      top32_fra36_fra43_02
      top32_fra53
      top32_fra53_but54
      top32_fra38
      top32_fra53_but55
      top32_fra38_lab48
      top32_fra37
      top32_fra37_lab45
      top32_fra38_but49
      top32_fra37_fra46_02
      top32_fra37_fra46

   meth init
      skip
   end

   meth top32(delete:Delproc <=proc{$} {self.top32 tkClose} end
                 ...) = M
      case {HasFeature M parent} then
         self.top32=M.parent
      else
         self.top32={New Tk.toplevel tkInit(delete:Delproc
            )}
      end
      {Tk.send wm(focusmodel self.top32 passive)}
      {Tk.send wm(geometry self.top32 '339x369+240+302')}
      {Tk.send wm(maxsize self.top32 1265 994)}
      {Tk.send wm(minsize self.top32 1 1)}
      {Tk.send wm(overrideredirect self.top32 0)}
      {Tk.send wm(resizable self.top32 1 1)}
      {Tk.send wm(deiconify self.top32)}
      {Tk.send wm(title self.top32 "Line Style")}
      self.top32_fra36={New Tk.frame tkInit(parent:self.top32
					    borderwidth:2
					    height:52
					    width:125)}
      self.top32_fra36_lab41={New Tk.label tkInit(parent:self.top32_fra36
						  borderwidth:1  text:'Dash')}
      self.top32_fra36_lab42={New Tk.label tkInit(parent:self.top32_fra36
						  borderwidth:1 text:'Width')}
      self.top32_fra36_fra43={New Tk.frame tkInit(parent:self.top32_fra36
						  borderwidth:1 height:30
						  relief:raised width:22)}
      self.top32_fra36_fra43_01={New Tk.scrollbar tkInit(parent:self.top32_fra36_fra43
							 borderwidth:1 orient:vert width:10)}
      self.top32_fra36_fra43_02={New Tk.canvas tkInit(parent:self.top32_fra36_fra43
						      background:white borderwidth:2
						      height:58 relief:ridge width:100)}
      self.top32_fra36_fra64={New Tk.frame tkInit(parent:self.top32_fra36
						  borderwidth:2 height:71 width:53)}
      self.top32_fra36_fra64_sca65={New Tk.scale tkInit(parent:self.top32_fra36_fra64
							'from':1.0 sliderlength:20 to:10.0
							width:12)}
      self.top32_fra37={New Tk.frame tkInit(parent:self.top32
					    borderwidth:2 height:75 width:125)}
      self.top32_fra37_lab45={New Tk.label tkInit(parent:self.top32_fra37
						  text:'Arrows')}
      self.top32_fra37_fra46={New Tk.frame tkInit(parent:self.top32_fra37
						  borderwidth:1 height:30 relief:raised
						  width:30)}
      self.top32_fra37_fra46_01={New Tk.scrollbar tkInit(parent:self.top32_fra37_fra46
							 borderwidth:1 orient:vert width:10)}
      self.top32_fra37_fra46_02={New Tk.canvas tkInit(parent:self.top32_fra37_fra46
						      background:white borderwidth:2
						      height:76 relief:ridge width:100 )}
      self.top32_fra37_fra47={New Tk.frame tkInit(
         parent:self.top32_fra37
         borderwidth:1 height:30 relief:raised width:30)}
      self.top32_fra37_fra47_01={New Tk.scrollbar tkInit(
         parent:self.top32_fra37_fra47
         borderwidth:1 orient:vert width:10)}
      self.top32_fra37_fra47_02={New Tk.canvas tkInit(
         parent:self.top32_fra37_fra47
         background:white borderwidth:2 height:76 relief:ridge width:90 )}
      self.top32_fra38={New Tk.frame tkInit(
         parent:self.top32
         borderwidth:2 height:25 width:125)}
      self.top32_fra38_lab48={New Tk.label tkInit(
         parent:self.top32_fra38
         borderwidth:1 text:'Color')}
      self.top32_fra38_but49={New Tk.button tkInit(
         parent:self.top32_fra38
         padx:11 pady:4 text:'Others')}
      self.top32_fra38_can50={New Tk.canvas tkInit(
         parent:self.top32_fra38
         background:white borderwidth:2 height:52 relief:ridge width:208)}
      self.top32_can52={New Tk.canvas tkInit(
         parent:self.top32
         background:white borderwidth:2 height:44 relief:ridge width:355)}
      self.top32_fra53={New Tk.frame tkInit(
         parent:self.top32
          borderwidth:2 height:75 width:125)}
      self.top32_fra53_but54={New Tk.button tkInit(parent:self.top32_fra53
						   padx:11 pady:4 text:'Ok')}
      self.top32_fra53_but55={New Tk.button tkInit(parent:self.top32_fra53
						   padx:11 pady:4 text:'Cancel')}
     {Tk.send pack(self.top32_fra36 'in':self.top32 anchor:center expand:true fill:both ipadx:5 pady:2 side:top)}
     {Tk.send grid(columnconf self.top32_fra36 0 weight:1)}
     {Tk.send grid(self.top32_fra36_lab41 'in':self.top32_fra36 column:0 row:0 columnspan:1 rowspan:1 padx:10 sticky:w)}
     {Tk.send grid(self.top32_fra36_lab42 'in':self.top32_fra36 column:1 row:0 columnspan:1 rowspan:1)}
     {Tk.send grid(self.top32_fra36_fra43 'in':self.top32_fra36 column:0 row:1 columnspan:1 rowspan:1 padx:10 sticky:ew)}
     {Tk.send grid(columnconf self.top32_fra36_fra43 0 weight:1)}
     {Tk.send grid(rowconf self.top32_fra36_fra43 0 weight:1)}
     {Tk.send grid(self.top32_fra36_fra43_01 'in':self.top32_fra36_fra43 column:1 row:0 columnspan:1 rowspan:1 sticky:ns)}
     {Tk.send grid(self.top32_fra36_fra43_02 'in':self.top32_fra36_fra43 column:0 row:0 columnspan:1 rowspan:1 sticky:nesw)}
     {Tk.send grid(self.top32_fra36_fra64 'in':self.top32_fra36 column:1 row:1 columnspan:1 rowspan:1)}
     {Tk.send place(self.top32_fra36_fra64_sca65 x:2 y:2 width:44 height:61 anchor:nw)}
     {Tk.send pack(self.top32_fra37 'in':self.top32 anchor:center expand:0 fill:x side:top)}
     {Tk.send grid(columnconf self.top32_fra37 0 weight:1)}
     {Tk.send grid(columnconf self.top32_fra37 1 weight:1)}
     {Tk.send grid(self.top32_fra37_lab45 'in':self.top32_fra37 column:0 row:0 columnspan:1 rowspan:1 padx:10 sticky:w)}
     {Tk.send grid(self.top32_fra37_fra46 'in':self.top32_fra37 column:0 row:1 columnspan:1 rowspan:1 padx:10 sticky:ew)}
     {Tk.send grid(columnconf self.top32_fra37_fra46 0 weight:1)}
     {Tk.send grid(rowconf self.top32_fra37_fra46 0 weight:1)}
     {Tk.send grid(self.top32_fra37_fra46_01 'in':self.top32_fra37_fra46 column:1 row:0 columnspan:1 rowspan:1 sticky:ns)}
     {Tk.send grid(self.top32_fra37_fra46_02 'in':self.top32_fra37_fra46 column:0 row:0 columnspan:1 rowspan:1 sticky:nesw)}
     {Tk.send grid(self.top32_fra37_fra47 'in':self.top32_fra37 column:1 row:1 columnspan:1 rowspan:1 padx:10 sticky:ew)}
     {Tk.send grid(columnconf self.top32_fra37_fra47 1 weight:1)}
     {Tk.send grid(rowconf self.top32_fra37_fra47 0 weight:1)}
     {Tk.send grid(self.top32_fra37_fra47_01 'in':self.top32_fra37_fra47 column:0 row:0 columnspan:1 rowspan:1 sticky:ns)}
     {Tk.send grid(self.top32_fra37_fra47_02 'in':self.top32_fra37_fra47 column:1 row:0 columnspan:1 rowspan:1 sticky:nesw)}
     {Tk.send pack(self.top32_fra38 'in':self.top32 anchor:center expand:0 fill:x pady:5 side:top)}
     {Tk.send grid(columnconf self.top32_fra38 1 weight:1)}
     {Tk.send grid(self.top32_fra38_lab48 'in':self.top32_fra38 column:0 row:0 columnspan:1 rowspan:1 padx:10 sticky:ew)}
     {Tk.send grid(self.top32_fra38_but49 'in':self.top32_fra38 column:0 row:1 columnspan:1 rowspan:1 padx:10 sticky:w)}
     {Tk.send grid(self.top32_fra38_can50 'in':self.top32_fra38 column:1 row:0 columnspan:1 rowspan:2 padx:10 sticky:w)}
     {Tk.send pack(self.top32_can52 'in':self.top32 anchor:center expand:0 fill:x padx:10 side:top)}
     {Tk.send pack(self.top32_fra53 'in':self.top32 anchor:center expand:1 fill:both ipady:5 padx:10 side:top)}
     {Tk.send pack(self.top32_fra53_but54 'in':self.top32_fra53 anchor:s expand:0 fill:none pady:5 side:left)}
     {Tk.send pack(self.top32_fra53_but55 'in':self.top32_fra53 anchor:s expand:0 fill:none pady:5 side:right)}
     {Tk.addYScrollbar self.top32_fra37_fra47_02 self.top32_fra37_fra47_01}
     {Tk.addYScrollbar self.top32_fra37_fra46_02 self.top32_fra37_fra46_01}
     {Tk.addYScrollbar self.top32_fra36_fra43_02 self.top32_fra36_fra43_01}
   end

end
