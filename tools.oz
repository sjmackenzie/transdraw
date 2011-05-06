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


   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Classe de la boite d'outils
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class Tool
   
   % Class generique des outils : les differents outils disponibles
   % vont heriter de cette classe en overridant les methodes associees
   % aux evenements TK

   feat tool icon
   
   attr l imageon imageoff

   meth label(L?)
      L=@l
   end

   meth select()
      {self.tool select}
   end

   meth deselect(I)
      {self.tool deselect(I)}
   end
   
   meth drawon()
      {@l tk(configure image:@imageon)}
   end

   meth drawoff()
      {@l tk(configure image:@imageoff)}
   end

   meth gettool(?T)
      T=self.tool
   end

   meth geticon(?I)
      I=self.icon
   end
   
   meth init(FILEOFF FILEON X Y PARENT TOOL ICON ?L)

      % la methode init recoit en entree les deux images a afficher
      % (boutton en etat on et en etat off), la coordonne ou l'afficher,
      % le tk a utiliser et ou le dessiner

      imageon<-{New Tk.image tkInit(type:photo
				    format:gif
				    data:FILEON
				    palette:'6/6/5')}
      imageoff<-{New Tk.image tkInit(type:photo
				     format:gif
				     data:FILEOFF
				     palette:'6/6/5')}
      % les deux images sont crees, on va maintenant afficher quoi et ou
      l<-{New Tk.label tkInit(parent:PARENT image:@imageoff)}
      L=@l
      self.tool=TOOL
      {Tk.batch [grid(@l row:Y column:X)]}
      thread
	 self.icon=ICON
      end
   end
end
   
class ToolBox

   feat act client
   
   attr dc current curtool toolwin thid shown oldone

   prop locking
      
   meth init(T ACTPORT CLIENT)

   % la methode init recoit en entree le canvas de tcl/tk sur lequel on
   % va mettre les outils, ainsi que le nombre d'outils horizontalement
   % et verticalement. Nota : les outils vont etre symbolise par des gifs
   % de 28 pixels X 28 pixels, un gif pour un etat selectionne et un gif
   % pour un etat deselectionne. Nota : me rappeler d'ecrire les commentaires
   % en anglais !!!!!!!!!
      dc<-{New Tk.frame tkInit(parent:T
			       bd:3
			       cursor:'left_ptr'
			       relief:groove
			       bg:gray)}
      {Tk.send pack(@dc side:top anchor:n fill:y)}
      self.act=ACTPORT
%      {Tk.send pack(propagate @dc false)}
      current<-nil
      {CLIENT setmousestatus(@dc "Choose a tool"
			     leave:proc{$}
				      shown<-false
				   end)}
      self.client=CLIENT
      thid<-nil
      shown<-false
      oldone<-nil
      toolwin<-nil
   end

   meth getcurrent(?CURRENT)
      CURRENT=@current
   end

   meth getcurtool(?TOOL)
      TOOL={@current gettool($)}
   end
   
   meth settool(I)
      case @current of
	 nil then
	 current<-I
	 {@current drawon}
	 {@current select}
      else
	 case {@current label($)}=={I label($)} then skip
	 else
	    {@current deselect({I gettool($)})}
	    {@current drawoff}
	    current<-I
	    {@current drawon}
	    {@current select}
	 end
      end
   end

   meth drawtooltip(Label ToolTips)
      case {IsDet ToolTips} then
	 case ToolTips==nil then skip else
	    M X Y in
	    X={Tk.returnInt winfo(rootx Label)}
	    Y={Tk.returnInt winfo(rooty Label)}
	    toolwin<-{New Tk.toplevel tkInit(withdraw:true bg:black width:1 height:1
					     visual:{Tk.return winfo(visual Label)}
					     colormap:Label)}
	    M={New Tk.message tkInit(parent:@toolwin text:ToolTips
				     bg:'#e4e2bc' aspect:800
				     font:"helvetica 8")}
	    {Tk.batch [wm(overrideredirect @toolwin true)
		       wm(geometry @toolwin '+'#{IntToString (X+6)}#'+'#{IntToString (Y+32)})
		       pack(M padx:1 pady:1)
		       wm(deiconify @toolwin)
		       wm(geometry @toolwin '+'#{IntToString (X+6)}#'+'#{IntToString (Y+32)})]}
	 end
      else skip end
   end
   
   meth removetooltip
      case {IsObject @toolwin} then
	 {@toolwin tkClose}
	 toolwin<-nil
      else skip end
   end

   
   meth enter(Label ToolTips)
      lock
	 case @thid==nil then skip else
	    try
	       {Thread.terminate @thid}
	    catch X then skip end
	 end
	 case @shown then
	    case Label==@oldone then skip else
	       {self drawtooltip(Label ToolTips)}
	       oldone<-Label
	    end
	 else
	    local T in thid<-T end
	    thread
	       {Thread.this @thid}
	       {Delay 1000}
	       {self drawtooltip(Label ToolTips)}
	       oldone<-Label
	       shown<-true
	       thid<-nil
	    end
	    {Wait @thid}
	 end
      end
   end

   meth leave(Label)
      lock
	 case @thid==nil then skip else
	    try
	       {Thread.terminate @thid}
	    catch X then skip end
	    thid<-nil
	    oldone<-nil
	    shown<-false
	 end
	 {self removetooltip}
      end
   end
   
   meth addbutton(FILEOFF FILEON X Y TOOL Text ?ICON)
      local I L in
	 I={New Tool init(FILEOFF FILEON X Y @dc TOOL I L)}
	 ICON=I
	 {L tkBind(event:"<1>"
		   action:self.act#toolbut(I))}
	 case @current of
	    nil then
	    current<-I
	    {@current drawon}
	    {@current select}
	 else skip end	 
	 {L tkBind(event:"<Enter>"
		   action:self#enter(L Text))}
	 {L tkBind(event:"<Leave>"
		   action:self#leave(L))}
	 {L tkBind(event:"<Motion>"
		   action:self#enter(L Text))}
      end
   end
   

end

