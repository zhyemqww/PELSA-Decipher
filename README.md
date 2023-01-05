# PELSA-Decipher
#  















<center><font size="13" ><b>PELSA-Decipher</b></font></center>









   

<center><font size="6">User Manual</font></center>


<center><font size="4">(Version: Beta 0.1.0)</font></center>




















<center><font size="4">Developed by Group1809, Dalian Institute of Chemical Physics,</font></center>

<center><font size="4">Chinese Academy of Sciences</font></center>









## Contents

[**<font color=#34495e>Contact</font>**](# contact)

[**<font color=#34495e>Address</font>**](# address)

[**<font color=#34495e>Scope of PELSA-Decipher</font>**](# Scope of PELSA-Decipher)

[<font color=#34495e>1. Getting Started</font>](# 1. Getting Started)

​	[<font color=#34495e>1.1 Installing PELSA-Decipher</font>](# 1.1 Installing PELSA-Decipher)

​	[<font color=#34495e>1.2 Installing R</font>](# 1.2 Installing R)

​	[<font color=#34495e>1.3 Configuring Environment Variables</font>](# 1.3 Configuring Environment Variables)

[<font color=#34495e>2. The Format of input Files and Data</font>](# 2. The Format of input Files and Data)

​	[<font color=#34495e>2.1 File Format</font>](# 2.1 File Format)

​	[<font color=#34495e>2.2 Data Format</font>](# 2.2 Data Format)

[<font color=#34495e>3. Module Introduction</font>](# 3. Module Introduction)

​	[<font color=#34495e>3.1 Statistical Testing</font>](# 3.1 Statistical Testing)

​	[<font color=#34495e>3.2 Local Stability Plot</font>](# 3.2 Local Stability Plot)

​	[<font color=#34495e>3.3 Pro/Pep Affinity</font>](# 3.3 Pro/Pep Affinity)

[<font color=#34495e>4. Demo</font>](# 4. Demo)

​	[<font color=#34495e>4.1 Statistical Testing</font>](# 4.1 Statistical Testing)

​	[<font color=#34495e>4.2 Local Stability Plot</font>](# 4.2 Local Stability Plot)

​	[<font color=#34495e>4.3 Pro/Pep Affinity</font>](# 4.3 Pro/Pep Affinity)

[<font color=#34495e>5. Common Problems and Solutions</font>](# 5. Common Problems and Solutions)

​	[<font color=#34495e>5.1 Cannot be opened</font>](# 5.1 Cannot be opened)

​	[<font color=#34495e>5.2 Unexpected termination</font>](# 5.2 Unexpected termination)

















### [Contact](# contents)

**Group leader**: Mingliang Ye   mingliang@dicp.ac.cn

**Developer**: Haiyang Zhu        zhyemqww@dicp.ac.cn

​                     Kejia Li                 lkj2016@dicp.ac.cn

​                     Zheng Fang          zhengfang@dicp.ac.cn











### [Address](# contents)

Dalian Institute of Chemical Physics, CAS

457 Zhongshan Road

Dalian, China 116023













### [Scope of PELSA-Decipher](# contents)

PELSA-Decipher is a freely available software tool aimed at processing quantitative datasets acquired from PELSA experiments. PELSA-Decipher enables simultaneous ligand-binding protein identification, binding region localization, and binding affinity calculation.

















## [1. Getting Started](# contents)

### [1.1 Installing PELSA-Decipher](# contents)

As a portable software, PELSA-Decipher can be run without installation.

### [1.2 Installing R](# contents)

There is no need to install R again if R has already been set in Windows. Otherwise, please run the provided R installation package in zip file.

**Note**: it is not recommended to install R in `C:\Program Files`.

### [1.3 Configuring Environment Variables](# contents)

#### [<font color=#34495e>1.3.1 Find the installation directory of R in your computer</font>](# contents)

Right click the shortcut icon of R on your desktop and select “properties”. The installation folder path should be in the box “Start in”, e.g., `D:\Tools\R-4.2.0`.

#### [<font color=#34495e>1.3.2 Create the following environment variables on your computer</font>](# contents)

The value of the created variable is your R installation path or R library path. R library is in the R installation folder. For example, if your R installation path is `D:\Tools\R-4.2.0`, then the R library path is `D:\Tools\R-4.2.0\library`. The environment variables should be created as follows:

```python
Variable               Value

R_HOME                 R installation path

R_LIBS_USER            R library path

R_USER                 R library path
```

For details on how to configure environment variables, see (https://docs.oracle.com/en/database/oracle/machine-learning/oml4r/1.5.1/oread/creating-and-modifying-environment-variables-on-windows.html)



## [2. The Format of input Files and Data](# contents)

### [2.1 File Format](# contents)

In the current version (Beta 0.1.0) , only **.csv** files are supported.

### [2.2 Data Format](# contents)

#### [<font color=#34495e>2.2.1 Raw Peptide Intensity File</font>](# contents)

PELSA-Decipher is developed for processing quantitative dataset. The dataset should contain descriptive columns and quantitative columns. The descriptive columns should contain the information below, and be placed at the first five columns (with column name fixed):

| Genes   | ProteinDescriptions    | UniProtIds | Sequences   | PeptidePositions | ...... |
|---------|------------------------|------------|-------------|------------------|--------|
| ......  | ......                 | ......     | ......      | ......           | ...... |
| PIGBOS1 | Protein PIGBOS1        | A0A0B4J2F0 | MQLVQESEEK  | 43               | ...... |
| MARCOL  | MARCO-like protein     | A0A1B0GUY1 | AGVLNQPGILK | 93               | ...... |
| RBM47   | RNA-binding protein 47 | A0AV96     | GFAFVEYESHR | 195              | ...... |
| ......  | ......                 | ......     | ......      | ......           | ...... |

**Tip:** A peptide might belong to multiple proteins. In this case, the first **Genes** and **UniProtIds** are assigned to that peptide.

#### [<font color=#34495e>2.2.2 Proteins of Interest and Contamination Database</font>](# contents)

PELSA-Decipher supports annotation of proteins of interest and removal of proteins that are included in the contamination database (*e.g*., albumin). To achieve this, users should provide a list of proteins of interest and a contamination database (the format is as follows).

**Proteins of Interest:**

| UniProtIds |
| :--------: |
|   ......   |
|   Q9NXG6   |
|   Q02809   |
|   O00469   |
|   ......   |

**Contamination Database:**

| UniProtIds |
| :--------: |
|   ......   |
|   Q32MB2   |
|   P19013   |
|   Q7RTT2   |
|   ......   |



## [3. Module Introduction](# contents)

### [3.1 Statistical Testing](# contents)

This module is designed for statistical testing to identify significantly changed peptides and proteins.

![image-20230104151724027](C:\Users\zhyemqww\AppData\Roaming\Typora\typora-user-images\image-20230104151724027.png)



***Step 1: upload and setting***

**Raw Peptide Intensity** (required)**:** raw peptide intensity data output by searching engines (*e.g*., Spectronaut).

**Proteins of Interest** (optional)**:** the list of proteins of interest; if provided, these proteins will be annotated in the resulting file.

**Contaminant Database** (optional): the list of protein contaminants; if provided, these proteins will be excluded from the resulting file.

**Export Folder** (required)**:** the directory of the exported files

**Num of Descriptive Cols:** the number of descriptive columns in the Raw Peptide Intensity file. As indicated in 2.2.1, this value is fixed to 5.

**Num of Sample Groups:** for differential abundance t-test, only two sample groups are allowed: control group and ligand-treated group. Therefore, this value is fixed to 2.

**Num of Replicates**: the number of experimental replicates for each sample group. At least three replicates are required for the statistical t-test analysis.

**Order of Sample Groups:** 1 or 2. 1 indicates that the columns of control group precede the columns of ligand-treated group, whereas 2 indicates the opposite.

**Concentrations Points:** the applied concentration of the analyte ligand in each sample group.

***Step 2: plotting***

Click **Load**.

> **Boxplot** shows the distribution of peptide intensity in each LC-MS/MS run. This plot informs whether the raw peptide intensities between different runs need to be normalized.
>
> **Peptide/Protein Volcano Plot** shows the results of the differential abundance test by plotting the peptides’ or proteins’ fold changes against the significance level. When changing the thresholds of **-Log10 P.value** and **Log2 FC**, the **Load** button should be clicked again to refresh the plot.

***Step 3: export the resulting files***

Select **Protein** to export protein-level results of differential abundance test;

Select **Peptide** to export peptide-level results of differential abundance test;

Select **Both** to export both files.

Click **Export**.



### [3.2 Local Stability Plot](# contents)

This module is designed to generate Protein Local Stability Plot.

![image-20230104151945545](C:\Users\zhyemqww\AppData\Roaming\Typora\typora-user-images\image-20230104151945545.png)



***Step 1: upload and setting***

**Peptide File** (required)**:** the peptide-level results of differential abundance test exported in 3.1.

**Domain info** (required): the domain architectures of the proteins.

**Proteins of interest** (optional): the list of proteins of interest. If provided, the proteins of interest will be present in **Protein** panel (below).

**Export Folder** (required)**:** the directory of the exported files.

***Step 2: filter***

If there are no pre-determined proteins of interest, users can define the proteins of interest by setting the thresholds of -Log10 P.value and Log2 FC (located at the bottom of **Protein** panel).

Click **Filter**.

***Step 3: preview***

Select a protein in **Protein** panel and click **Preview** to display the protein local stability plot for the selected protein.

***Step 4: export the resulting files***

Set **Ligands**, **Cell Lines**, and **Experiment Date**.

**Combined Plot:** generate a summary PDF file.

**Split Results:** store the results of each protein separately in a folder named by the protein's gene name.

Click **Export**.



### [3.3 Pro/Pep Affinity](# contents)

This module is designed to calculate the affinity between peptides/proteins and the analyte ligand.

![image-20230104152047501](C:\Users\zhyemqww\AppData\Roaming\Typora\typora-user-images\image-20230104152047501.png)



***Step 1: upload and setting***

**DD Raw Peptide Intensity** (required): raw peptide intensities output by searching engines (e.g., Spectronaut) from a dose-dependent PELSA experiment.

**Proteins of Interest** (optional): the list of proteins of interest; if provided, these proteins will be present in the **Protein** panel.

**Contaminant Database** (optional): the list of protein contaminants; if provided, these proteins will be excluded from the resulting file.

**Export Folder** (required)**:** the directory of the exported files.

**Num of Descriptive Cols:** the number of descriptive columns in the DD Raw Peptide Intensity file. This value is fixed to 5.

**Num of Sample Groups:** the number of concentration points (including the control group).

**Num of Replicates**: the number of experimental replicates for each sample group. At least three replicates are required for the statistical t-test analysis.

**Reorder Columns by Position:** descriptive columns of the dataset should be placed in front of the quantitative columns; the quantitative columns should be rearranged by the corresponding ligand concentrations (from the lowest to the highest).

**Concentration Points:** the applied concentrations (from the lowest to the highest). The units of the input concentration points should be nM, uM, mM, or M. There should be no space between the numerical value and unit symbol. For example, the input concentration point should be 1mM instead of 1 mM.

The protein-level affinity is calculated by fitting the ligand concentrations and average fold changes of the peptides (from that protein) to a four-parameter log-logistic trendline. The following parameters are used to select peptides with high-quality dose-response data for protein-level affinity calculation.

**Max CV:** maximum coefficient of variation (CV). The CV of peptide intensities under any concentration point should be \< **Max CV**.

**Min R²:** R² refers to the correlation to the sigmoid trend of the ligand dose-response profile. The R² of the selected peptides should be \> **Min R².**

**Max Exp/Veh Ratio:** Exp/Veh Ratio refers to the fold change of peptide intensity (maximum ligand concentration group versus control group). The Exp/Veh Ratio of the selected peptide should be \< **Max Exp/Veh Ratio.**

**Min Significance Value:** significance value refers to the lower of -Log10P.values acquired in the top 2 largest ligand concentrations. The significance values of the selected peptides should be \> **Min Significance Value.**

***Step 2: load data***

Click **Load**.

When the process bar value reaches 100, click **Refresh Table**.

***Step 3: preview***

Select a protein and click **Preview** to display the dose-response curve.

***Step 4: export the resulting files***

Select **Protein** to export protein-level affinity results;

Select **Peptide** to export peptide-level affinity results;

Select **Both** to export both files.

Click **Export**.



## [4. Demo](# contents)

In this section, we will use demo data to demonstrate how PELSA-Decipher works. The demo data can be found in the folder “DemoFiles” in our installation package “PELSA-Decipher-Beta01”. If “PELSA-Decipher-Beta01” is in the E drive in your computer, *e.g.*, `E:/PELSA-Decipher-Beta01`, you can load the demo data as indicated below.

### [4.1 Statistical Testing](# contents)

The demo data in this section is from a PELSA analysis of staurosporine-treated HeLa cell lysates (four technical replicates). Staurosporine is a pan-kinase inhibitor and the applied concentration is 20uM. A list of human kinase proteins downloaded from KinHub (<http://www.kinhub.org>) is imported as proteins of interest. The contaminant database is derived from Maxquant (<https://www.maxquant.org/>) in the directory `(MaxQuant\bin\conf)`.

```py
Raw Peptide Intensity File -> E:/PELSA-Decipher-Beta01/DemoFiles/statistical_testing/Raw_Peptide_Intensity_File.csv

Proteins of Interest -> E:/PELSA-Decipher-Beta01/DemoFiles/statistical_testing/Proteins_of_Interest.csv

Contaminant Database -> E:/PELSA-Decipher-Beta01/DemoFiles/statistical_testing/Contaminant_Database.csv

Export Folder -> E:/PELSA-Decipher-Beta01/DemoFiles/statistical_testing_export

Num of Descriptive Cols -> 5

Num of Sample Groups -> 2

Num of Replicates -> 4

Order of Sample Groups -> 1

Concentrations Points -> 
vehicle
20uM
```

![image-20230104153834380](C:\Users\zhyemqww\AppData\Roaming\Typora\typora-user-images\image-20230104153834380.png)



### [4.2 Local Stability Plot](# contents)

The peptide-level statistical testing results from 4.1 are imported as Peptide File. A list containing 13 kinase proteins is imported as Proteins of Interest. Domain features of 20,268 proteins derived from Uniprot are imported as Domain Info.

```py
Peptide File -> E:/PELSA-Decipher-Beta01/DemoFiles/local_stability_plot/Peptide_File.csv

Proteins of Interest -> E:/PELSA-Decipher-Beta01/DemoFiles/local_stability_plot/Proteins_of_Interest.csv

Domain Info -> E:/PELSA-Decipher-Beta01/DemoFiles/local_stability_plot/Domain_Info.tsv

Export Folder -> E:/PELSA-Decipher-Beta01/DemoFiles/local_stability_plot_export

-Log10 P.vaue -> 0.00

Log2 FC -> 0.00

Ligands -> Stau

Cell Lines -> HeLa
```

![image-20230104154000094](C:\Users\zhyemqww\AppData\Roaming\Typora\typora-user-images\image-20230104154000094.png)



### [4.3 Pro/Pep Affinity](# contents)

The demo data in this section is from a dose-response PELSA analysis of R2HG-treated Jurkat cell lysates (four replicates). The applied R2HG concentration points are: 0uM, 20uM, 200uM, 1mM, 5mM, and 10mM. A list of 116 previously-known αKG-binding proteins is imported as Proteins of Interest. The same Contaminant Database in 4.1 is imported in this panel.

```py
DD Raw Peptide Intensity -> E:/PELSA-Decipher-Beta01/DemoFiles/pro_pep_affinity/DD_Raw_Peptide_Intensity.csv

Proteins of Interest -> E:/PELSA-Decipher-Beta01/DemoFiles/pro_pep_affinity/Proteins_of_Interest.csv

Contaminant Database -> E:/PELSA-Decipher-Beta01/DemoFiles/pro_pep_affinity/Contaminant_Database.csv

Export Folder -> E:/PELSA-Decipher-Beta01/DemoFiles/pro_pep_affinity_export

Num of Descriptive Cols -> 5

Num of Sample Groups -> 6

Num of Replicates -> 4

Reorder Columns by Position  -> 1:5, 6:9, 22:25, 26:29, 10:13, 14:17, 18:21

Concentration Points -> 
000uM
020uM
200uM
001mM
005mM
010mM

Max CV -> 0.50

Min R2 -> 0.9

Max Exp/Veh Ratio -> 0.75

Min Significance Value -> 2.0
```

![image-20230104154023571](C:\Users\zhyemqww\AppData\Roaming\Typora\typora-user-images\image-20230104154023571.png)



## [5. Common Problems and Solutions](# contents)

### [5.1 Cannot be opened](# contents)

Please ensure that the environment variables are configured correctly. If PELSA-Decipher still cannot be opened, please re-install R (version 4.2) and set the environment variables.

### [5.2 Unexpected termination](# contents)

Please check the anti-virus software. We observed that some anti-virus software can clean up the executable files of PELSA-Decipher.

Please check the installation path of R. If R is installed in `C:\Program Files`, please reinstall R in another path and set the environment variables.
