clear all
close all

%%% load figure data %%%
load ../data/figureData.mat

%%% choose which figures to create %%%
figure1(fig1)
figure2(fig2)
figure3(fig3)
figure4(fig4)
figure5(fig5)
figure6(fig6)
figure7(fig7)
figure8(fig8)

%%% Example NL responses %%%
function figure1(fig1)

    figure(1)

    subplot('position',fig1.POS(1,:))
        plot(fig1.A1.t,fig1.A1.g,'k')
        axis([0 12 0 60 ])
        set(gca,'xtick',0:5:10,'ytick',0:30:60)
        ylabel('conductance (nS)')
        box('off')
        text(9,54,'in-phase','fontsize',8)
        ti = title('A1'); ti.Position = [.7,60,0];

    subplot('position',fig1.POS(2,:))
        plot(fig1.A2.t,fig1.A2.g,'k')
        axis([0 12 00 60 ])
        set(gca,'xtick',0:5:10,'ytick',0:30:60)
        box('off')
        text(7.7,54,'out-of-phase','fontsize',8)
        ti = title('A2'); ti.Position = [.7,60,0];
    subplot('position',fig1.POS(3,:))
        hold all
        plot(fig1.B1.t,fig1.B1.v1,'color','k')
        plot(fig1.B1.t,fig1.B1.v2,'color',fig1.COL(3,:))
        axis([0 12 -75 25 ])
        set(gca,'xtick',0:5:10,'ytick',-60:30:0)
        ylabel('voltage (mV)')
        ti = title('B1'); ti.Position = [.7,25,0];

    subplot('position',fig1.POS(4,:))
        hold all
        plot(fig1.B2.t,fig1.B2.v1,'k')
        plot(fig1.B2.t,fig1.B2.v2,'color',fig1.COL(3,:))
        axis([0 12 -75 25 ])
        set(gca,'xtick',0:5:10,'ytick',-60:30:0)
        leg = legend({'V_1','V_2'},'box','off','fontsize',8);
        leg.Position = [.9 .16+.5 .05 .05];
        leg.ItemTokenSize = [10,1];
        ti = title('B2'); ti.Position = [.7,25,0];
        
    subplot('position',fig1.POS(5,:))
        hold all
        plot(fig1.C1.t,fig1.C1.v1,'k')
        plot(fig1.C1.t,fig1.C1.v2,'color',fig1.COL(2,:))    
        axis([0 12 -75 25 ])
        set(gca,'xtick',0:5:10,'ytick',-60:30:0)
        ylabel('voltage (mV)')
        ti = title('C1'); ti.Position = [.7,25,0];

    subplot('position',fig1.POS(6,:))
        hold all
        plot(fig1.C2.t,fig1.C2.v1,'k')
        plot(fig1.C2.t,fig1.C2.v2,'color',fig1.COL(2,:))    
        axis([0 12 -75 25 ])
        set(gca,'xtick',0:5:10,'ytick',-60:30:0)
        leg = legend({'V_1','V_2'},'box','off','fontsize',8);
        leg.Position = [.9 .16+.25 .05 .05];
        leg.ItemTokenSize = [10,1];
        ti = title('C2'); ti.Position = [.7,25,0];

    subplot('position',fig1.POS(7,:))
        hold all
        plot(fig1.D1.t,fig1.D1.v1,'k')
        plot(fig1.D1.t,fig1.D1.v2,'color',fig1.COL(1,:))
        axis([0 12 -75 25 ])
        set(gca,'xtick',0:5:10,'ytick',-60:30:0)
        xlabel('time (ms)')
        ylabel('voltage (mV)')
        ti = title('D1'); ti.Position = [.7,25,0];

    subplot('position',fig1.POS(8,:))
        hold all
        plot(fig1.D2.t,fig1.D2.v1,'color','k')
        plot(fig1.D2.t,fig1.D2.v2,'color',fig1.COL(1,:))
        axis([0 12 -75 25 ])
        set(gca,'xtick',0:5:10,'ytick',-60:30:0)
        xlabel('time (ms)')
        leg = legend({'V_1','V_2'},'box','off','fontsize',8);
        leg.Position = [.9 .16 .05 .05];
        leg.ItemTokenSize = [10,1];
        ti = title('D2'); ti.Position = [.7,25,0];
        
    set(findall(gcf,'-property','FontSize'),'FontSize',8)
    set(gcf,'units','inches','position',[0 0 5.2 5.5])
    set(gcf, 'PaperPositionMode','auto')


end


%%% ITD TUNING - effect of structure %%%
function figure2(fig2)

    figure(2)

    subplot('position',fig2.POS(1,:))
    hold all    
    errorbar(fig2.A.x1,fig2.A.y1,fig2.A.s1,'linewidth',1,'color',fig2.COL(1,:))
    errorbar(fig2.A.x2,fig2.A.y2,fig2.A.s2,'linewidth',1,'color',fig2.COL(2,:))
    errorbar(fig2.A.x3,fig2.A.y3,fig2.A.s2,'linewidth',1,'color',fig2.COL(3,:))
    
    plot(fig2.A.x1r,fig2.A.y1r,'--','linewidth',1,'color',fig2.COL(1,:))
    plot(fig2.A.x2r,fig2.A.y2r,'--','linewidth',1,'color',fig2.COL(2,:))
    plot(fig2.A.x3r,fig2.A.y3r,'--','linewidth',1,'color',fig2.COL(3,:))
    
    xlabel('TD (\mus)')
    ylabel('spike rate (Hz)')
    axis([1000*[-1.1 1.1]*500/4000 0 550])
    set(gca,'xtick',-100:100:100)
    ti = title('A'); ti.Position = [-125 560 0 ];

    text(137,440,'(.9,.9)','fontsize',8)
    text(137,192,'(.9,.5)','fontsize',8)
    text(137,73,'(.3,.2)','fontsize',8)

    subplot('position',fig2.POS(2,:))
    h = pcolor(fig2.B.X,fig2.B.Y,fig2.B.C);
    h.EdgeColor = 'none';
    set(gca,'xtick',.1:.4:.9,'ytick',.1:.4:.9)
    xl = xlabel('\kappa_{1\rightarrow 2}');
    yl = ylabel('\kappa_{2\rightarrow 1}');
    text(.2, .835, '$\Delta R$ [Hz]','interpreter','latex')
    axis([.05 .95 .05 .95])
    set(gca,'fontsize',10)
    caxis([0 500])
    cb = colorbar;
    colormap(parula)
    box off
  
    xlabel('Forward coupling ($\kappa_{1\rightarrow 2}$)','interpreter','latex');
    ylabel('Backward coupling ($\kappa_{2\rightarrow 1}$)','interpreter','latex');
    ti = title('B'); ti.Position = [0.1  0.97 0 ];
    
    set(findall(gcf,'-property','FontSize'),'FontSize',10)
    set(gcf,'units','inches','position',[0 0 5.2 2.2])
    
end


%%% Coding perspective: input amplitude and mean scatter and thresholds %%%
function figure3(fig3)

    figure(3)
    
    MS = 3;

    subplot('position',fig3.POS(1,:))
    hold all
    plot(fig3.A.x1,fig3.A.y1,'o','markeredgecolor','none','markerfacecolor','k','markersize',MS)
    plot(fig3.A.x2,fig3.A.y2,'o','markeredgecolor','k','markerfacecolor','none','markersize',MS)
    xlabel('g_{mean} (nS)')
    ylabel('g_{amp} (nS)')
    axis([5 35 0  22 ])

    plot(fig3.A.x3,fig3.A.y3,'k','linewidth',1)
    
    meanIn = fig3.A.meanIn;
    meanOut = fig3.A.meanOut;
    plot(meanIn(1),0.9,'kv','markersize',MS+2,'markerfacecolor','k'); 
    plot(meanIn(1)*[1 1],[0.9 3],'k','linewidth',1)
    plot(meanOut(1),0.9,'v','color',.5*[1 1 1],'markersize',MS+2,'markerfacecolor',.5*[1 1 1]); 
    plot(meanOut(1)*[1 1],[0.9 3],'color',.5*[1 1 1],'linewidth',1)
    plot(6.3,meanIn(2),'k<','markersize',MS+4,'markerfacecolor','k'); 
    plot([6.1 9],meanIn(2)*[1 1],'k','linewidth',1)
    plot(6.3,meanOut(2),'<','color',.5*[1 1 1],'markersize',MS+4,'markerfacecolor',.5*[1 1 1]); 
    plot([6.1 9], meanOut(2)*[1 1],'color',.5*[1 1 1],'linewidth',1)
    set(gca,'xtick',[10:10:30],'ytick',[0:10:20])
    ti = title('A'); ti.Position=[6 22 0];
    
    subplot('position',fig3.POS(2,:))
    hold all

    plot(fig3.B.x99, fig3.B.y99,'-o','color',fig3.COL(1,:),'linewidth',1,'markersize',2,'markeredgecolor','none','markerfacecolor',fig3.COL(1,:))
    plot(fig3.B.x95, fig3.B.y95,'-o','color',fig3.COL(2,:),'linewidth',1,'markersize',2,'markeredgecolor','none','markerfacecolor',fig3.COL(2,:))
    plot(fig3.B.x32, fig3.B.y32,'-o','color',fig3.COL(3,:),'linewidth',1,'markersize',2,'markeredgecolor','none','markerfacecolor',fig3.COL(3,:))

    xlabel('g_{mean} (nS)')
    ylabel('g_{amp} (nS)')
    axis([0 35 0  90 ])
    ti = title('B'); ti.Position=[1 91 0];

    leg = legend({'[.9,.9]','[.9,.5]','[.3,.2]'},'box','off');
    leg.String = leg.String(1:3);
    leg.ItemTokenSize = [6,1];

    set(findall(gcf,'-property','FontSize'),'FontSize',10)
    set(gcf,'units','inches','position',[0 0 5.2 2.2])
    set(gcf, 'PaperPositionMode','auto')

end





%%% Nonlinear dynamics and coupling: I-V relation, spike upstroke slope
function figure4(fig4)

    figure(4)

    subplot('position',fig4.POS(1,:))
    hold all
    plot(fig4.A.x99,fig4.A.v99,'linewidth',2,'color',fig4.COL(1,:))
    plot(fig4.A.x95,fig4.A.v95,'linewidth',2,'color',fig4.COL(2,:))
    plot(fig4.A.x32,fig4.A.v32,'linewidth',2,'color',fig4.COL(3,:))
    plot(fig4.A.x0,fig4.A.v0,'k','linewidth',2)
    xlim([-600 1200])
    leg = legend({'[.9,.9]','[.9,.5]','[.3,.2]'},'box','off');
    leg.String = leg.String(1:3);
    leg.ItemTokenSize = [6,1];
    leg.Position = [.14 .65 .07 .1];
    set(gca,'ytick',-65:5:-50,'xtick',-1000:500:1000,'xticklabel',{'','','0','','1000'})
    ti = title('A');
    ti.Position = [-450 -47.5 0];
    xlabel('current (pA)')
    ylabel('V_1 (mV)')


    subplot('position',fig4.POS(2,:))
    h = pcolor(fig4.B.X,fig4.B.Y,fig4.B.C);
    h.EdgeColor = 'none';
    box('off')
    set(gca,'xtick',.3:.2:.9,'ytick',.3:.2:.9)
    cb = colorbar;
    cb.Location ='south';
    cb.Label.Interpreter = 'latex';
    cb.Label.String ='$[mV]$';
    cb.Label.Position = [1.38 3. 0 ];
    cb.FontSize=8;
    cb.Label.FontSize = 8;
    cb.Position = [0.475 0.77 0.12 0.04];
    xl = xlabel('$\kappa_{1\rightarrow 2}$','interpreter','latex','fontsize',10);
    yl = ylabel('$\kappa_{2\rightarrow 1}$','interpreter','latex','fontsize',10);
    set(gca,'xtick',.1:.4:.9,'ytick',.1:.4:.9)
    ti=title('B');
    ti.Position =[.1 1.25 0];


    subplot('position',fig4.POS(3,:))
    h = pcolor(fig4.C.X,fig4.C.Y,fig4.C.C);
    h.EdgeColor = 'none';
    box('off')
    set(gca,'xtick',.3:.2:.9,'ytick',.3:.2:.9)
    cb = colorbar;
    cb.Location ='south';
    cb.Label.Interpreter = 'latex';
    cb.Label.String ='$\log_{10}[mV/ms]$';
    cb.Label.Position = [4 3 0 ];
    cb.FontSize=8;
    cb.Label.FontSize = 8;
    cb.Position = [0.8 0.77 0.12 0.04];
    xl = xlabel('$\kappa_{1\rightarrow 2}$','interpreter','latex','fontsize',10);
    yl = ylabel('$\kappa_{2\rightarrow 1}$','interpreter','latex','fontsize',10);
    set(gca,'xtick',.1:.4:.9,'ytick',.1:.4:.9)
    ti=title('C');
    ti.Position =[.1 1.25 0];
    
    set(gcf,'units','inches','position',[0 0 5.2 2.4])
    set(gcf, 'PaperPositionMode','auto')

end

%%% Integrate-and-fire model %%%%
function figure5(fig5)

    figure(5)

    subplot('position',fig5.POS(1,:))
        plot(fig5.xA1,fig5.yA1,'k','linewidth',fig5.LW)
        ti=title('A1'); ti.Position = [ -1. 5.1260         0];
        xlabel('x')
        ylabel('f(x)')
        text(-.8,4.1,'p=0')
        text(-.8,3,'q=1')
        axis([-1.2 2.4 -1.5 5])
        box('off')
    subplot('position',fig5.POS(2,:))
        plot(fig5.xA2,fig5.yA2,'k','linewidth',fig5.LW)
        text(-.8,4.1,'p=1')
        text(-.8,3,'q=4')
        ti=title('A2'); ti.Position = [ -1. 5.1260  0];
        xlabel('x')
        ylabel('f(x)')
        axis([-1.2 2.4 -1.5 5])
        box('off')
    subplot('position',fig5.POS(3,:))
        hold all
        plot(fig5.xB1,fig5.yB1,'k','linewidth',fig5.LW)
        xlim([0 5])
        xlabel('t')
        ylabel('x')
        ti =title('B1'); ti.Position = [ .3 57 0];
        axis([0 5 -7 55])
        box('off')
    subplot('position',fig5.POS(4,:))
        hold all
        plot(fig5.xB2,fig5.yB2,'k','linewidth',fig5.LW)
        xlim([0 5])
        xlabel('t')
        ylabel('x')
        ti =title('B2'); ti.Position = [ .3 57 0];
        axis([0 5 -7 55])
        box('off')
    subplot('position',fig5.POS(5,:))
        hold all
        for i=1:3
            plot(fig5.xC{i},fig5.yC{i},'linewidth',fig5.LW,'color',fig5.COL(4-i,:))
        end
        ti = title('C'); ti.Position = [.05, 2.8 0];
        txt = text(.59,2.5,'nonlinearity (p)');
        leg = legend(num2str(fig5.P'),'box','off');
        leg.ItemTokenSize = [10,1];
        leg.Position = [.33 .21 .1 0];
        xlabel('g_{mean} (nS)')
        ylabel('g_{amp} (nS)')
        box('off')
    subplot('position',fig5.POS(6,:))
        errorbar(fig5.xD,fig5.yD,fig5.zD,'k','linewidth',fig5.LW)
        axis([.8 4.2 0 850])
        xlabel('spike growth (q)')
        ylabel('spike rate (Hz)')
        set(gca,'xtick',1:5,'ytick',0:200:1000)
        ti=title('D'); ti.Position =  [0.98 860 0];
        box('off')
        set(gca,'ytick',0:400:800)
    set(findall(gcf,'-property','FontSize'),'FontSize',10)
    leg.FontSize=8;
    txt.FontSize=8;
    set(gcf,'units','inches','position',[0 0 5.2 5])
    set(gcf, 'PaperPositionMode','auto')
   
end



% phasic & tonic models: phase planes and bifurcations
function figure6(fig6)

    figure(6)

    subplot('position',fig6.POS(1,:)), hold all
        ti=title('A1'); ti.Position=[-58 .31 0];
     
        plot(fig6.A1.xv{1},fig6.A1.h{1} ,'linewidth',2,'color',[1 1 1]*0);
        plot(fig6.A1.xv{2},fig6.A1.h{2} ,'linewidth',2,'color',[1 1 1]*.4); 
        plot(fig6.A1.xv{3},fig6.A1.h{3} ,'linewidth',2,'color',[1 1 1]*.8);
        plot(fig6.A1.x0,fig6.A1.h0,'k:','linewidth',2)
        xlabel('V_2 (mV)')
        ylabel('h')
        ylim([0 .3])

    subplot('position',fig6.POS(2,:)), hold all
        ti=title('A2'); ti.Position=[-58 .31 0];
        plot(fig6.A2.xv{1},fig6.A2.h{1} ,'linewidth',2,'color',[1 1 1]*0);
        plot(fig6.A2.xv{2},fig6.A2.h{2} ,'linewidth',2,'color',[1 1 1]*.4); 
        plot(fig6.A2.xv{3},fig6.A2.h{3} ,'linewidth',2,'color',[1 1 1]*.8);
        plot(fig6.A2.x0,fig6.A2.h0,'k:','linewidth',2)
        leg = legend(num2str(fig6.A2.vleg'),'box','off');
        leg.Position = [.85 .84 .05 .05];
        leg.ItemTokenSize = [10,1];
        text(-32,.29,'$V_1$','interpreter','latex');xlabel('V_2 (mV)')
        ylabel('h')
        ylim([0 .3])

    subplot('position',fig6.POS(3,:)), hold all
        d = fig6.B1.d; d1 = fig6.B1.d1; d2 = fig6.B1.d2;
            [~,imin] = min(d1);
        plot(d(:,1),d(:,2),'.','color','k')
        plot(fig6.B1.d1(1:imin),fig6.B1.d2(1:imin),'color',.75*[1 1 1])
        plot([0 70],1285.78*[1 1],'k--','linewidth',1)
        axis([0 70 0 4000])
        ylabel('g_{Na} (nS)')
        xlabel('I_{0} (pA)')
        ti=title('B1'); ti.Position=[4 4100 0];

    subplot('position',fig6.POS(4,:)), hold all
        plot(fig6.B2.ds1,fig6.B2.d(fig6.B2.ds2,2),'.','color','k')
        patch([fig6.B2.ds1 fliplr(fig6.B2.ds1)], [fig6.B2.d(fig6.B2.ds2,2) max(ylim)*ones(size(fig6.B2.ds2))], [1 1 1]*.75)   
        plot([0 70],1521.72*[1 1],'k--','linewidth',1)
        axis([0 70 0 4000])
        ti=title('B2'); ti.Position=[4 4100 0];
        xlabel('I_{0} (pA)')
        set(findall(gcf,'-property','FontSize'),'FontSize',10)
        set(gcf,'units','inches','position',[0 0 5.2 4.4])
        set(gcf, 'PaperPositionMode','auto')
end




%%%%% ITD tuning for phasic model  %%%%%
function figure7(fig7)

    figure(7)
    LW = 1;

    subplot('position',fig7.POS(1,:))
        hold all;
        plot(fig7.A.x{1},fig7.A.y{1},'-o','color',fig7.COL(4,:),'linewidth',LW,'markersize',3,'markeredgecolor','none','markerfacecolor',fig7.COL(4,:))
        plot(fig7.A.x{2},fig7.A.y{2},'-o','color',fig7.COL(3,:),'linewidth',LW,'markersize',3,'markeredgecolor','none','markerfacecolor',fig7.COL(3,:))
        plot(fig7.A.x{3},fig7.A.y{3},'-o','color',fig7.COL(2,:),'linewidth',LW,'markersize',3,'markeredgecolor','none','markerfacecolor',fig7.COL(2,:))
        plot(fig7.A.x{4},fig7.A.y{4},'-o','color',fig7.COL(1,:),'linewidth',LW,'markersize',3,'markeredgecolor','none','markerfacecolor',fig7.COL(1,:))
        xlabel('g_{mean}')
        ylabel('g_{amp}')
        ti = title('A'); ti.Position = [2 81 0 ];
        leg = legend(num2str([9 7.7 5 3]'),'box','off');
        leg.Position = [.35 .67 .05 .05];
        leg.ItemTokenSize = [16,1];
        set(gca,'ytick',0:25:75)
        text(27,80,'$\sigma$','interpreter','latex')

    subplot('position',fig7.POS(2,:))
        hold all
        for i=1:4
            errorbar(fig7.B.x,fig7.B.y{i},fig7.B.e{i},'linewidth',LW,'color',fig7.COL(i,:))
            plot(fig7.B.x1,fig7.B.y1{i},'--','linewidth',LW,'color',fig7.COL(i,:))

        end
        xlabel('ITD (\mus)')
        ylabel('spike rate (Hz)')
        axis([1000*[-1.1 1.1]*500/4000 0 550])
        set(gca,'xtick',-100:100:100)
        ti = title('B'); ti.Position = [-125 560 0 ];

    set(findall(gcf,'-property','FontSize'),'FontSize',10)
    set(gcf,'units','inches','position',[0 0 5.2 2.2])
    set(gcf, 'PaperPositionMode','auto')

        
end




%%%%% METHODS: Parameter values %%%%%%%
function figure8(fig8)

    figure(8)
    
    CONFIG = fig8.CONFIG;
    MS = fig8.MS;
    COL = fig8.COL;
    POS = fig8.POS;
    
    subplot('position',fig8.POS(1,:))
    hold all
    [c, h] = contour(fig8.A.XSA,fig8.A.XAS,fig8.A.gCpt1,[115:20:200],'k','linewidth',2);
    clabel(c,h,'labelspacing',200, 'fontsize',8);
    plot(CONFIG(1,1),CONFIG(1,2),'o','markersize',MS,'markeredgecolor','none','markerfacecolor',COL(1,:))
    plot(CONFIG(2,1),CONFIG(2,2),'o','markersize',MS,'markeredgecolor','none','markerfacecolor',COL(2,:))
    plot(CONFIG(3,1),CONFIG(3,2),'o','markersize',MS,'markeredgecolor','none','markerfacecolor',COL(3,:))
    set(gca,'xtick',.1:.4:.9,'ytick',.1:.4:.9)
    ti = title('A','fontsize',14);
    text(.13, .87, 'g_1 [nS]')
    axis([0 1 0 1])
    ylabel('backward coupling (\kappa_{2\rightarrow 1})');
    xlabel('forward coupling (\kappa_{1\rightarrow 2})');
    set(gca,'fontsize',10)

    subplot('position',POS(2,:))
        hold all
        [c, h] = contour(fig8.B.XSA,fig8.B.XAS,fig8.B.gCpt2,[5:30:135],'k','linewidth',2);
        clabel(c,h,'labelspacing',300, 'fontsize',8);
        plot(CONFIG(1,1),CONFIG(1,2),'o','markersize',MS,'markeredgecolor','none','markerfacecolor',COL(1,:))
        plot(CONFIG(2,1),CONFIG(2,2),'o','markersize',MS,'markeredgecolor','none','markerfacecolor',COL(2,:))
        plot(CONFIG(3,1),CONFIG(3,2),'o','markersize',MS,'markeredgecolor','none','markerfacecolor',COL(3,:))
        set(gca,'xtick',.1:.4:.9,'ytick',.1:.4:.9)
        title('g_2 [nS]')
        xl = xlabel('\kappa_{1\rightarrow 2}');
        yl = ylabel('\kappa_{2\rightarrow 1}');
        title('g_2 [nS]')
        axis([0 1 0 1])
        ti = title('B','fontsize',14);
        text(.13, .87, 'g_2 [nS]')
        set(gca,'fontsize',10)

    subplot('position',fig8.POS(3,:))
        hold all
        [c, h] = contour(fig8.C.XSA,fig8.C.XAS,fig8.C.gAx,[30 60 120 240 480],'color','k','linewidth',2);
        clabel(c,h,'labelspacing',118, 'fontsize',8);
        plot(CONFIG(1,1),CONFIG(1,2),'o','markersize',MS,'markeredgecolor','none','markerfacecolor',COL(1,:))
        plot(CONFIG(2,1),CONFIG(2,2),'o','markersize',MS,'markeredgecolor','none','markerfacecolor',COL(2,:))
        plot(CONFIG(3,1),CONFIG(3,2),'o','markersize',MS,'markeredgecolor','none','markerfacecolor',COL(3,:))
        set(gca,'xtick',.1:.4:.9,'ytick',.1:.4:.9)
        axis([0 1 0 1])
        xl = xlabel('\kappa_{1\rightarrow 2}');
        yl = ylabel('\kappa_{2\rightarrow 1}');
        ti = title('C','fontsize',14);
        text(.13, .87, 'g_{ax} [nS]')
        set(gca,'fontsize',10)

    subplot('position',fig8.POS(4,:))
        h = pcolor(fig8.D.X,fig8.D.Y,fig8.D.C);
        h.EdgeColor = 'none';
        set(gca,'xtick',.1:.4:.9,'ytick',.1:.4:.9)
        xl = xlabel('\kappa_{1\rightarrow 2}');
        yl = ylabel('\kappa_{2\rightarrow 1}');
        text(.2, .835, 'g_{Na} [nS]')
        axis([.05 .95 .05 .95])
        set(gca,'fontsize',10)
        cb = colorbar('ticks',1000:2000:7000);
        ti = title('D','fontsize',14);
        colormap('parula')
        box off

    set(findall(gcf,'-property','FontSize'),'FontSize',10)
    set(gcf,'units','inches','position',[0 0 5.2 5])
    set(gcf, 'PaperPositionMode','auto')
    
end
    
    