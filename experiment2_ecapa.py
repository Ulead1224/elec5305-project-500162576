import os
import glob
import numpy as np
import pandas as pd
import torch
import torchaudio
import soundfile as sf

from speechbrain.inference.speaker import EncoderClassifier
from speechbrain.utils.fetching import LocalStrategy


# Settings
CLEAN_FOLDER = "clean_speech"
OUTPUT_FOLDER = "output"
RESULT_FOLDER = os.path.join(OUTPUT_FOLDER, "ECAPA_results")

NOISE_TYPES = ["DKITCHEN", "TBUS", "PSTATION"]
SNR_FOLDERS = ["-5dB", "+0dB", "+5dB", "+10dB"]

os.makedirs(RESULT_FOLDER, exist_ok=True)


# Load pretrained ECAPA-TDNN
classifier = EncoderClassifier.from_hparams(
    source="speechbrain/spkrec-ecapa-voxceleb",
    savedir="pretrained_models/spkrec-ecapa-voxceleb",
    local_strategy=LocalStrategy.COPY,
    run_opts={"device": "cpu"}
)


# Extract speaker embedding
def extract_embedding(path):
    audio, fs = sf.read(path, dtype="float32")

    if audio.ndim > 1:
        audio = np.mean(audio, axis=1)

    waveform = torch.from_numpy(audio).float().unsqueeze(0)

    if fs != 16000:
        waveform = torchaudio.transforms.Resample(fs, 16000)(waveform)

    with torch.no_grad():
        embedding = classifier.encode_batch(waveform)

    return embedding.squeeze().cpu().numpy()


# Cosine similarity
def cosine_similarity(a, b):
    return float(
        np.dot(a, b) /
        (np.linalg.norm(a) * np.linalg.norm(b))
    )


# Clean speech
clean_files = sorted(
    glob.glob(os.path.join(CLEAN_FOLDER, "*.flac"))
)

clean_embeddings = {}

for path in clean_files:
    name = os.path.splitext(os.path.basename(path))[0]
    clean_embeddings[name] = extract_embedding(path)


# Process noisy and Wiener-enhanced speech
results = []

for noise in NOISE_TYPES:
    for snr_folder in SNR_FOLDERS:

        folder = os.path.join(
            OUTPUT_FOLDER, noise, snr_folder
        )

        for clean_path in clean_files:

            name = os.path.splitext(
                os.path.basename(clean_path)
            )[0]

            noisy_path = os.path.join(
                folder, name + "_noisy.wav"
            )

            wiener_path = os.path.join(
                folder, name + "_wiener.wav"
            )

            if not os.path.exists(noisy_path) or \
               not os.path.exists(wiener_path):
                continue

            e_clean = clean_embeddings[name]
            e_noisy = extract_embedding(noisy_path)
            e_wiener = extract_embedding(wiener_path)

            cos_noisy = cosine_similarity(
                e_clean, e_noisy
            )

            cos_wiener = cosine_similarity(
                e_clean, e_wiener
            )

            # Embedding drift
            D_noisy = 1 - cos_noisy
            D_wiener = 1 - cos_wiener

            # Embedding recovery
            R_emb = D_noisy - D_wiener

            snr = int(
                snr_folder.replace("dB", "").replace("+", "")
            )

            speaker = name.split("-")[0]

            results.append({
                "File": name,
                "Speaker": speaker,
                "Noise": noise,
                "Input_SNR_dB": snr,
                "Cosine_Clean_Noisy": cos_noisy,
                "Cosine_Clean_Wiener": cos_wiener,
                "D_noisy": D_noisy,
                "D_wiener": D_wiener,
                "R_emb": R_emb
            })


# Save results
results_df = pd.DataFrame(results)

results_df.to_csv(
    os.path.join(
        RESULT_FOLDER,
        "ECAPA_embedding_results.csv"
    ),
    index=False
)

summary_df = (
    results_df
    .groupby(["Noise", "Input_SNR_dB"])
    [["D_noisy", "D_wiener", "R_emb"]]
    .mean()
    .reset_index()
)

summary_df.to_csv(
    os.path.join(
        RESULT_FOLDER,
        "ECAPA_embedding_summary.csv"
    ),
    index=False
)

print(summary_df)

print(
    "\nMean R_emb:",
    results_df["R_emb"].mean()
)

print("\nExperiment 2 completed.")

