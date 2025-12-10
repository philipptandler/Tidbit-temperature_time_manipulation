import Metashape
import csv
from datetime import datetime

# Get the current document and active chunk
doc = Metashape.app.document
chunk = doc.chunk

# Folder of current project
project_folder = Metashape.app.document.path.rsplit("/", 1)[0]
output_csv = f"{project_folder}/Times_SelectedImages_from_AgisoftMetashape.csv"

with open(output_csv, mode="w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["camera_label", "timestamp_ISO", "timestamp_custom"])

    for cam in chunk.cameras:
        # Skip photos that are unchecked in the Reference pane
        if not cam.reference.enabled:
            continue

        # Skip cameras without an associated photo
        if cam.photo is None:
            continue

        meta = cam.photo.meta
        if "Exif/DateTimeOriginal" not in meta:
            continue  # Skip if no timestamp available

        raw = meta["Exif/DateTimeOriginal"]  # e.g. "2025:09:04 10:17:55"

        # Convert to Python datetime
        try:
            dt = datetime.strptime(raw, "%Y:%m:%d %H:%M:%S")
        except:
            # fallback for rare formats
            dt = datetime.fromisoformat(raw.replace(":", "-", 2))

        # Two recommended formats
        iso_fmt = dt.strftime("%Y-%m-%d %H:%M:%S")       # machine-friendly
        custom_fmt = dt.strftime("%m-%d-%Y %H:%M:%S")   # custom format for Tidbit

        writer.writerow([cam.label, iso_fmt, custom_fmt])

print(f"Saved timestamps for checked photos to: {output_csv}")
