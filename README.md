# ELEC5305 Project - 500162576

## Effect of Wiener Speech Enhancement on Speaker Identity Preservation Under Noise

This project investigates whether classical Wiener speech enhancement improves or damages speaker identity information under different noise conditions.

An STFT-based Wiener filter is used to reduce background noise in speech signals. In addition to conventional signal-quality evaluation using Signal-to-Noise Ratio (SNR), a pretrained ECAPA-TDNN speaker model is used to analyse whether speaker identity information is preserved after enhancement.

The project specifically investigates whether improvement in signal quality can occur at the same time as degradation of speaker-related information.

## Research Question

Does classical Wiener speech enhancement improve or damage speaker identity information in modern speaker embeddings under different noise conditions?

A secondary question is whether improved SNR can occur simultaneously with degraded speaker-verification performance.

## Methodology

The experimental pipeline consists of:

1. Clean speech is selected from the LibriSpeech dataset.
2. Environmental noise from the DEMAND dataset is added at different SNR levels.
3. STFT-based Wiener filtering is applied to the noisy speech.
4. Enhanced speech is reconstructed using inverse STFT (ISTFT).
5. Signal-level performance is evaluated using SNR improvement.
6. A pretrained ECAPA-TDNN model is used to extract speaker embeddings from clean, noisy, and Wiener-enhanced speech.
7. Cosine similarity and embedding recovery are used to evaluate speaker identity preservation.
8. Speaker-verification performance is evaluated under different noise and enhancement conditions.

## Tools

- MATLAB
- Python
- SpeechBrain
- PyTorch

## Signal Processing Techniques

- Short-Time Fourier Transform (STFT)
- Wiener Filtering
- Inverse Short-Time Fourier Transform (ISTFT)
- Signal-to-Noise Ratio (SNR)
- Speaker Embedding Analysis
- Cosine Similarity
- Speaker Verification

## Datasets

### Speech
- LibriSpeech

### Environmental Noise
- DEMAND
- DKITCHEN
- TBUS
- PSTATION

## Experimental Conditions

The speech signals are evaluated under four input SNR conditions:

- -5 dB
- 0 dB
- 5 dB
- 10 dB

Three environmental noise conditions are considered:

- Domestic kitchen noise (DKITCHEN)
- Bus noise (TBUS)
- Public station noise (PSTATION)

## Experiments

### Experiment 1: Wiener Speech Enhancement

Evaluate the effectiveness of the STFT-based Wiener filter using SNR improvement.

### Experiment 2: Speaker Embedding Analysis

Compare ECAPA-TDNN embeddings extracted from clean, noisy, and Wiener-enhanced speech.

Embedding recovery is used to determine whether Wiener enhancement moves the speaker representation closer to or further from the clean reference.

### Experiment 3: Speaker Verification

Evaluate speaker-verification performance using target and impostor trials.

### Experiment 4: Joint Analysis

Compare signal-level SNR improvement with speaker-identity preservation to investigate whether better signal quality necessarily leads to better speaker-verification performance.

## Expected Outcomes

The project aims to determine whether Wiener filtering can improve conventional signal quality while simultaneously altering speaker-specific information.

The results will provide a comparison between:

- Signal-quality improvement
- Speaker-embedding preservation
- Speaker-verification performance

## Course

ELEC5305

## Git Hub Link
https://github.com/Ulead1224/elec5305-project-500162576
