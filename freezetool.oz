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



class FreezeTool

   from StandardTool
   
   feat dc canvas seltag client actions selborder color border freeze steal toolbar iconbar
      localize
   
   attr sellist dragmode clickmode orgx orgy x1 y1 x2 y2

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
	    dragmode<-1
	    % on va tester comment interpreter le drag en fonction du clickmode
	    case @clickmode
	    of 2 then % on commence un cadre de selection
	       dragmode<-2
	       % on deselectionne tout
	       {self.client releasefreezelock({@sellist getlist($)})}
	       sellist<-{New Objlistclass init}
	       {self drawrect(@orgx @orgy X Y blue)}
	    [] 4 then % on shift-commence un cadre de selection
	       dragmode<-2
	       {self drawrect(@orgx @orgy X Y blue)}	       
	    else skip end
	 else skip end	    
      [] 1 then skip
      [] 2 then % on continue un cadre de selection
	 {self drawrect(@orgx @orgy X Y blue)}
      else skip end
   end

   meth crelease(X Y)
      % B1-ButtonRelease : fin cadre de selection
      case @dragmode
      of 0 then % un click dans le vide sur le canvas -> on deselectionne le tout
	 {self.client releasefreezelock({@sellist getlist($)})}
	 sellist<-{New Objlistclass init}
	 clickmode<-0
      [] 1 then skip
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
		      {@sellist member(O $)}==false
		   then
		      {L addobj(O)}
		      {@sellist addobj(O)}
		   else skip end
		end
	     end}
	    case {@sellist length($)}==0 then skip else
	       case {self isfreeze($)} then
		  {self.client getfreezelock({@sellist getlist($)})}
	       else
		  {self.client steallock({@sellist getlist($)})}
	       end
	    end
	 end
	 clickmode<-0
	 dragmode<-0
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
	    {self.client releasefreezelock({@sellist getlist($)})}
	    sellist<-{New Objlistclass init}
	    {@sellist addobj(O)}
	    % on selectionne cet objet
	    case {self isfreeze($)} then
	       {self.client getfreezelock(O|nil)}
	    else
	       {self.client steallock(O|nil)}
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
	    % on selectionne cet objet
	    case {self isfreeze($)} then
	       {self.client getfreezelock(O|nil)}
	    else
	       {self.client steallock(O|nil)}
	    end
	    % on signale qu'il ne faut pas le deselectionner
	    clickmode<-3
	 else
	    % c'est un objet selectionne-> on le deselectionne
	    {@sellist subtract(O)}
	    {self.client releasefreezelock(O|nil)}
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
	    {self.client releasefreezelock({@sellist getlist($)})}
	    sellist<-{New Objlistclass init}
	    {@sellist addobj(O)}
	    %on selectionne l'objet (en attendant le lock)
	    case {self isfreeze($)} then
	       {self.client getfreezelock(O|nil)}
	    else
	       {self.client steallock(O|nil)}
	    end
	 end
	 clickmode<-0
      else {self crelease(X Y)} end
   end

   meth justundone
      skip
   end

   meth addfreeze(O)
      {@sellist addobj(O)}
   end

   meth subtract(O)
      {@sellist subtract(O)}
   end
   
   meth select()
      clickmode<-0
      dragmode<-0
      {self.actions setactions(self true true gridded:false)}
      case {self isfreeze($)} then
	 {self.client setcursor('target')}
	 {self.client setmousestatus(self.dc "Use mouse to select the objets to freeze")}
      else
	 {self.client setcursor('hand2')}
	 {self.client setmousestatus(self.dc "Use mouse to select the objets to steal")}
      end
      {Tk.send pack(self.iconbar side:left)}
   end

   meth deselect(NEXT)      
      {Tk.send pack(forget self.iconbar)}
      {self.actions clearactions}
      {self.client setcursor('')}
   end

   meth isfreeze(?B)
      B=({self.toolbar getcurrent($)}==self.freeze)
   end

   meth init(TOOLBAR DC CLIENT ACTIONS IMGFON IMGFOFF IMGSON IMGSOFF ICONBAR LOCALIZE)
      self.dc=DC
      self.actions=ACTIONS
      self.localize=LOCALIZE
      self.client=CLIENT
      sellist<-{New Objlistclass init()}
      self.seltag={New Tk.canvasTag tkInit(parent:self.dc)}
      self.iconbar={New Tk.frame tkInit(parent:ICONBAR.2
					bg:gray)}
      self.toolbar=TOOLBAR
      local Icon={New ICONBAR.1 init(parent:self.iconbar height:ICONBAR.3)}
      in
	 {Icon addButtons([command(bitmap:{self.localize "mini-lock.gif"}
				   feature:but1
				   tooltips:'Unfreeze everything'
				   action:self#resetfreezelist)])}      
      end
      {TOOLBAR addbutton(IMGFOFF
			 IMGFON
			 1 0
			 self
			 "Freeze tool (To prevent other users from modifying objects)"
			 self.freeze)}
      {TOOLBAR addbutton(IMGSOFF
			 IMGSON
			 1 1
			 self
			 "Stealing tool (To steal objects locked by other users)"
			 self.steal)}
   end

   meth resetfreezelist
      {self.client releasefreezelock({@sellist getlist($)})}
      sellist<-{New Objlistclass init()}
   end
   
end

