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


class SelectBorderClass
   
   feat dc actport client brect bnw bn bne be bse bs bsw bw
   
   attr shown x1 x2 y1 y2 movemode sizemode sx1 sx2 sy1 sy2 color

   meth init(DC ACTPORT CLIENT)
      proc{SetCursor Tag Type}
	 {Tag tkBind(event:"<Enter>"
		     action:ACTPORT#client(setcursor(Type)))}
	 {Tag tkBind(event:"<Leave>"
		     action:ACTPORT#client(setcursor("left_ptr")))}
      end
   in
      self.dc=DC
      self.client=CLIENT
      shown<-false
      movemode<-false
      sizemode<-false
      self.brect={New Tk.canvasTag tkInit(parent:self.dc)}
      {self.brect tkBind(event:'<1>'
			 args:[float(x) float(y)]
			 action:ACTPORT#bordermove)}
      {SetCursor self.brect "fleur"}
      self.bnw={New Tk.canvasTag tkInit(parent:self.dc)}
      {self.bnw tkBind(event:'<1>'
		       args:[float(x) float(y)]
		       action:ACTPORT#size(1 1 0 0)
		      )}
      {SetCursor self.bnw "top_left_corner"}
      self.bn={New Tk.canvasTag tkInit(parent:self.dc)}
      {self.bn tkBind(event:'<1>'
		      args:[float(x) float(y)]
		      action:ACTPORT#size(0 1 0 0)
		     )}      
      {SetCursor self.bn "top_side"}
      self.bne={New Tk.canvasTag tkInit(parent:self.dc)}
      {self.bne tkBind(event:'<1>'
		       args:[float(x) float(y)]
		       action:ACTPORT#size(0 1 1 0)
		      )}      
      {SetCursor self.bne "top_right_corner"}
      self.be={New Tk.canvasTag tkInit(parent:self.dc)}
      {self.be tkBind(event:'<1>'
		      args:[float(x) float(y)]
		      action:ACTPORT#size(0 0 1 0)
		     )}      
      {SetCursor self.be "right_side"}
      self.bse={New Tk.canvasTag tkInit(parent:self.dc)}
      {self.bse tkBind(event:'<1>'
		       args:[float(x) float(y)]
		       action:ACTPORT#size(0 0 1 1)
		      )}      
      {SetCursor self.bse "bottom_right_corner"}
      self.bs={New Tk.canvasTag tkInit(parent:self.dc)}
      {self.bs tkBind(event:'<1>'
		      args:[float(x) float(y)]
		      action:ACTPORT#size(0 0 0 1)
		     )}      
      {SetCursor self.bs "bottom_side"}
      self.bsw={New Tk.canvasTag tkInit(parent:self.dc)}
      {self.bsw tkBind(event:'<1>'
		       args:[float(x) float(y)]
		       action:ACTPORT#size(1 0 0 1)
		      )}      
      {SetCursor self.bsw "bottom_left_corner"}
      self.bw={New Tk.canvasTag tkInit(parent:self.dc)}      
      {self.bw tkBind(event:'<1>'
		      args:[float(x) float(y)]
		      action:ACTPORT#size(1 0 0 0)
		     )}      
      {SetCursor self.bw "left_side"}
   end

   meth getselsize(X1 Y1 X2 Y2)
      X1=@sx1
      X2=@sx2
      Y1=@sy1
      Y2=@sy2
   end
   
   meth show(SELLIST R)
      Scale={self.client getscale($)} in
         % calcule la taille de la selection et affiche le bord
         % en plus, bind les commandes
      case @shown==true then %efface l'ancien cadre
	 {self.brect tk(delete)}
	 {self.bnw tk(delete)} {self.bn tk(delete)}
	 {self.bne tk(delete)} {self.be tk(delete)}
	 {self.bsw tk(delete)} {self.bs tk(delete)}
	 {self.bse tk(delete)} {self.bw tk(delete)}
      else skip end
      case {Length SELLIST $}>0 then % on a quelque chose a afficher
	 case R andthen {self.client alllocked($)} then
	    color<-black
	 else
	    color<-red
	 end
	 sx1<-1000.0  % plus l'infini en fait
	 sx2<-0.0     % moins l'infini
	 sy1<-1000.0
	 sy2<-0.0
	 local T in
	    T={self.client getlocklist($)}
	    {ForAll SELLIST proc{$ O}
			       local X1 X2 Y1 Y2 in
				  {O getsize(X1 Y1 X2 Y2)}
				  case X1<@sx1 then sx1<-X1 else skip end
				  case X2>@sx2 then sx2<-X2 else skip end
				  case Y1<@sy1 then sy1<-Y1 else skip end
				  case Y2>@sy2 then sy2<-Y2 else skip end
			       end
			       case {Member O T $}==true then
				  {O settag(black)}
			       else
				  {O settag(red)}
			       end
			    end}
	 end
	 x1<-@sx1*Scale-10.0
	 x2<-@sx2*Scale+10.0
	 y1<-@sy1*Scale-10.0
	 y2<-@sy2*Scale+10.0
	 {self.dc tk(crea rect
		     @x1-5.0 @y1
		     @x1+5.0 @y2
		     fill:@color
		     outline:white
		     stipple:gray50
		     tags:self.brect)}
	 {self.dc tk(crea rect
		     @x2-5.0 @y1
		     @x2+5.0 @y2
		     fill:@color
		     outline:white
		     stipple:gray50
		     tags:self.brect)}
	 {self.dc tk(crea rect
		     @x1 @y1-5.0
		     @x2 @y1+5.0
		     fill:@color
		     outline:white
		     stipple:gray50
		     tags:self.brect)}
	 {self.dc tk(crea rect
		     @x1 @y2-5.0
		     @x2 @y2+5.0
		     fill:@color
		     outline:white
		     stipple:gray50
		     tags:self.brect)}		     
%	 {self.dc tk(crea rect
%		     @x1 @y1
%		     @x2 @y2
%		     outline:white
%		     width:4
%		     tags:self.brect)}
%	 {self.dc tk(crea rect
%		     @x1 @y1
%		     @x2 @y2
%		     outline:@color
%		     width:2
%		     tags:self.brect)}
	 {self.dc tk(crea rect
		     @x1-5.0 @y1-5.0
		     @x1+5.0 @y1+5.0
		     fill:@color
		     outline:@color
		     tags:self.bnw)}
	 {self.dc tk(crea rect
		     (@x1+@x2)/2.0-5.0 @y1-5.0
		     (@x1+@x2)/2.0+5.0 @y1+5.0
		     fill:@color
		     outline:@color
		     tags:self.bn)}
	 {self.dc tk(crea rect
		     @x2-5.0 @y1-5.0
		     @x2+5.0 @y1+5.0
		     fill:@color
		     outline:@color
		     tags:self.bne)}
	 {self.dc tk(crea rect
		     @x2-5.0 (@y1+@y2)/2.0-5.0
		     @x2+5.0 (@y1+@y2)/2.0+5.0
		     fill:@color
		     outline:@color
		     tags:self.be)}
	 {self.dc tk(crea rect
		     @x2-5.0 @y2-5.0
		     @x2+5.0 @y2+5.0
		     fill:@color
		     outline:@color
		     tags:self.bse)}
	 {self.dc tk(crea rect
		     (@x1+@x2)/2.0-5.0 @y2-5.0
		     (@x1+@x2)/2.0+5.0 @y2+5.0
		     fill:@color
		     outline:@color
		     tags:self.bs)}
	 {self.dc tk(crea rect
		     @x1-5.0 @y2-5.0
		     @x1+5.0 @y2+5.0
		     fill:@color
		     outline:@color
		     tags:self.bsw)}
	 {self.dc tk(crea rect
		     @x1-5.0 (@y1+@y2)/2.0-5.0
		     @x1+5.0 (@y1+@y2)/2.0+5.0
		     fill:@color
		     outline:@color
		     tags:self.bw)}
	 shown<-true
      else skip end
   end
end

class SelectTool

   from StandardTool
   
   feat dc canvas seltag client actions selborder color border iconbar localize
   
   attr sellist dragmode clickmode orgx orgy x1 y1 x2 y2 sx1 sx2 sy1 sy2 long haut

      
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

   meth csclick(X Y)
         % shift-click sur le canvas
      clickmode<-4
      dragmode<-0
      orgx<-X
      orgy<-Y
   end

   meth cdclick(X Y)
         % double-click
      skip
   end
   
   meth cmotion(X Y)
         % B1-Motion : deplacement ou cadre de selection
      case @dragmode
      of 0 then
            % on ne fait encore de drag.
	    % On passe en dragmode si on a fait un deplacement d'au moins 3 pixels
	 case ({Abs (@orgx-X)}+{Abs (@orgy-Y)})>2.0 then
	       % on passe en dragmode ce qui (notamment) redirige tous les messages vers cette procedure
	    dragmode<-1
	       % on va tester comment interpreter le drag en fonction du clickmode
	    case @clickmode
	    of 2 then % on commence un cadre de selection
	       dragmode<-2
	          % on deselectionne tout
	       {self.client releasesellock({@sellist getlist($)})}
	       sellist<-{New Objlistclass init}
	       {self.selborder show(nil true)}
	       {self drawrect(@orgx @orgy X Y blue)}
	    [] 4 then % on shift-commence un cadre de selection
	       dragmode<-2
	       {self.selborder show(nil true)}
	       {self drawrect(@orgx @orgy X Y blue)}	       
	    else % on commence un deplacement de la selection
	       local X1 Y1 X2 Y2 GX GY TX TY in
		  {self.actions setgridded(true)}
		  {self.selborder getselsize(X1 Y1 X2 Y2)}
		  long<-X2-X1
		  haut<-Y2-Y1
		  x1<-X1
		  y1<-Y1
		  {self.actions gridcoord(X Y GX GY)}
		  {self.actions gridcoord(@orgx @orgy TX TY)}
		  orgx<-TX
		  orgy<-TY
		     % on cache le cadre de selection
		  {self.selborder show(nil true)}
		     % on dessine le cadre de deplacement		     
		  {self drawrect((@x1+GX-@orgx) (@y1+GY-@orgy) (@x1+GX-@orgx)+@long (@y1+GY-@orgy)+@haut blue)}
		  {Send self.actport client(setcursor("fleur"))}
	       end
	    end
	 else skip end	    
      [] 1 then % on continue un deplacement de la selection	    	       
	 {self drawrect((@x1+X-@orgx) (@y1+Y-@orgy) (@x1+X-@orgx)+@long (@y1+Y-@orgy)+@haut blue)}
      [] 2 then % on continue un cadre de selection
	 {self drawrect(@orgx @orgy X Y blue)}
      [] 3 then % on resize
	 case @clickmode
	 of 0 then % on commence
	    local X1 Y1 X2 Y2 in
	       {self.selborder getselsize(X1 Y1 X2 Y2)}
	       x1<-X1
	       x2<-X2
	       y1<-Y1
	       y2<-Y2
	       {self.selborder show(nil true)}
	       clickmode<-1
	       % calcul du orgx et du orgy -> evite de resizer par defaut
	       case @sx1==1 then orgx<-X1-X else skip end
	       case @sx2==1 then orgx<-X2-X else skip end
	       case @sy1==1 then orgy<-Y1-Y else skip end
	       case @sy2==1 then orgy<-Y2-Y else skip end
	       % changement du curseur
	       case @sx1==1 then
		  case @sy1==1 then
		     {Send self.actport client(setcursor("top_left_corner"))}
		  elsecase @sy2==1 then
		     {Send self.actport client(setcursor("bottom_left_corner"))}
		  else
		     {Send self.actport client(setcursor("left_side"))}
		  end
	       elsecase @sx2==1 then
		  case @sy1==1 then
		     {Send self.actport client(setcursor("top_right_corner"))}
		  elsecase @sy2==1 then
		     {Send self.actport client(setcursor("bottom_right_corner"))}
		  else
		     {Send self.actport client(setcursor("right_side"))}
		  end
	       else
		  case @sy1==1 then
		     {Send self.actport client(setcursor("top_side"))}
		  else
		     {Send self.actport client(setcursor("bottom_side"))}
		  end
	       end
	    end
	 else % on continue
	    skip
	 end
	 case @sx1==1 then x1<-X+@orgx else skip end
	 case @sx2==1 then x2<-X+@orgx else skip end
	 case @sy1==1 then y1<-Y+@orgy else skip end
	 case @sy2==1 then y2<-Y+@orgy else skip end
	 local TX TY in
	    {self.actions gridcoord(@x1 @y1 TX TY)}
	    case @sx1==1 then x1<-TX else skip end
	    case @sy1==1 then y1<-TY else skip end
	 end
	 local TX TY in
	    {self.actions gridcoord(@x2 @y2 TX TY)}
	    case @sx2==1 then x2<-TX else skip end
	    case @sy2==1 then y2<-TY else skip end
	 end
	 {self drawrect(@x1 @y1 @x2 @y2 blue)}
      else skip end
   end
   
   meth crelease(X Y)
         % B1-ButtonRelease : fin deplacement ou fin cadre de selection
      case @dragmode
      of 0 then % un click dans le vide sur le canvas -> on deselectionne le tout
	 {self.client releasesellock({@sellist getlist($)})}
	 sellist<-{New Objlistclass init}
	 {self.selborder show(nil true)}
	 clickmode<-0
      [] 1 then % on deplace la selection au nouvel endroit
	 {self.actions setgridded(false)}
	 {self.client startundolog}
	 {self.seltag tk(delete)}
	 clickmode<-0
	 dragmode<-0
	 {self.client setcursor('left_ptr')}
	 % on deplace tous les objets selectionnes
	 {ForAll {@sellist getlist($)}
	  proc {$ O}
	     {self.client move(O (X-@orgx) (Y-@orgy))}
	  end}
	 {self.selborder show({@sellist getlist($)} true)}
      [] 2 then % on termine le cadre de selection et... on selectionne !
	 {self.seltag tk(delete)}
	    %tout d'abord, on reordonne
	 case @orgx>X then x1<-@orgx orgx<-X else x1<-X end
	 case @orgy>Y then y1<-@orgy orgy<-Y else y1<-Y end
	 local L in
	    L={New Objlistclass init}
	    {ForAll {self.client getlist($)}
	     proc {$ O}
		local X1 Y1 X2 Y2 in
		   {O getsize(X1 Y1 X2 Y2)}
		   case X1>@orgx andthen
		      X2<@x1 andthen
		      Y1>@orgy andthen
		      Y2<@y1 andthen
		      {O isvisible($)} andthen
		      {@sellist member(O $)}==false
		   then
		      {L addobj(O)}
		      {@sellist addobj(O)}
		   else skip end
		end
	     end}
	    case {@sellist length($)}==0 then skip else
	       dragmode<-0
	       {self.selborder show({@sellist getlist($)} false)}
	       {self.client getsellock({@sellist getlist($)})}
	       local S in
		  S={{L getlast($)} getstate($)}
		  {self.color setoutlinecolor(S.c1)}
		  {self.color setfillcolor(S.c2)}
		  {self.border setwidth(S.width)}
	       end
	    end
	 end
	 clickmode<-0
	 dragmode<-0
      [] 3 then
	 case @clickmode
	 of 0 then
	    dragmode<-0
	 else % on resize reelement
	    {self.actions setgridded(false)}
	    {self.client startundolog}
	    {self.seltag tk(delete)}
	    local X1 Y1 X2 Y2 in
	       {self.selborder getselsize(X1 Y1 X2 Y2)} % info toujours valable pcq pas recalculee
%	       case @sx1==1 then x1<-X+@orgx else skip end
%	       case @sx2==1 then x2<-X+@orgx else skip end
%	       case @sy1==1 then y1<-Y+@orgy else skip end
%	       case @sy2==1 then y2<-Y+@orgy else skip end
%	          % on va eviter de resizer a une taille nulle
%	       local TX TY in
%		  {self.actions gridcoord(@x1 @y1 TX TY)}
%		  case @sx1==1 then x1<-TX else skip end
%		  case @sy1==1 then y1<-TY else skip end
%	       end
%	       local TX TY in
%		  {self.actions gridcoord(@x2 @y2 TX TY)}
%		  case @sx2==1 then x2<-TX else skip end
%		  case @sy2==1 then y2<-TY else skip end
%	       end
	       case @x1==@x2 then x2<-@x2+1.0 else skip end
	       case @y1==@y2 then y2<-@y2+1.0 else skip end
	          % je dois donc determiner une fonction qui enverrait
	          % X1 Y1 X2 Y2 sur @x1 @y1 @x2 @y2
	          % et l'appliquer a tous les elements selectionnes
	       {ForAll {@sellist getlist($)}
		proc {$ O}
		   local OX1 OX2 OY1 OY2 in
		      {O getsize(OX1 OY1 OX2 OY2)}
		      {self.client resize(O
					  (OX1-X1)*((@x2-@x1)/(X2-X1))+@x1
					  (OY1-Y1)*((@y2-@y1)/(Y2-Y1))+@y1
					  (OX2-X1)*((@x2-@x1)/(X2-X1))+@x1
					  (OY2-Y1)*((@y2-@y1)/(Y2-Y1))+@y1)}
		   end
		end}
	       {self.selborder show({@sellist getlist($)} true)}
	    end
	    dragmode<-0
	    clickmode<-0
	    {self.client setcursor('left_ptr')}
	 end	    
      else
	 dragmode<-0
	 clickmode<-0
      end
   end
   
   meth oclick(O X Y)
      case @dragmode==0 then
            % on clique sur un objet. On doit determiner ce que l'on doit faire
	    % On retient donc que l'on a enfonce le bouton de la souris
	 clickmode<-1
	    % On retient aussi l'endroit ou l'on a clique
	 orgx<-X
	 orgy<-Y
            % C'est quand on relachera ou deplacera la souris que l'on interpretera ce qu'il faut faire
	 case {@sellist member(O $)}==false then
	       % c'est un objet pas deja selectionne
	       % on deselectionne le reste
	    {self.client releasesellock({@sellist getlist($)})}
	    sellist<-{New Objlistclass init}
	    {@sellist addobj(O)}
	    {self.selborder show({@sellist getlist($)} false)}
	       % on selectionne cet objet
	    {self.client getsellock(O|nil)}
	    local S in
	       S={O getstate($)}
	       {self.color setoutlinecolor(S.c1)}
	       {self.color setfillcolor(S.c2)}
	       {self.border setwidth(S.width)}
	    end	    
	       % on signale qu'il ne faut pas le deselectionner
	    clickmode<-3
	 else skip end	    
      else
	 {self cclick(X Y)}
      end
   end
      
   meth osclick(O X Y)
      case @dragmode==0 then
            % on clique sur un objet. On doit determiner ce que l'on doit faire
	    % On retient donc que l'on a enfonce le bouton de la souris
	 clickmode<-1
	    % On retient aussi l'endroit ou l'on a clique
	 orgx<-X
	 orgy<-Y
            % C'est quand on relachera ou deplacera la souris que l'on interpretera ce qu'il faut faire
	 case {@sellist member(O $)}==false then
	       % c'est un objet pas deja selectionne
	    {@sellist addobj(O)}
	    {self.selborder show({@sellist getlist($)} false)}
	       % on selectionne cet objet
	    {self.client getsellock(O|nil)}
	    local S in
	       S={O getstate($)}
	       {self.color setoutlinecolor(S.c1)}
	       {self.color setfillcolor(S.c2)}
	       {self.border setwidth(S.width)}
	    end	    
	       % on signale qu'il ne faut pas le deselectionner
	    clickmode<-3
	 else
	       % c'est un objet selectionne-> on le deselectionne
	    {@sellist subtract(O)}
	    {self.selborder show({@sellist getlist($)} true)}
	    {self.client releasesellock(O|nil)}
	       % on signale d'ignorer les messages suivants
	    clickmode<-10
	    dragmode<-10
	 end
      else
	 {self cclick(X Y)}
      end
   end
   
   meth omotion(O X Y)
         % on deplace la souris, le bouton etant enfonce -> on passe la main au canvas
      {self cmotion(X Y)}
   end

   meth orelease(O X Y)
      case @dragmode==0 then
	 case {@sellist member(O $)} then
	    skip % objet deja selectionne, click idiot on ignore
	 else
	       % on deselectionne le reste
	    {self.client releasesellock({@sellist getlist($)})}
	    sellist<-{New Objlistclass init}
	    {@sellist addobj(O)}
	    {self.selborder show({@sellist getlist($)} false)}
	       %on selectionne l'objet (en attendant le lock)
	    {self.client getsellock(O|nil)}
	    local S in
	       S={O getstate($)}
	       {self.color setoutlinecolor(S.c1)}
	       {self.color setfillcolor(S.c2)}
	       {self.border setwidth(S.width)}
	    end
	 end
	 clickmode<-0
      else {self crelease(X Y)} end
   end
      
   meth justundone
      skip
   end
   
   meth size(X1 Y1 X2 Y2 X Y)
      {self.actions setgridded(true)}
      sx1<-X1
      sx2<-X2
      sy1<-Y1
      sy2<-Y2
      dragmode<-3
      clickmode<-0
      {self cmotion(X Y)}
   end

   meth bordermove(X Y)
      TX TY in
      {self.actions setgridded(true)}
      {self.actions gridcoord(X Y TX TY)}
      dragmode<-1
      orgx<-TX
      orgy<-TY
      local X1 Y1 X2 Y2 in
	 {self.selborder getselsize(X1 Y1 X2 Y2)}
	 long<-X2-X1
	 haut<-Y2-Y1
	 x1<-X1
	 y1<-Y1
         % on cache le cadre de selection
	 {self.selborder show(nil true)}
	 % on dessine le cadre de deplacement
	 {self drawrect((@x1+TX-@orgx) (@y1+TY-@orgy) (@x1+TX-@orgx)+@long (@y1+TY-@orgy)+@haut blue)}
      end
   end

   meth setoutlinecolor(C)
      {self.client startundolog}
      {ForAll {@sellist getlist($)}
       proc {$ O}
	  {self.client setoutlinecolor(O C)}
       end}
   end

   meth setfillcolor(C)
      {self.client startundolog}
      {ForAll {@sellist getlist($)}
       proc {$ O}
	  {self.client setfillcolor(O C)}
       end}
   end

   meth setwidth(W)
      {self.client startundolog}
      {ForAll {@sellist getlist($)}
       proc {$ O}
	  {self.client setwidth(O W)}
       end}
   end

   meth setautosel(O)
      case {O isvisible($)} then
	 {@sellist addobj(O)}
      else skip end
   end

   meth setsel(L)
      sellist<-{New Objlistclass init()}
      {@sellist appendlist(L)}
      {self.selborder show({@sellist getlist($)} true)}
   end

   meth subsel(O)
      {@sellist subtract(O)}
   end
   
   meth select()
      clickmode<-0
      dragmode<-0
      {self.actions setactions(self true true gridded:false)}
      {self.color setactions(self)}
      {self.border setactions(self)}
      {self.client setcursor('left_ptr')}
      {self.client setmousestatus(self.dc "Use mouse to select and modify")}
      {Tk.send pack(self.iconbar side:left)}
      {ForAll {@sellist getlist($)}
       proc{$ O}
	  case {O isvisible($)} then skip else
	     {@sellist subtract(O)}
	  end
       end}
      case {@sellist length($)}==0 then skip else
	 {self.selborder show({@sellist getlist($)} true)}
      end
   end

   meth deselect(NEXT)
      {self.selborder show(nil true)}
      {Tk.send pack(forget self.iconbar)}
      {self.actions clearactions}
      {self.color clearactions}
      {self.border clearactions}
      {self.client releasesellock({@sellist getlist($)})}
      sellist<-{New Objlistclass init}
      {self.client setcursor('')}
   end

   meth init(TOOLBAR DC CLIENT ACTIONS IMGON IMGOFF ACTPORT COLOR BORDER ICON
	     ICONBAR LOCALIZE)
      self.dc=DC
      self.localize=LOCALIZE
      self.actions=ACTIONS
      self.actport=ACTPORT
      self.client=CLIENT
      sellist<-{New Objlistclass init()}
      self.selborder={New SelectBorderClass init(self.dc ACTPORT CLIENT)}
      self.seltag={New Tk.canvasTag tkInit(parent:self.dc)}
      self.color=COLOR
      self.border=BORDER
      self.iconbar={New Tk.frame tkInit(parent:ICONBAR.2
					bg:gray)}
      local
	 IconB={New ICONBAR.1 init(parent:self.iconbar height:ICONBAR.3)}
      in
	 {IconB addButtons([command(bitmap:{self.localize "net-cut.gif"}
				    feature:but1
				    action:ACTPORT#menu(cut)
				    tooltips:'Cut the current selection')
			    command(bitmap:{self.localize "net-copy.gif"}
				    feature:but2
				    action:ACTPORT#menu(copy)
				    tooltips:'Copy the current selection')
			    command(bitmap:{self.localize "net-paste.gif"}
				    feature:but3
				    action:ACTPORT#menu(paste)
				    tooltips:'Paste the current selection')
			    command(bitmap:{self.localize "mini-cross.gif"}
				    feature:but4
				    action:self.actport#menu(delete)
				    tooltips:'Delete the current selection')
			    command(bitmap:{self.localize "net-duplicate.gif"}
				    feature:but5
				    action:self.actport#menu(duplicate)
				    tooltips:'Duplicate the current selection')
			    separator(feature:but6)
			    command(bitmap:{self.localize "net-group.gif"}
				    feature:but7
				    action:self.actport#menu(group)
				    tooltips:'Group the selected objects')
			    command(bitmap:{self.localize "net-ungroup.gif"}
				    feature:but8
				    action:self.actport#menu(ungroup)
				    tooltips:'Ungroup the selected objects')])}	 
      end
      {TOOLBAR addbutton(IMGOFF
			 IMGON
			 0 0
			 self
			 "Selection and modification tool"
			 ICON)}
   end

   meth updsel
      case @dragmode==0 then {self.selborder show({@sellist getlist($)} true)}
      else skip end
   end

   meth getsellist(?L)
      L={@sellist getlist($)}
   end

   meth resetsellist
      sellist<-{New Objlistclass init()}
      {self.selborder show(nil true)}
   end
   
   meth abort
      sellist<-{New Objlistclass init()}
      {self.selborder show(nil false)}
      {self.client setcursor('left_ptr')}
      case @clickmode==0 andthen @dragmode==0 then
	 skip
      else
	 {self.seltag tk(delete)}
	 clickmode<-10
	 dragmode<-10
      end
   end

end

