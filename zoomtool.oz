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



class ZoomTool

   from StandardTool
   
   feat dc canvas seltag client actions zoom toolbar iconbar
      localize zoomlist dialogbox iconb
   
   attr dragmode clickmode orgx orgy x1 y1 x2 y2 curzoom

   meth drawrect(X1 Y1 X2 Y2 C)
      Scale={self.client getscale($)} in
      {self.seltag tk(delete)}
      {self.dc tk(creat rect
		  X1*Scale Y1*Scale
		  X2*Scale Y2*Scale
		  outline:white
		  width:3
		  tags:self.seltag)}
      {self.dc tk(crea rect
		  X1*Scale Y1*Scale
		  X2*Scale Y2*Scale
		  outline:C
		  tags:self.seltag)}      
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % Messages recus des evenements TCL/TK
   %

   meth cclick(X Y)
      % Click sur le canvas : on doit determiner ce que l'on doit faire
      clickmode<-2
      dragmode<-0
      orgx<-X
      orgy<-Y
   end

   meth cdclick(X Y)
      skip
   end

   meth csclick(X Y)
      % shift-click sur le canvas
      clickmode<-4
      dragmode<-0
      orgx<-X
      orgy<-Y
   end
   
   meth cmotion(X Y)
      % B1-Motion : cadre de selection
      case @dragmode
      of 0 then % on ne fait encore de drag. On passe en dragmode si on a fait un deplacement d'au moins 3 pixels
	 case ({Abs (@orgx-X)}+{Abs (@orgy-Y)})>2.0 then
	    % on passe en dragmode ce qui (notamment) redirige tous les messages vers cette procedure
	    dragmode<-2
	    {self drawrect(@orgx @orgy X Y blue)}
	 else skip end
      [] 2 then % on continue un cadre de selection
	 {self drawrect(@orgx @orgy X Y blue)}
      else skip end
   end

   meth crelease(X Y)
      % B1-ButtonRelease : fin cadre de selection
      case @dragmode
      of 0 then % un click dans le vide sur le canvas -> ignore
	 clickmode<-0
      [] 1 then skip
      [] 2 then % on termine le cadre de selection et... on selectionne !
	 Base X2 Y2 in
	 {self.seltag tk(delete)}
	 %tout d'abord, on reordonne
	 case @orgx>X then X2=@orgx orgx<-X else X2=X end
	 case @orgy>Y then Y2=@orgy orgy<-Y else Y2=Y end
	 % maintenant on zoome
	 local V1 V2 in
	    V1={Tk.returnFloat winfo(width self.dc) $}/(X2-@orgx)
	    V2={Tk.returnFloat winfo(height self.dc) $}/(Y2-@orgy)
	    case V1<V2 then Base=V1 else Base=V2 end
	 end
	 curzoom<-Base
	 {self chgzoom(0.0)}
	 {self.dc tk(xview moveto @orgx/1000.0)}
	 {self.dc tk(yview moveto @orgy/1000.0)}
	 clickmode<-0
	 dragmode<-0
      else
	 dragmode<-0
	 clickmode<-0
      end
   end

   meth zoomlist(?R)
      R={VirtualString.toString {FloatToInt @curzoom*100.0}#" %"}|self.zoomlist
   end
   
   meth setzoom(Index)
      case Index==1 then skip else
	 case Index=={Length self.zoomlist}+1 then
	    Lock={NewCell unit}
	    T E B1 B2 B3 V Ok Cancel
	 in
	    proc{Ok}
	       MyVal Old New in
	       {Exchange Lock Old New}
	       {Wait Old}
	       {Tk.send grab(release T)}
	       MyVal={E tkReturnInt(get $)}
	       case {IsInt MyVal} andthen MyVal>24 andthen MyVal<1001 then
		  curzoom<-{IntToFloat MyVal}/100.0
		  {T tkClose}
		  {self.client setscale(@curzoom)}
		  {self.iconb setState(button:zoom
				       state:r(list:ZoomTool,zoomlist($)
					       index:1))}
	       else
		  _={self.dialogbox message(title:"Error in size selection"
					    text:"\nFont size must be between 25 and 1000.\n"
					    bitmap:error
					    buttons:ok)}
	       end
	       New=unit
	    end
	    proc{Cancel}
	       Old New in
	       {Exchange Lock Old New}
	       {Wait Old}
	       try
		  {Tk.send grab(release T)}
		  {T tkClose}
		  {self.iconb setState(button:zoom
				       state:r(index:1))}
	       catch X then skip end
	       New=unit
	    end
	    T={New Tk.toplevel tkInit(title:"Choose a zoom level in percent")}
	    E={New Tk.entry tkInit(parent:T
				   bg:white)}
	    B1={New Tk.button tkInit(parent:T
				     text:"Ok"
				     action:proc{$} {Ok}
					    end)}
	    B2={New Tk.button tkInit(parent:T
				     text:"Cancel"
				     action:proc{$} {Cancel}
					    end)}
	    {T tkBind(event:"<Return>"
		      action:proc{$} {Ok} end)}
	    {T tkBind(event:"<Escape>"
		      action:proc{$} {Cancel} end)}
	    {Tk.batch [pack(E side:top expand:true fill:x padx:5 pady:5)
		       pack(B1 B2 side:left padx:5 pady:5)
		       focus(E)
		       grab(T)]}
	 else
	    curzoom<-{Nth [0.25 0.33 0.50 0.75 1.00 1.50 2.00 2.50 3.00 4.00] Index-1}
	    {self.client setscale(@curzoom)}
	    {self.iconb setState(button:zoom
				 state:r(list:ZoomTool,zoomlist($)
					 index:1))}
	 end
      end
   end

   meth chgzoom(Val)
      X Y in
      X={Nth {self.dc tkReturnListFloat(xview $)} 1}
      Y={Nth {self.dc tkReturnListFloat(yview $)} 1}
      curzoom<-@curzoom+Val
      case @curzoom<0.25 then curzoom<-0.25
      elsecase @curzoom>10.00 then curzoom<-10.00
      else skip end
      {self.client setscale(@curzoom)}
      {self.dc tk(xview moveto X)}
      {self.dc tk(yview moveto Y)}      
      {self.iconb setState(button:zoom
			   state:r(list:ZoomTool,zoomlist($)
				   index:1))}
   end

   meth zoomfull
      WH={Tk.returnFloat winfo(height self.dc) $}
      OR={Tk.returnFloat winfo(width self.dc) $}
      Base
   in
      case WH<OR then Base=WH else Base=OR end
      curzoom<-Base/1000.0
      {self chgzoom(0.0)}
   end

   meth zoom100
      {self chgzoom(1.0-@curzoom)}
   end
   
   meth select()
      clickmode<-0
      dragmode<-0
      curzoom<-{self.client getscale($)}
      {Tk.send pack(self.iconbar side:left)}
      {self.actions setactions(self false false gridded:false)}
      {self.client setcursor('sizing')}
      {self.client setmousestatus(self.dc "Drag a square to zoom the area")}
   end

   meth deselect(NEXT)
      {Tk.send pack(forget self.iconbar)}
      {self.actions clearactions}
      {self.client setcursor('')}
   end

   meth init(TOOLBAR DC CLIENT ACTIONS IMGFON IMGFOFF ICONBAR DIALOGBOX LOCALIZE)
      self.dc=DC
      self.actions=ACTIONS
      self.localize=LOCALIZE
      self.client=CLIENT
      self.seltag={New Tk.canvasTag tkInit(parent:self.dc)}
      self.toolbar=TOOLBAR
      self.dialogbox=DIALOGBOX
      self.zoomlist=["25 %" "33 %" "50 %" "75 %" "100 %" "150 %" "200 %" "250 %" "300 %" "400 %" "..."]
      curzoom<-{self.client getscale($)}
      self.iconbar={New Tk.frame tkInit(parent:ICONBAR.2
					bg:gray)}
      self.iconb={New ICONBAR.1 init(parent:self.iconbar height:ICONBAR.3)}
      {self.iconb addButtons([command(bitmap:{self.localize "mini-zoom+.gif"}
				      feature:but1
				      tooltips:'Zoom in 25 %'
				      action:self#chgzoom(0.25))
			      command(bitmap:{self.localize "mini-zoom-.gif"}
				      feature:but2
				      tooltips:'Zoom out 25 %'
				      action:self#chgzoom(~0.25))
			      command(text:"100 %"
				      feature:but3
				      tooltips:'Zoom 100 %'
				      action:self#zoom100)
			      command(bitmap:{self.localize "mini-doc.gif"}
				      feature:but4
				      tooltips:'Zoom full document'
				      action:self#zoomfull)
			      list(list:ZoomTool,zoomlist($)				     
				   width:50
				   listw:5
				   listh:10
				   tooltips:'Zoom selection'
				   feature:zoom
				   default:1
				   showfirst:false
				   action:self#setzoom)])}
      {TOOLBAR addbutton(IMGFOFF
			 IMGFON
			 0 1
			 self
			 "Zoom Tool"
			 self.zoom)}
   end
   
end

