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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cette classe gere l'affichage du status consistant ou pas du whiteboard.
%
%

class ConsistantState

   feat frame txt canvas rond

   attr const
      
   meth init(P CLIENT)
      self.frame={New Tk.frame tkInit(parent:P
				      bd:3
				      relief:groove
				      width:56
				      bg:gray)}
      self.canvas={New Tk.canvas tkInit(parent:self.frame
					width:58
					height:28
					bg:gray)}
      self.rond={New Tk.canvasTag tkInit(parent:self.canvas)}
      self.txt={New Tk.canvasTag tkInit(parent:self.canvas)}
      {self.canvas tk(crea oval
		      36 4
		      56 24
		      outline:black
		      width:2
		      fill:green
		      tags:self.rond)}
      {self.canvas tk(crea text
		      20 14
		      text:'0'
		      tags:self.txt)}
      {Tk.send pack(self.canvas)}
      {Tk.send pack(self.frame anchor:n fill:y)}
      const<-true
      {CLIENT setmousestatus(self.frame "Green=consistant state/Red=modifications may abort")}
   end

   meth yes
      {self.rond tk(itemconfigure fill:green)}
      {self count(0)}
      const<-true
   end

   meth no
      {self.rond tk(itemconfigure fill:red)}
      const<-false
   end

   meth orange
      {self.rond tk(itemconfigure fill:orange)}
      const<-true
   end
   
   meth get(?B)
      B=@const
   end

   meth count(T)
      {self.txt tk(itemconfigure text:T)}
   end
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cette classe gere le bouton reset des locks freezes
%
%


class ResetFreeze

   feat frame canvas txt cadenas cadre line1 line2 freezetool

   attr const threadid

   prop locking
      
   meth init(P F CLIENT)
      self.freezetool=F
      self.frame={New Tk.frame tkInit(parent:P
				      bd:3
				      relief:groove
				      width:56
				      bg:gray)}
      self.canvas={New Tk.canvas tkInit(parent:self.frame
					width:58
					height:28
					bg:gray)}
      {ForAll [self.txt self.cadre self.cadenas self.line1 self.line2]
       proc{$ O}
	  O={New Tk.canvasTag tkInit(parent:self.canvas)}
       end}
      {self.canvas tk(crea rect
		      4 4
		      58 28
		      fill:''
		      tags:self.cadre)}
      % dessine l'ombre
      {self.canvas tk(crea line
		      4 28
		      4 4
		      58 4
		      fill:white
		      width:2
		      tags:self.line1)}
      {self.canvas tk(crea line
		      58 4
		      58 28
		      4 28
		      fill:c(157 157 157)
		      width:2
		      tags:self.line2)}
      % affiche le texte
      {self.canvas tk(crea text
		      20 14
		      text:'0'
		      tags:self.txt)}
      % affiche le lock a droite
      {self.canvas tk(crea rect
		      39 9
		      53 24
		      fill:black
		      tags:self.cadenas)}
      {self.canvas tk(crea oval
		      43 6
		      49 12
		      outline:black
		      tags:self.cadenas)}
      {self.canvas tk(crea oval
		      43 12
		      49 18
		      fill:white
		      outline:white
		      tags:self.cadenas)}
      {self.canvas tk(crea rect
		      45 14
		      47 22
		      fill:white
		      outline:white
		      tags:self.cadenas)}
      {self.canvas tkBind(event:'<1>'
			  action:self#click)}
      {self.canvas tkBind(event:'<B1-ButtonRelease>'
			  action:self#release)}
      {self.cadenas tkBind(event:'<1>'
			   action:self#click)}
      {self.cadenas tkBind(event:'<B1-ButtonRelease>'
			   action:self#release)}
      {self.txt tkBind(event:'<1>'
		       action:self#click)}
      {self.txt tkBind(event:'<B1-ButtonRelease>'
		       action:self#release)}
      const<-true
      {Tk.send pack(self.canvas)}
      {Tk.send pack(self.frame anchor:n fill:y)}
      threadid<-nil
      {CLIENT setmousestatus(self.frame "Click to release the frozen objects")}
   end

   meth click
      lock
	 {self.line1 tk(itemconfigure fill:c(127 127 127))}
	 {self.line2 tk(itemconfigure fill:white)}
	 {self.canvas tk(move self.txt 1 1)}
	 {self.canvas tk(move self.cadenas 1 1)}
	 {self count(0)}
	 {self.freezetool resetfreezelist}
      end
   end

   meth release
      lock
	 {self.line1 tk(itemconfigure fill:white)}
	 {self.line2 tk(itemconfigure fill:c(127 127 127))}
	 {self.canvas tk(move self.txt ~1 ~1)}
	 {self.canvas tk(move self.cadenas ~1 ~1)}
      end
   end

   meth count(N)
      lock
      {self.txt tk(itemconfigure text:N)}
      case N==0 then % si vide
	 case @threadid\=nil then % si un thread en cours
	    try {Thread.terminate @threadid}
	    catch X then skip
	    end
	    threadid<-nil
	    {self.cadre tk(itemconfigure fill:'')}
	 else skip end
      else
	 case @threadid==nil then % on va commencer le thread
	    local
	       proc {BLINK}
		  {self.cadre tk(itemconfigure fill:c(255 0 255))}
		  {Delay 200}
		  {self.cadre tk(itemconfigure fill:c(255 255 0))}
		  {Delay 200}
		  {BLINK}
	       end
	       proc {WAIT}
		  case @threadid==nil then {WAIT} else skip end
	       end
	    in
	       thread
		  threadid<-{Thread.this $}
		  {BLINK}
	       end
	       {WAIT}
	    end
	 else skip end
      end
      end
   end
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cette classe gere le scale qui s'occupe de la taille du trait
%
%

class BorderWidth

   feat frame scale
   
   attr size objreceiver curval modif

   meth init(P CLIENT)
      self.frame={New Tk.frame tkInit(parent:P
				      bd:3
				      relief:groove
				      bg:gray)}
      local TC T in
	 TC={New Tk.canvas tkInit(parent:self.frame
				  width:13
				  height:70
				  bg:gray)}
	 T={New Tk.canvasTag tkInit(parent:TC)}
	 {TC tk(crea poly
		0 10
		0 60
		10 60
		fill:black
		tags:T)}
	 self.scale={New Tk.scale tkInit(parent:self.frame
					 'from':1
					 to:10
					 showvalue:true
					 orient:vertical
					 length:70
					 action:self#modified
					 args:[float]
					 bg:gray)}
	 {self.scale tkBind(event:'<B1-ButtonRelease>'
			    action:self#changescale)}
	 {Tk.send pack(self.scale side:left)}
	 {Tk.send pack(TC anchor:w)}
	 {Tk.send pack(self.frame anchor:n fill:y)}
	 {self.scale tk(set 1)}
      end
      modif<-false
      curval<-1
      {CLIENT setmousestatus(self.frame "Changes the line width")}
   end

   meth modified(S)
      modif<-true % on a modifie le scale
      curval<-S
   end
   
   meth changescale
      case @modif then % si on a modifie le scale...
	 modif<-false
	 case @objreceiver==nil then
	    skip
	 else
	    {@objreceiver setwidth(@curval)}
	 end
      else skip end
   end
		     
   meth setactions(O)
      objreceiver<-O
   end

   meth clearactions
      objreceiver<-nil
   end
   
   meth getwidth(?S)
      S=@curval
   end
   
   meth setwidth(S)
      curval<-S
      {self.scale tk(set @curval)}      
   end
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cette classe gere les couleurs.
%
%

class ColorSelection

   feat frame canvas c1 c2 line1 line2 dialogbox

   attr c1 c2 objreceiver oc2
      
   meth init(P DIALOGBOX CLIENT)
      self.dialogbox=DIALOGBOX
      self.frame={New Tk.frame tkInit(parent:P
				      bd:3
				      relief:groove
				      bg:gray)}
      self.canvas={New Tk.canvas tkInit(parent:self.frame
					width:58
					height:28
					bg:gray)}
      {ForAll [self.c1 self.c2 self.line1 self.line2]
       proc {$ O}
	  O={New Tk.canvasTag tkInit(parent:self.canvas)}
       end}
      {self.c1 tkBind(event:'<1>'
		      action:self#selcolor(1))}
      {self.c2 tkBind(event:'<1>'
		      action:self#selcolor(2))}
      {self.c2 tkBind(event:'<3>'
		      action:proc{$}
				{self setfillcolor('')}
				case @objreceiver==nil then
				   skip
				else
				   {@objreceiver setfillcolor(@c2)}
				end
			     end)}
      c1<-c(0 0 0)
      c2<-c(255 255 255)
      {self.canvas tk(crea rect
		      4 4
		      56 26
		      outline:black
		      fill:@c1
		      tags:self.c1)}
      {self.canvas tk(crea rect
		      14 9
		      46 21
		      outline:black
		      fill:@c2
		      tags:self.c2)}
      {Tk.send pack(self.canvas)}
      {Tk.send pack(self.frame anchor:n fill:y)}
      objreceiver<-nil
      oc2<-false
      {CLIENT setmousestatus(self.frame "<Left>=Changes the color/<Right> in fill=No filling")}
   end

   meth setactions(O)
      objreceiver<-O
   end

   meth clearactions
      objreceiver<-nil
   end

   meth getactions(?O)
      O=@objreceiver
   end

   meth getoutlinecolor(?C)
      C=@c1
   end

   meth getfillcolor(?C)
      C=@c2
   end

   meth setoutlinecolor(C)
      c1<-C
      {self.c1 tk(itemconfigure fill:@c1)}
   end

   meth setfillcolor(C)
      case @oc2 then
	 {self.line1 tk(delete)}
	 {self.line2 tk(delete)}
      else skip end
      c2<-C
      case @c2=='' then
	 oc2<-true
	 {self.c2 tk(itemconfigure fill:white)}
	 {self.canvas tk(crea line
			 14 9
			 46 21
			 fill:black
			 tags:self.line1)}
	 {self.canvas tk(crea line
			 46 9
			 14 21
			 fill:black
			 tags:self.line2)}
      else
	 oc2<-false
	 {self.c2 tk(itemconfigure fill:@c2)}
      end	 
   end
  
   meth setcolor(N Col)
      case N
      of 1 then
	 {self setoutlinecolor(Col)}
	 case @objreceiver==nil then
	    skip
	 else
	    {@objreceiver setoutlinecolor(@c1)}
	 end
      [] 2 then
	 {self setfillcolor(Col)}
	 case @objreceiver==nil then
	    skip
	 else
	    {@objreceiver setfillcolor(@c2)}
	 end
      end
   end
   
   meth selcolor(N)
      local D F Ss L Col C
      in
	 case N==1 then
	    L='outline'
	    C=@c1
	 else
	    L='fill'
	    case @c2=='' then % transparent
	       C=c(255 255 255)
	    else
	       case {Width @c2 $}==3 then % couleurs RGB
		  C=@c2
	       else % couleurs directes : black, white, red,...
		  C=c(255 255 255)
	       end
	    end
	 end
	 Col={self.dialogbox chooseColor(title:'Color '#L#' selection'
					 initialcolor:C)}
	 case Col=='' then skip
	 else
	    {self setcolor(N Col)}
	 end
      end
   end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cette classe gere la barre de couleur du bas de la fenetre.
%
%


class ColorBar

   feat canvas colorlist color leftframe leftcanvas rightcanvas
      dialogbox
      
   attr tagsarray threadid nu nudisp

   prop locking

   meth drawbutton(Parent X1 Y1 X2 Y2 Text Proc)
      Tagl1 Tagl2 Tagr Tagt Tagb
   in
      {ForAll [Tagl1 Tagl2 Tagr Tagt Tagb]
       proc{$ O}
	  O={New Tk.canvasTag tkInit(parent:Parent)}
       end}
      {Parent tk(crea rect
		 X1 Y1 X2 Y2
		 fill:grey
		 tags:Tagr)}
      {Parent tk(crea line X1 Y2 X1 Y1 X2 Y1
		 fill:white
		 tags:Tagl1)}
      {Parent tk(crea line X2 Y1 X2 Y2 X1 Y2
		 fill:black
		 tags:Tagl2)}
      case {Length Text}==1 then
	 {Parent tk(crea text
		    (X1+X2) div 2
		    (Y1+Y2) div 2
		    text:Text
		    tags:Tagt)}
      else
	 {Parent tk(crea text
		    ((X1+X2) div 2)-2
		    (Y1+Y2) div 2
		    text:[{Nth Text 1}]
		    tags:Tagt)}
	 {Parent tk(crea text
		    ((X1+X2) div 2)+2
		    (Y1+Y2) div 2
		    text:[{Nth Text 2}]
		    tags:Tagt)}
      end
      {Parent tk(addtag Tagb withtag Tagr)}
      {Parent tk(addtag Tagb withtag Tagl1)}
      {Parent tk(addtag Tagb withtag Tagl2)}
      {Parent tk(addtag Tagb withtag Tagt)}
      {Tagb tkBind(event:'<Enter>'
		   action:self#highlight(Tagr c(224 224 224)))}
      {Tagb tkBind(event:'<Leave>'
		   action:self#highlight(Tagr grey))}
      {Tagb tkBind(event:'<1>'
		   action:self#click(Tagl1 Tagl2 Tagt Proc))}
      {Tagb tkBind(event:'<B1-ButtonRelease>'
		   action:self#release(Tagl1 Tagl2 Tagt))}
   end

   meth highlight(Tag Col)
      {Tag tk(itemconfigure fill:Col)}
   end

   meth click(Tagl1 Tagl2 Tagt Proc)
      lock
	 {Tagl1 tk(itemconfigure fill:black)}
	 {Tagl2 tk(itemconfigure fill:white)}
	 {Tagt tk(move 1 1)}
         % on bouge deja de 1
	 {self Proc}
         % on fait tout dans un thread
	 local
	    proc {MW}
	       {self Proc}
	       {Delay 100}
	       {MW}
	    end
	    proc {WAIT}
	       case @threadid==nil then {WAIT} else skip end
	    end
	 in
	    thread
	       threadid<-{Thread.this $}
	       {Delay 500}
	       {MW}
	    end
	    {WAIT}
	 end
      end
   end
   
   meth release(Tagl1 Tagl2 Tagt)
      lock
	 {Tagl1 tk(itemconfigure fill:white)}
	 {Tagl2 tk(itemconfigure fill:black)}
	 {Tagt tk(move ~1 ~1)}
	 try {Thread.terminate @threadid}
	 catch X then skip
	 end
	 threadid<-nil
      end
   end
   
   meth skipit
      skip
   end
      
   meth init(P COLOR DIALOGBOX CLIENT)
      self.dialogbox=DIALOGBOX
      self.color=COLOR
      self.canvas={New Tk.canvas tkInit(parent:P
					width:400
					height:20
					highlightthickness:0
					borderwidth:0
					bg:gray)}
      self.rightcanvas={New Tk.canvas tkInit(parent:P
					     width:40
					     height:20
					     bg:gray)}
      self.leftcanvas={New Tk.canvas tkInit(parent:P
					    width:40
					    height:20
					    bg:gray)}
      {CLIENT setmousestatus(P "<Left>=set outline color, <Right>=set fill color, <Center>=change color")}
      ColorBar,drawbutton(self.leftcanvas 22 2 40 20 "<" moveleft)
      ColorBar,drawbutton(self.leftcanvas 2  2 20 20 "<<" pageleft)
      ColorBar,drawbutton(self.rightcanvas 2  2 20 20 ">" moveright)
      ColorBar,drawbutton(self.rightcanvas 22 2 40 20 ">>" pageright)
      nu<-1  % numero de celui affiche le plus a gauche
      tagsarray<-{New Objarrayclass init(20 nil)}
      nudisp<-20 % nombre de machins affiches
      {self alloctags}
      {List.forAllInd ['' c(255 255 255) c(0 0 0) c(255 0 0) c(0 255 0)
		       c(0 0 255)
		       c(255 255 0) c(255 0 255) c(0 255 255)
		       c(31 31 31) c(63 63 63) c(95 95 95) c(127 127 127)
		       c(159 159 159) c(191 191 191) c(223 223 223)]
       proc {$ I C}
	  {self setcolor(I C)}
       end}
      {P tkBind(event:'<Configure>'
		action:self#Resized
		args: [float(h) float(w)]
		append:true)}
      {Tk.batch [grid(self.leftcanvas  row:0 column:0)
		 grid(self.canvas      row:0 column:1 sticky:we)
		 grid(self.rightcanvas row:0 column:2)
		 grid(columnconfigure P 1 weight:1)
		 grid(propagate self.canvas false)]}
      threadid<-nil
      {P tk(configure width:400)}
   end

   meth moveleft
      case @nu<2 then
	 skip % rien a faire
      else
	 nu<-@nu-1
	 {self.canvas tk(move all 20 0)}
      end
   end

   meth moveright
      case @nu+@nudisp-2>{@tagsarray size($)} then
	 % on va creer l'espace supplementaire
	 {@tagsarray expand({@tagsarray size($)}+@nudisp)}
	 % et y associer des tags vide
	 {self alloctags}
      else skip end
      nu<-@nu+1
      {self.canvas tk(move all ~20 0)}
%      {self.canvas tk(xview moveto @nu*20)}
   end

   meth pageleft
      Old in
      Old=@nu
      nu<-Old-(@nudisp-1)
      case @nu<1 then nu<-1 else skip end
      {self.canvas tk(move all (Old-@nu)*20 0)}
   end

   meth pageright
      case @nu+@nudisp*2+2>{@tagsarray size($)} then
	 % on va creer l'espace supplementaire
	 {@tagsarray expand(@nu+@nudisp*2+10)}
	 % et y associer des tags vide
	 {self alloctags}
      else skip end      
      nu<-@nu+(@nudisp-1)
      {self.canvas tk(move all ~20*(@nudisp-1) 0)}
   end
   
   meth setcolor(N C)
      case C=='' then % vide
	 X1 Y1 X2 Y2 Tag in
	 Tag={@tagsarray get(N $)}.tags
	 [X1 Y1 X2 Y2]={self.canvas tkReturnListInt(bbox(Tag) $)}
	 {self.canvas tk(delete Tag)}
	 {self.canvas tk(crea rect
			 X1+1 Y1+1 X2-1 Y2-1
			 fill:white
			 outline:black
			 tags:Tag)}
	 {self.canvas tk(crea line
			 X1+1 Y1+1 X2-1 Y2-1 X2-1 Y1+1 X1+1 Y2-1
			 fill:black
			 tags:Tag)}
	 {ForAll ['<1>' '<Shift-1>' '<Shift-3>' '<2>' '<Control-1>']
	  proc{$ Event}
	     {Tag tkBind(event:Event
			 action:proc{$} skip end)}
	  end}
      else skip
	 {{@tagsarray get(N $)}.tags tk(itemconfigure fill:C)}
      end
      {Assign {@tagsarray get(N $)}.color C}
   end
   
   meth alloctags
      local
	 proc {PROC N}
	    case {@tagsarray get(N $)}==nil then
	       local T C in
		  T={New Tk.canvasTag tkInit(parent:self.canvas)}
		  {T tkBind(event:'<1>'
			    action:self#setoutlinecolor(N))}
		  {T tkBind(event:'<3>'
			    action:self#setfillcolor(N))}
		  {T tkBind(event:'<Shift-1>'
			    action:self#getoutlinecolor(N))}
		  {T tkBind(event:'<Shift-3>'
			    action:self#getfillcolor(N))}
		  {T tkBind(event:'<2>'
			    action:self#changecolor(N))}
		  {T tkBind(event:'<Control-1>'
			    action:self#changecolor(N))}
		  {self.canvas tk(crea rect
				  (N-@nu)*20+1 1
				  (N-@nu+1)*20-1 19
				  outline:black
				  fill:c(255 255 255)
				  tags:T)}
		  C={NewCell c(255 255 255) $}
		  {@tagsarray put(N c(tags:T color:C))}
	       end
	    else skip end
	    case N<{@tagsarray size($)} then
	       {PROC N+1}
	    else skip end
	 end
      in
	 {PROC 1}
      end
   end

   meth Resized(H W)
%      {self.canvas tk(configure width:W)} % on se resize
      % quand a savoir pourquoi il faut faire -4.0 ici ???
      nudisp<-{FloatToInt (W-1.0)/20.0+1.0}
      case @nu+@nudisp-1>{@tagsarray size($)} then
	 % on va creer l'espace supplementaire
	 {@tagsarray expand({@tagsarray size($)}+@nudisp)}
	 % et y associer des tags vide
	 {self alloctags}
      else skip end      
   end

   meth setoutlinecolor(N)
      local C A in
	 C={Access {@tagsarray get(N $)}.color $}
	 A={self.color getactions($)}
	 {self.color setoutlinecolor(C)}
	 case A==nil then
	    skip
	 else
	    {A setoutlinecolor(C)}
	 end
      end
   end

   meth setfillcolor(N)
      local C A in
	 C={Access {@tagsarray get(N $)}.color $}
	 A={self.color getactions($)}
	 {self.color setfillcolor(C)}
	 case A==nil then
	    skip
	 else
	    {A setfillcolor(C)}
	 end
      end
   end

   meth getoutlinecolor(N)
      {self setcolor(N {self.color getoutlinecolor($)})}
   end

   meth getfillcolor(N)
      local C in
	 C={self.color getfillcolor($)}
	 case {IsRecord C $} then
	    case {Width C $}==3 then
	       {self setcolor(N {self.color getfillcolor($)})}
	    else skip end
	 else skip end
      end
   end

   meth changecolor(N)
      D F Ss O Col C
   in
      O={Access {@tagsarray get(N $)}.color $}
      case O=='' then % transparent
	 C=c(255 255 255)
      else
	 C=O
      end
      Col={self.dialogbox chooseColor(title:'Color selection'
				      initialcolor:C)}
      case Col=='' then skip else
	 {self setcolor(N Col)}
      end
   end     

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cette classe gere le debug interne du programme
%
%

class Debug

   feat win frame button
   
   meth init(P C)
      local
	 \insert 'textwindow.oz'
      in
	 self.frame={New Tk.frame tkInit(parent:P
					 bd:3
					 relief:groove
					 width:56)}
	 self.button={New Tk.button tkInit(parent:self.frame
					   text:'Debug'
					   action:proc {$}
						     {C debug}
						  end)}
	 self.win={New Window open('Debug Window')}
	 {Tk.send pack(self.button)}
	 {Tk.send pack(self.frame anchor:n fill:y)}
      end
   end

   meth print(Msg)
      {self.win print({StringToAtom {VirtualString.toString Msg}})}
   end

   meth close
      {self.win close}
   end
      
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cette classe permet de simuler un reseau lent
%
%

class SlowNet

   feat frame chkbutton
   
   meth init(P C)
      self.frame={New Tk.frame tkInit(parent:P
				      bd:3
				      relief:groove
				      width:56)}
      self.chkbutton={New Tk.checkbutton tkInit(parent:self.frame
						text:'Slow'
						action:proc {$}
							  {C switchslownetwork}
						       end)}
      {Tk.send pack(self.chkbutton)}
      {Tk.send pack(self.frame anchor:n fill:y)}
   end

end
