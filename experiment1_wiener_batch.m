

root = fileparts(mfilename('fullpath'));
cleanRoot = fullfile(root,'dev-clean','LibriSpeech','selected_speech');
noiseRoot = fullfile(root,'Demand');
outRoot = fullfile(root,'wiener_fixed');


speakers = {'1272','1462','1673','174','1919','251','422','652','777','84'};
noises = {'DKITCHEN','TBUS','PSTATION'};
snrs = [-5 0 5 10];

fs = 16000;
win = sqrt(hann(512,'periodic'));
rows = cell(120,6);
n = 0;

for i = 1:numel(speakers)
    id = speakers{i};
    [s,f] = audioread(fullfile(cleanRoot,id,'verification.flac'));
    assert(f == fs);
    s = mean(s,2);

    for j = 1:numel(noises)
        [v,f] = audioread(fullfile(noiseRoot,noises{j},'ch01.wav'));
        v = mean(v,2);
        if f ~= fs
            v = resample(v,fs,f);
        end
        v = v-mean(v);
        v = repmat(v,ceil(numel(s)/numel(v)),1);
        v = v(1:numel(s));

        for k = 1:numel(snrs)
            snr = snrs(k);
            noise = v*sqrt(mean(s.^2)/(mean(v.^2)*10^(snr/10)));
            x = s+noise;

            X = stft(x,fs,'Window',win,'OverlapLength',256,'FFTLength',512);
            N = stft(noise(1:min(4000,end)),fs,...
                'Window',win,'OverlapLength',256,'FFTLength',512);

            P = max(mean(abs(N).^2,2),eps);
            S = max(abs(X).^2-P,0);
            G = max(S./(S+P+eps),0.05);

            y = real(istft(G.*X,fs,...
                'Window',win,'OverlapLength',256,'FFTLength',512));

            L = min(numel(s),numel(y));
            a = s(1:L);
            b = x(1:L);
            y = y(1:L);

            inSNR = 10*log10(sum(a.^2)/(sum((b-a).^2)+eps));
            outSNR = 10*log10(sum(a.^2)/(sum((y-a).^2)+eps));

            folder = fullfile(outRoot,noises{j},sprintf('SNR_%d',snr));
            if ~exist(folder,'dir')
                mkdir(folder);
            end

            factor = max(1,max(abs([b;y]))/0.99);
            audiowrite(fullfile(folder,[id '_clean.wav']),a/factor,fs);
            audiowrite(fullfile(folder,[id '_noisy.wav']),b/factor,fs);
            audiowrite(fullfile(folder,[id '_wiener.wav']),y/factor,fs);

            n = n+1;
            rows(n,:) = {id,noises{j},snr,inSNR,outSNR,outSNR-inSNR};
        end
    end
    fprintf('%s OK\n',id);
end

T = cell2table(rows,'VariableNames',...
    {'SpeakerID','NoiseType','TargetSNR','InputSNR','OutputSNR','SNRImprovement'});

writetable(T,fullfile(outRoot,'SNR_results.csv'));
disp(groupsummary(T,{'NoiseType','TargetSNR'},'mean','SNRImprovement'));
fprintf('Processed %d files.\n',height(T));
