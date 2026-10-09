import os
import pandas as pd
import matplotlib.pyplot as plt

# ============================================================
# Experiment 2 - Plot Embedding Recovery
# ============================================================

RESULT_FOLDER = os.path.join("output", "ECAPA_results")

csv_file = os.path.join(
    RESULT_FOLDER,
    "ECAPA_embedding_summary.csv"
)

# Read Experiment 2 results
df = pd.read_csv(csv_file)

print("Loaded results:")
print(df)

# Noise types
noise_types = ["DKITCHEN", "TBUS", "PSTATION"]

# Create figure
plt.figure(figsize=(7, 5))

# Plot one line for each noise environment
for noise in noise_types:

    data = df[df["Noise"] == noise].sort_values("Input_SNR_dB")

    plt.plot(
        data["Input_SNR_dB"],
        data["R_emb"],
        marker="o",
        linewidth=2,
        label=noise
    )

# R_emb = 0 reference line
plt.axhline(
    y=0,
    linestyle="--",
    linewidth=1
)

# Labels
plt.xlabel("Input SNR (dB)")
plt.ylabel("Embedding Recovery ($R_{emb}$)")

plt.title(
    "Speaker Embedding Recovery after Wiener Enhancement"
)

plt.xticks([-5, 0, 5, 10])

plt.grid(
    True,
    linestyle="--",
    alpha=0.4
)

plt.legend()

plt.tight_layout()

# Save high-resolution figure
output_file = os.path.join(
    RESULT_FOLDER,
    "Embedding_Recovery.png"
)

plt.savefig(
    output_file,
    dpi=300,
    bbox_inches="tight"
)

plt.show()

