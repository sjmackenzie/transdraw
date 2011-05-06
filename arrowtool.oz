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


%\define WEB

class ArrowObj

   from StandardObj
   
   feat dc actions objtag tagmark client

   attr seglist c1 c2 rtk map shown blinkthread order tagcol width
      arrowl arrowr x1 y1 x2 y2 i black displayed segtags dash hyperlink

   meth getstate(?S)
      S=tree(type:curve
	     points:{@seglist getlist($)}
	     c1:@c1 c2:@c2
	     id:@map
	     width:@width
	     arrowl:@arrowl
	     arrowr:@arrowr
	     dash:@dash
	     hyperlink:@hyperlink
	     order:@order)
   end

   meth gettype(?T)
      T=curve
   end
   
   meth createtk
      Scale={self.client getscale($)}
      TempTag
   in
      tagcol<-nil
      self.objtag={New Tk.canvasTag tkInit(parent:self.dc)}
      TempTag={New Tk.canvasTag tkInit(parent:self.dc)}
      self.tagmark={New Tk.canvasTag tkInit(parent:self.dc)}
      {self.dc tk(crea line
		  ~10 ~10
		  ~5 ~5
		  ~15 ~15
		  fill:@c1
		  tags:TempTag
		  width:@width*Scale
		  smooth:true
		  joinstyle:round
		  stipple:@dash
		 )}
      {self.dc tk(addtag self.objtag withtag TempTag)}
      displayed<-false
      segtags<-TempTag|nil
      {self changecoord}
      {self.actions bindtag(self.objtag self)}
   end

   meth changecoord
      Scale={self.client getscale($)} in
      case {@seglist length($)}<1 then
	 % on cache le tout
	 {List.forAllInd @segtags
	  proc{$ I SegTag}
	     case I>1 then
		{SegTag tk(delete)}
		{self.dc tk(dtag SegTag)}
	     else
		{self.dc tk(coords SegTag ~10 ~10 ~5 ~5 ~15 ~15)}
%		{self.dc tk(dtag SegTag)}
	     end
	  end}
	 segtags<-{List.nth @segtags 1}|nil
      else
	 Last={@seglist length($)}
	 fun {ListToAtom Liste}
	    {StringToAtom {VirtualString.toString
			   {List.toTuple '#'
			    {Map Liste fun{$ C} " "#{FloatToInt {IntToFloat C}*Scale} end}}}}
	 end
	 proc{Loop I R S}
	    case R of Segr|Rs then
	       SegTag Ss Seg L in
	       Seg={Record.map {Record.filterInd Segr fun{$ I P} {IsInt I} end} fun{$ O} O*Scale end}
	       case Seg.1==Seg.3 andthen Seg.2==Seg.4 then
		  case Seg.5==Seg.7 andthen Seg.6==Seg.8 then
		     L=[Seg.1 Seg.2 Seg.7 Seg.8]
		  else
		     L=[Seg.1 Seg.2 Seg.5 Seg.6 Seg.7 Seg.8]
		  end
	       else
		  case Seg.5==Seg.7 andthen Seg.6==Seg.8 then
		     L=[Seg.1 Seg.2 Seg.3 Seg.4 Seg.7 Seg.8]
		  else
		     L=[Seg.1 Seg.2 Seg.3 Seg.4 Seg.5 Seg.6 Seg.7 Seg.8]
		  end
	       end
	       case S of ST|Sss then
		  SegTag=ST
		  Ss=Sss
		  {self.dc tk(coords SegTag b(L))}
	       else
		  SegTag={New Tk.canvasTag tkInit(parent:self.dc)}
		  Ss=nil
		  segtags<-SegTag|@segtags
		  {self.dc tk(crea line b(L)
			      fill:@c1
			      tags:SegTag
			      smooth:true
			      stipple:@dash
			      joinstyle:round
			      width:@width*Scale)}
		  {self.dc tk('lower' SegTag self.objtag)}
		  {self.dc tk(addtag self.objtag withtag SegTag)}
	       end
	       case I==1 then
		  {SegTag tk(itemconfigure arrow:first arrowshape:{ListToAtom @arrowl})}
	       elsecase I==Last then
		  {SegTag tk(itemconfigure arrow:last arrowshape:{ListToAtom @arrowr})}
	       else
		  {SegTag tk(itemconfigure arrow:none)}
	       end
	       {Loop I+1 Rs Ss}
	    else
	       case S of SegTag|Ss then % efface les segments supplementaires
		  {self.dc tk(delete SegTag)}
		  {self.dc tk(dtag SegTag)}
		  segtags<-{List.subtract @segtags SegTag} % suppression de la liste
		  {Loop I+1 nil Ss}
	       else
		  skip
	       end
	    end
	 end
      in
	 {Loop 1 {Reverse {@seglist getlist($)}} {Reverse @segtags}}
	 case {@seglist length($)}==1 then
	    Seg={Record.map {@seglist getfirst($)} fun{$ O}
						      case {IsFloat O} then
							 O*Scale
						      else
							 O
						      end
						   end}
	    L
	    SegTag={New Tk.canvasTag tkInit(parent:self.dc)}
	 in
%	    case Seg.1==Seg.3 andthen Seg.2==Seg.4 then
%	       case Seg.5==Seg.7 andthen Seg.6==Seg.8 then
%		  L=[Seg.1 Seg.2 Seg.7 Seg.8]
%	       else
%		  L=[Seg.1 Seg.2 Seg.5 Seg.6 Seg.7 Seg.8]
%	       end
%	    else
%	       case Seg.5==Seg.7 andthen Seg.6==Seg.8 then
%		  L=[Seg.1 Seg.2 Seg.3 Seg.4 Seg.7 Seg.8]
%	       else
%		  L=[Seg.1 Seg.2 Seg.3 Seg.4 Seg.5 Seg.6 Seg.7 Seg.8]
%	       end
%	    end
%	    {self.dc tk(crea line b(L)
%			fill:@c1
%			tags:SegTag
%			smooth:true
%			stipple:@dash
%			joinstyle:round
%			width:@width*Scale)}
	    case Seg.5==Seg.7 andthen Seg.6==Seg.8 then
	       L=r(Seg.3 Seg.4 Seg.5 Seg.6)
	    else
	       L=r(Seg.5 Seg.6 Seg.7 Seg.8)
	    end
	    local
	       DX=L.1-L.3
	       DY=L.2-L.4
	       D={Sqrt DX*DX+DY*DY}
	    in
	       {self.dc tk(crea line
			   L.3+DX/D L.4+DY/D
			   L.3 L.4
			   smooth:true
			   joinstyle:round
			   width:@width*Scale
			   stipple:@dash
			   fill:@c1
			   tags:SegTag)}
	    end 
	    {SegTag tk(itemconfigure 
		       arrow:last
		       arrowshape:{ListToAtom @arrowr})}
	    {self.dc tk('lower' SegTag self.objtag)}
	    {self.dc tk(addtag self.objtag withtag SegTag)}
	    segtags<-SegTag|@segtags
	 else skip end
      end
   end
   
   meth initstate(DC S ACTIONS CLIENT)
      self.client=CLIENT
      self.dc=DC
      self.actions=ACTIONS
      blinkthread<-nil
      c1<-S.c1
      c2<-S.c2
      map<-S.id
      width<-S.width
      shown<-true
      order<-{self.client getlast($)}+1
      arrowl<-S.arrowl
      arrowr<-S.arrowr
      dash<-S.dash
      black<-black % silly line
      seglist<-{New Objlistclass init}
      hyperlink<-S.hyperlink
      {@seglist appendlist({Reverse S.points})}
      {self createtk}
   end

   meth init(DC C1 C2 W Al Ar Dash ACTIONS CLIENT)
      self.client=CLIENT
      self.dc=DC
      self.actions=ACTIONS
      blinkthread<-nil
      c1<-C1
      c2<-C2
      arrowl<-Al
      arrowr<-Ar
      dash<-Dash
      width<-W
      map<-{NewName $}
      shown<-true
      order<-{self.client getlast($)}+1
      black<-black % silly line
      seglist<-{New Objlistclass init()}
      hyperlink<-""
      {self createtk}
   end

   meth bindtag(T)
      {self.actions bindtag(self.objtag T)}
   end

   meth resetbind
      {self.actions bindtag(self.objtag self)}
   end
   
   meth drawtag(COL)
      Scale={self.client getscale($)} in
      case @tagcol
      of nil then
	 skip
      else
	 {self.tagmark tk(delete)}
      end
      case COL==nil orelse {@seglist length($)}<1 then skip else
	 local Seg X Y in
	    Seg={@seglist getmember(1 $)}
	    X=Seg.1 Y=Seg.2
	    {self.dc tk(crea rect
			X*Scale-2.0 Y*Scale-2.0
			X*Scale+2.0 Y*Scale+2.0
			fill:COL
			outline:COL
			tags:self.tagmark)}
	 end
      end
      tagcol<-COL
   end

   meth setstate(S)
      Scale={self.client getscale($)} in
      map<-S.id
      shown<-true
      case @c1==S.c1 then
	 skip
      else
	 {self.objtag tk(itemconfigure fill:S.c1)}
	 c1<-S.c1
      end
      case @c2==S.c2 then
	 skip
      else
	 c2<-S.c2
      end
      case @width==S.width then
	 skip
      else
	 width<-S.width
	 {self.objtag tk(itemconfigure width:@width*Scale)}
      end
      case @arrowl==S.arrowl then
	 skip
      else
	 arrowl<-S.arrowl
%	 {self.objtag tk(itemconfigure arrow:@arrow)}
      end
      case @arrowr==S.arrowr then
	 skip
      else
	 arrowr<-S.arrowr
      end
      hyperlink<-S.hyperlink
      {self changepoints({Reverse S.points})}
   end      

   meth setid(I)
      map<-I
   end

   meth getid(?I)
      I=@map
   end
   
   meth changepoints(L)
      seglist<-{New Objlistclass init}
      {@seglist appendlist(L)}
      case @shown then
	 {self changecoord}
      else skip end
   end

   meth changesize(IX1 IY1 IX2 IY2)
      local OX1 OX2 OY1 OY2 SX SY L X1 X2 Y1 Y2
	 proc{CHANGESIZE}
	    fun{CX X}
	       (X-OX1)*SX+X1
	    end
	    fun{CY Y}
	       (Y-OY1)*SY+Y1
	    end
	    fun {Loop X}
	       case X of Seg|Xs then
		  r({CX Seg.1} {CY Seg.2}
		    {CX Seg.3} {CY Seg.4}
		    {CX Seg.5} {CY Seg.6}
		    {CX Seg.7} {CY Seg.8})|{Loop Xs}
	       else nil end
	    end
	 in
	    {L appendlist({Reverse {Loop {@seglist getlist($)}}})}
	 end
      in
	 case IX1<IX2 then
	    X1=IX1
	    X2=IX2
	 else
	    X1=IX2
	    X2=IX1
	 end
	 case IY1<IY2 then
	    Y1=IY1
	    Y2=IY2
	 else
	    Y1=IY2
	    Y2=IY1
	 end
	 {self getsize(OX1 OY1 OX2 OY2)}
	 SX=(X2-X1)/(OX2-OX1)
	 SY=(Y2-Y1)/(OY2-OY1)
	 i<-1
	 L={New Objlistclass init()}
	 {CHANGESIZE}
	 {self changepoints({Reverse {L getlist($)}})}
      end
      {self movetag}
   end

   meth transform(W)
      fun{Transform L Proc}
	 fun{Loop Xs}
	    case Xs of Seg|Zs then
	       R1={Proc Seg.1 Seg.2}
	       R2={Proc Seg.3 Seg.4}
	       R3={Proc Seg.5 Seg.6}
	       R4={Proc Seg.7 Seg.8}
	    in
	       r(R1.1 R1.2 R2.1 R2.2 R3.1 R3.2 R4.1 R4.2)|{Loop Zs}
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
      case W
      of lrotate then
	 fun{MyP X Y}
	    r(MX+Y-MY MY-X+MX)
	 end
      [] rrotate then
	 fun{MyP X Y}
	    r(MX-Y+MY MY+X-MX)
	 end
      [] hrotate then
	 fun{MyP X Y}
	    r(2.0*MX-X 2.0*MY-Y)
	 end
      [] vflip then
	 fun{MyP X Y}
	    r(X 2.0*MY-Y)
	 end
      [] hflip then
	 fun{MyP X Y}
	    r(2.0*MX-X Y)
	 end
      end
      {self changepoints({Reverse {Transform {@seglist getlist($)} MyP}})}
      {self movetag}
   end
   
   meth getsize(?X1 ?Y1 ?X2 ?Y2)
      Scale=1.0/{self.client getscale($)} in
      [X1 Y1 X2 Y2]={Map {self.dc tkReturnListFloat(bbox(self.objtag) $)} fun{$ P} P*Scale end}
   end
   
   meth setoutlinecolor(C)
      c1<-C
      {self.objtag tk(itemconfigure fill:@c1)}
   end

   meth setfillcolor(C)
      c2<-C
   end

   meth setwidth(W)
      Scale={self.client getscale($)} in
      width<-W
      {self.objtag tk(itemconfigure width:@width*Scale)}
   end

   meth setdash(D)
      dash<-D
      {self.objtag tk(itemconfigure stipple:D)}
   end

   meth setarrows(L R)
      arrowl<-L
      arrowr<-R
      {self changecoord}
   end
   
   meth belowtag(?T)
      T={Nth @segtags 1} % le premier puisqu'ils sont inseres en dessous
   end

   meth toptag(?T)
      T={Nth @segtags {Length @segtags}} % le dernier
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
      {self settag(none)}
      {self changesize(~20.0 ~20.0 ~10.0 ~10.0)}
      shown<-false
   end

   meth isvisible(?B)
      B=@shown
   end

   meth redraw
      Scale={self.client getscale($)} in
      {self.objtag tk(itemconfigure width:@width*Scale)}
      case @shown then
	 {self changecoord}
	 {self movetag}
      else skip end
   end
   
   meth kill
      {self settag(none)}
      {self.objtag tk(delete)}
   end

   meth addseg(Seg)
      {@seglist addobj(Seg)}
      case @shown then {self changecoord} else skip end
   end
   
   meth chgseg(Nu Seg)
      {@seglist replace(Nu Seg)}
      case @shown then {self changecoord} else skip end
   end

   meth delseg(Nu)
      case {@seglist length($)}>1 then
	 {@seglist delete(Nu)}
	 case @shown then {self changecoord} else skip end
      else skip end
   end

   meth insertseg(Nu Seg)
      {@seglist setmember(Nu Seg)}
      case @shown then {self changecoord} else skip end
   end

   meth getvoisins(Nu Seg1 Seg2 Seg3)
      NB={@seglist length($)}
   in
      case NB==1 then
	 Seg2={@seglist getmember(1 $)}
      else
	 SL={List.drop {Reverse {@seglist getlist($)}} Nu-1}
      in
	 case Nu==1 then
	    [Seg2 Seg3]={List.take SL 2}
	    Seg1=nil
	 elsecase Nu==NB then
	    [Seg1 Seg2]={List.take SL 2}
	    Seg3=nil
	 else
	    [Seg1 Seg2 Seg3]={List.take SL 3}
	 end
      end
   end
   
   meth length(L)
      L={@seglist length($)}
   end
   
end

class ArrowTool

   from StandardTool
   
   feat dc canvas client actions actport color border seltool iconbar localize
      cointag templines tempcurve templineorg dialogbox iconb
   
   attr ncurve state dragmode orgx orgy nuedit tseg1 tseg2 tseg3 tx1 ty1 tx2 ty2 tx3 ty3 tx4 ty4
      creatmode curcoul toget oldncurve
      dash arrowl arrowr editmode

   meth release
      case @oldncurve.obj==nil then skip else
	 case @oldncurve.creation then
	    {self.client releaselock(@oldncurve.obj)}
	 else
	    {self.client releasesellock(@oldncurve.obj)}
	 end
	 {@oldncurve.obj settag(none)}
      end
   end

   meth createit(B)
      {self.templines tk(delete)}
      {self.templineorg tk(delete)}
      case {@ncurve length($)}<1 then % pas de sens
	 {@ncurve kill}
	 ncurve<-nil
	 oldncurve<-r(obj:nil creation:false)
      else
	 case B then {@ncurve delseg({@ncurve length($)})} % efface le segment introduit en trop
	 else skip end
	 {self.client addobject(@ncurve)}
	 {self.client updatenow(@ncurve)}
	 oldncurve<-r(obj:@ncurve creation:true)
	 {@ncurve settag(black)}
	 ncurve<-nil
	 state<-0
      end
   end
   
   meth draw(nu:ThisNu<=0 return:Return<=nil)
      Col=@curcoul
      PL
      Scale={self.client getscale($)}
      ST
      Lim
      proc{Loop R I}
	 case R of Y|Rs
	 then case Rs of X|Rss then
		 case I<2 orelse I>Lim then {Loop Rss I+1} else
		    Tag in
		    Tag={New Tk.canvasTag tkInit(parent:self.dc)}
		    {self.dc tk(crea rect
				X-2.0 Y-2.0
				X+2.0 Y+2.0
				fill:white
				outline:Col
				tags:Tag)}
		    {self.dc tk(addtag self.cointag withtag Tag)}
		    {Tag tkBind(event:"<1>"
				args:[float(x) float(y)]
				action:self.actport#coinclick(I Tag))}
		    case I==ThisNu then Return=c(I Tag) else skip end
		    {Loop Rss I+1}
		 end
	      else skip end
	 else skip end
      end
      {@ncurve settag(none)}
      Tag={@ncurve toptag($)}
      {Tag tkBind(event:"<Enter>"
		  action:self.actport#client(setcursor('dotbox')))}
      {Tag tkBind(event:"<Leave>"
		  action:self.actport#client(setcursor('pencil')))}
      {Tag tkBind(event:"<1>"
		  args:[float(x) float(y)]
		  action:self.actport#borderclick)}
   in
      {self.dc tk(delete self.cointag)}
      ST={@ncurve getstate($)}
      case ST.c2=='' then
	 Lim=({Length ST.points} div 2) else
	 Lim=({Length ST.points} div 2)-1
      end
      PL=ST.points
      {Loop {Reverse {Map PL fun{$ P} P*Scale end}} 1}
   end

   meth drawtemp
      Scale={self.client getscale($)} in
      {self.dc tk(delete self.templines)}
      case @tx1==nil then
	 {self.dc tk(crea line
		     @tx2*Scale @ty2*Scale
		     @tx3*Scale @ty3*Scale
		     tags:self.templines)}
      elsecase @tx3==nil then
	 {self.dc tk(crea line
		     @tx1*Scale @ty1*Scale
		     @tx2*Scale @ty2*Scale
		     tags:self.templines)}
      else
	 {self.dc tk(crea line
		     @tx1*Scale @ty1*Scale
		     @tx2*Scale @ty2*Scale
		     @tx3*Scale @ty3*Scale
		     tags:self.templines)}
      end
      {self.dc tk('lower' self.templines self.cointag)}
   end

   meth renil
      tx1<-nil tx2<-nil tx3<-nil tx4<-nil
      ty1<-nil ty2<-nil ty3<-nil ty4<-nil
      tseg1<-nil tseg2<-nil tseg3<-nil
   end
   
   meth cclick(X Y) % click
      case @ncurve==nil then
	 % creation d'une nouvelle courbe
	 Scale=1.0/{self.client getscale($)} in
	 {self.client setmousestatus(self.dc "Curve/arrow creation : drag to set points and tangents, double-click to end" force:true)}
	 {self release}
	 {self.client startundolog}
	 ncurve<-{New ArrowObj init(self.dc
				    {self.color getoutlinecolor($)}
				    {self.color getfillcolor($)}
				    {self.border getwidth($)}
				    @arrowl
				    @arrowr
				    @dash
				    self.actions self.client)}
	 orgx<-X*Scale
	 orgy<-Y*Scale
	 {self renil}
	 tx1<-X
	 ty1<-Y
	 local Scale={self.client getscale($)} in
	    {self.dc tk(crea rect
			@tx1*Scale-2.0 @ty1*Scale-2.0
			@tx1*Scale+2.0 @ty1*Scale+2.0
			tags:self.templineorg
			outline:blue)}
	 end
	 creatmode<-true
	 state<-1 % on passe en mode drag du premier point
      else
	 case @creatmode then
	    % ajout d'un point
	    case @state
	    of 0 then skip % etat impossible
	    [] 1 then skip % etat impossible
	    [] 2 then skip % etat impossible
	    [] 3 then % insertion du second point
	       Scale=1.0/{self.client getscale($)} in
	       tx4<-X
	       ty4<-Y
	       tx3<-X
	       ty3<-Y
	       state<-4
	    end
	 else
	    % creation d'une nouvelle ligne alors
	    % => relachement de celle-ci
	    {self release}
	    % click normal
	    {self cclick(X Y)}
	 end
      end
   end

   meth cdclick(X Y) % double-click -> fin de la ligne
      case @ncurve==nil then skip else
	 {self createit(true)}
      end
%      case @ncurve==nil orelse @state\=1 then skip else
%	 ST={@ncurve getstate($)}
%	 X1 Y1 X2 Y2
%      in
%	 {@ncurve settag(black)}
%	 {@ncurve setfillcolor({self.color getfillcolor($)})}
%	 [X1 Y1 X2 Y2]={List.take {Reverse ST.points} 4}
%	 case X1==X2 andthen Y1==Y2 then
%	    {@ncurve delpoint({Length ST.points} div 2)} % efface le pt supplementaire introduit par le double-click
%	 else skip end
%	 {self update}
%	 state<-0
%	 {self.client setmousestatus(self.dc "Use mouse to draw a new polygon, or click on an existing one to edit" force:true)}
%      end
   end
   
   meth csclick(X Y) % shift-click
      {self cclick(X Y)} % passe la main au click normal
   end
   
   meth cmotion(X Y) % deplacement
      case @ncurve==nil then skip else
	 case @creatmode then
	    Scale={self.client getscale($)} in
	    case @state
	    of 0 then % etat impossible
	       skip
	    [] 1 then
	       case {Abs Scale*X-@orgx}+{Abs Scale*Y-@orgy}>2.0 then
		  state<-2
		  {self cmotion(X Y)}
	       else skip end
	    [] 2 then
	       tx2<-X ty2<-Y
	       {self.templineorg tk(delete)}
	       {self.dc tk(crea line
			   @tx1*Scale @ty1*Scale
			   @tx2*Scale @ty2*Scale
			   fill:blue
			   tags:self.templineorg)}
	       {self.dc tk(crea rect
			   @tx1*Scale-2.0 @ty1*Scale-2.0
			   @tx1*Scale+2.0 @ty1*Scale+2.0
			   tags:self.templineorg
			   outline:blue)}
	       {self.dc tk(crea rect
			   @tx2*Scale-2.0 @ty2*Scale-2.0
			   @tx2*Scale+2.0 @ty2*Scale+2.0
			   tags:self.templineorg
			   outline:blue)}
	    [] 3 then skip % etat impossible
	    [] 4 then 
	       case {Abs Scale*X-@orgx}+{Abs Scale*Y-@orgy}>2.0 then
		  state<-5
		  {self cmotion(X Y)}
	       else skip end % ignore car deplacement trop petit
	    [] 5 then
	       tx3<-X ty3<-Y
	       {self.templines tk(delete)}
	       {self.dc tk(crea line
			   @tx3*Scale @ty3*Scale
			   @tx4*Scale @ty4*Scale
			   fill:blue
			   tags:self.templines)}
	       {self.dc tk(crea rect
			   @tx3*Scale-2.0 @ty3*Scale-2.0
			   @tx3*Scale+2.0 @ty3*Scale+2.0
			   tags:self.templines
			   outline:blue)}
	       {self.dc tk(crea rect
			   @tx4*Scale-2.0 @ty4*Scale-2.0
			   @tx4*Scale+2.0 @ty4*Scale+2.0
			   tags:self.templines
			   outline:blue)}
	       {self.dc tk(crea line
			   @tx1*Scale @ty1*Scale
			   @tx2*Scale @ty2*Scale
			   @tx3*Scale @ty3*Scale
			   @tx4*Scale @ty4*Scale
			   smooth:true
			   tags:self.templines)}
	    else skip end
	 else
	    skip
	 end
      end
   end

   meth crelease(X Y) % relachement du bouton
      case @ncurve==nil then skip else
	 case @creatmode then
	    Scale={self.client getscale($)} in
	    case @state
	    of 0 then skip
	    [] 1 then % au meme endroit
	       tx2<-@tx1 ty2<-@ty1
	       state<-3
	    [] 2 then
	       tx2<-X ty2<-Y
	       state<-3
	    [] 3 then skip % etat impossible
	    [] 4 then
	       tx4<-@tx3 ty4<-@ty3
	       state<-5
	       {self crelease(X Y)}
	    [] 5 then
	       {self.templines tk(delete)}
	       {@ncurve addseg(r(@tx1 @ty1 @tx2 @ty2 @tx3 @ty3 @tx4 @ty4 line:false linked:true))}
	       tx1<-@tx4 ty1<-@ty4
	       tx2<-2.0*@tx4-@tx3
	       ty2<-2.0*@ty4-@ty3
	       {self.templineorg tk(delete)}
	       {self.dc tk(crea line
			   @tx3*Scale @ty3*Scale
			   @tx2*Scale @ty2*Scale
			   tags:self.templineorg
			   fill:blue)}
	       {self.dc tk(crea rect
			   @tx1*Scale-2.0 @ty1*Scale-2.0
			   @tx1*Scale+2.0 @ty1*Scale+2.0
			   tags:self.templineorg
			   outline:blue)}
	       {self.dc tk(crea rect
			   @tx2*Scale-2.0 @ty2*Scale-2.0
			   @tx2*Scale+2.0 @ty2*Scale+2.0
			   tags:self.templineorg
			   outline:blue)}
	       {self.dc tk(crea rect
			   @tx3*Scale-2.0 @ty3*Scale-2.0
			   @tx3*Scale+2.0 @ty3*Scale+2.0
			   tags:self.templineorg
			   outline:blue)}
	       state<-3
	    else skip end
	 else skip end
      end
   end

   meth oclick(O X Y)
      case @ncurve==nil then
	 % passage en mode d'edition
	 creatmode<-false
	 ncurve<-O
	 state<-0
	 {ForAll [nodemove nodeadd nodedel nodeunlnk nodelink]
	  proc{$ B}
	     {self.iconb setState(button:B active:true)}
	  end}
      else
	 case @creatmode then
	    {self cclick(X Y)}
	 else
	    case @editmode
	    of move then skip
	    [] add then skip
	    [] delete then skip
	    [] unlink then skip
	    [] link then skip
	    else skip end
	 end
      end
%      case (@state==0 orelse @state==3) andthen {O getstate($)}.type=='line' then
%	 % peut-etre clique-t'on simplement sur l'objet en vue de le modifier
%	 state<-2 % attente de savoir-> c'est sur le release que l'on peut savoir
%	 toget<-O
%	 orgx<-X
%	 orgy<-Y
%      else
%      end
   end

   meth osclick(O X Y)
      {self oclick(O X Y)}
   end

   meth omotion(O X Y)
      {self cmotion(X Y)}
   end

   meth orelease(O X Y)
      {self crelease(X Y)}
   end

   meth odclick(O X Y)
      {self cdclick(X Y)}
   end

   meth coinclick(C Tag X Y)
      case @state==3 then
	 state<-4
	 orgx<-X
	 orgy<-Y
	 nuedit<-r(nu:C tag:Tag)
	 {self.cointag tkBind(event:"<Leave>"
			      action:self.actport#client(setcursor('crosshair')))}
	 local X1 Y1 X2 Y2 X3 Y3 in
	    {@ncurve getvoisins(C X1 Y1 X2 Y2 X3 Y3)}
	    tx1<-X1
	    tx2<-X2
	    tx3<-X3
	    ty1<-Y1
	    ty2<-Y2
	    ty3<-Y3
	 end
      else skip end
   end

   meth delpoint(X Y)
      case @state==4 then
	 {@ncurve delpoint(@nuedit.nu)}
	 {self update}
	 {self.dc tk(delete @nuedit.tag)}
	 {self draw}
	 state<-3
      end
   end
   
   meth borderclick(X Y)
      PL
      SEG={NewCell 0}
      POINT={NewCell nil}
      DIST={NewCell nil}
      fun{Dist S ?R}
	 % S=r(X1 Y1 X2 Y2)
	 % returns R=r(X3 Y3) qui est sur la droite def par P et minimise la distance a (X,Y)
	 % function returns la longueur de (X,Y) a la droite
	 L={Sqrt (S.3-S.1)*(S.3-S.1)+(S.4-S.2)*(S.4-S.2)}
      in
	 case L==0.0 then % si L est nul =>
	    R=r(S.1 S.2) % le resultat est le point en question
	    {Sqrt (X-R.1)*(X-R.1)+(Y-R.2)*(Y-R.2)} % la distance est celle-ci
	 else
	    Tt T in
	    Tt=((S.2-Y)*(S.2-S.4)-(S.1-X)*(S.3-S.1))/(L*L)
	    case Tt<0.0 then T=0.0
	    elsecase Tt>1.0 then T=1.0
	    else T=Tt end
	    R=r(S.1+T*(S.3-S.1) S.2+T*(S.4-S.2))
	    {Sqrt (X-R.1)*(X-R.1)+(Y-R.2)*(Y-R.2)} % la distance est celle-ci
%	    T*L
	 end
      end
      proc{Loop R OX OY I}
	 case R of Y|Rs then
	    case Rs of X|Rss then
	       case I==0 then
		  {Loop Rss X Y I+1}
	       else
		  D P in
		  D={Dist r(OX OY X Y) P}
		  case {Access DIST}==nil orelse D<{Access DIST} then
		     {Assign DIST D}
		     {Assign POINT P}
		     {Assign SEG I}
		  else skip end
		  {Loop Rss X Y I+1}
	       end
	    else skip end
	 else skip end
      end      
   in
      PL={Reverse {@ncurve getstate($)}.points}
      {Loop PL 0 0 0}
      local
	 Point={Access POINT}
	 Seg={Access SEG}
	 Return
      in
	 {@ncurve insertpoint({Access SEG}+1 {Access POINT}.1 {Access POINT}.2)}
	 {self update}
	 {self draw(nu:{Access SEG}+1 return:Return)}
	 {self coinclick(Return.1 Return.2 X Y)}
%	 {self.dc tk(crea line
%		     {Nth PL Seg*2-1} {Nth PL Seg*2}
%		     {Nth PL Seg*2+1} {Nth PL Seg*2+2}
%		     fill:red)}
%	 {self.dc tk(crea rect
%		     Point.1-2.0 Point.2-2.0
%		     Point.1+2.0 Point.2+2.0
%		     fill:red
%		     outline:red)}
%      end
      end
   end
   
   meth justundone % envoye en cas d'undo pour signaler que l'objet a disparu
      state<-0
      {self.dc tk(delete self.cointag)}
      {self.dc tk(delete self.templines)}
      ncurve<-nil
   end
   
   meth updsel
      case @state\=3 then skip else
	 curcoul<-blue
	 {self draw}
      end
   end

   meth abort
      case @creatmode then skip % on s'en fout dans ce cas-ci
      else
	 state<-0
	 {self.dc tk(delete self.cointag)}
	 {self.dc tk(delete self.templines)}
	 case @ncurve==nil then skip else
	    Tag in
	    Tag={@ncurve toptag($)}
	    {self.actions bindtag(Tag @ncurve)} % rebind le click sur le bord
	    {Tag tkBind(event:"<Enter>")}
	    {Tag tkBind(event:"<Leave>")}
	    ncurve<-nil
	 end
      end
   end

   meth getcurobj(Obj)
      case @creatmode andthen @ncurve\=nil then % mode creation de courbes
	 Obj=@ncurve
      elsecase @oldncurve.obj\=nil then % courbes crees en attente
	 Obj=@oldncurve.obj
      else Obj=nil end
   end
   
   meth setoutlinecolor(C)
      Obj in
      {self getcurobj(Obj)}
      case Obj==nil then skip else
	 {self.client setoutlinecolor(Obj C)}
      end
   end

   meth setfillcolor(C)
      Obj in
      {self getcurobj(Obj)}
      case Obj==nil then skip else
	 {self.client setfillcolor(Obj C)}
      end
   end

   meth setwidth(W)
      Obj in
      {self getcurobj(Obj)}
      case Obj==nil then skip else
	 {self.client setwidth(Obj W)}
      end
   end

   meth setarrows(Left Right)
      Obj in
      {self getcurobj(Obj)}
      case Obj==nil then skip else
	 {Obj setarrows(Left Right)}
	 {self.client update(Obj)}
      end
      arrowl<-Left
      arrowr<-Right
   end

   meth setdash(Dash)
      Obj in
      {self getcurobj(Obj)}
      case Obj==nil then skip else
	 {Obj setdash(Dash)}
	 {self.client update(Obj)}
      end
      dash<-Dash
   end
   
   meth setlinestyle
      Return in
      Return={self.dialogbox getLineStyle(arrowl:@arrowl
					  arrowr:@arrowr
					  dash:@dash
					  fill:{self.color getoutlinecolor($)}
					  width:{FloatToInt {self.border getwidth($)}}
					 )}
      case Return=='' then skip else
	 {self.client startundolog}
	 {self.color setoutlinecolor(Return.fill)}
	 {self.border setwidth({IntToFloat Return.width})}
	 {self setoutlinecolor(Return.fill)}
	 {self setwidth({IntToFloat Return.width})}
	 {self setarrows(Return.arrowl Return.arrowr)}
	 {self setdash(Return.dash)}
      end
   end

   meth select()
      {self.actions setactions(self true true gridded:true)}
      {self.actions setgridded(true)}
      {self.client setcursor('pencil')}
      {self.client setmousestatus(self.dc "Use mouse to draw a new curve, or click on an existing one to edit")}
      {self.color setactions(self)}
      {self.border setactions(self)}
      dragmode<-0
      state<-0
      ncurve<-nil
      oldncurve<-r(obj:nil creation:false)
      creatmode<-false
      {Tk.send pack(self.iconbar side:left)}
   end

   meth deselect(NEXT)
      {Tk.send pack(forget self.iconbar)}
      {self.actions clearactions}
      {self.client setcursor('')}
      state<-0
      case @ncurve\=nil andthen @creatmode then
	 {self createit(false)}
      else skip end
      case @oldncurve.obj==nil then skip else
	 case NEXT==self.seltool then
	    {self.seltool setautosel(@oldncurve.obj)}
	 else
	    {self release}
	 end
      end
      {self.templines tk(delete)}
      {self.templineorg tk(delete)}
      {self.color clearactions}
      {self.border clearactions}
      {self.cointag tk(delete)}
   end
      
   meth init(TOOLBAR DC CLIENT ACTIONS ACTPORT DIALOGBOX IMGON IMGOFF X Y COLOR BORDER
	     SELTOOL ICONBAR LOCALIZE)
\ifndef WEB      
      {TOOLBAR addbutton(IMGOFF 
			 IMGON
			 X Y
			 self
			 "Curves and arrows drawing tool"
			 _)}
\endif
      self.localize=LOCALIZE
      self.dc=DC
      self.client=CLIENT
      self.actions=ACTIONS
      self.actport=ACTPORT
      self.color=COLOR
      self.border=BORDER
      self.seltool=SELTOOL
      self.dialogbox=DIALOGBOX
      state<-0
      editmode<-move
      self.cointag={New Tk.canvasTag tkInit(parent:self.dc)}
      self.templines={New Tk.canvasTag tkInit(parent:self.dc)}
      self.templineorg={New Tk.canvasTag tkInit(parent:self.dc)}
      self.tempcurve={New Tk.canvasTag tkInit(parent:self.dc)}
      {self.cointag tkBind(event:"<Enter>"
			   action:self.actport#client(setcursor('crosshair')))}
      {self.cointag tkBind(event:"<Leave>"
			   action:self.actport#client(setcursor('pencil')))}
      {self.cointag tkBind(event:"<B1-Motion>"
			   args:[float(x) float(y)]
			   action:self.actport#cmotion)}
      {self.cointag tkBind(event:"<B1-ButtonRelease>"
			   args:[float(x) float(y)]
			   action:self.actport#crelease)}
      {self.cointag tkBind(event:"<Double-1>"
			   args:[float(x) float(y)]
			   action:self.actport#delpoint)}
      dash<-''
      arrowl<-[0 0 0]
      arrowr<-[0 0 0]
      self.iconbar={New Tk.frame tkInit(parent:ICONBAR.2
					bg:gray)}
      self.iconb={New ICONBAR.1 init(parent:self.iconbar height:ICONBAR.3)}
      {self.iconb addButtons([command(bitmap:{self.localize "mini-paint.gif"}
				      feature:but1
				      tooltips:"Set the line style"
				      action:self#setlinestyle)
			      command(bitmap:{self.localize "mini-line.gif"}
				      feature:but2
				      tooltips:"Plain line - no dash"
				      action:self#setdash(''))
			      command(bitmap:{self.localize "mini-noleft.gif"}
				      feature:but3
				      tooltips:"No begining arrow"
%					action:self#setarrows([0 0 0] @arrowr)) % oz bugs ???
				      action:proc{$}
						{self setarrows([0 0 0] @arrowr)}
					     end)
			      command(bitmap:{self.localize "mini-noright.gif"}
				      feature:but4
				      tooltips:"No ending arrow"
%					action:self#setarrows(@arrowl [0 0 0]))
				      action:proc{$}
						{self setarrows(@arrowl [0 0 0])}
					     end)
			      separator(feature:but5)
			      radio(bitmap:{self.localize "mini-nodemove.gif"}
				    feature:nodemove
				    tooltips:"Move nodes"
				    ref:nodemode
				    state:@editmode==move
				    active:false
				    action:proc{$} skip end)
			      radio(bitmap:{self.localize "mini-nodedel.gif"}
				    feature:nodedel
				    tooltips:"Delete nodes"
				    state:@editmode==delete
				    active:false
				    ref:nodemode
				    action:proc{$} skip end)
			      radio(bitmap:{self.localize "mini-nodeadd.gif"}
				    feature:nodeadd
				    state:@editmode==add
				    active:false
				    tooltips:"Add nodes"
				    ref:nodemode
				    action:proc{$} skip end)
			      separator(feature:nodesep)
			      radio(bitmap:{self.localize "mini-nodeunlnk.gif"}
				    state:@editmode==unlink
				    active:false
				    feature:nodeunlnk
				    tooltips:"Unlink tangents at node"
				    ref:nodemode
				    action:proc{$} skip end)
			      radio(bitmap:{self.localize "mini-nodelink.gif"}
				    feature:nodelink
				    state:@editmode==link
				    active:false
				    tooltips:"Link tangents at node"
				    ref:nodemode
				    action:proc{$} skip end)])}
      
   end

end
