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

ELEC5305— Speech and Audio Processing 

## Git Hub Link
https://github.com/Ulead1224/elec5305-project-500162576
