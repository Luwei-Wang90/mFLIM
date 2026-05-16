# mFLIM: Multiplexed Fluorescence Lifetime Imaging Microscopy

This software package provides a reference implementation of the mFLIM technique described in our paper:
“mFLIM: capturing nanoscale 3D organelle architecture and dynamics via spatiotemporal multiplexed FLIM”
Luwei Wang, Min Yi, Yue Chen, Zhongyang Liu, Renlong Zhang, Xiaoyu Weng, Liwei Liu, Junle Qu*

The mFLIM technique enables volumetric super-resolution reconstruction of fluorescence lifetime images from spatiotemporally encoded FLIM data acquired with a single excitation wavelength and a single detection channel.

## 1. Prerequisites
Ensure the following software is installed and configured on your system:
MATLAB (R2019b or later compatible versions)
Bio-Formats Toolbox for MATLAB
a.Required for reading Becker & Hickl TCSPC .sdt files.
b.Download from: https://docs.openmicroscopy.org/bio-formats/
c.Follow the official installation instructions to add the toolbox to your MATLAB path.

## 2. Data Preparation
Before starting, please prepare the following data files:
Raw mFLIM Data
a.Spatiotemporally encoded FLIM data in Becker & Hickl TCSPC format (.sdt files).
b.These files contain the time-tagged photon stream recorded under dual‑beam excitation (Gaussian beam + time‑delayed 3D cage beam).
Reference Lifetime Map
a.The fluorescence lifetime map (in .asc format) obtained by fitting the Part 1 (Gaussian‑excited) decay channels from the same dataset, typically generated using software such as SPCImage (Becker & Hickl).
b.This map serves as a reference for lifetime scaling and is required for the final HSV color mapping.
Note: The code expects the .asc file to be located in a subfolder (e.g., ./3 beads/) or you must modify the load file path in the script (line 121).

## 3. Processing Workflow
For image reconstruction using MATLAB, please follow the procedure below:
Start MATLAB and navigate to the folder containing the mFLIM_v2605.m script and your data files.
Open and run the script mFLIM_v2605.m.
A file dialog box will appear. Select the target .sdt file to be processed.
The script will automatically:
a.Load and parse the spatiotemporal photon stream.
b.Separate photons into Part 1 (Gaussian‑excited) and Part 2 (modulated‑beam‑excited) channels based on the defined time channel boundary (α).
c.Generate the super‑resolved intensity image (Im) via weighted pixel‑wise subtraction.
d.Load the reference lifetime map (.asc file) and normalize it using lifetime_min and lifetime_max.
e.Fuse the super‑resolved intensity with the lifetime map to produce the final mFLIM image in HSV color space.
The output file is saved as mFLIM_image.tif in the same folder.
To ensure optimal results, key parameters must be set correctly in the code, including the time channel (α, line 48), the cutoff frequency radius (d, line 73), the weight coefficient (β, line 111), the lifetime scale (lines 125-126).
Important: (1) The alpha value is experiment-specific and must be calibrated on your system. It depends on the optical path delay between the Gaussian and the modulated beam; (2) The d value can be chosen by running the script once, examining the Fourier spectrum plot, and selecting a radius that includes the central low-frequency components while excluding high-frequency noise; (3) The beta value may need re-optimization when you change samples or imaging conditions. Always start low and increase stepwise.

## 4. Example
A complete walkthrough using example data (provided in the working folder of this repository):
Prepare data: Copy the example .sdt file and its corresponding .asc reference file into the working folder.
Open MATLAB R2019b and navigate to the repository root.
Run mFLIM_v2605.m.
In the file dialog, select the example .sdt file.
The script will process the data and generate: Ig.tif, Id.tif, Id_smooth.tif, Im.tif, and mFLIM_image.tif.
The output mFLIM_image.tif integrates super‑resolved structural intensity (encoded in the value channel) with quantitative lifetime information (encoded in the hue channel), following the HSV‑to‑RGB visualization described in the paper.
To verify correct reconstruction, compare the lifetime values from the output image with those obtained from SPCImage fitting of the Part 1 channels (deviation should be <3%).

## 5. Output Description
The final output mFLIM_image.tif is a 24‑bit RGB image where:
Hue (color) encodes the fluorescence lifetime (scaled by lifetime scale).
Value (brightness) encodes the super‑resolved intensity from the subtraction step.
Saturation is fixed to maximum (1) to ensure clear color contrast.
For quantitative analysis, the script also saves the following intermediate files in the same folder:
Ig.tif – Confocal intensity image (sum of Part 1 channels).
Id.tif – Raw donut intensity image (sum of Part 2 channels).
Id_smooth.tif – Low‑pass filtered donut image (after Fourier domain smoothing).
Im.tif – Super‑resolved intensity image (Ig - beta*Id_smooth), normalized to [0, 1].
Note: The script currently does not save the lifetime map separately, but you can easily add “imwrite(uint16(lifetime), ‘lifetime_map.tif’)” after normalization if needed.

## 6. License
This project is licensed under the MIT License.

## 7. Contact
For questions, bug reports, or collaboration inquiries, please contact:
Dr. Luwei Wang
Email: wanglowell@szu.edu.cn
Shenzhen University, China
