close all; clear all; clc

% setup
channels = ['L', 'R'];
Fs = 44100;
nBits = 16;
targetDir = './kemar/elev-10/';
targetFiles = dir(fullfile(targetDir, strcat(channels(1), '*.wav')));

% impulse response pairing
impulseResponsePairs = {}; % todo: preallocate memory based on length(targetFiles)
for i = 1:length(targetFiles)
	fileName = targetFiles(i).name;
	identifier = strip(fileName, 'left', channels(1));
	if exist(fullfile(targetDir, strcat(channels(2), identifier)), 'file')
		% impulse pair exists
		impulseResponsePairs = [impulseResponsePairs; {fileName, strcat(channels(2), identifier)}];
	end
end
disp(impulseResponsePairs);

% sound source
t = 0 : 1/Fs : .2;
f = 1000;
A = .5;
w = 0 * pi/180; % degrees
y = A * sin(2 * pi * f * t + w);
sourceAudio = y;

% recursive convolution
outputAudio = []; % todo: preallocate memory based on size(impulseResponsePairs, 1)
for i = 1:size(impulseResponsePairs, 1)
	[fl,Fsl] = audioread(fullfile(targetDir, impulseResponsePairs{i, 1}));
	[fr,Fsr] = audioread(fullfile(targetDir, impulseResponsePairs{i, 2}));
	if Fsl == Fsr
		convoluted = [conv(sourceAudio, fl, 'valid'); conv(sourceAudio, fr, 'valid')]';
		outputAudio = [outputAudio; convoluted];
	end
end

plot(outputAudio);
sound(outputAudio, Fs, nBits);
