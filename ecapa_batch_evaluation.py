
import pandas as pd
import numpy as np
from sklearn.metrics import roc_curve

df = pd.read_csv("ECAPA_scores.csv")
results = []

for (noise, snr, kind), g in df.groupby(
    ["NoiseType", "SNR", "Type"], sort=False
):
    fpr, tpr, _ = roc_curve(
        g["SameSpeaker"],
        g["CosineSimilarity"],
        drop_intermediate=False
    )

    fnr = 1 - tpr
    diff = fpr - fnr
    i = np.where(diff >= 0)[0][0]

    if i == 0:
        eer = fpr[0]
    else:
        a = -diff[i-1] / (diff[i] - diff[i-1])
        eer = fpr[i-1] + a * (fpr[i] - fpr[i-1])

    results.append([noise, snr, kind, eer * 100])

out = pd.DataFrame(
    results,
    columns=["NoiseType", "SNR", "Type", "EER_Percent"]
)

out.to_csv("EER_verified.csv", index=False)

print(out.to_string(index=False))
print("Saved EER_verified.csv")
