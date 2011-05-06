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



class BrowseTool

   from StandardTool
   
   feat dc actport canvas client actions toolbar iconbar localize tag iconb
   
   attr browsemode toget abortdef showh histl

   prop locking
      
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % Messages recus des evenements TCL/TK
   %

   meth draw(O)
      X1 Y1 X2 Y2 Scale={self.client getscale($)} in
      {O getsize(X1 Y1 X2 Y2)}
      {self.tag tk(delete)}
      {self.dc tk(crea rect
		  X1*Scale-2.0 Y1*Scale-2.0
		  X2*Scale+2.0 Y2*Scale+2.0
		  outline:blue
		  fill:blue
		  tags:self.tag)}
      {self.dc tk(lower self.tag {O belowtag($)})}
   end
      
   meth oclick(O X Y)
      case {O getstate($)}.hyperlink=="" andthen @browsemode\=2 then
	 toget<-nil
      else
	 toget<-O
	 {self.client setcursor("trek")}
	 {self draw(O)}
      end
   end
      
   meth cclick(X Y)
      skip
   end

   meth cdclick(X Y)
      skip
   end

   meth csclick(X Y)
      skip
   end
   
   meth cmotion(X Y)
      skip
   end

   meth crelease(X Y)
      skip
   end
   
   meth osclick(O X Y)
      {self oclick(O X Y)}
   end

   meth odclick(O X Y)
      {self oclick(O X Y)}
   end
   
   meth omotion(O X Y)
      skip
   end

   meth orelease(O X Y)
      LINK={O getstate($)}.hyperlink
   in
      {self.tag tk(delete)}
      {self.client setcursor("left_ptr")}
      case O==@toget then
	 case @browsemode
	 of 0 then
	    histl<-{self.client getserver($)}|@histl
	    {self deselect(nil)}
	    {self.client browseto(false LINK)}
	    {self select}
	 [] 1 then
	    {self.client browseto(true LINK)}
	    {self deselect(nil)}
	    {self select}
	 [] 2 then
	    {self definelink(O LINK)}
	 end
      else skip end
      toget<-nil
   end

   meth reselect(X Y)
      {self select}
   end
   
   meth setbrowse(V)
      browsemode<-V
   end

   meth hbrowse
      skip
   end
   
   meth switchshowh(B)
      lock
	 showh<-B
	 {ForAll {self.client getlist($)}
	  proc{$ O}
	     {O markhyperlink(B)}
	  end}
      end
   end
   
   meth modifyobj(O)
      {self bind(O)}
   end
   
   meth justundone
      skip
   end

   meth dummy(1:Var<=nil)
      skip
   end

   meth definelink(O LINK)
      T E B1 B2 B3 L F1 F2 S Quit Abort
   in
      lock
	 {self.client getsellock([O])}
	 S={NewLock}
	 T={New Tk.toplevel tkInit(title:"Define hyperlink"
				   withdraw:true
				   delete:proc{$}
					     lock S in
						case {IsFree Quit} then
						   Quit=cancel
						else skip end
					     end
					  end)}
	 F1={New Tk.frame tkInit(parent:T borderwidth:2 relief:sunken)}
	 F2={New Tk.frame tkInit(parent:T)}
	 L={New Tk.label tkInit(parent:F1 text:"Enter hyperlink to \n\n - a ticket to a drawing server (x-oz-ticket://...)\n - a pickled ticket to a drawing server (http://...)\n - or a snapshot of a drawing (http://.../filename.trd)\n"
			       justify:left anchor:nw)}
	 E={New Tk.entry tkInit(parent:F1 bg:white)}
	 B1={New Tk.button tkInit(parent:F2
				  text:"Ok"
				  action:proc{$}
					    lock X in
					       case {IsFree Quit} then
						  Quit=ok
					       else skip end
					    end
					 end)}
	 B2={New Tk.button tkInit(parent:F2
				  text:"Clear hyperlink"
				  action:proc{$}
					    lock X in
					       case {IsFree Quit} then
						  Quit=clear
					       else skip end
					    end
					 end)}
	 B3={New Tk.button tkInit(parent:F2
				  text:"Cancel"
				  action:proc{$}
					    lock X in
					       case {IsFree Quit} then
						  Quit=cancel
					       else skip end
					    end
					 end)}
	 {E tk(insert 'end' {O gethyperlink($)})}
	 {T tkBind(event:"<Return>"
		   action:proc{$}
			     lock X in
				case {IsFree Quit} then
				   Quit=ok
				else skip end
			     end
			  end)}
	 {T tkBind(event:"<Escape>"
		   action:proc{$}
			     lock X in
				case {IsFree Quit} then
				   Quit=cancel
				else skip end
			     end
			  end)}
	 {Tk.batch [pack(F1 side:top expand:true fill:both padx:5 pady:5)
		    pack(F2 side:top)
		    pack(L side:top expand:true fill:both)
		    pack(E side:top expand:true fill:x padx:5 pady:5)
		    pack(B1 B2 B3 side:left padx:5 pady:5)
		    wm(deiconify T)
		    focus(E)
		    grab(set T)
		   ]}
	 Abort=@abortdef
      end
      thread
	 {WaitOr Quit Abort}
	 lock
	    case {IsFree Quit} then Quit=cancel else skip end
	    case Quit
	    of ok then
	       Return={E tkReturn(get $)}
	    in
	       {self.client sethyperlink(O Return)}
	       {self.client releasesellock([O])}
	    [] clear then
	       {self.client sethyperlink(O "")}
	       {self.client releasesellock([O])}
	    [] cancel then
	       case {IsFree Abort} then
		  {self.client releasesellock([O])}
	       else skip end
	    else skip end
	    case Quit==ok orelse Quit==clear then
	       {self bind(O)}
	    else skip end
	    {Tk.send grab(release T)}
	    {T tkClose}
	 end
      end
   end
   
   meth abort
      lock
	 @abortdef=unit
	 local X in abortdef<-X end
      end
   end

   meth bind(O)
      lock
	 case {O gethyperlink($)}=="" then
	    {{O getfulltag($)} tkBind(event:"<Enter>")}
	    {{O getfulltag($)} tkBind(event:"<Leave>")}
	 else
	    {{O getfulltag($)} tkBind(event:"<Enter>"
				      action:proc{$}
						{self.client setcursor("trek")}
						{self.client setmousestatus(self.dc "Hyperlink to "#{O gethyperlink($)} force:true)}
						
					     end)}
	    {{O getfulltag($)} tkBind(event:"<Leave>"
				      action:proc{$}
						{self.client setcursor("left_ptr")}
						{self.client setmousestatus(self.dc "Use mouse to browse" force:true)}
					     end)}
	    case @showh then
	       {O markhyperlink(true)}
	    else skip end
	 end
      end
   end

   meth select()
      toget<-nil
      {self.actions setactions(self true true gridded:false)}
      {self.client setcursor("left_ptr")}
      {self.client setmousestatus(self.dc "Use mouse to browse")}
      {Tk.send pack(self.iconbar side:left)}
      {self.iconb setState(button:bleft active:@histl\=nil)}
      {ForAll {self.client getlist($)}
       proc{$ O}
	  {self bind(O)}
       end}
   end

   meth deselect(NEXT)      
      {Tk.send pack(forget self.iconbar)}
      {self.actions clearactions}
      {self.client setcursor('')}
      {ForAll {self.client getlist($)}
       proc{$ O}
	  {{O getfulltag($)} tkBind(event:"<Enter>")}
	  {{O getfulltag($)} tkBind(event:"<Leave>")}
	  {O markhyperlink(false)}
       end}
   end

   meth init(TOOLBAR DC CLIENT ACTIONS ACTPORT IMGFON IMGFOFF X Y ICONBAR LOCALIZE)
      self.dc=DC
      self.actions=ACTIONS
      self.localize=LOCALIZE
      self.client=CLIENT
      self.tag={New Tk.canvasTag tkInit(parent:self.dc)}
      self.toolbar=TOOLBAR
      self.actport=ACTPORT
      local X in abortdef<-X end
      browsemode<-0
      showh<-true
      histl<-nil
\ifndef WEB      
      {TOOLBAR addbutton(IMGFOFF
			 IMGFON
			 X Y
			 self
			 "Navigation tool"
			 _)}
\endif
      self.iconbar={New Tk.frame tkInit(parent:ICONBAR.2
					bg:gray)}
      self.iconb={New ICONBAR.1 init(parent:self.iconbar height:ICONBAR.3)}
      {self.iconb addButtons([check(bitmap:{self.localize "mini-underline.gif"}
				    feature:but1
				    tooltips:"Show hyperlinked text"
				    state:@showh
				    action:self#switchshowh)
			      separator(feature:but2)
			      command(bitmap:{self.localize "mini-left.gif"}
				      feature:bleft
				      tooltips:"Go to previous drawing"
				      action:self#hbrowse
				      active:false)
			      separator(feature:but5)
			      radio(bitmap:{self.localize "mini-window.gif"}
				    feature:but6
				    tooltips:"Browse mode using this editor"
				    ref:bmode
				    state:@browsemode==0
				    action:self#setbrowse(0))
			      radio(bitmap:{self.localize "mini-windows.gif"}
				    feature:but7
				    tooltips:"Browse mode using new editors"
				    ref:bmode
				    state:@browsemode==1
				    action:self#setbrowse(1))
			      radio(bitmap:{self.localize "net-group.gif"}
				    feature:but8
				    tooltips:"Define hyperlinks"
				    ref:bmode
				    state:@browsemode==2
				    action:self#setbrowse(2))])}
      
   end
   
end

