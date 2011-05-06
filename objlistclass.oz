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



%
% cet objet sert juste a gerer une liste
%

class Objlistclass

   attr liste i n

   meth addobj(O)
      liste<-O|@liste
   end

   meth addobjright(O)
      Objlistclass,setmember(1 O)
   end
   
   meth getlist(?X)
      X=@liste
   end

   meth setlist(X)
      liste<-X
   end

   meth appendlist(L)
      liste<-{List.append {Reverse L} @liste}
   end
   
   meth member(O ?B)
      {Member O @liste ?B}
   end

   meth getmember(N ?O) % retourne le Neme objet de la liste
      {Nth {Reverse @liste $} N O}
   end

   meth setmember(N O) % place O a l'endroit specifie
      D F G T
   in
      {List.takeDrop {Reverse @liste} N-1 F D}
      G=O|D
      T={Append {Reverse G} {Reverse F} $}
      liste<-T
   end

   meth replace(N1 O) % remplace l'element N par la valeur O
      N={Length @liste}-N1+1 in      
      liste<-{List.append {List.take @liste N-1} O|{List.drop @liste N}}
   end

   meth delete(N1)
      N={Length @liste}-N1+1 in
      liste<-{List.append {List.take @liste N-1} {List.drop @liste N}}
   end
   
   meth getindex(O ?N) % retourne l'index de l'objet O
      {List.forAllInd {Reverse @liste}
       proc{$ I P}
	  case {IsFree N} andthen P==O then
	     N=I
	  else skip end
       end}
   end

   meth movemember(N M) % deplace le Neme objet en Meme position
      T in
      T=Objlistclass,getmember(N $) % on obtient l'objet
      Objlistclass,subtract(T)      % on le supprime de la Neme position
      Objlistclass,setmember(M T)   % on l'insere a la Meme position
   end
   
   meth length(?N)
      {Length @liste N}
   end
   
   meth subtract(O)
      liste<-{List.subtract @liste O}
   end

   meth getlast(?O)
      {Nth @liste 1 O}
   end

   meth getfirst(?O)
      {Nth @liste {Length @liste $} O}
   end

   meth removefirst
      liste<-{List.take @liste {Length @liste $}-1 $}
   end

   meth removelast
      liste<-{List.drop @liste 1 $}
   end

   meth drop(N) % abandonne les N derniers elements
      liste<-{List.drop @liste N $}
   end
   
   meth listasstring(?S)
      i<-""
      {ForAll {Reverse @liste}
       proc{$ O}
	  case @i=="" then i<-O else
	     i<-@i#" "#O
	  end
       end}
      S=@i
   end

   meth init()
      liste<-{MakeList 0 $}
   end
end

%
% cet objet sert a gerer un tableau extensible
%

class Objarrayclass

   attr array high inits

   meth init(H I)
      array<-{NewArray 1 H I $}
      high<-H
      inits<-I
   end

   meth expand(H)
      local NEW
	 proc {COPY N}
	    {Put NEW N {Array.get @array N $}}
	    case N<@high then
	       {COPY N+1}
	    else skip end
	 end
      in
	 {NewArray 1 H @inits NEW} % augmente la taille
	 {COPY 1} % recopie les anciens elements
	 high<-H
	 array<-NEW % remplace l'ancien array
      end
   end
   
   meth get(N ?X)
      case N<@high+1 then
	 {Array.get @array N X}
      else
	 {self expand(N+10)}
	 X=@inits
      end
   end

   meth put(N X)
      case N<@high+1 then
	 {Put @array N X}
      else
	 {self expand(N+10)}
	 {Put @array N X}
      end
   end

   meth size(?N)
      {Array.high @array N}
   end

end

% Cette procedure va me permettre de faire des objets stationnaires

proc {NewAsynch Cl Init ?AObj}
   P={NewPort S}
   X={New Cl Init}
   S
in
   proc {AObj M}
      {Send P M}
   end
   thread
      {ForAll S
       proc{$ M}
	  {X M}
       end}
   end
end

proc {NewRedir PortRedir ?AObj}
   proc {AObj M}
      {Send PortRedir M}
   end
end

