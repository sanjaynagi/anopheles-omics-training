***The malaria-vector software ecosystem training course***

* ***RNA-Seq-Pop [https://github.com/sanjaynagi/rna-seq-pop](https://github.com/sanjaynagi/rna-seq-pop)***   
* ***Malariagen\_data [https://github.com/malariagen/malariagen-data-python](https://github.com/malariagen/malariagen-data-python)***   
* ***AnoExpress [https://github.com/sanjaynagi/AnoExpress](https://github.com/sanjaynagi/AnoExpress)***   
* ***AgamPrimer [https://github.com/sanjaynagi/AgamPrimer](https://github.com/sanjaynagi/AgamPrimer)***   
* ***The malaria-vector-selection-atlas [https://github.com/anopheles-genomic-surveillance/selection-atlas](https://github.com/anopheles-genomic-surveillance/selection-atlas)***   
- ***AmpSeeker [https://github.com/sanjaynagi/AmpSeeker](https://github.com/sanjaynagi/AnoExpress)***    
* ***AnoSpp package [https://github.com/malariagen/anospp-analysis](https://github.com/malariagen/anospp-analysis)***   
* ***Multiply [https://github.com/JasonAHendry/multiply](https://github.com/JasonAHendry/multiply)*** 

***Goals/Aims***

* Teach good practices in data management in bioinformatics.  
  * Excerpts/highlights from Vince Buffalo book   
  * Git concepts   
* Teach the utility of workflow managers in bioinformatics (snakemake, nextflow).   
* Equip researchers to analyse multiple types of omics data, not just WGS.  
  * RNA-Seq bouake dataset \- RNA-Seq-Pop  
  * WGS \- malariagen\_data, selection-atlas  
  * Amplicon-Seq \- GAARD dataset with AmpSeeker  
* Enhance research into genomic surveillance and novel resistance variant discovery.

**Target audience**

Those interested in bioinformatics of malaria vectors.

**Learning outcomes**

* Understand the use of genomic surveillance in vector control  
* Understand the utility of workflow managers (snakemake, nextflow) in bioinformatics  
* Analyse RNA-Seq and Amplicon sequencing data to help identify markers associated with resistance   
* Confidently interpret the results of RNA-Seq and Amplicon-Sequencing analysis

**Description**

The idea for the course is to complement the malariagen-PAMCA workshops, focusing less on pop gen and WGS, and more on other types of omic data, such as RNA and Amplicon Sequencing, on general concepts in bioinformatics, such as using workflow managers (snakemake) and git. 

Using the RNA-Seq-Pop example dataset (downloaded directly within the workflow with ffq), we give each participant two or three candidate genes to use for further steps, which they then use throughout the course, with malariagen\_data, AnoExpress, AgamPrimer etc. Ideally these are interesting candidates. At the end of the course, everyone presents what they found, in a similar way to the TROP970 bioinformatics module. 

**T3 connect insights**

*Funding for the course?*

*Know as much as you can about your learners* 

*Welcome environment, talk about your own struggles first, its normal to find it difficult*

*What are the learning outcomes? \-\> how to achieve those*   
*What are the assessments? \-\> offline assessment for remote learners, formal assessment for TROP970 (presentations).*

*Can we build a quiz (for each day) into the website? Yes if we use nextjs\!*   
*Could also do .md spoiler tags* 

*Types of assessment \- question banks, quizzes, presentations/posters*

*How are we evaluating the course?*  
*Build this all then ask chatgpt for help* 

***Remember***  
1 hour flex time each day, own projects or tailored training.   
Plan B in case things go wrong?

***Course Programme***

***Day 1 \- Intro to Anopheles genomics and RNA-Seq-Pop***  
---

***\[am\] Intro***

* *Genomic surveillance of malaria vectors, what, why, how*   
* *Introduction to the Ag1000G/Af1*  
* ***Introduction to the malaria package ecosystem***  
* [***omic’ approaches to discovering genes and mutations involved in insecticide resistance***](https://docs.google.com/presentation/d/1Q19ED9eN3PMMrECRlTouOZ200kNJvHxhhUFAQfnwrSs/edit#slide=id.g27bc5a4acd7_0_0)

***\[pm\] Workflow managers \+ RNA-Seq-Pop***

* *RNA-Seq-Pop lecture*  
* *Introduction to workflow managers and snakemake*

*Workshop*

* *Getting started, the snakemake directory structure*  
* *Configuring the workflow*   
* *ffq to download training data, set off running\!*  
* *Meanwhile, dummy result data. We will explore results tomorrow.* 

**\[day 2\] \- Transcriptomics \- RNA-Seq-Pop and AnoExpress**  
---

**\[am\] \- RNA-Seq-Pop results**

* Intro to transcriptomics   
* Exploring RNA-Seq-Pop results  
  * Give each participant candidate genes to look into in future sessions. 

**\[pm\] \- Transcriptomics** 

* Transcriptomic studies of malaria vectors, past, current, future   
* Intro to AnoExpress \-  the package 

*Workshop*

* Using AnoExpress to load and visualise expression data 

**Day 3 \- WGS \+ malariagen\_data \+ GWSS**  
---

**\[am\] \- WGS, Ag1000g and malariagen\_data**

* Intro/Recap on WGS / Ag1000G  
* Intro to malariagen\_data

*Workshop*

* Using malariagen\_data for IR related gene/mutation discovery   
* Malariagen\_data \+ AnoExpress functions 

**\[pm\] \- GWSS and the malaria vector selection atlas** 

* Intro to Selection and genome-wide selection scans  
* The malaria vector selection Atlas 

**Day 4 \- Primer/probe design and Amplicon sequencing**   
---

**\[am\] AgamPrimer** 

* Case study first \- Kdr/Ace1  
* Taking candidates and designing primers and probes   
* Designing LNA assays \- snp genotyping 

**\[pm\] Amplicon sequencing** 

* Introduction to amplicon sequencing  
* AnoSpp  
* Multiply \- amplicon sequencing panel design   
    
* AmpSeeker pipeline

*Workshop*

* Run AmpSeeker example dataset analysis and explore results

**Day 5 \- Show and tell, and wrap up** 

---

**\[am\]** 

* Presentations/show and tell on what everyone has found

**\[pm\]**

* Good practices in bioinformatics and data analysis \[Vince Buffalo \- bioinformatics book\]  
  * Folder structure   
  * Github / git / repos   
  * reproducibility / conda 

* Everyone does own bits of analysis, I help  
* Help with others own bioinformatic projects 