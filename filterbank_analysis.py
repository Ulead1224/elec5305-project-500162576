
from pathlib import Path
import csv
import numpy as np
import torch
import torchaudio
import soundfile as sf

root = Path(__file__).resolve().parent
data = root / "wiener_fixed"

speakers = ["1272","1462","1673","174","1919","251","422","652","777","84"]
noises = ["DKITCHEN","TBUS","PSTATION"]
snrs = [-5,0,5,10]

mel = torchaudio.transforms.MelSpectrogram(
    sample_rate=16000,
    n_fft=400,
    win_length=400,
    hop_length=160,
    n_mels=80
)

def features(path):
    x, sr = sf.read(str(path),dtype="float32")
    assert sr == 16000
    if x.ndim == 2:
        x = x.mean(axis=1)
    with torch.no_grad():
        m = mel(torch.tensor(x))
        return torch.log(m.clamp_min(1e-10)).numpy()

rows = []

for noise in noises:
    for snr in snrs:
        folder = data / noise / f"SNR_{snr}"

        for speaker in speakers:
            clean = features(folder / f"{speaker}_clean.wav")
            noisy = features(folder / f"{speaker}_noisy.wav")
            wiener = features(folder / f"{speaker}_wiener.wav")

            dn = np.mean(np.abs(clean-noisy),axis=1)
            dw = np.mean(np.abs(clean-wiener),axis=1)

            rows.append([
                speaker,noise,snr,
                float(dn.mean()),
                float(dw.mean()),
                float(dn.mean()-dw.mean()),
                float(dn[:27].mean()),
                float(dw[:27].mean()),
                float(dn[27:54].mean()),
                float(dw[27:54].mean()),
                float(dn[54:].mean()),
                float(dw[54:].mean())
            ])

        print(noise,snr,"OK")

with open(root / "Filterbank_results.csv","w",newline="") as f:
    w = csv.writer(f)
    w.writerow([
        "SpeakerID","NoiseType","SNR",
        "NoisyDistortion","WienerDistortion","DistortionReduction",
        "LowNoisy","LowWiener",
        "MidNoisy","MidWiener",
        "HighNoisy","HighWiener"
    ])
    w.writerows(rows)

print("Processed",len(rows),"samples.")
print("Saved Filterbank_results.csv")
