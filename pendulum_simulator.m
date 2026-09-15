function pendulum_simulator()
%PENDULUM_SIMULATOR Interactive pendulum simulation with UI controls.
% Physics calculations are handled by pendulum_solve.m.

% Configuration
DEF.L      = 1.0;
DEF.m      = 1.0;
DEF.b      = 0.1;
DEF.theta0 = 30;
DEF.omega0 = 0.0;
DEF.g      = 9.81;
DEF.tspan  = 15;
DEF.dt     = 0.02;

C.bg      = [0.10 0.11 0.14];
C.panel   = [0.14 0.16 0.20];
C.accent  = [0.27 0.67 0.95];
C.accent2 = [0.95 0.60 0.20];
C.accent3 = [0.45 0.90 0.55];
C.text    = [0.92 0.93 0.95];
C.subtext = [0.55 0.60 0.68];
C.border  = [0.22 0.25 0.32];
C.red     = [0.95 0.35 0.35];

fig = uifigure('Name','Pendulum Simulator', ...
               'Position',[80 60 1200 720], ...
               'Color',C.bg, 'Resize','on');
fig.AutoResizeChildren = 'off';
fig.CloseRequestFcn = @(~,~) onClose(fig);
fig.SizeChangedFcn = @(src,~) enforceMinSize(src, [900 600]);

rootGrid = uigridlayout(fig,[1 2], ...
    'ColumnWidth',{282,'1x'}, ...
    'RowHeight',{'1x'}, ...
    'Padding',[8 8 8 8], ...
    'ColumnSpacing',8, ...
    'BackgroundColor',C.bg);

leftPanel = uipanel(rootGrid, ...
    'BackgroundColor',C.panel,'BorderType','none');
leftPanel.Layout.Row = 1; leftPanel.Layout.Column = 1;

outerGrid = uigridlayout(leftPanel,[5 1], ...
    'RowHeight',{66, 4, '1x', 4, 90}, ...
    'Padding',[0 6 0 6], ...
    'RowSpacing',0, ...
    'BackgroundColor',C.panel);

titlePanel = uipanel(outerGrid,'BackgroundColor',C.panel,'BorderType','none');
titlePanel.Layout.Row = 1; titlePanel.Layout.Column = 1;

tgT = uigridlayout(titlePanel,[2 1], ...
    'RowHeight',{'1x',22},'Padding',[4 4 4 0],'BackgroundColor',C.panel);
lb1 = uilabel(tgT,'Text','pendulum', ...
    'FontName','Courier New','FontSize',20,'FontWeight','bold', ...
    'FontColor',C.accent,'HorizontalAlignment','center','BackgroundColor',C.panel);
lb1.Layout.Row = 1; lb1.Layout.Column = 1;
lb2 = uilabel(tgT,'Text','SIMULATOR', ...
    'FontName','Courier New','FontSize',10,'FontColor',C.subtext, ...
    'HorizontalAlignment','center','BackgroundColor',C.panel);
lb2.Layout.Row = 2; lb2.Layout.Column = 1;

sep1 = uipanel(outerGrid,'BackgroundColor',C.border,'BorderType','none');
sep1.Layout.Row = 2; sep1.Layout.Column = 1;

paramPanel = uipanel(outerGrid,'BackgroundColor',C.panel,'BorderType','none');
paramPanel.Layout.Row = 3; paramPanel.Layout.Column = 1;

paramDefs = { ...
    'L',      'Pendulum Length',   '(m)',     DEF.L,      [0.1  10  ]; ...
    'm',      'Bob Mass',          '(kg)',    DEF.m,      [0.01 100 ]; ...
    'b',      'Damping Coeff.',    '(Nms)',   DEF.b,      [0    50  ]; ...
    'theta0', 'Initial Angle',     '(deg)',   DEF.theta0, [-180 180 ]; ...
    'omega0', 'Initial Ang. Vel.', '(rad/s)', DEF.omega0, [-50  50  ]; ...
    'g',      'Gravity',           '(m/s^2)', DEF.g,      [0.1  30  ]; ...
    'tspan',  'Sim. Duration',     '(s)',     DEF.tspan,  [1    300 ]; ...
    'dt',     'Output Time Step',  '(s)',     DEF.dt,     [0.001 1  ]; ...
};
nP = size(paramDefs,1);

pGrid = uigridlayout(paramPanel,[nP 1], ...
    'RowHeight',repmat({'1x'},1,nP), ...
    'Padding',[6 4 6 4],'RowSpacing',4,'BackgroundColor',C.panel);

fields = struct();
for k = 1:nP
    card = uipanel(pGrid,'BackgroundColor',C.bg,'BorderType','none');
    card.Layout.Row = k; card.Layout.Column = 1;

    cg = uigridlayout(card,[2 3], ...
        'RowHeight',{18,'1x'},'ColumnWidth',{'fit','1x','fit'}, ...
        'Padding',[6 4 6 4],'RowSpacing',2,'ColumnSpacing',4, ...
        'BackgroundColor',C.bg);

    lbSym = uilabel(cg,'Text',paramDefs{k,1}, ...
        'FontName','Courier New','FontSize',9,'FontWeight','bold', ...
        'FontColor',C.accent,'BackgroundColor',C.bg,'HorizontalAlignment','center');
    lbSym.Layout.Row = 1; lbSym.Layout.Column = 1;

    lbName = uilabel(cg,'Text',paramDefs{k,2}, ...
        'FontName','Courier New','FontSize',9,'FontColor',C.text,'BackgroundColor',C.bg);
    lbName.Layout.Row = 1; lbName.Layout.Column = 2;

    lbUnit = uilabel(cg,'Text',paramDefs{k,3}, ...
        'FontName','Courier New','FontSize',8,'FontColor',C.subtext, ...
        'BackgroundColor',C.bg,'HorizontalAlignment','right');
    lbUnit.Layout.Row = 1; lbUnit.Layout.Column = 3;

    ef = uieditfield(cg,'numeric', ...
        'Value',paramDefs{k,4},'Limits',paramDefs{k,5}, ...
        'FontName','Courier New','FontSize',12,'FontColor',C.accent, ...
        'BackgroundColor',C.panel,'HorizontalAlignment','left');
    ef.Layout.Row = 2; ef.Layout.Column = [1 3];
    fields.(paramDefs{k,1}) = ef;
end

sep2 = uipanel(outerGrid,'BackgroundColor',C.border,'BorderType','none');
sep2.Layout.Row = 4; sep2.Layout.Column = 1;

btnPanel = uipanel(outerGrid,'BackgroundColor',C.panel,'BorderType','none');
btnPanel.Layout.Row = 5; btnPanel.Layout.Column = 1;

bGrid = uigridlayout(btnPanel,[2 2], ...
    'RowHeight',{'1x',26},'ColumnWidth',{'1x','1x'}, ...
    'Padding',[8 6 8 6],'RowSpacing',4,'ColumnSpacing',8, ...
    'BackgroundColor',C.panel);

btnReset = uibutton(bGrid,'push','Text','Reset Parameters', ...
    'FontName','Courier New','FontSize',12,'FontWeight','bold', ...
    'FontColor',C.text,'BackgroundColor',C.red);
btnReset.Layout.Row = 1; btnReset.Layout.Column = 1;

btnRun = uibutton(bGrid,'push','Text','Run', ...
    'FontName','Courier New','FontSize',12,'FontWeight','bold', ...
    'FontColor',C.bg,'BackgroundColor',C.accent);
btnRun.Layout.Row = 1; btnRun.Layout.Column = 2;

statusLbl = uilabel(bGrid,'Text','Ready.', ...
    'FontName','Courier New','FontSize',9,'FontColor',C.subtext, ...
    'HorizontalAlignment','center','BackgroundColor',C.panel);
statusLbl.Layout.Row = 2; statusLbl.Layout.Column = [1 2];

rightPanel = uipanel(rootGrid,'BackgroundColor',C.bg,'BorderType','none');
rightPanel.Layout.Row = 1; rightPanel.Layout.Column = 2;

rGrid = uigridlayout(rightPanel,[1 1],'Padding',[0 0 0 0],'BackgroundColor',C.bg);

tabGroup = uitabgroup(rGrid);
tabGroup.Layout.Row = 1; tabGroup.Layout.Column = 1;

tabAnim   = uitab(tabGroup,'Title','  Animation  ');
tabAngle  = uitab(tabGroup,'Title','  Angle & Vel.');
tabPhase  = uitab(tabGroup,'Title','  Phase Space ');
tabEnergy = uitab(tabGroup,'Title','  Energy      ');

animTabGrid = uigridlayout(tabAnim,[2 1], ...
    'RowHeight',{'1x', 86}, ...
    'Padding',[4 4 4 4],'RowSpacing',4,'BackgroundColor',C.bg);

axAnim = uiaxes(animTabGrid, ...
    'Color',C.bg,'XColor',C.border,'YColor',C.border);
axAnim.Layout.Row = 1; axAnim.Layout.Column = 1;
applyAxStyle(axAnim, C);
title(axAnim,'Pendulum Animation','Color',C.text,'FontName','Courier New','FontSize',14);
axAnim.XTickLabel = {};
axAnim.YTickLabel = {};

% Reuse these graphics objects for every animation frame.
hold(axAnim,'on');
hAnimCeiling  = fill(axAnim, NaN, NaN, C.panel, ...
    'EdgeColor',C.border,'LineWidth',0.5, ...
    'HandleVisibility','off','Visible','off');
hAnimGhost    = plot(axAnim, NaN, NaN, '-', 'Color',[C.accent 0.12], ...
    'LineWidth',1.2,'HandleVisibility','off','Visible','off');
hAnimPivot    = plot(axAnim, 0, 0, 'o', 'MarkerSize',7, ...   % pivot — never moves
    'MarkerFaceColor',C.subtext,'MarkerEdgeColor',C.border, ...
    'LineWidth',1,'HandleVisibility','off','Visible','off');
hAnimTrail    = plot(axAnim, NaN, NaN, '-', 'Color',[C.accent 0.75], ...
    'LineWidth',2.0,'HandleVisibility','off','Visible','off');
hAnimRod      = plot(axAnim, NaN, NaN, '-', 'Color',C.subtext, ...
    'LineWidth',2.5,'HandleVisibility','off','Visible','off');
phi0          = linspace(0, 2*pi, 60);
hAnimBob      = fill(axAnim, NaN(size(phi0)), NaN(size(phi0)), C.accent, ...
    'EdgeColor',C.bg,'LineWidth',0.5,'HandleVisibility','off','Visible','off');
hAnimTimeTxt  = text(axAnim, 0, 0, '', 'FontName','Courier New', ...
    'FontSize',10,'Color',C.subtext,'Visible','off');
hAnimAngleTxt = text(axAnim, 0, 0, '', 'FontName','Courier New', ...
    'FontSize',11,'Color',C.accent,'FontWeight','bold','Visible','off');
hold(axAnim,'off');

ctrlPanel = uipanel(animTabGrid,'BackgroundColor',C.panel,'BorderType','none');
ctrlPanel.Layout.Row = 2; ctrlPanel.Layout.Column = 1;

ctrlGrid = uigridlayout(ctrlPanel,[2 5], ...
    'RowHeight',{40, 32}, ...
    'ColumnWidth',{90, 90, 90, '1x', 150}, ...
    'Padding',[8 6 8 6],'RowSpacing',2,'ColumnSpacing',6, ...
    'BackgroundColor',C.panel);

btnPlay = uibutton(ctrlGrid,'push','Text','Play', ...
    'FontName','Courier New','FontSize',12,'FontWeight','bold', ...
    'FontColor',C.bg,'BackgroundColor',C.accent);
btnPlay.Layout.Row = 1; btnPlay.Layout.Column = 1;

btnPause = uibutton(ctrlGrid,'push','Text','Pause', ...
    'FontName','Courier New','FontSize',12,'FontWeight','bold', ...
    'FontColor',C.text,'BackgroundColor',C.border);
btnPause.Layout.Row = 1; btnPause.Layout.Column = 2;

btnAnimRst = uibutton(ctrlGrid,'push','Text','Restart', ...
    'FontName','Courier New','FontSize',12,'FontWeight','bold', ...
    'FontColor',C.text,'BackgroundColor',[0.20 0.22 0.28]);
btnAnimRst.Layout.Row = 1; btnAnimRst.Layout.Column = 3;

speedHolder = uipanel(ctrlGrid,'BackgroundColor',C.panel,'BorderType','none');
speedHolder.Layout.Row = 1; speedHolder.Layout.Column = 5;
speedInner = uigridlayout(speedHolder,[1 2], ...
    'ColumnWidth',{'fit','1x'},'Padding',[2 0 2 0],'ColumnSpacing',6, ...
    'BackgroundColor',C.panel);
lbSpd = uilabel(speedInner,'Text','Speed:', ...
    'FontName','Courier New','FontSize',10,'FontColor',C.subtext, ...
    'BackgroundColor',C.panel,'HorizontalAlignment','right');
lbSpd.Layout.Row = 1; lbSpd.Layout.Column = 1;
speedDrop = uidropdown(speedInner, ...
    'Items',{'0.25x','0.5x','1x','2x','4x','8x'},'Value','1x', ...
    'FontName','Courier New','FontSize',12, ...
    'FontColor',C.text,'BackgroundColor',C.bg);
speedDrop.Layout.Row = 1; speedDrop.Layout.Column = 2;

scrubSlider = uislider(ctrlGrid, ...
    'Limits',[1 2],'Value',1, ...   % real limits set after each Run
    'MajorTicks',[],'MinorTicks',[], ...
    'FontColor',C.bg);              % match background so track label is invisible
scrubSlider.Layout.Row = 2; scrubSlider.Layout.Column = [1 4];

timeLbl = uilabel(ctrlGrid,'Text','-- / --', ...
    'FontName','Courier New','FontSize',10,'FontColor',C.subtext, ...
    'HorizontalAlignment','right','BackgroundColor',C.panel);
timeLbl.Layout.Row = 2; timeLbl.Layout.Column = 5;

angleGrid = uigridlayout(tabAngle,[2 1], ...
    'RowHeight',{'1x','1x'}, ...
    'Padding',[8 8 8 8],'RowSpacing',8,'BackgroundColor',C.bg);

axTheta = uiaxes(angleGrid,'Color',C.bg,'XColor',C.border,'YColor',C.border);
axTheta.Layout.Row = 1; axTheta.Layout.Column = 1;
applyAxStyle(axTheta, C);
title(axTheta,'Angular Displacement','Color',C.text,'FontName','Courier New','FontSize',12);
xlabel(axTheta,'Time (s)',   'Color',C.subtext,'FontName','Courier New');
ylabel(axTheta,'theta (deg)','Color',C.subtext,'FontName','Courier New');

axOmega = uiaxes(angleGrid,'Color',C.bg,'XColor',C.border,'YColor',C.border);
axOmega.Layout.Row = 2; axOmega.Layout.Column = 1;
applyAxStyle(axOmega, C);
title(axOmega,'Angular Velocity','Color',C.text,'FontName','Courier New','FontSize',12);
xlabel(axOmega,'Time (s)',    'Color',C.subtext,'FontName','Courier New');
ylabel(axOmega,'omega (rad/s)','Color',C.subtext,'FontName','Courier New');

phaseGrid = uigridlayout(tabPhase,[1 1], ...
    'Padding',[8 8 8 8],'BackgroundColor',C.bg);
axPhase = uiaxes(phaseGrid,'Color',C.bg,'XColor',C.border,'YColor',C.border);
axPhase.Layout.Row = 1; axPhase.Layout.Column = 1;
applyAxStyle(axPhase, C);
title(axPhase,'Phase Portrait  (theta vs omega)', ...
    'Color',C.text,'FontName','Courier New','FontSize',14);
xlabel(axPhase,'theta (deg)', 'Color',C.subtext,'FontName','Courier New');
ylabel(axPhase,'omega (rad/s)','Color',C.subtext,'FontName','Courier New');

energyGrid = uigridlayout(tabEnergy,[1 1], ...
    'Padding',[8 8 8 8],'BackgroundColor',C.bg);
axEnergy = uiaxes(energyGrid,'Color',C.bg,'XColor',C.border,'YColor',C.border);
axEnergy.Layout.Row = 1; axEnergy.Layout.Column = 1;
applyAxStyle(axEnergy, C);
title(axEnergy,'Mechanical Energy','Color',C.text,'FontName','Courier New','FontSize',14);
xlabel(axEnergy,'Time (s)',   'Color',C.subtext,'FontName','Courier New');
ylabel(axEnergy,'Energy (J)','Color',C.subtext,'FontName','Courier New');

btnReset.ButtonPushedFcn = @(~,~) cbReset(fields, DEF, statusLbl, C);

btnRun.ButtonPushedFcn = @(~,~) cbRun( ...
    fields, statusLbl, C, fig, btnRun, ...
    axAnim, axTheta, axOmega, axPhase, axEnergy, ...
    scrubSlider, timeLbl, btnPlay, btnPause);

btnPlay.ButtonPushedFcn    = @(~,~) animPlay   (fig, btnPlay, btnPause, C);
btnPause.ButtonPushedFcn   = @(~,~) animPause  (fig, btnPlay, btnPause, C);
btnAnimRst.ButtonPushedFcn = @(~,~) animRestart(fig, btnPlay, btnPause, C);

speedDrop.ValueChangedFcn   = @(src,~) animSetSpeed(fig, src.Value);
scrubSlider.ValueChangedFcn = @(src,~) animScrub(fig, src.Value, btnPlay, btnPause, C);

s0              = blankAnimState();
s0.hCeiling     = hAnimCeiling;
s0.hGhost       = hAnimGhost;
s0.hPivot       = hAnimPivot;
s0.hTrail       = hAnimTrail;
s0.hRod         = hAnimRod;
s0.hBob         = hAnimBob;
s0.hTimeTxt     = hAnimTimeTxt;
s0.hAngleTxt    = hAnimAngleTxt;
s0.scrubSlider  = scrubSlider;
s0.timeLbl      = timeLbl;
setappdata(fig, 'animState', s0);

end  % pendulum_simulator


function s = blankAnimState()
    s.runId       = 0;
    s.timer       = [];
    s.playing     = false;
    s.frameIdx    = 1;
    s.nFrames     = 0;
    s.playbackTime = 0;
    s.timerPeriod = 0.033;
    s.speedMult   = 1.0;
    s.bx          = [];
    s.by          = [];
    s.theta       = [];
    s.t           = [];
    s.L           = 1;
    s.R           = 0.06;
    s.phi         = linspace(0, 2*pi, 60);
    s.trailLen    = 150;
    s.hCeiling    = [];
    s.hGhost      = [];
    s.hPivot      = [];
    s.hTrail      = [];
    s.hRod        = [];
    s.hBob        = [];
    s.hTimeTxt    = [];
    s.hAngleTxt   = [];
    s.scrubSlider = [];
    s.timeLbl     = [];
end

function cbReset(fields, DEF, statusLbl, C)
    names = fieldnames(fields);
    for j = 1:numel(names)
        fields.(names{j}).Value = DEF.(names{j});
    end
    statusLbl.Text      = 'Values reset to defaults.';
    statusLbl.FontColor = C.accent;
end

function cbRun(fields, statusLbl, C, fig, btnRun, ...
               axAnim, axTheta, axOmega, axPhase, axEnergy, ...
               scrubSlider, timeLbl, btnPlay, btnPause)

    % Prevent callback re-entry while drawnow processes UI events.
    btnRun.Enable = 'off';

    % Incrementing runId invalidates callbacks left over from an earlier run.
    s = getappdata(fig, 'animState');
    if ~isempty(s.timer) && isvalid(s.timer)
        stop(s.timer);
        delete(s.timer);
    end
    prevSpeedMult = s.speedMult;
    s.runId   = s.runId + 1;   % invalidate all in-flight callbacks right now
    s.playing = false;
    s.timer   = [];
    setappdata(fig, 'animState', s);
    drawnow;                   % flush any queued callbacks before touching graphics

    L     = fields.L.Value;
    m     = fields.m.Value;
    b     = fields.b.Value;
    th0   = fields.theta0.Value;   % degrees — pendulum_solve converts internally
    om0   = fields.omega0.Value;
    g     = fields.g.Value;
    T     = fields.tspan.Value;
    dtOut = fields.dt.Value;

    statusLbl.Text      = 'Solving ODE ...';
    statusLbl.FontColor = C.subtext;
    drawnow;

    [sol, errMsg] = pendulum_solve(L, m, b, th0, om0, g, T, dtOut);
    if ~isempty(errMsg)
        statusLbl.Text      = ['ODE error: ' errMsg];
        statusLbl.FontColor = C.red;
        btnRun.Enable = 'on';
        return;
    end

    tSol     = sol.t;
    theta    = sol.theta;
    omega    = sol.omega;
    thetaDeg = sol.thetaDeg;
    KE       = sol.KE;
    PE       = sol.PE;
    E        = sol.E;
    bx       = sol.bx;
    by       = sol.by;
    nFrames  = numel(tSol);

    plotIdx = sampleIndices(nFrames, 5000);
    doPlotAngle (axTheta, axOmega, tSol(plotIdx), thetaDeg(plotIdx), omega(plotIdx), C);
    doPlotPhase (axPhase, thetaDeg(plotIdx), omega(plotIdx), C);
    doPlotEnergy(axEnergy, tSol(plotIdx), KE(plotIdx), PE(plotIdx), E(plotIdx), C);

    R   = 0.06 * L;
    phi = linspace(0, 2*pi, 60);
    lim = L * 1.25;

    hCeiling  = s.hCeiling;
    hGhost    = s.hGhost;
    hPivot    = s.hPivot;
    hTrail    = s.hTrail;
    hRod      = s.hRod;
    hBob      = s.hBob;
    hTimeTxt  = s.hTimeTxt;
    hAngleTxt = s.hAngleTxt;
    prevRunId = s.runId;

    axAnim.XLim            = [-lim  lim];
    axAnim.YLim            = [-lim  lim];
    axAnim.DataAspectRatio = [1 1 1];

    hCeiling.XData    = [-lim  lim  lim -lim];
    hCeiling.YData    = [lim*0.02  lim*0.02  lim*0.10  lim*0.10];
    hCeiling.Visible  = 'on';

    hGhost.XData = bx(plotIdx); hGhost.YData = by(plotIdx); hGhost.Visible = 'on';
    hTrail.XData  = bx(1); hTrail.YData = by(1); hTrail.Visible  = 'on';
    hRod.XData    = [0  bx(1)]; hRod.YData = [0  by(1)]; hRod.Visible = 'on';
    hBob.XData    = R*cos(phi) + bx(1);
    hBob.YData    = R*sin(phi) + by(1);
    hBob.Visible  = 'on';

    hPivot.Visible = 'on';

    hTimeTxt.Position  = [-lim*0.95  lim*0.22  0];
    hTimeTxt.String    = '';
    hTimeTxt.Visible   = 'on';
    hAngleTxt.Position = [-lim*0.95  lim*0.14  0];
    hAngleTxt.String   = '';
    hAngleTxt.Visible  = 'on';

    scrubSlider.Limits = [1  max(2, nFrames)];
    scrubSlider.Value  = 1;

    timerPeriod = s.timerPeriod;
    trailLen    = min(nFrames, max(60, round(3.0 / dtOut)));

    newRunId = prevRunId + 1;

    tmr = timer('ExecutionMode','fixedRate','Period',timerPeriod);
    tmr.TimerFcn = @(~,~) animTimerCb(fig, newRunId);
    tmr.StopFcn  = @(~,~) onTimerStop (fig, newRunId);

    s             = blankAnimState();
    s.runId       = newRunId;
    s.timer       = tmr;
    s.playing     = false;
    s.frameIdx    = 1;
    s.nFrames     = nFrames;
    s.playbackTime = tSol(1);
    s.timerPeriod = timerPeriod;
    s.speedMult   = prevSpeedMult;
    s.bx          = bx;
    s.by          = by;
    s.theta       = theta;
    s.t           = tSol;
    s.L           = L;
    s.R           = R;
    s.phi         = phi;
    s.trailLen    = trailLen;
    s.hCeiling    = hCeiling;
    s.hGhost      = hGhost;
    s.hPivot      = hPivot;
    s.hTrail      = hTrail;
    s.hRod        = hRod;
    s.hBob        = hBob;
    s.hTimeTxt    = hTimeTxt;
    s.hAngleTxt   = hAngleTxt;
    s.scrubSlider = scrubSlider;
    s.timeLbl     = timeLbl;
    setappdata(fig, 'animState', s);

    animUpdateTime(fig, tSol(1));
    drawnow;

    statusLbl.Text = sprintf('Done.  Peak: %.1f deg   E0: %.3f J', ...
        max(abs(thetaDeg)), E(1));
    statusLbl.FontColor = C.accent;

    btnRun.Enable = 'on';

    animPlay(fig, btnPlay, btnPause, C);
end

function animTimerCb(fig, runId)
    if ~isvalid(fig), return; end
    s = getappdata(fig, 'animState');
    if isempty(s) || s.runId ~= runId || ~s.playing || s.nFrames == 0, return; end

    s.playbackTime = min(s.playbackTime + s.speedMult * s.timerPeriod, s.t(end));
    s.frameIdx = find(s.t <= s.playbackTime, 1, 'last');
    setappdata(fig, 'animState', s);

    animUpdateTime(fig, s.playbackTime);
    drawnow limitrate;

    if s.playbackTime >= s.t(end)
        stop(s.timer);   % triggers StopFcn → onTimerStop → s.playing = false
    end
end

function onTimerStop(fig, runId)
    if ~isvalid(fig), return; end
    s = getappdata(fig, 'animState');
    if isempty(s) || s.runId ~= runId, return; end
    s.playing = false;
    setappdata(fig, 'animState', s);
end

function animUpdateTime(fig, playbackTime)
    s = getappdata(fig, 'animState');
    if isempty(s) || isempty(s.bx), return; end

    if ~isvalid(s.hRod) || ~isvalid(s.hBob) || ~isvalid(s.hTrail), return; end

    idx = find(s.t <= playbackTime, 1, 'last');
    nextIdx = min(idx + 1, s.nFrames);
    interval = s.t(nextIdx) - s.t(idx);
    fraction = 0;
    if interval > 0
        fraction = (playbackTime - s.t(idx)) / interval;
    end
    theta = s.theta(idx) + fraction * (s.theta(nextIdx) - s.theta(idx));
    bx = s.L * sin(theta);
    by = -s.L * cos(theta);

    s.hRod.XData = [0  bx];
    s.hRod.YData = [0  by];

    s.hBob.XData = s.R * cos(s.phi) + bx;
    s.hBob.YData = s.R * sin(s.phi) + by;

    i0 = max(1, idx - s.trailLen + 1);
    s.hTrail.XData = [s.bx(i0:idx); bx];
    s.hTrail.YData = [s.by(i0:idx); by];

    s.hTimeTxt.String = sprintf('t = %.2f s', playbackTime);
    s.hAngleTxt.String = sprintf('theta = %.1f deg', rad2deg(theta));

    if ~isempty(s.scrubSlider) && isvalid(s.scrubSlider)
        s.scrubSlider.Value = min(idx + fraction, s.scrubSlider.Limits(2));
    end

    if ~isempty(s.timeLbl) && isvalid(s.timeLbl)
        s.timeLbl.Text = sprintf('%.2f / %.2f s', playbackTime, s.t(end));
    end
end

function animPlay(fig, btnPlay, btnPause, C)
    s = getappdata(fig, 'animState');
    if isempty(s) || isempty(s.timer) || ~isvalid(s.timer), return; end

    if s.playbackTime >= s.t(end)
        s.frameIdx = 1;
        s.playbackTime = s.t(1);
        setappdata(fig, 'animState', s);
        animUpdateTime(fig, s.playbackTime);
        drawnow;
        s = getappdata(fig, 'animState');   % re-read after update
    end

    s.playing = true;
    setappdata(fig, 'animState', s);

    if strcmp(s.timer.Running, 'off')
        start(s.timer);
    end

    btnPlay.BackgroundColor  = C.accent2;
    btnPause.BackgroundColor = C.border;
end

function animPause(fig, btnPlay, btnPause, C)
    s = getappdata(fig, 'animState');
    if isempty(s), return; end

    s.playing = false;
    setappdata(fig, 'animState', s);

    if ~isempty(s.timer) && isvalid(s.timer) && strcmp(s.timer.Running,'on')
        stop(s.timer);
    end

    btnPlay.BackgroundColor  = C.accent;
    btnPause.BackgroundColor = C.subtext;
end

function animRestart(fig, btnPlay, btnPause, C)
    animPause(fig, btnPlay, btnPause, C);

    s = getappdata(fig, 'animState');
    if isempty(s) || isempty(s.bx), return; end

    s.frameIdx = 1;
    s.playbackTime = s.t(1);
    setappdata(fig, 'animState', s);
    animUpdateTime(fig, s.playbackTime);
    drawnow;

    animPlay(fig, btnPlay, btnPause, C);
end

function animSetSpeed(fig, speedStr)
    s = getappdata(fig, 'animState');
    if isempty(s), return; end

    s.speedMult = str2double(erase(speedStr, 'x'));
    setappdata(fig, 'animState', s);
end

function animScrub(fig, sliderVal, btnPlay, btnPause, C)
    s = getappdata(fig, 'animState');
    if isempty(s) || isempty(s.bx), return; end

    if s.playing
        animPause(fig, btnPlay, btnPause, C);
        s = getappdata(fig, 'animState');   % re-read after pause writes playing=false
    end

    idx = max(1, min(round(sliderVal), s.nFrames));
    s.frameIdx = idx;
    s.playbackTime = s.t(idx);
    setappdata(fig, 'animState', s);
    animUpdateTime(fig, s.playbackTime);
    drawnow limitrate;
end

function onClose(fig)
    s = getappdata(fig, 'animState');
    if ~isempty(s) && ~isempty(s.timer) && isvalid(s.timer)
        stop(s.timer);
        delete(s.timer);
    end
    delete(fig);
end


function doPlotAngle(axTh, axOm, t, thDeg, om, C)
    cla(axTh); applyAxStyle(axTh, C);
    hold(axTh,'on');
    plot(axTh, t, thDeg, 'Color',C.accent,'LineWidth',1.6);
    yline(axTh, 0, 'Color',C.border,'LineStyle','--','LineWidth',0.8, ...
          'HandleVisibility','off');
    hold(axTh,'off');

    cla(axOm); applyAxStyle(axOm, C);
    hold(axOm,'on');
    plot(axOm, t, om, 'Color',C.accent2,'LineWidth',1.6);
    yline(axOm, 0, 'Color',C.border,'LineStyle','--','LineWidth',0.8, ...
          'HandleVisibility','off');
    hold(axOm,'off');
end

function doPlotPhase(ax, thDeg, om, C)
    cla(ax); applyAxStyle(ax, C);

    n     = numel(thDeg);
    cdata = linspace(0, 1, n)';
    patch(ax, [thDeg; NaN], [om; NaN], [cdata; NaN], ...
          'EdgeColor','interp','FaceColor','none','LineWidth',1.4, ...
          'EdgeAlpha',0.9,'HandleVisibility','off');
    colormap(ax, makeColormap(C.panel, [0.3 0.3 0.5], C.accent3));

    hold(ax,'on');
    hStart = scatter(ax, thDeg(1), om(1), 80, 'o','filled', ...
            'MarkerFaceColor',C.accent2,'MarkerEdgeColor','none','DisplayName','Start');
    hEnd = scatter(ax, thDeg(end), om(end), 60, 's','filled', ...
            'MarkerFaceColor',C.red,   'MarkerEdgeColor','none','DisplayName','End');
    hold(ax,'off');

    legend(ax, [hStart hEnd], {'Start','End'}, ...
           'TextColor',C.subtext,'Color',C.panel, ...
           'EdgeColor',C.border,'FontName','Courier New','FontSize',8);
end

function doPlotEnergy(ax, t, KE, PE, E, C)
    cla(ax); applyAxStyle(ax, C);
    hold(ax,'on');
    plot(ax, t, KE, 'Color',C.accent, 'LineWidth',1.4,'DisplayName','Kinetic');
    plot(ax, t, PE, 'Color',C.accent2,'LineWidth',1.4,'DisplayName','Potential');
    plot(ax, t, E,  'Color',C.text,   'LineWidth',1.8,'LineStyle','--','DisplayName','Total');
    hold(ax,'off');
    legend(ax, 'TextColor',C.subtext,'Color',C.panel, ...
           'EdgeColor',C.border,'FontName','Courier New','FontSize',9);
end


function applyAxStyle(ax, C)
    ax.Color      = C.bg;
    ax.XColor     = C.border;
    ax.YColor     = C.border;
    ax.GridColor  = C.border;
    ax.GridAlpha  = 0.5;
    ax.FontName   = 'Courier New';
    ax.FontSize   = 9;
    ax.XGrid      = 'on';
    ax.YGrid      = 'on';
    box(ax, 'off');
end

function cmap = makeColormap(c1, c2, c3)
    n  = 256;
    h1 = floor(n/2);   h2 = n - h1;
    t1 = linspace(0,1,h1)';
    t2 = linspace(0,1,h2)';
    cmap = [c1 + t1.*(c2-c1);  c2 + t2.*(c3-c2)];
end

function idx = sampleIndices(n, maxPoints)
    idx = unique(round(linspace(1, n, min(n, maxPoints))));
end

function enforceMinSize(fig, minimumSize)
    position = fig.Position;
    newSize = max(position(3:4), minimumSize);
    if any(newSize ~= position(3:4))
        fig.Position = [position(1:2), newSize];
    end
end
