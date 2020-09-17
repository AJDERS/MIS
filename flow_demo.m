%  Demonstration for showing the pulsatile flow in the
%  human body
%
%  Version 2.0, 3/9-98, JAJ
%  Version 3.0, 18/9-2017, JAJ
%     Improved version with better display and distances on
%  Version 3.1, 17/9-2018, JAJ
%     Small changes in font sizes

%  Set default text font and line size

clf
set(0,'defaultaxesfontsize',18);
set(0,'defaulttextfontsize',18);

hp1=axes('Units','normalized','position',[0.25 0.1 0.7 0.8]);  %  Window for presentation
axes(hp1)

%  Place push buttons on the display

t1=uicontrol('Style','Pushbutton','Units','normalized','Position',[0.02 0.8 0.15 0.08],...
             'Callback','carotid','String','Carotid artery','FontSize', 16);

t2=uicontrol('Style','Pushbutton','Units','normalized','Position',[0.02 0.7 0.15 0.08],...
             'Callback','femoral','String','Femoral artery','FontSize', 16);
          
          
t3=uicontrol('Style','Pushbutton','Units','normalized','Position',[0.02 0.5 0.15 0.08],...
             'Callback','show_pro','String','Movie','FontSize', 16);

t3a=uicontrol('Style','Pushbutton','Units','normalized','Position',[0.02 0.4 0.15 0.08],...
             'Callback','movie(M,20,20*62/60);','String','Repeat movie','FontSize', 16);

t3b=uicontrol('Style','Pushbutton','Units','normalized','Position',[0.02 0.3 0.15 0.08],...
              'Callback','movie(M,20,10*62/60);','String','Repeat slow','FontSize', 16);

t4=uicontrol('Style','Pushbutton','Units','normalized','Position',[0.02 0.15 0.15 0.08],...
             'Callback','plot_pro','String','Profiles','FontSize', 16);

t4=uicontrol('Style','Pushbutton','Units','normalized','Position',[0.02 0.05 0.15 0.08],...
             'Callback','movement','String','Scatterer movement','FontSize', 16);
          
%  Initialize data for the carotid artery

carotid
