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


class GroupObj

   from StandardObj
   
   feat dc actions client fulltag

   attr c1 c2 x1 x2 y1 y2 map shown order width i objlist hyperlink

   meth getstate(?S)
%      local L in
%	 L={New Objlistclass init}
%	 {ForAll {@objlist getlist($)}
%	  proc{$ O}
%	     {L addobj({O getstate($)})}
%	  end}
	 S=tree(type:group
		objlist:{Reverse {List.map {@objlist getlist($)} fun{$ O} {O getstate($)} end}}
		c1:@c1 c2:@c2
		id:@map
		hyperlink:@hyperlink
		width:@width
		order:@order)
%      end
   end

   meth gettype(?T)
      T=group
   end
   
   meth initstate(DC S ACTIONS CLIENT)
      tagcol<-none
      self.client=CLIENT
      self.dc=DC
      self.actions=ACTIONS
      c1<-S.c1
      c2<-S.c2
      map<-S.id
      width<-S.width
      hyperlink<-S.hyperlink
      objlist<-{New Objlistclass init}
      {ForAll S.objlist
       proc {$ S}
	  local TEMP in
	     {self.client statetoobj(S TEMP)}
	     {@objlist addobj(TEMP)}
	     {TEMP bindtag(self)}
	  end
       end}
      shown<-true
      order<-{self.client getlast($)}+1
      self.fulltag={New Tk.canvasTag tkInit(parent:self.dc)}
   end

   meth init(DC S ACTIONS CLIENT)
      tagcol<-none
      self.client=CLIENT
      self.dc=DC
      self.actions=ACTIONS
      c1<-{S getfirst($)}.c1
      c2<-{S getfirst($)}.c2
      width<-{S getfirst($)}.width
      map<-{NewName $}
      shown<-true
      order<-{self.client getlast($)}+1
      objlist<-{New Objlistclass init}
      hyperlink<-""
      {ForAll {S getlist($)}
       proc {$ SS}
	  local TEMP in
	     {self.client statetoobj(SS TEMP)}
	     {@objlist addobj(TEMP)}
	     {TEMP bindtag(self)}
	  end
       end}
      shown<-true
      self.fulltag={New Tk.canvasTag tkInit(parent:self.dc)}
   end
   
   meth bindtag(T)
      {ForAll {@objlist getlist($)}
       proc {$ O}
	  {O bindtag(T)}
       end}
   end
   
   meth resetbind
      {ForAll {@objlist getlist($)}
       proc {$ O}
	  {O resetbind}
       end}
   end   

   meth getfulltag(?T)
      {self.dc tk(dtag self.fulltag)}
      {ForAll {@objlist getlist($)}
       proc {$ O}
	  {self.dc tk(addtag self.fulltag withtag {O getfulltag($)})}
       end}
      T=self.fulltag
   end

   meth settag(C)
%	 {ForAll {@objlist getlist($)}
%	  proc {$ O}
%	     {O settag(C)}
%	  end}
      tagcol<-C
      {{@objlist getfirst($)} settag(C)}
   end
      
   meth setstate(L)
      map<-L.id
      shown<-true
      i<-1
      {ForAll L.objlist
       proc{$ S}
	  {{@objlist getmember(@i $)} setstate(S)}
	  i<-@i+1
       end}
      c1<-L.c1
      c2<-L.c2
      width<-L.width
      order<-L.order
      hyperlink<-L.hyperlink
   end      

   meth setid(I)
      map<-I
   end

   meth getid(?I)
      I=@map
   end

   meth changesize(JX1 JY1 JX2 JY2)
      local X1 X2 Y1 Y2 IX1 IX2 IY1 IY2 in
	 case JX1<JX2 then
	    IX1=JX1
	    IX2=JX2
	 else
	    IX1=JX2
	    IX2=JX1
	 end
	 case JY1<JY2 then
	    IY1=JY1
	    IY2=JY2
	 else
	    IY1=JY2
	    IY2=JY1
	 end
	 {self getsize(X1 Y1 X2 Y2)}
	 {ForAll {@objlist getlist($)}
	  proc{$ O}
	     local OX1 OY1 OX2 OY2 in
		{O getsize(OX1 OY1 OX2 OY2)}
		{O changesize((OX1-X1)*((IX2-IX1)/(X2-X1))+IX1
			      (OY1-Y1)*((IY2-IY1)/(Y2-Y1))+IY1
			      (OX2-X1)*((IX2-IX1)/(X2-X1))+IX1
			      (OY2-Y1)*((IY2-IY1)/(Y2-Y1))+IY1)}
	     end
	  end}
      end
   end
   
   meth transform(W)
      fun{Transform L Proc}
	 fun{Loop Xs}
	    case Xs of X|Y|Zs then
	       R={Proc X Y} in
	       R.2|R.1|{Loop Zs}
	    else nil end
	 end
      in
	 {Loop L}
      end
      MyP X1 Y1 X2 Y2 MX MY
   in
      {self getsize(X1 Y1 X2 Y2)}
      MX=(X1+X2)/2.0
      MY=(Y1+Y2)/2.0
      {ForAll {@objlist getlist($)}
       proc{$ O}
	  OX1 OY1 OX2 OY2 OX OY DX DY in
	  {O transform(W)}
	  {O getsize(OX1 OY1 OX2 OY2)}
	  OX=(OX1+OX2)/2.0
	  OY=(OY1+OY2)/2.0
	  case W
	  of lrotate then % faire tourner le pt (OX,OY) autour de (MX,MY)
	     DX=MX+OY-MY-OX
	     DY=MY-OX+MX-OY
	  [] rrotate then
	     DX=MX-OY+MY-OX
	     DY=MY+OX-MX-OY
	  [] hrotate then
	     DX=2.0*MX-2.0*OX
	     DY=2.0*MY-2.0*OY
	  [] vflip then
	     DX=0.0
	     DY=2.0*MY-2.0*OY
	  [] hflip then
	     DX=2.0*MX-2.0*OX
	     DY=0.0
	  end
	  {O changesize(OX1+DX OY1+DY OX2+DX OY2+DY)}
       end}
   end
   
   meth getsize(?X1 ?Y1 ?X2 ?Y2)
      local SX1 SY1 SX2 SY2 in
	 {{@objlist getfirst($)} getsize(SX1 SY1 SX2 SY2)}
	 x1<-SX1
	 x2<-SX2
	 y1<-SY1
	 y2<-SY2
      end
      {ForAll {@objlist getlist($)}
       proc{$ O}
	  local CX1 CY1 CX2 CY2 in
	     {O getsize(CX1 CY1 CX2 CY2)}
	     case CX1<@x1 then x1<-CX1 else skip end
	     case CX2>@x2 then x2<-CX2 else skip end
	     case CY1<@y1 then y1<-CY1 else skip end
	     case CY2>@y2 then y2<-CY2 else skip end
	  end
       end}
      X1=@x1
      X2=@x2
      Y1=@y1
      Y2=@y2
   end
   
   meth setoutlinecolor(C)
      c1<-C
      {ForAll {@objlist getlist($)}
       proc {$ O}
	  {O setoutlinecolor(C)}
       end}
   end
   
   meth setfillcolor(C)
      c2<-C
      {ForAll {@objlist getlist($)}
       proc {$ O}
	  {O setfillcolor(C)}
       end}
   end

   meth setwidth(W)
      width<-W
      {ForAll {@objlist getlist($)}
       proc {$ O}
	  {O setwidth(W)}
       end}
   end

   meth belowtag(?T)
      T={{@objlist getfirst($)} belowtag($)}
   end

   meth toptag(?T)
      T={{@objlist getlast($)} toptag($)}
   end

   meth raiseafter(T)
      i<-T
      {ForAll {Reverse {@objlist getlist($)}}
       proc{$ O}
	  {O raiseafter(@i)}
	  i<-{O toptag($)}
       end}
   end

   meth lower
      i<-nil
      {ForAll {Reverse {@objlist getlist($)}}
       proc{$ O}
	  case @i==nil then
	     {O lower}
	  else
	     {O raiseafter(@i)}
	  end
	  i<-{O toptag($)}
       end}
   end

   meth lowerbefore(T)
      i<-T
      {ForAll {@objlist getlist($)}
       proc{$ O}
	  {O lowerbefore(@i)}
	  i<-{O belowtag($)}
       end}
   end

   meth getorder(?R)
      R=@order
   end

   meth setorder(R)
      order<-R
   end
   
   meth markinvisible
      {ForAll {@objlist getlist($)}
       proc {$ O}
	  {O markinvisible}
       end}
      shown<-false
   end

   meth isvisible(?B)
      B=@shown
   end
   
   meth redraw
      {ForAll {@objlist getlist($)}
       proc {$ O}
	  {O redraw}
       end}
      {self movetag}
   end
   
   meth kill
      {ForAll {@objlist getlist($)}
       proc {$ O}
	  {O kill}
       end}
   end

   meth getlist(L)
      L={@objlist getlist($)}
   end
   
end

