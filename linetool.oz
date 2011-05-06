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


class LineObj

   from StandardObj
   
   feat dc actions objtag tagmark client filltag fulltag

   attr pointlist c1 c2 rtk map shown blinkthread order tagcol width
      x1 y1 x2 y2 i black tobind hyperlink

   meth getstate(?S)
      S=tree(type:line
	     points:{@pointlist getlist($)}
	     c1:@c1 c2:@c2
	     id:@map
	     width:@width
	     hyperlink:@hyperlink
	     order:@order)
   end

   meth gettype(?T)
      T=line
   end
   
   meth createtk
      Scale={self.client getscale($)} in
      tagcol<-nil
      self.objtag={New Tk.canvasTag tkInit(parent:self.dc)}
      self.filltag={New Tk.canvasTag tkInit(parent:self.dc)}
      self.tagmark={New Tk.canvasTag tkInit(parent:self.dc)}
      self.fulltag={New Tk.canvasTag tkInit(parent:self.dc)}
      {self.dc tk(crea line
		  ~10 ~10
		  ~5 ~5
		  fill:@c1
		  tags:self.objtag
		  width:@width*Scale
		  joinstyle:round
		 )}
      {self changecoord}
      {self.actions bindtag(self.objtag self)}
      tobind<-self
   end

   meth changecoord
      Scale={self.client getscale($)} in
      {self.dc tk(coords self.objtag b({Map {@pointlist getlist($)} fun{$ P} P*Scale end}))}
      case @c2=='' then skip else
	 {self.dc tk(coords self.filltag b({Map {@pointlist getlist($)} fun{$ P} P*Scale end}))}
      end
   end
   
   meth initstate(DC S ACTIONS CLIENT)
      self.client=CLIENT
      self.dc=DC
      self.actions=ACTIONS
      blinkthread<-nil
      c1<-S.c1
      c2<-''
      hyperlink<-S.hyperlink
      map<-S.id
      width<-S.width
      shown<-true
      order<-{self.client getlast($)}+1
      black<-black % silly line
      pointlist<-{New Objlistclass init}
      {@pointlist appendlist({Reverse S.points})}
      {self createtk}
      {self setfillcolor(S.c2)}
   end

   meth init(DC X Y C1 W ACTIONS CLIENT)
      self.client=CLIENT
      self.dc=DC
      self.actions=ACTIONS
      blinkthread<-nil
      c1<-C1
      c2<-''
      hyperlink<-""
      width<-W
      map<-{NewName $}
      shown<-true
      order<-{self.client getlast($)}+1
      black<-black % silly line
      pointlist<-{New Objlistclass init()}
      {@pointlist addobj(Y)}
      {@pointlist addobj(X)}
      {@pointlist addobj(Y)}
      {@pointlist addobj(X)}
      {self createtk}
   end

   meth bindtag(T)
      {self.actions bindtag(self.objtag T)}
      case @c2=='' then skip else
	 {self.actions bindtag(self.filltag T)}
      end
      tobind<-T
   end

   meth resetbind
      {self.actions bindtag(self.objtag self)}
      case @c2=='' then skip else
	 {self.actions bindtag(self.filltag self)}
      end
      tobind<-self
   end
   
   meth getfulltag(?T)
      {self.dc tk(dtag self.fulltag)}
      {self.dc tk(addtag self.fulltag withtag self.objtag)}
      {self.dc tk(addtag self.fulltag withtag self.filltag)}
      T=self.fulltag
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
	 local X Y in
	    X={@pointlist getmember(2 $)}
	    Y={@pointlist getmember(1 $)}
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
	 {self.objtag tk(itemconfigure fill:S.c1)}
	 c1<-S.c1
      end
      case @c2==S.c2 then
	 skip
      else
	 {self setfillcolor(S.c2)}
      end
      case @width==S.width then
	 skip
      else
	 width<-S.width
	 {self.objtag tk(itemconfigure width:@width*Scale)}
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
      pointlist<-{New Objlistclass init}
      {@pointlist appendlist(L)}
      case @shown then
	 {self changecoord}
      else skip end
   end

   meth changesize(IX1 IY1 IX2 IY2)
      local OX1 OX2 OY1 OY2 SX SY L X1 X2 Y1 Y2
%	 proc {CHANGESIZE}
%	    {L addobj(({@pointlist getmember(@i $)}-OY1)*SY+Y1)}
%	    {L addobj(({@pointlist getmember(@i+1 $)}-OX1)*SX+X1)}
%	    i<-@i+2
%	    case @i<E then {CHANGESIZE} else skip end
%	 end
	 proc{CHANGESIZE}
	    fun {Loop Xs}
	       case Xs of X|Y|Zs then
		  (X-OX1)*SX+X1|(Y-OY1)*SY+Y1|{Loop Zs}
	       else nil end
	    end
	 in
	    {L appendlist({Reverse {Loop {@pointlist getlist($)}}})}
	 end
      in
%	 case IX1<IX2 then
	    X1=IX1
	    X2=IX2
%	 else
%	    X1=IX2
%	    X2=IX1
%	 end
%	 case IY1<IY2 then
	    Y1=IY1
	    Y2=IY2
%	 else
%	    Y1=IY2
%	    Y2=IY1
%	 end
%	 E={@pointlist length($)}
	 {self getsize(OX1 OY1 OX2 OY2)}
	 % on calcule le ratio a appliquer
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
	    case Xs of X|Y|Zs then
	       R={Proc X Y} in
	       R.1|R.2|{Loop Zs}
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
      {self changepoints({Reverse {Transform {@pointlist getlist($)} MyP}})}
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
      case @c2=='' then
	 case C=='' then
	    skip % de pas de remplissage a pas de remplissage
	 else
	    % on passe de pas de remplissage a du remplissage
	    % il faut donc ajouter ajouter le point final=> c'est le point du debut
	    {@pointlist addobj({@pointlist getmember(1 $)})}
	    {@pointlist addobj({@pointlist getmember(2 $)})}
	    % ensuite il faut creer le polygone
	    c2<-C
	    {self.dc tk(crea poly ~100 ~100 ~90 ~90 ~100 ~90
			tags:self.filltag
			fill:C)}
	    % le placer sous les lignes
	    {self.dc tk(lower self.filltag self.objtag)}
	    % le binder pour les evenements souris
	    {self.actions bindtag(self.filltag @tobind)}
            % et finalement en changer les coordonnees pour le redessiner correctement
	    {self changecoord}
	 end
      else
	 case C=='' then
	    % on passe a du remplissage a pas de remplissage
	    c2<-C
	    % efface le remplissage
	    {self.dc tk(delete self.filltag)}
	    % on supprime les deux points finaux
	    local L in
	       L={@pointlist getlist($)}
	       pointlist<-{New Objlistclass init}
	       {@pointlist appendlist({List.take {Reverse L} {Length L}-2})}
	    end
	    {self changecoord}
	 else
	    % on change juste le remplissage
	    c2<-C
	    {self.dc tk(itemconfigure self.filltag fill:C)}
	 end
      end
   end

   meth setwidth(W)
      Scale={self.client getscale($)} in
      width<-W
      {self.objtag tk(itemconfigure width:@width*Scale)}
   end

   meth belowtag(?T)
      case @c2=='' then
	 T=self.objtag
      else
	 T=self.filltag
      end
   end

   meth toptag(?T)
      T=self.objtag
   end

   meth raiseafter(T)
      {self.dc tk('raise' self.objtag T)}
      case @c2=='' then skip else
	 {self.dc tk(lower self.filltag self.objtag)}
      end
   end

   meth lower
      {self.dc tk(lower self.objtag)}
      case @c2=='' then skip else
	 {self.dc tk(lower self.filltag self.objtag)}
      end
   end

   meth lowerbefore(T)
      {self.dc tk(lower self.objtag T)}
      case @c2=='' then skip else
	 {self.dc tk(lower self.filltag self.objtag)}
      end
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
      {self.filltag tk(delete)}
   end

   meth addpoint(X Y)
      {@pointlist addobj(Y)}
      {@pointlist addobj(X)}
      case @shown then
	 {self changecoord}
      else skip end
   end

   meth chgpoint(Nu X Y)
      NB={@pointlist length($)}
   in
      case @c2=='' then
	 case Nu==2 then % remplace les deux premiers points
	    {@pointlist replace(1 Y)}
	    {@pointlist replace(2 X)}
	    {@pointlist replace(3 Y)}
	    {@pointlist replace(4 X)}
	 else
	    {@pointlist replace(Nu*2-1 Y)}
	    {@pointlist replace(Nu*2 X)}
	 end
      else
	 case Nu==2 then % remplace le dernier point, ainsi que les deux premiers
	    {@pointlist replace(1 Y)}
	    {@pointlist replace(2 X)}
	    {@pointlist replace(3 Y)}
	    {@pointlist replace(4 X)}
	    {@pointlist replace(NB-1 Y)}
	    {@pointlist replace(NB X)}
	 else
	    {@pointlist replace(Nu*2-1 Y)}
	    {@pointlist replace(Nu*2 X)}
	 end
      end
      case @shown then
	 {self changecoord}
      else skip end
   end

   meth delpoint(Nu)
      NB={@pointlist length($)}
   in
      case @c2=='' then
	 case NB>6 then
	    case Nu==2 then % supprime le premier point, et change le second  en consequence
	       X Y in
	       {@pointlist delete(1)}
	       {@pointlist delete(1)}
	       Y={@pointlist getmember(3 $)}
	       X={@pointlist getmember(4 $)}
	       {@pointlist replace(1 Y)}
	       {@pointlist replace(2 X)}
	    else
	       {@pointlist delete(Nu*2-1)}
	       {@pointlist delete(Nu*2-1)}
	    end
	 else skip end
      else
	 case NB>8 then
	    case Nu==2 then 
	       X Y in
	       {@pointlist delete(1)}
	       {@pointlist delete(1)}
	       Y={@pointlist getmember(3 $)}
	       X={@pointlist getmember(4 $)}
	       {@pointlist replace(1 Y)}
	       {@pointlist replace(2 X)}
	       {@pointlist replace(NB-3 Y)}
	       {@pointlist replace(NB-2 X)}
	    else
	       {@pointlist delete(Nu*2-1)}
	       {@pointlist delete(Nu*2-1)}
	    end
	 else skip end
      end
      case @shown then
	 {self changecoord}
      else skip end
   end

   meth insertpoint(Nu X Y)
      {@pointlist setmember(Nu*2-1 X)}
      {@pointlist setmember(Nu*2-1 Y)}
      case @shown then
	 {self changecoord}
      else skip end
   end

   meth getvoisins(Nu X1 Y1 X2 Y2 X3 Y3)
      NB={@pointlist length($)}
      PL SL in
      PL={Reverse {@pointlist getlist($)}}
      SL={List.drop PL (Nu-2)*2}
      case @c2=='' then
	 case Nu==2 then
	    X1=nil Y1=nil
	    [Y2 X2 _ _ Y3 X3]={List.take SL 6}
	 elsecase Nu*2==NB then % dernier point
	    [Y1 X1 Y2 X2]=SL
	    X3=nil Y3=nil
	 else
	    [Y1 X1 Y2 X2 Y3 X3]={List.take SL 6}
	 end
      else
	 case Nu==2 then
	    [Y2 X2 _ _ Y3 X3]={List.take SL 6}
	    [Y1 X1]={List.take {List.drop PL NB-4} 2}
	 else
	    [Y1 X1 Y2 X2 Y3 X3]={List.take SL 6}
	 end
      end
   end
      
end

class LineTool

   from StandardTool
   
   feat dc canvas client actions actport color border seltool iconbar localize
      cointag templines
   
   attr nline state dragmode orgx orgy nuedit tx1 tx2 tx3 ty1 ty2 ty3
      creatmode curcoul toget

   meth release
      Tag in
      case @nline==nil then skip
      else
	 case @creatmode then
	    {self.client releaselock(@nline)}
	 else
	    {self.client releasesellock(@nline|nil)}
	 end
	 Tag={@nline toptag($)}
	 {self.actions bindtag(Tag @nline)} % rebind le click sur le bord
	 {Tag tkBind(event:"<Enter>")}
	 {Tag tkBind(event:"<Leave>")}
	 {@nline settag(none)}
	 {self.dc tk(delete self.cointag)}
      end
      nline<-nil
   end

   meth update
      case @nline==nil then skip
      elsecase @creatmode then
	 {self.client updatenow(@nline)}
      else
	 {self.client update(@nline)}
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
%		 TextTag={New Tk.canvasTag tkInit(parent:self.dc)}
%	      in
%		 {self.dc tk(crea text
%			     X+{IntToFloat I}*4.0 Y
%			     anchor:nw
%			     text:I
%			     fill:black
%			     tags:TextTag)}
		 case I<2 orelse I>Lim then {Loop Rss I+1} else
		    Tag in
		    Tag={New Tk.canvasTag tkInit(parent:self.dc)}
		    {self.dc tk(crea rect
				X-2.0 Y-2.0
				X+2.0 Y+2.0
				fill:white
				outline:Col
				tags:Tag)}
%		    {self.dc tk(itemconfigure TextTag fill:Col)}
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
      {@nline settag(none)}
      Tag={@nline toptag($)}
      {Tag tkBind(event:"<Enter>"
		  action:self.actport#client(setcursor('dotbox')))}
      {Tag tkBind(event:"<Leave>"
		  action:self.actport#client(setcursor('pencil')))}
      {Tag tkBind(event:"<1>"
		  args:[float(x) float(y)]
		  action:self.actport#borderclick)}
   in
      {self.dc tk(delete self.cointag)}
      ST={@nline getstate($)}
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
   
   meth cclick(X Y) % click
      case @state
      of 0 then % on commence une nouvelle ligne
	 Scale=1.0/{self.client getscale($)} in
	 {self.client setmousestatus(self.dc "Polygon creation : drag the mouse for freehand, click for straight lines" force:true)}
	 {self.client startundolog}
	 {self release}
	 nline<-{New LineObj init(self.dc
				  X Y
				  {self.color getoutlinecolor($)}
				  {self.border getwidth($)}
				  self.actions self.client)}
	 {self.client addobject(@nline)}
	 orgx<-X*Scale
	 orgy<-Y*Scale
	 creatmode<-true
	 state<-1 % on passe en mode d'ajouts de points
      [] 1 then
	 {@nline addpoint(X Y)}
	 {self update}
      [] 2 then % on est en mode d'attente de choix modif/creation
	 skip
      [] 3 then % on est en mode modification
	 {self.actions setgridded(true)}
	 state<-0
	 local NX NY in
	    {self.actions gridcoord(X Y NX NY)}
	    {self cclick(NX NY)}
	 end
      else skip
      end
   end

   meth cdclick(X Y) % double-click -> fin de la ligne
      case @nline==nil orelse @state\=1 then skip else
	 ST={@nline getstate($)}
	 X1 Y1 X2 Y2
      in
	 {@nline settag(black)}
	 {@nline setfillcolor({self.color getfillcolor($)})}
	 [X1 Y1 X2 Y2]={List.take {Reverse ST.points} 4}
	 case X1==X2 andthen Y1==Y2 then
	    {@nline delpoint({Length ST.points} div 2)} % efface le pt supplementaire introduit par le double-click
	 else skip end
	 {self update}
	 state<-0
	 {self.client setmousestatus(self.dc "Use mouse to draw a new polygon, or click on an existing one to edit" force:true)}
      end
   end
   
   meth csclick(X Y) % shift-click
      {self cclick(X Y)} % passe la main au click normal
   end
   
   meth cmotion(X Y) % deplacement
      case @state
      of 1 then % mode creation / ajout de ligne
	 Scale={self.client getscale($)} in
	 case {Abs Scale*X-@orgx}+{Abs Scale*Y-@orgy}>2.0 then
	    orgx<-X*Scale orgy<-Y*Scale
	    {@nline addpoint(X Y)}
	    {self update}
	 else skip end
      [] 2 then
	 Scale={self.client getscale($)} in
	 {self release} % de l'ancien
	 case ({Abs (@orgx-X)*Scale}+{Abs (@orgy-Y)*Scale})>2.0 then
	    % on passe en mode d'edition normal
	    {self.actions setgridded(true)}
	    local NX NY in
	       {self.actions gridcoord(@orgx @orgy NX NY)}
	       orgx<-NX
	       orgy<-NY
	    end
	    state<-0
	    nline<-nil
	    {self cclick(@orgx @orgy)}
	    local NX NY in
	       {self.actions gridcoord(X Y NX NY)}
	       {self cmotion(NX NY)}
	    end
	 else skip end % ignore, trop proche
%     [] 3 then % mode edition
      [] 4 then % deplacement d'une poignee
	 {self.actions setgridded(true)}
	 Scale={self.client getscale($)} in
	 {self.dc tk(move @nuedit.tag (X-@orgx)*Scale (Y-@orgy)*Scale)}
	 tx2<-@tx2+X-@orgx
	 ty2<-@ty2+Y-@orgy
	 {self drawtemp}
	 {self.client setcursor('crosshair')}
	 orgx<-X
	 orgy<-Y
      else skip end
   end
   
   meth crelease(X Y) % relachement du bouton
      case @state
      of 2 then % passe en mode d'edition
	 {self.client startundolog}
	 {self.client addundo(@toget setstate(@toget {@toget getstate($)}))}
	 state<-3
	 case @toget==@nline then
	    {@nline settag(none)} % supprime le marqueur pour ce mode
	 else
	    {self release}
	    nline<-@toget
	    creatmode<-false
	    {self.client getsellock(@nline|nil)}	    
	 end
	 case {self.client alllocked($)} orelse @creatmode then
	    curcoul<-blue
	 else
	    curcoul<-red
	 end
	 {self.client setmousestatus(self.dc "Node operations : drag to move, double-click to remove. Add a node by clicking on a line" force:true)}
	 {self.cointag tkBind(event:"<Enter>"
			      action:self.actport#client(setcursor('crosshair')))}
	 {self.cointag tkBind(event:"<Leave>"
			      action:self.actport#client(setcursor('pencil')))}
	 {self draw}
	 {self.actions setgridded(false)}
      [] 4 then % relachement suite au deplacement d'une poignee
	 {@nline chgpoint(@nuedit.nu X Y)}
	 {self update}
	 {self.cointag tkBind(event:"<Enter>"
			      action:self.actport#client(setcursor('crosshair')))}
	 {self.cointag tkBind(event:"<Leave>"
			      action:self.actport#client(setcursor('pencil')))}
	 {self.dc tk(delete self.templines)}
	 state<-3
	 {self.actions setgridded(false)}
      else skip end
   end

   meth oclick(O X Y)
      case (@state==0 orelse @state==3) andthen {O getstate($)}.type=='line' then
	 % peut-etre clique-t'on simplement sur l'objet en vue de le modifier
	 state<-2 % attente de savoir-> c'est sur le release que l'on peut savoir
	 toget<-O
	 orgx<-X
	 orgy<-Y
      else
	 {self cclick(X Y)}
      end
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
	 {self.cointag tkBind(event:"<Enter>")}
	 {self.cointag tkBind(event:"<Leave>")}
	 {self.cointag tkBind(event:"<1>")}
	 local X1 Y1 X2 Y2 X3 Y3 in
	    {@nline getvoisins(C X1 Y1 X2 Y2 X3 Y3)}
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
	 {@nline delpoint(@nuedit.nu)}
	 {self update}
	 {self.dc tk(delete @nuedit.tag)}
	 {self draw}
	 state<-3
	 {self.cointag tkBind(event:"<Enter>"
			      action:self.actport#client(setcursor('crosshair')))}
	 {self.cointag tkBind(event:"<Leave>"
			      action:self.actport#client(setcursor('pencil')))}
	 {Send self.actport client(setcursor('pencil'))}
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
      case @nline==nil then skip else
	 PL={Reverse {@nline getstate($)}.points}
	 {Loop PL 0 0 0}
	 local
	    Point={Access POINT}
	    Seg={Access SEG}
	    Return
	 in
	    {@nline insertpoint({Access SEG}+1 {Access POINT}.1 {Access POINT}.2)}
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
   end
   
   meth justundone % envoye en cas d'undo pour signaler que l'objet a disparu
      state<-0
      {self.dc tk(delete self.cointag)}
      {self.dc tk(delete self.templines)}
      nline<-nil
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
	 case @nline==nil then skip else
	    Tag in
	    Tag={@nline toptag($)}
	    {self.actions bindtag(Tag @nline)} % rebind le click sur le bord
	    {Tag tkBind(event:"<Enter>")}
	    {Tag tkBind(event:"<Leave>")}
	    nline<-nil
	 end
      end
   end
   
   meth setoutlinecolor(C)
      case @nline==nil then skip else
	 {@nline setoutlinecolor(C)}
	 {self update}
%	 {self.client setoutlinecolor(@nline C)}
      end
   end

   meth setfillcolor(C)
      case @nline==nil orelse @state==1 then skip else
	 {@nline setfillcolor(C)}
	 {self update}
%	 {self.client setfillcolor(@nline C)}
      end
   end

   meth setwidth(W)
      case @nline==nil then skip else
	 {@nline setwidth(W)}
	 {self update}
%	 {self.client setwidth(@nline W)}
      end
   end

   meth select()
      {self.actions setactions(self true true gridded:true)}
      {self.actions setgridded(true)}
      {self.client setcursor('pencil')}
      {self.client setmousestatus(self.dc "Use mouse to draw a new polygon, or click on an existing one to edit")}
%      {self.iconbar addButtons([command(bitmap:{self.localize "mini-paint.gif"}
%					feature:but1
%					tooltips:'Set the line style'
%					action:proc{$} skip end)])}
      {self.color setactions(self)}
      {self.border setactions(self)}
      dragmode<-0
      state<-0
      nline<-nil
   end

   meth deselect(NEXT)
%      {self.iconbar deleteButtons([but1])}
      {self.actions clearactions}
      {self.client setcursor('')}
      case @nline==nil then skip else
	 Tag={@nline toptag($)} in
	 {Tag tkBind(event:"<Enter>")}
	 {Tag tkBind(event:"<Leave>")}
	 {self.actions bindtag(Tag @nline)} % rebind le click sur le bord
	 {@nline settag(none)}
	 case @state==1 then
	    {@nline setfillcolor({self.color getfillcolor($)})}
	 else skip end
	 case NEXT==self.seltool then
	    {self.seltool setautosel(@nline)}
	 else
	    {self release}
	 end
      end
      state<-0
      {self.color clearactions}
      {self.border clearactions}
      {self.cointag tk(delete)}
   end
      
   meth init(TOOLBAR DC CLIENT ACTIONS ACTPORT IMGON IMGOFF X Y COLOR BORDER
	     SELTOOL ICONBAR LOCALIZE)
      {TOOLBAR addbutton(IMGOFF 
			 IMGON
			 X Y
			 self
			 "Line and polygon drawing tool"
			 _)}
      self.localize=LOCALIZE
      self.dc=DC
      self.iconbar=ICONBAR
      self.client=CLIENT
      self.actions=ACTIONS
      self.actport=ACTPORT
      self.color=COLOR
      self.border=BORDER
      self.seltool=SELTOOL
      state<-0
      self.cointag={New Tk.canvasTag tkInit(parent:self.dc)}
      self.templines={New Tk.canvasTag tkInit(parent:self.dc)}
      {self.cointag tkBind(event:"<B1-Motion>"
			   args:[float(x) float(y)]
			   action:self.actport#cmotion)}
      {self.cointag tkBind(event:"<B1-ButtonRelease>"
			   args:[float(x) float(y)]
			   action:self.actport#crelease)}
      {self.cointag tkBind(event:"<Double-1>"
			   args:[float(x) float(y)]
			   action:self.actport#delpoint)}
   end

end
