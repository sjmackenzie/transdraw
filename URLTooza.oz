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


functor

import
   Application Pickle System(showInfo:Show)

define
   fun{GenFunc URL}
      MyFunc
   in
      MyFunc=functor
      import
	 Tk TkTools Open OS Pickle Remote Module Connection
	 System
	 Application Property
      define
         Windows=({Property.get 'platform'}.os=='win32')
	 local
	    Name
	    T E2 F1 F3 L2 Cl B1 B2 L1
	 in
	    {Tk.send tk_setPalette(grey)}
	    T={New Tk.toplevel tkInit(title:"Start a new editor"
				      delete:proc{$} Cl=false end
				      withdraw:true)}
	    F1={New Tk.frame tkInit(parent:T relief:sunken borderwidth:2)}
	    F3={New Tk.frame tkInit(parent:T)}
	    E2={New Tk.entry tkInit(parent:F1
				    bg:white)}
	    L1={New Tk.label tkInit(parent:F1
				    text:"URL : "#URL
				    anchor:w justify:left)}
	    L2={New Tk.label tkInit(parent:F1
				    text:"Editor user's name :")}
	    {Tk.send pack(L1 side:top padx:5 pady:5)}
	    {Tk.send pack(L2 E2 side:left padx:5 pady:5)}
	    {Tk.send pack(F1 side:top expand:yes fill:both padx:5 pady:5)}
	    {Tk.send pack(F3 side:top expand:yes fill:x padx:5 pady:5)}
	    B1={New Tk.button tkInit(parent:F3
				     text:"Ok"
				     action:proc{$} Cl=true end)}
	    B2={New Tk.button tkInit(parent:F3
				     text:"Cancel"
				     action:proc{$} Cl=false end)}
	    {Tk.batch [pack(B1 B2 side:left padx:5)]}
	    {T tkBind(event:"<Return>"
		      action:proc{$} Cl=true end)}
	    {T tkBind(event:"<Escape>"
		      action:proc{$} Cl=false end)}
	    {Tk.send wm(deiconify T)}
	    {Tk.send focus(E2)}
	    {Wait Cl}
	    local N={E2 tkReturn(get $)} in
	       case N=="" then Name="NoName" else
		  Name=N
	       end
	    end
	    {T tkClose}
	    case Cl then
	       Quit TICKET M L B Error SERVER NEWCLIENT
	       proc{Insert Msg}
		  {L tk(insert 'end' Msg)}
	       end
	    in
	       M={New Tk.toplevel tkInit(title:"Connecting to a drawing"
					 delete:proc{$} {Application.exit 1} end)}
	       L={New Tk.listbox tkInit(parent:M
					width:60
					height:15)}
	       B={New Tk.button tkInit(parent:M
				       text:"Cancel"
				       action:proc{$} {Application.exit 1} end)}
	       {Tk.send pack(L expand:true fill:both)}
	       {Tk.send pack(B side:bottom)}
	       {Tk.send grab(B)}
	       {Insert "Retrieving the ticket from "#URL}
	       try
		  TICKET={Pickle.load URL}
	       catch X then Error=unit end
	       case {IsDet Error} then
		  {Insert "Error : wrong URL (still available ?)"}
	       else
		  {Insert "Ticket : "#TICKET}
		  {Insert "Connecting to the server"}
		  try
		     {Connection.take TICKET SERVER}
		  catch X then Error=unit end
		  case {IsDet Error} then
		     {Insert "Error : wrong ticket (is the drawing server still alive ?)"}
		  else
		     {Insert "Retrieving application"}
		     try
			{SERVER getclientclass(NEWCLIENT)}
		     catch X then Error=unit end
		     case {IsDet Error} then
			{Insert "Error : unable to get the application back."}
		     else
			TEMP in
			{Insert "Linking to local resources"}
			try
			   {NEWCLIENT Tk TkTools Open OS Pickle System Remote Connection Name TEMP Quit 0 0 0 SERVER}
			catch X then Error=unit end
			case {IsDet Error} then
			   {Insert "Error : version conflict ?"}
			else
			   {Insert "Starting application"}
			   {TEMP subscribe(windows:Windows)}
			end
		     end
		  end
	       end
	       case {IsDet Error} then
		  skip
	       else
		  {Tk.send grab(release B)}
		  {M tkClose}
	       end
	       {Wait Quit}
	       {Application.exit 0}
	    else
	       {Application.exit 0}
	    end
	 end
      end
   end
   Args={Application.getCmdArgs plain}
   case {Length Args}\=2  then
      {Show 'Usage: URLTooza <url> <filename.oza>'}
      {Application.exit 2}
   else
      URL={Nth Args 1}
      FILE={Nth Args 2}
      Func={GenFunc URL}
   in
      {Pickle.saveCompressed Func FILE 9}
      {Application.exit 0}
   end
end
