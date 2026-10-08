
%% Experiment 1: Wiener Speech Enhancement
% Clean speech : clean_speech
% Noise        : DKITCHEN, TBUS, PSTATION
% Input SNR    : -5, 0, 5, 10 dB
% Output       : processed WAV files + SNR results + one figure

clear; clc; close all;

%% SETTINGS

targetFs = 16000;
snrLevels = [-5 0 5 10];

cleanFolder  = 'clean_speech';
noiseFolder  = 'noise';
outputFolder = 'output';

noiseFiles = {
    'DKITCHEN.wav'
    'TBUS.wav'
    'PSTATION.wav'
};

noiseNames = {
    'DKITCHEN'
    'TBUS'
    'PSTATION'
};

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

speechFiles = dir(fullfile(cleanFolder, '*.flac'));

%% STFT PARAMETERS

windowLength = 512;
hopLength = 256;
overlapLength = windowLength - hopLength;
nfft = 512;

win = sqrt(hann(windowLength, 'periodic'));

%% RESULT STORAGE

FileName = {};
SpeakerID = {};
NoiseType = {};

TargetSNR = [];
InputSNR = [];
OutputSNR = [];
SNRImprovement = [];

%% MAIN EXPERIMENT

for n = 1:length(noiseFiles)

    % Load noise
    [noise, noiseFs] = audioread( ...
        fullfile(noiseFolder, noiseFiles{n}));

    if size(noise,2) > 1
        noise = noise(:,1);
    end

    if noiseFs ~= targetFs
        noise = resample(noise, targetFs, noiseFs);
    end

    noise = noise(:);
    noise = noise - mean(noise);

    for f = 1:length(speechFiles)

        fileName = speechFiles(f).name;

        % Load clean speech
        [clean, fs] = audioread( ...
            fullfile(cleanFolder, fileName));

        if size(clean,2) > 1
            clean = clean(:,1);
        end

        if fs ~= targetFs
            clean = resample(clean, targetFs, fs);
        end

        clean = clean(:);
        clean = clean - mean(clean);

        % Speaker ID
        parts = split(fileName, '-');
        currentSpeakerID = parts{1};

        % Match noise length
        if length(noise) < length(clean)
            repeatNumber = ceil(length(clean) / length(noise));
            currentNoise = repmat(noise, repeatNumber, 1);
        else
            currentNoise = noise;
        end

        currentNoise = currentNoise(1:length(clean));

        %% SNR CONDITIONS

        for s = 1:length(snrLevels)

            targetSNR = snrLevels(s);

            % Add noise at target SNR
            cleanPower = mean(clean.^2);
            noisePower = mean(currentNoise.^2);

            scaleFactor = sqrt( ...
                cleanPower / ...
                (noisePower * 10^(targetSNR/10)));

            scaledNoise = currentNoise * scaleFactor;
            noisy = clean + scaledNoise;

            %% STFT

            X = stft( ...
                noisy, ...
                targetFs, ...
                'Window', win, ...
                'OverlapLength', overlapLength, ...
                'FFTLength', nfft, ...
                'FrequencyRange', 'onesided');

            %% NOISE PSD ESTIMATION
            % Use first 0.25 s noise-only segment

            estimateSamples = min( ...
                round(0.25 * targetFs), ...
                length(currentNoise));

            noiseEstimate = ...
                currentNoise(1:estimateSamples) * scaleFactor;

            N = stft( ...
                noiseEstimate, ...
                targetFs, ...
                'Window', win, ...
                'OverlapLength', overlapLength, ...
                'FFTLength', nfft, ...
                'FrequencyRange', 'onesided');

            noisePSD = mean(abs(N).^2, 2);
            noisePSD = max(noisePSD, eps);

            %% WIENER FILTER

            noisyPSD = abs(X).^2;

            noisePSDMatrix = repmat( ...
                noisePSD, 1, size(X,2));

            speechPSD = max( ...
                noisyPSD - noisePSDMatrix, 0);

            G = speechPSD ./ ...
                (speechPSD + noisePSDMatrix + eps);

            % Gain floor
            G = max(G, 0.05);

            enhancedSTFT = G .* X;

            %% ISTFT

            enhanced = istft( ...
                enhancedSTFT, ...
                targetFs, ...
                'Window', win, ...
                'OverlapLength', overlapLength, ...
                'FFTLength', nfft, ...
                'FrequencyRange', 'onesided');

            enhanced = real(enhanced(:));

            %% MATCH LENGTH

            L = min([ ...
                length(clean), ...
                length(noisy), ...
                length(enhanced)]);

            cleanEval = clean(1:L);
            noisyEval = noisy(1:L);
            enhancedEval = enhanced(1:L);

            cleanEval = cleanEval - mean(cleanEval);
            noisyEval = noisyEval - mean(noisyEval);
            enhancedEval = enhancedEval - mean(enhancedEval);

            %% SNR EVALUATION

            inputError = noisyEval - cleanEval;
            outputError = enhancedEval - cleanEval;

            measuredInputSNR = 10 * log10( ...
                sum(cleanEval.^2) / ...
                (sum(inputError.^2) + eps));

            measuredOutputSNR = 10 * log10( ...
                sum(cleanEval.^2) / ...
                (sum(outputError.^2) + eps));

            deltaSNR = ...
                measuredOutputSNR - measuredInputSNR;

            fprintf( ...
                '%s | %s | %3d dB | Delta SNR = %+5.2f dB\n', ...
                fileName, ...
                noiseNames{n}, ...
                targetSNR, ...
                deltaSNR);

            %% STORE RESULTS

            FileName{end+1,1} = fileName;
            SpeakerID{end+1,1} = currentSpeakerID;
            NoiseType{end+1,1} = noiseNames{n};

            TargetSNR(end+1,1) = targetSNR;
            InputSNR(end+1,1) = measuredInputSNR;
            OutputSNR(end+1,1) = measuredOutputSNR;
            SNRImprovement(end+1,1) = deltaSNR;

            %% SAVE AUDIO

            [~, baseName, ~] = fileparts(fileName);

            conditionFolder = fullfile( ...
                outputFolder, ...
                noiseNames{n}, ...
                sprintf('%+ddB', targetSNR));

            if ~exist(conditionFolder, 'dir')
                mkdir(conditionFolder);
            end

            noisySave = noisyEval;
            enhancedSave = enhancedEval;

            % Prevent clipping
            if max(abs(noisySave)) > 1
                noisySave = noisySave / max(abs(noisySave));
            end

            if max(abs(enhancedSave)) > 1
                enhancedSave = ...
                    enhancedSave / max(abs(enhancedSave));
            end

            audiowrite( ...
                fullfile(conditionFolder, ...
                [baseName '_noisy.wav']), ...
                noisySave, targetFs);

            audiowrite( ...
                fullfile(conditionFolder, ...
                [baseName '_wiener.wav']), ...
                enhancedSave, targetFs);

        end
    end
end

%% SAVE RESULTS

resultsTable = table( ...
    FileName, ...
    SpeakerID, ...
    NoiseType, ...
    TargetSNR, ...
    InputSNR, ...
    OutputSNR, ...
    SNRImprovement);

writetable( ...
    resultsTable, ...
    fullfile(outputFolder, 'SNR_results.csv'));

%% AVERAGE RESULTS FOR FIGURE 1

summaryTable = groupsummary( ...
    resultsTable, ...
    {'NoiseType','TargetSNR'}, ...
    'mean', ...
    'SNRImprovement');

disp(summaryTable);

%% FIGURE 1: SNR IMPROVEMENT

figure;
hold on;

for n = 1:length(noiseNames)

    index = strcmp( ...
        summaryTable.NoiseType, ...
        noiseNames{n});

    data = summaryTable(index,:);

    [~, order] = sort(data.TargetSNR);
    data = data(order,:);

    plot( ...
        data.TargetSNR, ...
        data.mean_SNRImprovement, ...
        '-o', ...
        'LineWidth', 1.5);
end

yline(0,'--');

grid on;

xlabel('Input SNR (dB)');
ylabel('\DeltaSNR (dB)');

title('SNR Improvement after Wiener Enhancement');

legend(noiseNames, 'Location', 'best');

saveas( ...
    gcf, ...
    fullfile(outputFolder, ...
    'SNR_Improvement.png'));

fprintf('\nExperiment 1 completed.\n');