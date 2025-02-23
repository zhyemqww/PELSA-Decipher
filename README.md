# PELSA-Decipher: a software tool for the processing and interpretation of ligand-protein interaction dataset acquired by PELSA

## PELSA-Decipher

![PELSA](https://github.com/user-attachments/assets/5364f36d-4d7a-4bb2-94e1-5cb655051986)

## Overview

**PELSA-Decipher** is a free tool specifically designed to streamline the processing and analysis of PELSA data. It is an efficient and user-friendly software that offers the following key functionalities:

- **Differential Analysis (DA):** Quantitative comparison of differences between samples.
- **Protein Local Stability Analysis (ProLSA):** Exploration of stability characteristics across different regions of a protein.
- **Concentration-Dependent Analysis (CDA):** Analysis of the concentration effects on ligand-protein binding regions.

The software supports importing domain information from the UniProt database, enabling precise analysis of ligand-protein binding regions. Users can also define custom regions for targeted analysis. In addition, it provides flexible image customization options, supports multiple output formats, and allows batch export of result reports and images.

Beyond PELSA-specific data, **PELSA-Decipher** is also compatible with certain other data types, further enhancing its versatility and functionality.

Developed in Python, the software’s graphical user interface (GUI) is built using PySide6. The tool is available as a packed `.exe` application, which can be directly downloaded and executed. Detailed instructions on installation, operation, troubleshooting, and additional resources are provided in the accompanying documentation.

## Download

It is recommended to use PELSA-Decipher of the latest version, which could be downloaded [here](https://github.com/DICP-1809/PELSA-Decipher/releases), where previous version can also be acquired. The user manual is also included.

## Computer System Requirements

+ Operating System: Windows 10/11, x64

+ R Version: 4.X (X >= 3)

## License Application

PLESA-Decipher is a free software and the license is requested only for the purpose of understanding the use of the software and providing a better service. We promise that all your information will only be used for statistical purposes and will not be disclosed to any other person or third party.

![演示文稿](https://github.com/user-attachments/assets/aadd75b1-9a14-4945-b5df-ab8c67075111)

## Module Introduction：

### Differential Analysis (DA)


 The DA module in PELSA-Decipher uses a statistical model to identify differential proteins between experimental and control groups based on predefined thresholds. By integrating peptide-level quantitative data, the module enables differential analysis at both the peptide and protein levels. It also provides visualization of the differential analysis results, such as boxplots and volcano plots.

### Protein Local Stability Analysis (ProLSA)

The protein local stability analysis module is designed to assess and visualize information associated with changes in protein local stability after the ligand binding. 

### Concentration-Dependent Analysis (CDA)

The CDA module in PELSA-Decipher models the concentration dependence of peptides and proteins, enabling the calculation of both local and global affinities of ligands for their target proteins. 

## Other Software

For other software developed by the Mingliang Ye's Lab, please see https://github.com/DICP-1809.

## Contact Us
Group leader: Mingliang Ye
e-mail: mingliang@dicp.ac.cn

Developer: Haiyang Zhu
e-mail: zhyemqww@dicp.ac.cn

