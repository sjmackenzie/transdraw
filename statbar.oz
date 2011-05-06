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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Cette classe va gere la barre de status et les boutons
% de permission / empechement de vol
%

class StatusBar

   feat frame txt butyes butno

   attr curtxt pile id id2 running current

   prop locking
      
   meth init(Parent Default)
      self.frame=Parent
      self.txt={New Tk.label tkInit(parent:Parent
				    text:''
				    relief:ridge
				    anchor:w
				    width:10
				    bd:4
				    bg:gray)}
      self.butyes={New Tk.button tkInit(parent:Parent
					text:'Allow thief'
					action:self#allow
					bg:gray
				       )}
      self.butno={New Tk.button tkInit(parent:Parent
				       text:'Kick thief'
				       action:self#kick
				       bg:gray
				      )}
      {Tk.batch [grid(self.txt    row:0 column:0 sticky:nswe)
		 grid(columnconfigure self.frame 0 weight:1)]}
      curtxt<-''
      pile<-{New Objlistclass init()}
      running<-false
      {@pile addobj(Default)}
      local New in 
	 current<-New
      end
   end

   meth set(Txt)
      curtxt<-Txt
      {self.txt tk(configure text:Txt)}
   end

   meth push(Txt)
      lock
	 {@pile addobj(Txt)}
	 {self set(Txt)}
      end
   end

   meth pop
      lock
	 case {@pile length($)}>1 then
	    {@pile removelast}
	 else
	    skip
	 end
	 {self set({@pile getlast($)})}
      end
   end

   meth blinkbuttons
%      {self.butyes tk(configure state:normal)}
%      {self.butno tk(configure state:normal)}
      {Tk.batch ([grid(self.butyes row:0 column:1 sticky:nswe)
		  grid(self.butno  row:0 column:2 sticky:nswe)])}
      local X in
	 thread
	    local
	       proc{Blink}
		  {self.butyes tk(configure background:red)}
		  {self.butno tk(configure background:gray)}
		  {Delay 500}
		  {self.butyes tk(configure background:gray)}
		  {self.butno tk(configure background:red)}
		  {Delay 500}
		  {Blink}
	       end
	    in
	       X={Thread.this}
	       {Blink}
	    end	       
	 end
	 {Wait X}
	 id<-X
      end
   end

   meth disablebuttons
      try {Thread.terminate @id}
      catch X then skip
      end
      try {Thread.terminate @id2}
      catch X then skip
      end
      running<-false
%      {self.butyes tk(configure state:disabled)}
%      {self.butno tk(configure state:disabled)}
      {Tk.batch ([grid(forget self.butyes)
		  grid(forget self.butno)])}
      {self.butyes tk(configure background:gray)}
      {self.butno tk(configure background:gray)}
   end

   meth start(?B)
      case @running then
	 B=@current % bind current au resultat du vol en cours
	 {Wait B}
      else
	 running<-true
	 local New X in
	    current<-New % unbind current
	    B=@current
	    thread
	       {Thread.this X}
	       {self blinkbuttons}
	       {Delay 5000}
	       @current=true
	       try {Thread.terminate @id}
	       catch X then skip
	       end
	       running<-false
	       {Tk.batch ([grid(forget self.butyes)
			   grid(forget self.butno)])}
%	       {self.butyes tk(configure state:disabled)}
%	       {self.butno tk(configure state:disabled)}
	       {self.butyes tk(configure background:gray)}
	       {self.butno tk(configure background:gray)}
	    end
	    id2<-X
	 end
	 {Wait B}
      end
   end

   meth allow
      @current=true
      {self disablebuttons}
   end

   meth kick
      @current=false
      {self disablebuttons}
   end
   
end
				    
