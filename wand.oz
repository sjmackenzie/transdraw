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


proc{ArrayForAllInd Arr P}
   proc{Loop I}
      case I=<{Array.high Arr} then
	 {P I {Array.get Arr I}}
	 {Loop I+1}
      else
	 skip
      end
   end
in
   {Loop {Array.low Arr}}
end

class Wand

   attr visible state x y col lg sx sy
   
   feat canvas client dict tag myname
   
   meth init(DC CLIENT MyName)
      self.myname=MyName
      self.canvas=DC
      self.client=CLIENT
      self.dict={NewDictionary}
      visible<-false
      state<-0
      col<-black
      self.tag={New Tk.canvasTag tkInit(parent:self.canvas)}
      lg<-{Sqrt 15.0*15.0+20.0*20.0}
   end

   meth draw(OX1 OY1 OX2 OY2 Col Tag Name)
      Scale={self.client getscale($)}
      X1 Y1 X2 Y2
      Anchor X Y Ang in
      X1=OX1*Scale Y1=OY1*Scale
      X2=OX2*Scale
      Y2=OY2*Scale
      {self.canvas tk(delete Tag)}
      {self.canvas tk(crea line
		      X1 Y1
		      X2 Y2
		      arrow:first
		      arrowshape:q(9 15 5)
		      width:5
		      tags:Tag
		      capstyle:round
		      fill:white)}
      {self.canvas tk(crea line
		      X1 Y1
		      X2 Y2
		      arrow:first
		      arrowshape:q(9 15 5)
		      width:3
		      tags:Tag
		      fill:Col)}
      Ang={FloatToInt {Atan2 (X2-X1) (Y2-Y1)}*180.0/3.14159+180.0}
      case Ang>=22 andthen Ang<67 then Anchor=se
      elsecase Ang>=67 andthen Ang<112 then Anchor=e
      elsecase Ang>=112 andthen Ang<157 then Anchor=ne
      elsecase Ang>=157 andthen Ang<202 then Anchor=n
      elsecase Ang>=202 andthen Ang<247 then Anchor=nw
      elsecase Ang>=247 andthen Ang<292 then Anchor=w
      elsecase Ang>=292 andthen Ang<337 then Anchor=sw
      else Anchor=s
      end
      case Anchor
      of nw then X=X2+2.0 Y=Y2+2.0
      [] n then X=X2 Y=Y2+4.0
      [] ne then X=X2-2.0 Y=Y2+2.0
      [] e then X=X2-4.0 Y=Y2
      [] se then X=X2-2.0 Y=Y2-2.0
      [] s then X=X2 Y=Y2-4.0
      [] sw then X=X2+2.0 Y=Y2-2.0
      [] w then X=X2+4.0 Y=Y2
      end
      {self.canvas tk(crea text
		      X Y
		      text:Name
		      font:'Times -10'
		      tags:Tag
		      anchor:Anchor
		      fill:Col)}
   end
   
   meth click(X Y)
      sx<-X
      sy<-Y
      x<-X+@lg/2.0
      y<-Y+@lg*{Sqrt 3.0/4.0}
      Wand,draw(X Y @x @y @col self.tag self.myname)
      state<-1
      {self.client broadWand(X Y @x @y)}
   end

   meth motion(X Y)
      case @state==1 then
	 Scale={self.client getscale($)}
	 D
	 DX=@x-X
	 DY=@y-Y
      in
	 sx<-X
	 sy<-Y
	 % un peu de mathematique ici :
	 % x' et y' doivent se trouver
	 % sur un cercle de rayon sqrt(30*30+40*40), en minimisant
	 % |x-x'|+|y+y'| en norme 2
	 % Merci a Raphael Collet pour la solution de cette enigme
	 D={Sqrt DX*DX+DY*DY}
	 x<-X+@lg*DX/D
	 y<-Y+@lg*DY/D
	 Wand,draw(X Y @x @y @col self.tag self.myname)
	 {self.client broadWand(X Y @x @y)}
      else skip end
   end

   meth smotion(X Y)
      case @state==1 then
	 DX=@x-X
	 DY=@y-Y
      in
	 lg<-{Sqrt DX*DX+DY*DY}
	 case @lg<10.0 then
	    lg<-10.0
	    Wand,motion(X Y)
	 else
	    Wand,draw(X Y @x @y @col self.tag self.myname)
	    {self.client broadWand(X Y @x @y)}
	 end
      else skip end
   end
   
   meth dclick(X Y)
      state<-0
      {self.canvas tk(delete self.tag)}
      {self.client broadDelWand}
   end

   meth release(X Y)
      state<-@state*2
   end

   meth placeWand(C X1 Y1 X2 Y2)
      This in
      This={Dictionary.condGet self.dict C nil}
      case This==nil then
	 % cree une nouvelle entree
	 Tag in
	 Tag={New Tk.canvasTag tkInit(parent:self.canvas)}
	 {Dictionary.put self.dict C r(tag:Tag col:{NewCell black} vis:{NewCell true}
				       x1:{NewCell X1} x2:{NewCell X2} y1:{NewCell Y1} y2:{NewCell Y2}
				       name:'unknown')}
	 Wand,draw(X1 Y1 X2 Y2 black Tag 'unknown')
      else
	 % deplace l'entree precedente
	 {Assign This.x1 X1}
	 {Assign This.x2 X2}
	 {Assign This.y1 Y1}
	 {Assign This.y2 Y2}
	 case {Access This.vis} then
	    Wand,draw(X1 Y1 X2 Y2 {Access This.col} This.tag This.name)
	 else skip end
      end
   end

   meth doRadar(X Y)
      Wand,radar(nil X Y)
      Wand,click(X Y)
      {self.client broadRadar(X Y)}
   end
   
   meth radar(C OX OY)
      try
	 Col Skip
	 Scale={self.client getscale($)}
	 X Y
      in
	 X=OX*Scale Y=OY*Scale
	 case C==nil then Col=@col else
	    case {Access {Dictionary.get self.dict C}.vis} then skip else Skip=unit end
	    Col={Access {Dictionary.get self.dict C}.col}
	 end
	 case {IsFree Skip} then
	    thread
	       Tag={New Tk.canvasTag tkInit(parent:self.canvas)}
	       proc{Loop I}
		  case I>0.0 then
		     {Delay 50}
		     {self.canvas tk(coords Tag
				     X-I Y-I
				     X+I Y+I)}
		     {Loop I-10.0}
		  else
		     {self.canvas tk(delete Tag)}
		  end
	       end
	    in
	       {self.canvas tk(crea oval
			       X-300.0 Y-300.0
			       X+300.0 Y+300.0
			       outline:Col
			       tags:Tag)}
	       {Loop 280.0}
	    end
	 else skip end
      catch _ then skip end
   end		 

   meth deleteWand(C)
      This in
      This={Dictionary.condGet self.dict C nil}
      case This==nil then skip
      else
	 {self.canvas tk(delete This.tag)}
	 {Assign This.x1 ~10000.0}
	 {Assign This.y1 ~10000.0}
	 {Assign This.x2 ~10000.0}
	 {Assign This.y2 ~10000.0}
      end
   end

   meth addWand(C Col Name)
      Tag in
      Tag={New Tk.canvasTag tkInit(parent:self.canvas)}
      {Dictionary.put self.dict C r(tag:Tag col:{NewCell Col} vis:{NewCell true}
				    x1:{NewCell ~1000.0} x2:{NewCell ~1000.0} y1:{NewCell ~900.0} y2:{NewCell ~900.0}
				    name:Name
				   )}      
   end

   meth visible(C B)
      This in
      This={Dictionary.condGet self.dict C nil}
      case This==nil then skip
      else
	 {Assign This.vis B}
	 case B then
	    Wand,placeWand(C {Access This.x1} {Access This.y1} {Access This.x2} {Access This.y2})
	 else
	    {self.canvas tk(delete This.tag)}
	 end
      end
   end

   meth redrawAll
      {ForAll {Dictionary.entries self.dict}
       proc{$ E}
	  case E of C#This then
	     case {Access This.vis} then
		Wand,draw({Access This.x1} {Access This.y1} {Access This.x2} {Access This.y2} {Access This.col} This.tag This.name)
	     else skip end % pas visible
	  else skip end
       end}
      case @state==0 then % reaffiche aussi la baguette courrante
	 skip else
	 Wand,draw(@sx @sy @x @y @col self.tag self.myname)
      end
   end
   
   meth chgCol(C Col)
      This in
      This={Dictionary.condGet self.dict C nil}
      case This==nil then
	 col<-Col
	 {self.canvas tk(itemconfigure self.tag fill:@col)}
      else
	 {Assign This.col Col}
	 case {Access This.vis} then
	    Wand,placeWand(C {Access This.x1} {Access This.y1} {Access This.x2} {Access This.y2})
	 else
	    skip
	 end
      end
   end
  
end

proc{RubberFrame F ?F1 ?F2 V P ?Sep}

   class Separator

      prop locking

      feat canvas linew top parent bot vert
      attr x y pad prc
	 
      meth init(F ?Top ?Bottom V)
	 lock
	    prc<-nil
	    Bot Dummy1 Dummy2 in
	    self.vert=V
	    self.top={New Tk.frame tkInit(parent:F bd:0)}
	    self.bot={New Tk.frame tkInit(parent:F bd:0)}
	    Dummy1={New Tk.frame tkInit(parent:self.top height:4 width:4)}
	    Dummy2={New Tk.frame tkInit(parent:self.bot height:5 width:4)}
	    Top={New Tk.frame tkInit(parent:self.top bd:0)}
	    Bottom={New Tk.frame tkInit(parent:self.bot bd:0)}
	    case self.vert then
	       {Tk.batch [grid(Top     row:0 column:0 sticky:nswe)
			  grid(Dummy1  row:1 column:0 sticky:ns)
			  grid(Bottom  row:1 column:0 sticky:nswe)
			  grid(Dummy2  row:0 column:0 sticky:ns)
			  grid(rowconfigure    self.top 0 weight:1)
			  grid(columnconfigure self.top 0 weight:1)
			  grid(rowconfigure    self.bot 1 weight:1)
			  grid(columnconfigure self.bot 0 weight:1)]}
	    else
	       {Tk.batch [grid(Top     row:0 column:0 sticky:nswe)
			  grid(Dummy1  row:0 column:1 sticky:ns)
			  grid(Bottom  row:0 column:1 sticky:nswe)
			  grid(Dummy2  row:0 column:0 sticky:we)
			  grid(rowconfigure    self.top 0 weight:1)
			  grid(columnconfigure self.top 0 weight:1)
			  grid(rowconfigure    self.bot 0 weight:1)
			  grid(columnconfigure self.bot 1 weight:1)]}
	    end
	    self.parent=F
	    self.canvas={New Tk.canvas tkInit(parent:F
					      height:5
					      bd:0
					      bg:gray)}
	    self.linew={New Tk.canvasTag tkInit(parent:self.canvas)}
	    case self.vert then
	       {self.canvas tk(crea line
			       0 3
			       10000 3
			       fill:white
			       tags:self.linew)}
	       {self.canvas tk(crea line
			       0 4
			       10000 4
			       fill:black)}
	    else
	       {self.canvas tk(crea line
			       3 0
			       3 10000
			       fill:white
			       tags:self.linew)}
	       {self.canvas tk(crea line
			       4 0
			       4 10000
			       fill:black)}
	    end
	    {self.canvas tkBind(event:'<1>'
				args:[float('X') float('Y')]
				action:self#click)}
	    {self.canvas tkBind(event:'<B1-Motion>'
				args:[float('X') float('Y')]
				action:self#move)}
	    {self.canvas tkBind(event:'<ButtonRelease-1>'
				action:self#release)}
	    case self.vert then
	       {Tk.send place(self.top
			      x:0 y:0
			      relwidth:1.0
			      relheight:P
			      anchor:nw
			      bordermode:ignore)}
	       {Tk.send place(self.bot
			      x:0 y:0
			      rely:1.0
			      relx:1.0
			      relwidth:1.0
			      relheight:(1.0-P)
			      anchor:se
			      bordermode:ignore)}
	       {Tk.send place(self.canvas
			      x:0
			      rely:P
			      relwidth:1.0
			      height:8
			      anchor:w
			      bordermode:ignore
			     )}
	    else
	       {Tk.send place(self.top
			      x:0 y:0
			      relwidth:P
			      relheight:1.0
			      anchor:nw
			      bordermode:ignore)}
	       {Tk.send place(self.bot
			      x:0 y:0
			      relx:1.0
			      rely:0.0
			      relwidth:(1.0-P)
			      relheight:1.0
			      anchor:ne
			      bordermode:ignore)}
	       {Tk.send place(self.canvas
			      y:0
			      relx:P
			      relheight:1.0
			      width:8
			      anchor:n
			      bordermode:ignore
			     )}
	    end
	 end
      end

      meth click(X Y)
	 lock
	    x<-X y<-Y
	    {self.canvas tk(configure bg:black)}
	    {self.canvas tk(itemconfigure self.linew fill:black)}
	    case self.vert then
	       pad<-{Tk.returnFloat winfo(rooty self.canvas) $}-Y+4.0
	    else
	       pad<-{Tk.returnFloat winfo(rootx self.canvas) $}-X+4.0
	    end
	 end
      end

      meth move(X Y)
	 lock
	    case self.vert then
	       case Y\=@y then
		  WH OR Val in
		  WH={Tk.returnFloat winfo(height self.parent) $}
		  OR={Tk.returnFloat winfo(rooty self.parent) $}
		  Val=(Y+@pad-OR)/WH
		  case Val>=0.1 andthen Val=<0.9 then
		     {Tk.send place(self.top relheight:Val)}
		     {Tk.send place(self.canvas rely:Val)}
		     {Tk.send place(self.bot relheight:(1.0-Val))}
		  else skip end
		  y<-Y
	       else skip end
	    else
	       case X\=@x then
		  WH OR Val in
		  WH={Tk.returnFloat winfo(width self.parent) $}
		  OR={Tk.returnFloat winfo(rootx self.parent) $}
		  Val=(X+@pad-OR)/WH
		  case Val>=0.1 andthen Val=<0.9 then
		     {Tk.send place(self.top relwidth:Val)}
		     {Tk.send place(self.canvas relx:Val)}
		     {Tk.send place(self.bot relwidth:(1.0-Val))}
		  else skip end
		  x<-X
	       else skip end
	    end
	 end
      end
      
      meth release
	 lock
	    {self.canvas tk(configure bg:gray)}
	    {self.canvas tk(itemconfigure self.linew fill:white)}
	    case @prc==nil then skip else
	       {@prc}
	    end
	 end
      end

      meth setevent(P)
	 prc<-P
      end
      
   end
in
   Sep={New Separator init(F F1 F2 V)}
end
   
class ChatRoom

   feat parent chat people clist entry plist dest send carrow parrow
      chatlist me client separator wand faces leftb rightb facec facelist curface
      curfacetag
   attr height msgarray msgindex name to msglength filter mood facedisp

   meth getcolor(C)
      Min Max
      fun{Get}
	 (({IntToFloat {OS.rand}}-Min)/(Max-Min))*256.0
      end
      X Y T C1 C2 C3
   in
      {OS.randLimits X Y} Min={IntToFloat X} Max={IntToFloat Y}
      C1={FloatToInt {Get}}
      C2={FloatToInt {Get}}
      C3={FloatToInt {Get}}
      case {Abs (C1+C2+C3)-256*3}<40 then C=ChatRoom,getcolor($) else
	 C=c(C1 C2 C3)
      end
   end
   
   meth init(Frame Name Client Wand windows:Windows)
      self.parent=Frame
      self.client=Client
      self.wand=Wand
      name<-Name
      self.facelist=[r(0 0 0) r(0 0 3) r(0 3 3) r(1 0 0) r(1 1 1) r(1 2 2) r(1 3 3) r(2 0 0) r(2 1 1) r(2 2 2) r(2 3 3) r(3 0 0) r(3 1 1) r(3 2 2) r(3 3 3)]
      facedisp<-1
      {RubberFrame self.parent self.chat self.people false 0.8 self.separator}
      local T Tmp in
	 T={New Tk.frame tkInit(parent:self.chat)}
	 self.clist={New Tk.canvas tkInit(parent:T
					  height:1
					  width:1
					  relief:sunken
					  bg:white
					  bd:2
					 )}
	 case Windows then
	    self.carrow={New Tk.scrollbar tkInit(parent:T
						 background:grey
						 borderwidth:1
						 orient:vert)}
	 else
	    self.carrow={New Tk.scrollbar tkInit(parent:T
						 background:grey
						 borderwidth:1
						 orient:vert
						 width:10)}
	 end
	 self.entry={New Tk.entry tkInit(parent:self.chat
					 bg:white)}
	 {self.entry tkBind(event:'<Return>'
			    action:self#sendMsg)}
	 Tmp={New Tk.label tkInit(parent:self.chat
				  text:'To:')}
	 self.curface={New Tk.canvas tkInit(parent:self.chat
					    width:20
					    height:20)}
	 self.dest={New Tk.button tkInit(parent:self.chat
					 text:'Everybody'
					 pady:0
					 action:self#chgDest(nil)
					 anchor:center)}
	 self.send={New Tk.button tkInit(parent:self.chat
					 text:'Send'
					 action:self#sendMsg
					 pady:0)}
	 {Tk.send pack(self.clist side:left expand:true fill:both)}
	 {Tk.send pack(self.carrow side:right fill:y)}
	 {Tk.send pack(T expand:true fill:both anchor:nw)}
	 {Tk.send pack(Tmp side:left fill:y)}
	 {Tk.send pack(self.dest side:left fill:y)}
	 {Tk.send pack(self.send side:right fill:y)}
	 {Tk.send pack(self.entry side:right fill:both expand:true)}
	 {Tk.send pack(self.curface side:right)}
	 self.plist={New Tk.canvas tkInit(parent:self.people
					  height:1 width:1
					  relief:sunken
					  yscrollincrement:20
					  scrollregion:'0 2 1000 3'
					  bg:white
					  bd:2)}
	 case Windows then
	    self.parrow={New Tk.scrollbar tkInit(parent:self.people
						 background:grey
						 borderwidth:1
						 orient:vert)}
	 else
	    self.parrow={New Tk.scrollbar tkInit(parent:self.people
						 background:grey
						 borderwidth:1
						 orient:vert
						 width:10)}
	 end
	 self.faces={New Tk.frame tkInit(parent:self.people)}
	 self.leftb={New Tk.button tkInit(parent:self.faces
					  text:'<'
					  width:1 padx:2 pady:0
					  action:proc{$}
						    case @facedisp>1 then
						       facedisp<-@facedisp-1
						       {self.facec tk(move all 20 0)}
						    else skip end
						 end
					 )}
	 self.rightb={New Tk.button tkInit(parent:self.faces
					   text:'>'
					   width:1 padx:2 pady:0
					   action:proc{$}
						     case @facedisp<{Length self.facelist} then
							facedisp<-@facedisp+1
							{self.facec tk(move all ~20 0)}
						     else skip end
						  end
					  )}
	 self.facec={New Tk.canvas tkInit(parent:self.faces
					  bg:white
					  height:18
					  width:{Length self.facelist}*20)}
	 {Tk.batch [grid(self.plist    row:0 column:0 sticky:nsew)
		    grid(self.parrow   row:0 column:1 sticky:ns)
		    grid(self.faces    row:1 column:0 columnspan:2 sticky:we)
		    grid(rowconfigure self.people 0 weight:1)
		    grid(columnconfigure self.people 0 weight:1)]}
	 {Tk.batch [grid(self.leftb  row:0 column:0 sticky:nsew)
		    grid(self.facec  row:0 column:1 sticky:nsew)
		    grid(self.rightb row:0 column:2 sticky:nsew)
		    grid(columnconfigure self.faces 1 weight:1)]}
	 {self.client setmousestatus(self.parent "Chat room")}
	 {self.client setmousestatus(T "Click on a message to answer to the sender")}
	 {self.client setmousestatus(self.people "Click on a name to send a message to that person")}
	 {self.client setmousestatus(self.faces "Click to change your current face")}
	 {self.client setmousestatus(self.dest "Name of the recipient. Click to send a message to everybody")}
	 {self.client setmousestatus(self.send "Sends the message")}
	 {self.client setmousestatus(self.entry "Type your message here")}
	 {List.forAllInd self.facelist
	  proc{$ I F}
	     T={New Tk.canvasTag tkInit(parent:self.facec)}
	  in
	     ChatRoom,face((I-1)*20+2 2 F self.facec T T black)
	     {T tkBind(event:'<1>'
		       action:self#chgMood(F))}
	  end}
	 self.curfacetag={New Tk.canvasTag tkInit(parent:self.curface)}
	 {Tk.addYScrollbar self.clist self.carrow}
	 {Tk.addYScrollbar self.plist self.parrow}
      end
      self.chatlist={NewDictionary}
      msglength<-100
      msgarray<-{NewArray 0 @msglength-1 nil}
      msgindex<-0
      {ArrayForAllInd @msgarray
       proc{$ I E}
	  Tag in
	  Tag={New Tk.canvasTag tkInit(parent:self.clist)}
	  {Put @msgarray I r(id:nil msg:nil tag:Tag to:nil)}
       end}
      self.me={NewName}
      filter<-nil
      to<-nil
      mood<-r(0 0 0)
      ChatRoom,face(2 2 @mood self.curface self.curfacetag self.curfacetag black)
      ChatRoom,addChater(self.me @name)
      {self.separator setevent(proc{$} ChatRoom,setFilter(@filter) end)}
   end

   meth updChat
      L in
      L={List.filter {Dictionary.items self.chatlist}
	 fun{$ X} X.vis end}
      {List.forAllInd
       {List.sort L
	fun{$ A B}
	   A.name<B.name
	end}
       proc{$ I O}
	  Y in
	  Y=4+((I-1)*20)
	  {self.plist tk(move O.tag 0 Y-{Access O.y})}
	  {Assign O.y Y}
       end}
      {self.plist tk(configure scrollregion:{StringToAtom {VirtualString.toString '0 2 1000 '#({Length L}*20+4)}})}
   end

   meth face(X Y Mood DC Tag1 Tag2 Col)
      {DC tk(crea oval   % face
	     X    Y
	     X+16 Y+16
	     outline:Col
	     fill:white
	     tags:Tag2
	     width:1)}
      {DC tk(crea line   % noze
	     X+8  Y+7
	     X+8  Y+10
	     tags:Tag1
	     fill:Col)}
      case {HasFeature Mood 1} then
	 case Mood.1
	 of 0 then % smiling
	    {DC tk(crea arc
		   X+4  Y+5
		   X+12 Y+13
		   extent:180
		   start:180
		   style:arc
		   tags:Tag2
		   outline:Col)}
	 [] 1 then % neutral
	    {DC tk(crea line
		   X+4  Y+12
		   X+12 Y+12
		   tags:Tag1
		   fill:Col)}
	 [] 2 then % sad
	    {DC tk(crea arc
		   X+4  Y+11
		   X+12 Y+15
		   extent:180
		   start:0
		   style:arc
		   tags:Tag2
		   outline:Col)}
	 [] 3 then % round
	    {DC tk(crea oval
		   X+6  Y+11
		   X+10 Y+15
		   tags:Tag2
		   outline:Col)}
	 else skip end
      else skip end
      case {HasFeature Mood 2} then
	 case Mood.2
	 of 0 then % round
	    {DC tk(crea oval
		   X+4  Y+3
		   X+7  Y+6
		   outline:Col
		   tags:Tag2)}
	 [] 1 then % down left -> up right
	    {DC tk(crea line
		   X+4  Y+6
		   X+7  Y+3
		   fill:Col
		   tags:Tag1)}
	 [] 2 then % up left -> down right 
	    {DC tk(crea line
		   X+7  Y+7
		   X+4  Y+4
		   fill:Col
		   tags:Tag1)}
	 [] 3 then % horiz line
	    {DC tk(crea line
		   X+4  Y+5
		   X+7  Y+5
		   fill:Col
		   tags:Tag1)}
	 else skip end
      else skip end
      case {HasFeature Mood 3} then
	 case Mood.3
	 of 0 then % round
	    {DC tk(crea oval
		   X+9  Y+3
		   X+12 Y+6
		   outline:Col
		   tags:Tag2)}
	 [] 1 then % up left -> down right
	    {DC tk(crea line
		   X+10  Y+4
		   X+13 Y+7
		   fill:Col
		   tags:Tag1)}
	 [] 2 then % down left -> up right
	    {DC tk(crea line
		   X+13  Y+3
		   X+10  Y+6
		   fill:Col
		   tags:Tag1)}
	 [] 3 then % horiz line
	    {DC tk(crea line
		   X+10  Y+5
		   X+13  Y+5
		   fill:Col
		   tags:Tag1)}
	 else skip end
      else skip end
      case {HasFeature Mood 4} then % chapeau
	 case Mood.4
	 of 0 then
	    {DC tk(crea line
		   X    Y+3
		   X+8  Y
		   X+16 Y+3
		   X    Y+3
		   fill:Col
		   tags:Tag1)}
	 [] 1 then
	    {DC tk(crea line
		   X    Y+3
		   X+17 Y+3
		   fill:Col
		   tags:Tag1)}
	    {DC tk(crea rect
		   X+3  Y
		   X+13 Y+3
		   outline:Col
		   fill:white
		   tags:Tag2)}
	 else skip end
      else skip end
   end
   
   meth addChater(ID Name)
      C Tag ColTag ArrowTag RArrowTag NameTag UnderTag This in
      case ID==self.me then C=black else
	 ChatRoom,getcolor(C) % choisit une couleur pour le nouvel entrant
      end
      {ForAll [Tag ColTag ArrowTag NameTag RArrowTag UnderTag]
       proc{$ Tag}
	  Tag={New Tk.canvasTag tkInit(parent:self.plist)}
       end}
      This=ID
      {Dictionary.put self.chatlist ID r(name:Name
					 id:ID
					 col:C
					 vis:true
					 undertag:UnderTag
					 tag:Tag
					 coltag:ColTag
					 arrowtag:ArrowTag
					 rarrowtag:RArrowTag
					 nametag:NameTag
					 arrow:{NewCell true}
					 y:{NewCell 4})}
      {self.plist tk(crea rect
		     2 2
		     10000 22
		     fill:white
		     outline:white
		     tags:UnderTag)}
      {self.plist tk(crea rect
		     4 4
		     20 20
		     outline:black
		     width:1
		     fill:C
		     tags:ColTag)}
      case ID==self.me then
	 ChatRoom,face(24 4 r(0 0 0) self.plist ArrowTag RArrowTag black)
      else
	 {self.plist tk(crea rect
			24 4
			40 20
			outline:black
			fill:white
			tags:RArrowTag
			width:1)}
	 {self.plist tk(crea line
			26 6
			38 18
			arrow:first
			arrowshape:q(5 7 4)
			width:1
			tags:ArrowTag
			fill:C)}
      end
      {self.plist tk(crea text
		     44 4
		     justify:left
		     anchor:nw
		     text:Name
		     font:'Times -14'
		     tags:NameTag
		     fill:black)}
      {ColTag tkBind(event:'<1>'
		     action:self#chgCol(This))}
      case ID==self.me then
	 {ArrowTag tkBind(event:'<Triple-Shift-Control-Button-3>'
			  action:self#chgFace)}
	 {RArrowTag tkBind(event:'<Triple-Shift-Control-Button-3>'
			   action:self#chgFace)}
      else
	 {ArrowTag tkBind(event:'<1>'
			  action:self#switchArrow(This))}
	 {RArrowTag tkBind(event:'<1>'
			   action:self#switchArrow(This))}
      end
      {NameTag tkBind(event:'<1>'
		      action:self#chgDest(This))}
      {UnderTag tkBind(event:'<1>'
		       action:self#chgDest(This))}
      {self.plist tk(addtag Tag withtag UnderTag)}
      {self.plist tk(addtag Tag withtag NameTag)}
      {self.plist tk(addtag Tag withtag ColTag)}
      {self.plist tk(addtag Tag withtag ArrowTag)}
      {self.plist tk(addtag Tag withtag RArrowTag)}
      ChatRoom,updChat
      case ID==self.me then skip else
	 {self.wand addWand(ID C Name)}
      end
   end
   
   meth removeChater(ID)
      try
	 C in
	 C={Dictionary.get self.chatlist ID}
	 {self.plist tk(delete C.tag)}
	 {self.plist tk(dtag C.tag)}
	 {Dictionary.put self.chatlist ID {AdjoinAt C vis false}}
	 ChatRoom,updChat
      catch _ then skip end
   end

   meth removeAllChater
      {ForAll {Dictionary.entries self.chatlist}
       proc{$ L}
	  case L of ID#Name then
	     case ID==self.me then skip else ChatRoom,removeChater(ID) end
	  end
       end}
      {ArrayForAllInd @msgarray
       proc{$ I E}
	  Tag in
	  Tag=E.tag
	  {self.clist tk(delete Tag)}
	  {Put @msgarray I r(id:nil msg:nil tag:Tag to:nil)}	  
       end}
      msgindex<-0
   end

   meth getchatters(IDs)
      IDs={Map
	   {Filter {Dictionary.entries self.chatlist} % ne garde que les restants
	    fun{$ C}
	       case C of ID#Cl then
		  Cl.vis andthen ID\=self.me
	       else false
	       end
	    end}
	   fun{$ C} % ne garde que les couples ID#noms
	      case C of ID#Cl then
		 ID#Cl.name
	      end
	   end}
   end
   
   meth chgCol(ID)
      try
	 Old C in
	 Old={Dictionary.get self.chatlist ID}
	 C={DialogBox chooseColor(parent:self.parent
				  initialcolor:Old.col
				  title:{VirtualString.toString Old.name#"'s color"})}
	 case C=='' then skip
	 else
	    ChatRoom,setCol(ID C)
	 end
      catch _ then skip end
   end

   meth setCol(ID Col)
      try
	 Old in
	 Old={Dictionary.get self.chatlist ID}
	 {Dictionary.put self.chatlist ID {AdjoinAt Old col Col}}
	 {self.plist tk(itemconfigure Old.coltag fill:Col)}
	 {self.plist tk(itemconfigure Old.arrowtag fill:Col)}
	 case ID==self.me then
	    {self.plist tk(itemconfigure Old.rarrowtag outline:Col)}
	 else skip end
	 {self.wand chgCol(ID Col)}
	 ChatRoom,setFilter(@filter)
      catch _ then skip end
   end
   
   meth switchArrow(ID)
      try
	 case ID==self.me then skip else
	    Old in
	    Old={Dictionary.get self.chatlist ID}
	    case {Access Old.arrow} then
	       {Assign Old.arrow false}
	       {self.plist tk('raise' Old.rarrowtag Old.arrowtag)}
	       {self.wand visible(ID false)}
	    else
	       {Assign Old.arrow true}
	       {self.plist tk('raise' Old.arrowtag Old.rarrowtag)}
	       {self.wand visible(ID true)}
	    end
	 end
      catch _ then skip end
   end
   
   meth chgDest(ID)
      try
	 case ID\=nil andthen {Dictionary.get self.chatlist ID}.vis==false then skip else
	    Txt Rst in
	    case @filter==ID andthen @filter\=nil then skip else
	       case @filter==nil then
		  Rst={Dictionary.get self.chatlist self.me}
	       else
		  Rst={Dictionary.get self.chatlist @filter}
	       end
	       {self.plist tk(itemconfigure Rst.undertag fill:white)}
	       case ID==self.me then to<-nil else
		  to<-ID
	       end
	       case ID==nil orelse ID==self.me then Txt='Everybody' else
		  Txt={Dictionary.get self.chatlist ID}.name
	       end
	       {self.dest tk(configure text:Txt)}
	       ChatRoom,setFilter(ID)
	    end
	 end
      catch _ then skip end
   end

   meth chgTo(ID)
      try
	 case ID\=nil andthen {Dictionary.get self.chatlist ID}.vis==false then skip else
	    Txt in
	    case ID==self.me then to<-nil else
	       to<-ID
	    end
	    case ID==nil orelse ID==self.me then Txt='Everybody' else
	       Txt={Dictionary.get self.chatlist ID}.name
	    end
	    {self.dest tk(configure text:Txt)}
	 end
      catch _ then skip end
   end
   
   meth print(Y Msg Width)
      try
	 Txt Col in
	 case Msg.to\=self.me andthen Msg.to\=nil then
	    Col={Dictionary.get self.chatlist self.me}.col
	    Txt={VirtualString.toString "to:"#{Dictionary.get self.chatlist Msg.to}.name}
	 else
	    F1={Dictionary.condGet self.chatlist Msg.id r(name:"???" col:red)} in
	    case Msg.priv then
	       Txt={VirtualString.toString "from:"#F1.name}
	    else
	       Txt=F1.name
	    end
	    Col=F1.col
	 end
	 {self.clist tk(crea text
			24 Y
			anchor:nw
			width:80
			justify:left
			font:'Times -14'
			tags:Msg.tag
			text:Txt
			fill:Col)}
	 case Msg.mood==nil then skip else
	    ChatRoom,face(2 Y-2 Msg.mood self.clist Msg.tag Msg.tag Col)
	 end
	 {self.clist tk(crea text
			110 Y
			anchor:nw
			width:Width-115.0
			justify:left
			font:'Times -14'
			tags:Msg.tag
			text:Msg.msg
			fill:black)}
	 case Msg.to\=self.me then
	    {Msg.tag tkBind(event:'<1>'
			    action:self#chgTo(Msg.to))}
	    {Msg.tag tkBind(event:'<Double-1>'
			    action:self#chgDest(Msg.to))}
	 else
	    {Msg.tag tkBind(event:'<1>'
			    action:self#chgTo(Msg.id))}
	    {Msg.tag tkBind(event:'<Double-1>'
			    action:self#chgDest(Msg.id))}
	 end
      catch _ then skip end
   end

   meth defScroll(Tag)
      {self.clist tk(configure scrollregion:{self.clist tkReturn(bbox(Tag) $)})}
      % s'arrange pour scroller correctement
      local F L in
	 [F L]={self.clist tkReturnListFloat(yview $)}
	 {self.carrow tk(set 1.0-L+F 1.0)}
	 {self.clist  tk(yview moveto 1.0-L+F)}
      end
   end
   
   meth setFilter(ID)
      try
	 Rst Tag Foo in
	 case ID==nil then skip else
	    Rst={Dictionary.get self.chatlist ID}
	    {self.plist tk(itemconfigure Rst.undertag fill:grey)}
	    {self.plist tk(itemconfigure Rst.nametag font:'Times -14')}
	 end
      % efface les anciens
	 Tag={New Tk.canvasTag tkInit(parent:self.clist)}
	 {ArrayForAllInd @msgarray
	  proc{$ I E}
	     case E.id\=nil andthen ChatRoom,disp(E $) then
		case {IsFree Foo} then Foo=unit else skip end
		{self.clist tk(addtag Tag withtag E.tag)}
	     else skip end
	  end}
	 case {IsDet Foo} then
	    {self.clist tk(delete Tag)}
	    {self.clist tk(dtag Tag)}
	 else skip end
      % assigne le nouveau filtre
	 filter<-ID
      % affiche les nouveaux
	 local
	    Y={NewCell 2}
	    Width={Tk.returnFloat winfo(width self.clist) $}
	    Foo
	    proc{Loop I}
	       This={Array.get @msgarray I}
	    in
	       case This.id\=nil andthen ChatRoom,disp(This $) then
		  ChatRoom,print({Access Y} This Width)
		  {self.clist tk(addtag Tag withtag This.tag)}
		  case {IsFree Foo} then Foo=unit else skip end
		  local X1 Y1 X2 Y2 in
		     [X1 Y1 X2 Y2]={self.clist tkReturnListInt(bbox(This.tag) $)}
		     {Assign Y Y2+3}
		  end
	       else
		  skip
	       end
	       case I==(@msgindex mod @msglength) then skip else
		  case I+1<@msglength then
		     {Loop I+1}
		  else
		     {Loop ((I+1) mod @msglength)}
		  end
	       end
	    end
	 in
	    {Loop ((@msgindex+1) mod @msglength)}
         % determine la scroll region
	    case {IsDet Foo} then
	       ChatRoom,defScroll(Tag)
	    else
	       {self.clist tk(configure scrollregion:'0 0 1 1')}
	    end
	    {self.clist tk(dtag Tag)} % tag plus necessaire
	 end
      catch _ then skip end
   end

   meth disp(Msg ?B)
      B=@filter==nil orelse Msg.id==@filter orelse
      (Msg.id==self.me andthen (Msg.to==@filter orelse Msg.to==nil))
   end
   
   meth addMsg(ID Msg Private Mood)
      try
	 Width CurI Cur Scroll Tag Foo Y NewM in
	 Width={Tk.returnFloat winfo(width self.clist) $} % Taille du texte que l'on peut afficher
	 msgindex<-@msgindex+1
	 CurI=@msgindex mod @msglength
	 Cur={Array.get @msgarray CurI}
	 Tag={New Tk.canvasTag tkInit(parent:self.clist)}
	 case ID==self.me then
	    NewM=r(msg:Msg id:ID to:@to tag:Cur.tag priv:Private mood:Mood)
	 else
	    NewM=r(msg:Msg id:ID to:self.me tag:Cur.tag priv:Private mood:Mood)
	 end
	 case @msgindex>@msglength then
	 % on va detruire un vieux message.
	 % il va falloir prevoir de scroller si necessaire
	    case ChatRoom,disp(Cur $) then
	    % ce message etait affiche. On va donc l'effacer
	       local X1 Y1 X2 Y2 in
		  [X1 Y1 X2 Y2]={self.clist tkReturnListInt(bbox(Cur.tag) $)}
		  Scroll=Y2-Y1+1
	       end
	       {self.clist tk(delete Cur.tag)}
	    else skip end
	 else skip end
      % maintenant insere le nouveau message dans la liste
	 {Array.put @msgarray CurI NewM}
      % cree un tag general
	 {ArrayForAllInd @msgarray
	  proc{$ I E}
	     case E.id\=nil andthen I\=CurI andthen ChatRoom,disp(E $) then
		case {IsFree Foo} then Foo=unit else skip end
		{self.clist tk(addtag Tag withtag E.tag)} % ce message est imprime
	     else skip end
	  end}
      % affiche ce nouveau message
	 case ChatRoom,disp(NewM $) then
	    case {IsFree Foo} then
	       Y=2
	    else
	       X1 Y1 X2 Y2 in
	       [X1 Y1 X2 Y2]={self.clist tkReturnListInt(bbox(Tag) $)}
	       Y=Y2+3
	    end
	    ChatRoom,print(Y NewM Width)
	    {self.clist tk(addtag Tag withtag NewM.tag)}
	 else
	 % signale en mettant l'emetteur en gras
	    {self.plist tk(itemconfigure {Dictionary.get self.chatlist NewM.id}.nametag font:'Times -14 bold')}
	 end
      % si necessaire, scroll vers le haut
	 case {IsDet Scroll} then
	    {self.clist tk(move Tag 0 ~Scroll)}
	 else skip end
      % determine la scroll region
	 case {IsDet Foo} then
	    ChatRoom,defScroll(Tag)
	 else
	    {self.clist tk(configure scrollregion:'0 0 1 1')}
	 end
	 {self.clist tk(dtag Tag)} % tag plus necessaire
      catch _ then skip end
   end

   meth clearMsgs
      Rst Tag Foo in
      % efface les anciens
      Tag={New Tk.canvasTag tkInit(parent:self.clist)}
      {ArrayForAllInd @msgarray
       proc{$ I E}
	  case E.id\=nil andthen ChatRoom,disp(E $) then
	     case {IsFree Foo} then Foo=unit else skip end
	     {self.clist tk(addtag Tag withtag E.tag)}
	  else skip end
       end}
      case {IsDet Foo} then
	 {self.clist tk(delete Tag)}
	 {self.clist tk(dtag Tag)}
      else skip end
      % maz
      msgindex<-0
      {ArrayForAllInd @msgarray
       proc{$ I E}
	  Tag in
	  Tag={New Tk.canvasTag tkInit(parent:self.clist)}
	  {Put @msgarray I r(id:nil msg:nil tag:Tag to:nil)}
       end}      
   end
   
   meth sendMsg
      Msg in
      Msg={self.entry tkReturn(get $)}
      {self.entry tk(delete 0 {Length Msg})}
      ChatRoom,addMsg(self.me Msg false @mood)
      {self.client sendmsg(Msg @to @mood)}
   end

   meth chgMood(Mood)
      try
	 X1 Y1 X2 Y2 C in
	 mood<-Mood
	 C={Dictionary.get self.chatlist self.me}
	 [X1 Y1 X2 Y2]={self.plist tkReturnListInt(bbox(C.rarrowtag) $)}
	 {self.plist tk(delete C.arrowtag)}
	 {self.plist tk(delete C.rarrowtag)}
	 ChatRoom,face(24 Y1+1 @mood self.plist C.arrowtag C.rarrowtag C.col)
	 {self.plist tk(addtag C.tag withtag C.arrowtag)}
	 {self.plist tk(addtag C.tag withtag C.rarrowtag)}
	 {self.curface tk(delete self.curfacetag)}
	 ChatRoom,face(2 2 @mood self.curface self.curfacetag self.curfacetag black)
      catch _ then skip end
   end
      
   meth chgFace
      Msg in
      Msg={self.entry tkReturn(get $)}
      ChatRoom,chgMood({List.toRecord r {List.mapInd {self.entry tkReturnListInt(get $)} fun{$ I N} I#N end}})
      {self.entry tk(delete 0 {Length Msg})}
   end
      
end

