function tests = test_pendulum_ui
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projectRoot);
testCase.addTeardown(@() rmpath(projectRoot));
end

function testRunAndMinimumSize(testCase)
fig = openSimulator(testCase);
fig.Position = [100 100 650 450];
drawnow;
verifyGreaterThanOrEqual(testCase, fig.Position(3:4), [900 600]);

runButton = findall(fig, 'Type', 'uibutton', 'Text', 'Run');
feval(runButton.ButtonPushedFcn, runButton, []);
state = getappdata(fig, 'animState');
stop(state.timer);
verifyEqual(testCase, state.nFrames, 751);
verifyEqual(testCase, state.timerPeriod, 0.033, 'AbsTol', eps);
verifyGreaterThanOrEqual(testCase, state.playbackTime, 0);
verifyLessThan(testCase, state.playbackTime, 0.2);
end

function testSpeedControlAndPhaseLegend(testCase)
fig = openSimulator(testCase);
runButton = findall(fig, 'Type', 'uibutton', 'Text', 'Run');
feval(runButton.ButtonPushedFcn, runButton, []);
state = getappdata(fig, 'animState');
stop(state.timer);

speedControl = findall(fig, 'Type', 'uidropdown');
speedControl.Value = '0.25x';
feval(speedControl.ValueChangedFcn, speedControl, []);
state = getappdata(fig, 'animState');
verifyEqual(testCase, state.speedMult, 0.25);

axesObjects = findall(fig, 'Type', 'axes');
phaseAxis = axesObjects(arrayfun(@(ax) strcmp(ax.Title.String, ...
    'Phase Portrait  (theta vs omega)'), axesObjects));
legendObject = legend(phaseAxis);
verifyEqual(testCase, legendObject.String, {'Start','End'});
verifyEqual(testCase, numel(legendObject.PlotChildren), 2);
end

function testAnimationGeometryAndPlotLabels(testCase)
fig = openSimulator(testCase);
axesObjects = findall(fig, 'Type', 'axes');
titles = arrayfun(@(ax) string(ax.Title.String), axesObjects);
angleAxes = axesObjects(ismember(titles, ["Angular Displacement", "Angular Velocity"]));
labels = arrayfun(@(ax) {ax.Title.String, ax.XLabel.String, ax.YLabel.String}, ...
    angleAxes, 'UniformOutput', false);
runButton = findall(fig, 'Type', 'uibutton', 'Text', 'Run');
for run = 1:2
    feval(runButton.ButtonPushedFcn, runButton, []);
    state = getappdata(fig, 'animState');
    stop(state.timer);
    for k = 1:numel(angleAxes)
        ax = angleAxes(k);
        verifyEqual(testCase, {ax.Title.String, ax.XLabel.String, ax.YLabel.String}, labels{k});
        verifyEqual(testCase, char(ax.XGrid), 'on');
    end
end

ax = state.hRod.Parent;
verifyLessThanOrEqual(testCase, [ax.XLim(1) ax.YLim(1)], ...
    -(state.L + state.R) * [1 1]);
verifyGreaterThanOrEqual(testCase, [ax.XLim(2) ax.YLim(2)], ...
    (state.L + state.R) * [1 1]);

state.t = [0; 1];
state.theta = deg2rad([150; 210]);
state.bx = state.L * sin(state.theta);
state.by = -state.L * cos(state.theta);
state.nFrames = 2;
state.playing = true;
state.playbackTime = 0.5 - state.timerPeriod;
state.speedMult = 1;
setappdata(fig, 'animState', state);
feval(state.timer.TimerFcn, state.timer, []);
verifyEqual(testCase, state.hRod.XData(end), 0, 'AbsTol', 1e-12);
verifyEqual(testCase, state.hRod.YData(end), state.L, 'AbsTol', 1e-12);
verifyEqual(testCase, hypot(state.hRod.XData(end), state.hRod.YData(end)), ...
    state.L, 'AbsTol', 1e-12);
verifyEqual(testCase, state.hAngleTxt.String, 'theta = 180.0 deg');
end

function fig = openSimulator(testCase)
close(findall(groot, 'Type', 'figure', 'Name', 'Pendulum Simulator'));
pendulum_simulator;
drawnow;
fig = findall(groot, 'Type', 'figure', 'Name', 'Pendulum Simulator');
testCase.addTeardown(@() closeSimulator(fig));
end

function closeSimulator(fig)
if ~isempty(fig) && isvalid(fig)
    fig.CloseRequestFcn(fig, []);
end
end
