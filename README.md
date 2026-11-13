# Effect of Wiener Speech Enhancement on Speaker Identity Preservation Under Noise

**ELEC5305 — Speech and Audio Processing**  
**The University of Sydney | Student ID: 500162576**

---

## 1. Project Overview

This project investigates whether Wiener speech enhancement can improve speech quality while preserving speaker identity information.

STFT-based Wiener filtering is implemented in MATLAB, while a pretrained ECAPA-TDNN model is used in Python to evaluate speaker embeddings and speaker verification performance.

**Research Question:**

*Does improving speech quality through Wiener filtering necessarily improve speaker identity preservation and verification performance?*

## 2. Methodology

The experiment follows five main steps:

1. Select clean speech recordings from LibriSpeech.
2. Add DEMAND environmental noise at four SNR levels.
3. Apply STFT-based Wiener filtering in MATLAB.
4. Extract speaker embeddings using a pretrained ECAPA-TDNN model.
5. Evaluate SNR improvement, embedding drift, Mel-filterbank distortion, and Equal Error Rate (EER).

## 3. Experimental Setup

| Parameter | Configuration |
|---|---|
| Speech dataset | LibriSpeech dev-clean |
| Number of speakers | 10 |
| Noise dataset | DEMAND |
| Noise environments | DKITCHEN, TBUS, PSTATION |
| Input SNR levels | −5, 0, +5, +10 dB |
| Test recordings | 120 |
| Sampling rate | 16 kHz |
| Speaker model | Pretrained ECAPA-TDNN |
| Enhancement method | STFT-based Wiener filtering |

## 4. Datasets

Two publicly available datasets are used in this project. The original datasets are not included in this repository due to their size.

### 4.1 LibriSpeech — Clean Speech

**Source:** https://www.openslr.org/12

Ten speakers are selected from the LibriSpeech dev-clean dataset.

**Speaker IDs:** `1272`, `1462`, `1673`, `174`, `1919`, `251`, `422`, `652`, `777`, `84`

Each speaker has two separate recordings:

- `enrollment.flac` — Used as the speaker identity reference.
- `verification.flac` — Used for noise mixing, enhancement, and evaluation.

### 4.2 DEMAND — Environmental Noise

**Source:** https://zenodo.org/records/1227121

Three noise environments are selected:

| Noise Type | Environment |
|---|---|
| DKITCHEN | Domestic kitchen |
| TBUS | Bus |
| PSTATION | Public station |

Each noise type is tested at four input SNR levels: **−5, 0, +5, and +10 dB**.

### 4.3 Dataset Organisation

The following directory structure is used by the MATLAB experiment:

```text
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
```

The two LibriSpeech recordings must be selected from different utterances of the same speaker and renamed as shown above. The DEMAND recordings should be prepared in the indicated folders.

## 5. Project Files

### Source Code

| File | Description |
|---|---|
| `experiment1_wiener_batch.m` | Generates noisy and Wiener-enhanced speech and calculates SNR improvement. |
| `experiment2_ecapa.py` | Extracts ECAPA-TDNN embeddings and evaluates embedding drift and recovery. |
| `filterbank_analysis.py` | Measures Mel-filterbank distortion before and after enhancement. |
| `ecapa_batch_evaluation.py` | Evaluates speaker verification performance using EER. |

### Experimental Results

| File | Description |
|---|---|
| `SNR_results.csv` | SNR measurements for the 120 test recordings. |
| `ECAPA_embedding_results.csv` | Individual embedding drift and recovery results. |
| `ECAPA_embedding_summary.csv` | Average embedding results across noise and SNR conditions. |
| `Filterbank_results.csv` | Mel-filterbank distortion results. |
| `ECAPA_summary.csv` | EER results across experimental conditions. |

## 6. How to Run

### Requirements

- MATLAB with Signal Processing Toolbox
- Python 3
- PyTorch and Torchaudio
- SpeechBrain
- NumPy, Pandas, SoundFile, and Scikit-learn

Install the Python dependencies:

### Execution

**Step 1 — Prepare the datasets**


**Step 2 — Run Wiener filtering in MATLAB**


**Step 3 — Run speaker embedding analysis**


**Step 4 — Run Mel-filterbank analysis**


**Step 5 — Run speaker verification evaluation**



## 7. Experimental Results

The main results reported in this project are summarised below.

| Evaluation Metric | Result |
|---|---:|
| Average SNR Improvement | **+3.75 dB** |
| Average Noisy Embedding Drift | 0.2114 |
| Average Wiener Embedding Drift | 0.2371 |
| Average Embedding Recovery | **−0.0257** |
| Noisy Mel-filterbank Distortion | 3.2406 |
| Wiener Mel-filterbank Distortion | 2.2931 |
| Filterbank Distortion Reduction | **29.2%** |
| Average Noisy EER | **3.29%** |
| Average Wiener EER | **3.15%** |

### Key Findings

Wiener filtering improved the average signal-to-noise ratio and reduced Mel-filterbank distortion.

However, the average embedding recovery was negative, indicating that the enhanced speech embeddings were not consistently closer to the clean speaker references.

Speaker verification performance showed a small overall EER improvement, but the effect varied across noise environments and SNR conditions.




**GitHub:** https://github.com/Ulead1224/elec5305-project-500162576
