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



class StandardObj

   feat dc actions objtag tagmark typ client

   attr x1 x2 y1 y2 c1 c2 rtk map shown blinkthread order tagcol width black
      hyperlink

   meth getstate(?S)
      S=tree(type:self.typ
	     x1:@x1 x2:@x2 y1:@y1 y2:@y2
	     c1:@c1 c2:@c2
	     id:@map
	     width:@width
	     hyperlink:@hyperlink
	     order:@order)
   end

   meth gettype(?T)
      T=self.typ
   end
   
   meth createtk
      Scale={self.client getscale($)} in
      tagcol<-nil
      self.objtag={New Tk.canvasTag tkInit(parent:self.dc)}
      self.tagmark={New Tk.canvasTag tkInit(parent:self.dc)}
      {self.dc tk(crea self.typ
		  @x1*Scale @y1*Scale
		  @x2*Scale @y2*Scale
		  fill:@c2
		  outline:@c1
		  tags:self.objtag
		  width:@width*Scale)}
      {self.actions bindtag(self.objtag self)}
   end
   
   meth initstate(DC S ACTIONS CLIENT)
      self.client=CLIENT
      self.dc=DC
      self.actions=ACTIONS
      blinkthread<-nil
      self.typ=S.type
      x1<-S.x1
      x2<-S.x2
      y1<-S.y1
      y2<-S.y2
      c1<-S.c1
      c2<-S.c2
      map<-S.id
      width<-S.width
      black<-black
      shown<-true
      order<-{self.client getlast($)}+1
      hyperlink<-S.hyperlink
      {self createtk}
   end

   meth init(DC X1 Y1 X2 Y2 C1 C2 W ACTIONS TYP CLIENT)
      self.client=CLIENT
      self.dc=DC
      self.actions=ACTIONS
      blinkthread<-nil
      self.typ=TYP
      x1<-X1
      case X1==X2 then x2<-X2+1.0 else x2<-X2 end
      y1<-Y1
      case Y1==Y2 then y2<-Y2+1.0 else y2<-Y2 end
      c1<-C1
      c2<-C2
      width<-W
      black<-black
      map<-{NewName $}
      shown<-true
      hyperlink<-""
      order<-{self.client getlast($)}+1
      {self createtk}
   end

   meth bindtag(T)
      {self.actions bindtag(self.objtag T)}
   end

   meth resetbind
      {self.actions bindtag(self.objtag self)}
   end

   meth getfulltag(?T)
      T=self.objtag
   end

   meth markhyperlink(B)
      skip
   end
   
   meth sethyperlink(H)
      hyperlink<-H
   end

   meth gethyperlink(?H)
      H=@hyperlink
   end

   meth drawtag(COL)
      Scale={self.client getscale($)} in
      case @tagcol
      of nil then
	 skip
      else
	 {self.tagmark tk(delete)}
      end
      case COL==nil then skip else
	 case self.typ
	 of oval then
	    {self.dc tk(crea rect
			((@x1+@x2)/2.0)*Scale-2.0 @y1*Scale-2.0
			((@x1+@x2)/2.0)*Scale+2.0 @y1*Scale+2.0
			fill:COL
			outline:COL
			tags:self.tagmark)}
	 else
	    {self.dc tk(crea rect
			@x1*Scale-2.0 @y1*Scale-2.0
			@x1*Scale+2.0 @y1*Scale+2.0
			fill:COL
			outline:COL
			tags:self.tagmark)}
	 end	 
      end
      tagcol<-COL
   end

   meth settag(C)
      case @blinkthread==nil then
	 skip
      else
	 try {Thread.terminate @blinkthread}
	 catch X then skip
	 end
	 blinkthread<-nil
      end
      case @shown then
	 case C
	 of none then {self drawtag(nil)}
	 [] red then {self drawtag(red)}
	 [] black then {self drawtag(@black)}
	 [] blink then
	    local N in blinkthread<-N end
	    thread
	       @blinkthread={Thread.this $}
	       {self drawtag(red)}
	       {Delay 200}
	       {self drawtag(nil)}
	       {Delay 200}
	       {self drawtag(red)}
	       {Delay 200}
	       {self drawtag(nil)}
	       {Delay 200}
	       {self drawtag(red)}
	       {Delay 200}
	       {self drawtag(nil)}
	       blinkthread<-nil
	    end
	    {Wait @blinkthread}
	 [] stealon then
	    black<-blue
	    case @tagcol==black then
	       tagcol<-blue 
	       {self drawtag(@tagcol)}
	    else skip end
	 [] stealoff then
	    black<-black
	    case @tagcol==blue then
	       tagcol<-black
	       {self drawtag(@tagcol)}
	    else skip end
	 end
      else skip end
   end
   
   meth movetag
      case @shown then
	 case @tagcol
	 of black then {self settag(black)}
	 [] red then {self settag(black)}
	 else skip end
      else {self settag(none)} end
   end
   
   meth setstate(S)
      Scale={self.client getscale($)} in
      map<-S.id
      shown<-true
      case @c1==S.c1 then
	 skip
      else
	 {self.objtag tk(itemconfigure outline:S.c1)}
	 c1<-S.c1
      end
      case @c2==S.c2 then
	 skip
      else
	 {self.objtag tk(itemconfigure fill:S.c2)}
	 c2<-S.c2
      end
      case @width==S.width then
	 skip
      else
	 width<-S.width
	 {self.objtag tk(itemconfigure width:@width*Scale)}
      end
      hyperlink<-S.hyperlink
      {self changesize(S.x1 S.y1 S.x2 S.y2)}
   end      

   meth setid(I)
      map<-I
   end

   meth getid(?I)
      I=@map
   end
   
   meth changesize(X1 Y1 X2 Y2)
      Scale={self.client getscale($)} in
      case X1<X2 then
	 x1<-X1
	 x2<-X2
      else
	 x1<-X2
	 x2<-X1
      end
      case Y1<Y2 then
	 y1<-Y1
	 y2<-Y2
      else
	 y1<-Y2
	 y2<-Y1
      end
      case @shown then
	 {self.dc tk(coords self.objtag X1*Scale Y1*Scale X2*Scale Y2*Scale)}
      else skip end
      {self movetag}
   end

   meth transform(W)
      case W==rrotate orelse W==lrotate then
	 % seules ces transformations demandent un changement
	 X Y in
	 X=(@x2+@x1)/2.0-(@y2-@y1)/2.0
	 Y=(@y2+@y1)/2.0-(@x2-@x1)/2.0
	 {self changesize(X Y X+(@y2-@y1) Y+(@x2-@x1))}
      else skip end
   end
   
   meth getsize(?X1 ?Y1 ?X2 ?Y2)
      X1=@x1
      X2=@x2
      Y1=@y1
      Y2=@y2
   end
   
   meth setoutlinecolor(C)
      c1<-C
      {self.objtag tk(itemconfigure outline:@c1)}
   end

   meth setfillcolor(C)
      c2<-C
      {self.objtag tk(itemconfigure fill:@c2)}
   end

   meth setwidth(W)
      Scale={self.client getscale($)} in
      width<-W
      {self.objtag tk(itemconfigure width:@width*Scale)}
   end

   meth belowtag(?T)
      T=self.objtag
   end

   meth toptag(?T)
      T=self.objtag
   end

   meth raiseafter(T)
      {self.dc tk('raise' self.objtag T)}
   end

   meth lower
      {self.dc tk(lower self.objtag)}
   end

   meth lowerbefore(T)
      {self.dc tk(lower self.objtag T)}
   end

   meth getorder(?R)
      R=@order
   end

   meth setorder(R)
      order<-R
   end
   
   meth markinvisible
      {self changesize(~1001.0 ~1001.0 ~1000.0 ~1000.0)}
      {self settag(none)}
      shown<-false
   end

   meth isvisible(?B)
      B=@shown
   end
   
   meth redraw
      Scale={self.client getscale($)} in
      {self.objtag tk(itemconfigure width:@width*Scale)}
      case @shown then
	 {self changesize(@x1 @y1 @x2 @y2)}
	 {self movetag}
      else skip end
   end

   meth kill
      {self.objtag tk(delete)}
      {self settag(none)}
   end

end

class StandardTool

   feat dc canvas client actions actport typ color border seltool iconbar localize
   
   attr sx sy nrect lastcreated

   meth cclick(X Y) % click
      {self.client startundolog}
      sx<-X
      sy<-Y
      nrect<-{New StandardObj init(self.dc
				   X Y X Y
				   {self.color getoutlinecolor($)}
				   {self.color getfillcolor($)}
				   {self.border getwidth($)}
				   self.actions self.typ self.client)}
      {self.client addobject(@nrect)}
      case @lastcreated==nil then
	 skip
      else
	 {@lastcreated settag(none)}
	 {self.client releaselock(@lastcreated)}
      end
      lastcreated<-@nrect
   end

   meth csclick(X Y) % shift-click
      {self cclick(X Y)} % passe la main au click normal
   end

   meth cdclick(X Y) % double-click
      skip
   end
   
   meth cmotion(X Y) % deplacement
      {@nrect changesize(@sx @sy X Y)}
      {self.client updatenow(@nrect)}
   end

   meth crelease(X Y) % relachement du bouton
      {@lastcreated settag(black)}
   end

   meth odclick(O X Y)
      skip
   end
   
   meth justundone
      skip
   end

   meth updsel
      skip
   end

   meth abort
      skip
   end

   meth modifyobj(O)
      skip
   end
   
   meth setoutlinecolor(C)
      case @lastcreated==nil then skip else
	 {self.client setoutlinecolor(@lastcreated C)}
      end
   end

   meth setfillcolor(C)
      case @lastcreated==nil then skip else
	 {self.client setfillcolor(@lastcreated C)}
      end
   end

   meth setwidth(W)
      case @lastcreated==nil then skip else
	 {self.client setwidth(@lastcreated W)}
      end
   end

   meth select()
      {self.actions setactions(self false false gridded:true)}
      {self.color setactions(self)}
      {self.border setactions(self)}      
      {self.client setcursor('crosshair')}
      {self.client setmousestatus(self.dc "Use mouse to draw")}
      lastcreated<-nil
%      {self.iconbar addButtons([command(bitmap:{self.localize "mini-paint.gif"}
%					feature:but1
%					tooltips:'Set the line style'
%					action:proc{$} skip end)])}
   end

   meth deselect(NEXT)
%      {self.iconbar deleteButtons([but1])}
      {self.actions clearactions}
      {self.color clearactions}
      {self.border clearactions}
      {self.client setcursor('')}
      case @lastcreated==nil then skip else
	 {@lastcreated settag(none)}	 
	 case NEXT==self.seltool then
	    {self.seltool setautosel(@lastcreated)}
	 else
	    {self.client releaselock(@lastcreated)}
	 end
      end
   end
      
   meth init(TOOLBAR DC CLIENT ACTIONS IMGON IMGOFF TYP X Y COLOR BORDER
	     SELTOOL ICONBAR LOCALIZE)
      Text IconB in
      case TYP==rect then
	 Text="Rectangle drawing tool"
      else
	 Text="Circle drawing tool"
      end
      {TOOLBAR addbutton(IMGOFF 
			 IMGON
			 X Y
			 self
			 Text
			 _)}
      self.dc=DC
      self.localize=LOCALIZE
      self.client=CLIENT
      self.actions=ACTIONS
      self.typ=TYP
      self.color=COLOR
      self.border=BORDER
      self.seltool=SELTOOL
   end

end
