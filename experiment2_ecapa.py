
from pathlib import Path
import numpy as np
import pandas as pd
import soundfile as sf
import torch
import torchaudio
from speechbrain.inference.speaker import EncoderClassifier
from speechbrain.utils.fetching import LocalStrategy

root = Path(__file__).resolve().parent
data = root / "wiener_fixed"

model = EncoderClassifier.from_hparams(
    source="speechbrain/spkrec-ecapa-voxceleb",
    savedir=str(root / "pretrained_models"),
    local_strategy=LocalStrategy.COPY,
    run_opts={"device": "cpu"}
)

def embedding(path):
    x, fs = sf.read(path, dtype="float32")
    if x.ndim > 1:
        x = x.mean(axis=1)
    x = torch.from_numpy(x).unsqueeze(0)
    if fs != 16000:
        x = torchaudio.functional.resample(x, fs, 16000)
    with torch.no_grad():
        return model.encode_batch(x).squeeze().cpu().numpy()

def drift(a, b):
    return float(1 - np.dot(a, b) /
                 (np.linalg.norm(a) * np.linalg.norm(b)))

rows = []

for noise in ["DKITCHEN", "TBUS", "PSTATION"]:
    for snr in [-5, 0, 5, 10]:
        folder = data / noise / f"SNR_{snr}"

        for clean in sorted(folder.glob("*_clean.wav")):
            name = clean.stem.removesuffix("_clean")
            noisy = folder / f"{name}_noisy.wav"
            wiener = folder / f"{name}_wiener.wav"

            if not noisy.is_file() or not wiener.is_file():
                continue

            a = embedding(clean)
            d1 = drift(a, embedding(noisy))
            d2 = drift(a, embedding(wiener))

            rows.append([name, noise, snr, d1, d2, d1-d2])

if len(rows) != 120:
    raise ValueError(f"Expected 120 samples, found {len(rows)}")

df = pd.DataFrame(rows, columns=[
    "Speaker", "Noise", "Input_SNR_dB",
    "D_noisy", "D_wiener", "R_emb"
])

df.to_csv(root / "ECAPA_embedding_results.csv", index=False)

summary = df.groupby(["Noise", "Input_SNR_dB"])[
    ["D_noisy", "D_wiener", "R_emb"]
].mean().reset_index()

summary.to_csv(root / "ECAPA_embedding_summary.csv", index=False)

print(summary)
print("Mean recovery:", df["R_emb"].mean())
print("Processed:", len(df), "samples")
