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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Une petite classe pour afficher des fenetres avec du texte
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class Window

   feat
      win
      msg
      scroll
      closed

   meth open(Title)
      self.win={New Tk.toplevel tkInit(title:Title
				       width:100 height:50
				       delete:self#close)}
      self.msg={New Tk.listbox tkInit(parent:self.win)}
      self.scroll={New Tk.scrollbar tkInit(parent:self.win)}
      {Tk.addYScrollbar self.msg self.scroll}
      {Tk.batch [grid(self.msg row:0 column:0 sticky:nswe)
		 grid(self.scroll row:0 column:1 sticky:ns)
		 grid(columnconfigure self.win 0 weight:1)
		 grid(rowconfigure self.win 0 weight:1)]}
      {self.msg tkBind(event:'<Any-Key>'
		       action:proc{$} skip end)}
   end

   meth print(Msg)
      case {IsFree self.closed} then
	 {self.msg tk(insert 'end' Msg)}
      else skip end
   end

   meth close
      case {IsFree self.closed} then
	 {self.win tkClose}
	 self.closed=unit
      else skip end
   end
end



