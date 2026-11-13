# ELEC5305 Project - 500162576

## Effect of Wiener Speech Enhancement on Speaker Identity Preservation Under Noise

### Project Overview

This project investigates whether Wiener speech enhancement improves speech quality while preserving speaker identity information.

MATLAB is used for STFT-based Wiener filtering, and a pretrained ECAPA-TDNN model is used in Python to evaluate speaker embeddings and verification performance.

The main research question is whether better noise reduction always leads to better speaker verification.

## Methodology

1. Select clean speech from LibriSpeech.
2. Add DEMAND noise at different SNR levels.
3. Apply Wiener filtering using MATLAB.
4. Extract speaker embeddings using ECAPA-TDNN.
5. Evaluate SNR improvement, embedding drift, Mel-filterbank distortion, and Equal Error Rate (EER).

## Experimental Setup

- **Speech dataset:** LibriSpeech (10 speakers)
- **Noise dataset:** DEMAND
- **Noise types:** DKITCHEN, TBUS, PSTATION
- **Input SNR:** −5, 0, +5, +10 dB
- **Test recordings:** 120
- **Sampling rate:** 16 kHz

## Tools

- MATLAB
- Python
- SpeechBrain
- PyTorch

## Datasets

1. LibriSpeech (Speech Dataset)

Dataset: LibriSpeech dev-clean

Number of speakers: 10

Speaker IDs: 1272, 1462, 1673, 174, 1919, 251, 422, 652, 777, 84

Each speaker has separate enrollment and verification recordings.

Sampling rate: 16 kHz

Download: https://www.openslr.org/12

2. DEMAND (Noise Dataset)

Dataset: Diverse Environments Multi-channel Acoustic Noise Database (DEMAND)

Selected noise types: DKITCHEN, TBUS, PSTATION

Input SNR levels: −5, 0, +5, +10 dB

Download: https://zenodo.org/records/1227121

Dataset Preparation

The speech files should be organised as follows:

dev-clean/
└── LibriSpeech/
    └── selected_speech/
        ├── 1272/
        │   ├── enrollment.flac
        │   └── verification.flac
        ├── 1462/
        ├── 1673/
        ├── 174/
        ├── 1919/
        ├── 251/
        ├── 422/
        ├── 652/
        ├── 777/
        └── 84/

Demand/
├── DKITCHEN/
│   └── ch01.wav
├── TBUS/
│   └── ch01.wav
└── PSTATION/
    └── ch01.wav

The original datasets are not included in this GitHub repository due to their size. Users should download the datasets and prepare the selected recordings before running the experiments.
## Project Files

| File | Description |
|---|---|
| `experiment1_wiener_batch.m` | Performs noise mixing, Wiener filtering, audio reconstruction, and SNR evaluation. |
| `experiment2_ecapa.py` | Extracts ECAPA-TDNN speaker embeddings and calculates embedding drift and recovery. |
| `filterbank_analysis.py` | Calculates Mel-filterbank distortion for clean, noisy, and enhanced speech. |
| `ecapa_batch_evaluation.py` | Evaluates speaker verification performance using EER. |
| `SNR_results.csv` | SNR improvement results. |
| `ECAPA_embedding_results.csv` |  speaker embedding analysis results. |
| `ECAPA_embedding_summary.csv` | Summarises embedding drift and recovery across noise conditions. |
| `Filterbank_results.csv` | Mel-filterbank distortion results. |
| `ECAPA_summary.csv` |  speaker verification EER results. |

## Experimental Results

| Evaluation Metric | Result |
|---|---|
| Average SNR Improvement | +3.75 dB |
| Average Embedding Recovery | −0.0257 |
| Mel-filterbank Distortion Reduction | 29.2% |
| Average Noisy EER | 3.29% |
| Average Wiener EER | 3.15% |

Wiener filtering improved speech quality, but speaker embedding similarity and verification performance did not consistently improve.

## Conclusion

The results show that better noise reduction does not always lead to better speaker identity preservation.

This finding is relevant to practical applications such as voice authentication and telephone banking, where both speech quality and speaker verification accuracy are important.

## Course Information

**Course:** ELEC5305 — Speech and Audio Processing

## GitHub Link

https://github.com/Ulead1224/elec5305-project-500162576
