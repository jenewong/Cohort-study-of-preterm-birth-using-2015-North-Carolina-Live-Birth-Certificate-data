/*****************************************************************************
	Name: Jennifer Wong
	Program: EPID795_FinalProjectPart1_Wong.sas
    Date: November 3, 2021
	Description: Final Project Part 1 (parts A and B). 
*****************************************************************************/
OPTIONS MERGENOBY=warn NODATE NONUMBER FORMCHAR="|----|+|---+=|-/\<>*";
FOOTNOTE "EPID795_FinalProjectPart1_Wong.sas run at %SYSFUNC(DATETIME(), DATETIME.) by Jennifer Wong";
/******************************* begin program ******************************/

LIBNAME epid716 "/home/u59075382/epid716/Data";

*Question A1.1;
PROC CONTENTS DATA = epid716.birth2015_final;
TITLE "birthscohort data";
RUN;
TITLE;
*checking dataset - 61447 total observations, 9 variables;

PROC UNIVARIATE DATA = epid716.birth2015_final;
	VAR weeks;
	TITLE "Descriptive statistics for gestional age at birth";
RUN;
TITLE;

*For gestational age at birth (variable "weeks"), there are no observations missing data
or any extreme, out of range, and implausible values. All observations for gestional age
fall between the plausible values of 20 weeks and 43 weeks.;
*The mean gestational age is 39 weeks and the standard deviation is 2.1 weeks.;

PROC MEANS DATA = epid716.birth2015_final N NMISS MEAN STD RANGE MEDIAN P5 P95; 
	VAR weeks;
	TITLE "Descriptive statistics for gestional age at birth";
RUN;
TITLE;
*checking for any missing observations, mean, std dev, range, median, 5th and 9th percentile;

PROC FREQ DATA = epid716.birth2015_final;
	TABLES weeks / MISSING;
	TITLE "Frequency of gestional age at birth";
RUN;
TITLE;
*checking for any extreme, out of range, and implausible values for gestional age (weeks);


*Question A1.2;
PROC SGPLOT DATA = epid716.birth2015_final;
	HISTOGRAM weeks / BINWIDTH = 1;
	XAXIS LABEL = "Gestational age at birth (weeks)" LABELATTRS = (size = 12);
	YAXIS LABEL = "Percent of births (%)" LABELATTRS = (size = 12);
	TITLE HEIGHT = 1.7 "Percent of Births by Gestational Age at Birth";
	FOOTNOTE HEIGHT = 1.1 "Figure 1.  Gestational age at birth was measured from a cohort study 
	population of 61,447 North Carolina live births in 2015. All data were derived from North Carolina 
	Live Birth Certificate data for 2015. The study population included live singleton births without 
	congenital malformations that experienced the entire risk period for preterm birth (the 17-week 
	interval beginning with the 21st week of gestation and ending upon completion of the 37th week of 
	gestation) during 2015. Births with unknown gestational age were excluded. The gestational 
	age at birth has a minimum of 20 weeks, maximum of 43 weeks, median and mean of 39 weeks, 
	and standard deviation of 2.1 weeks.";
RUN;
TITLE;
FOOTNOTE;

*Question A2.1;
PROC UNIVARIATE DATA = epid716.birth2015_final;
	VAR weeknum;
	TITLE "Descriptive statistics for week of birth in the year 2015";
RUN;
TITLE;

*The median week of birth (weeknum) is the 33rd week of the year 2015. There are no observations
with missing data for weeknum and the range of data is consistent with what is expected. There are 53 
weeks in the year 2015, and the range of data for weeknum is week 2 to week 50.;

PROC MEANS DATA = epid716.birth2015_final N NMISS MEAN STD RANGE MEDIAN P5 P95; 
	VAR weeknum;
	TITLE "Descriptive statistics for week of birth in 2015";
RUN;
TITLE;
*checking for any missing observations, mean, std dev, range, median, 5th and 9th percentile;

PROC FREQ DATA = epid716.birth2015_final;
	TABLE weeknum / MISSING;
	TITLE 'PROC FREQ of Year 2015 Week of Birth'; 
RUN;
*checking range of data;

*Question A2.2; 
PROC SGPLOT DATA = epid716.birth2015_final;
	HISTOGRAM weeknum / BINWIDTH = 1;
	TITLE "Distribution of week of births in 2015";
RUN;
TITLE;

*The data for weeknum does not have extreme, out of range, or inplausible values.;

*Question A2.3;
PROC SORT DATA = epid716.birth2015_final OUT = births2; *new dataset sorting by weeks;
	BY weeks;
RUN;

PROC SGPLOT DATA = epid716.birth2015_final;
	SCATTER X = weeknum Y = weeks;
	XAXIS LABEL = "2015 Calendar Week";
	YAXIS LABEL = "Gestational Age (Weeks) at Birth";
	TITLE 'Gestational Age (Weeks) at Birth By 2015 Calendar Week of Birth'; 
RUN;

*Data meets all eligibility criteria
The earliest week in the year in which a term birth can occur is the 38th week. For this study, births that
ocurred on or after the first day of the 38th week are term. 
The latest week in the year in which a preterm birth can occur is 17th week. There are 53 weeks in the year
2015. The study consists of births with the entire 17-week risk period for preterm birth occurring within
the year 2015. Since the 37th week of gestation is the last week of the risk period for preterm birth, 
53-37+1 = 17th week.; 


*Question A3.1;
DATA births3; *new dataset that adds variable pwk;
	SET epid716.birth2015_final;
	pwk = MIN(17, weeks - 19.5); *created new variable using MIN function. pwk classifies each birth 
	according to person-weeks at risk where term births are pwk=17 (max person-weeks at risk for preterm
	birth. For preterm births, they occured in the middle of the week.;
	LABEL pwk = "Person-weeks at risk of pre-term birth"
	 	  weeks="Weeks of gestation"
		  weeknum="2015 calendar week of birth";
RUN;

PROC CONTENTS DATA = births3;
TITLE "New dataset with pwk variable";
RUN;
TITLE;
*checking to make sure new variable was created;

PROC PRINT DATA = births3 (OBS = 10) LABEL; 
	VAR pwk;
	TITLE "Risk period for preterm birth";
RUN;
TITLE;
*checking to make sure variable does as intended;

PROC PRINT DATA = epid716.birth2015_final (OBS = 10);
	VAR weeks;
	TITLE "Number of weeks of gestional age completed at birth";
RUN;
TITLE; 
*checking to make sure variable does as intended;

PROC FREQ DATA = births3;
	TABLE weeks*pwk / MISSING LIST;
	TITLE 'Completed weeks of gestation (calculated) by person-time at risk'; 
RUN;
*checking data again;

*Question A3.2;
PROC UNIVARIATE DATA = births3;
	VAR pwk;
	WHERE . < pwk < 17;
	TITLE "Descriptive statistics for person-time at risk";
RUN;
TITLE;
*Among preterm births, the mean of person-time at risk is 14 person-weeks and the standard deviation 
is 3.4 person-weeks.;

*Question A4.1;
PROC FORMAT ;
	VALUE pretermf
	. = "Missing"
	0 = "Term"
	1 = "Preterm";
RUN;

DATA births4; *dataset that includes the new preterm variable;
	SET births3;
	IF missing(weeks) or weeks = 99 THEN preterm = .;
	ELSE IF weeks >= 37 THEN preterm = 0;
	ELSE IF 20 <= weeks <= 36 THEN preterm = 1;
	LABEL preterm = "Birth Status";
	FORMAT preterm pretermf.;
RUN; 
*preterm variable is based on weeks variable(completed weeks of gestation). Preterm is defined as
live birth with 20 - <37 weeks of gestation completed. Term is defined as greater than or equal to 37 
weeks of gestation completed.;

PROC PRINT DATA = births4 (OBS = 700) LABEL;
	VAR weeks preterm;
	TITLE "Weeks and Birth Status";
RUN;
TITLE;
*checking to make sure variable does as intended;

PROC FREQ DATA = births4;
	TABLE weeks*preterm / MISSING LIST;
	TITLE 'Completed weeks of gestation (calculated) by preterm birth'; 
RUN;
*checking data again;

*Question A4.2;
PROC SGPLOT DATA = births4;
	VBAR preterm / STAT = percent;
	VLINE preterm / STAT = percent LINEATTRS = (THICKNESS = 0px) datalabel;
	TITLE "Proportion of birth status";
RUN;
TITLE;
PROC FREQ DATA = births4;
	TABLE preterm / MISSING;
	TITLE 'Proportion of births that were term and preterm';
RUN;
*8.4% of all births in the data are preterm births.;

PROC FREQ DATA = births4;
	WHERE preterm = 1;
	TABLE weeks / MISSING;
	TITLE 'Completed weeks of gestation (calculated) by preterm birth among 17-week risk period';
RUN;
*40% of preterm births occured in the final week (week 36) of the 17-week risk period.;

*Question B1; 
PROC FREQ DATA = births4;
	TABLES prenatal;
	TITLE "All data including women who received or did not receive prenatal care";
RUN;
TITLE;
*checking to see if there are any unknown (99) or no prenatal care (88) observations;
*there are 1461 observations who received not prenatal care (88) and 606 observations with
unknown information about prenatal care (99) that would need to be accounted for before
analysis of data; 

DATA births4n; *creating numeric versions of prenatal variable;
	SET births4;
	prenatal_num = prenatal+0; 
RUN;
*Check numeric recode;

PROC UNIVARIATE DATA = births4n;
	VAR prenatal_num;
	TITLE 'PROC UNIVARIATE: Month of pregnancy when prenatal care began';
RUN;

*Question B2;
DATA births5; *dataset that drops observations where prenatal care is unknown or no;
	SET births4;
	IF prenatal > 9 THEN DELETE;
RUN;

PROC PRINT DATA = births5 (OBS = 150);
	TITLE "Women who received prenatal care";
RUN;
TITLE;

PROC PRINT DATA = births4 (OBS = 150);
	TITLE "All data including women who received or did not receive prenatal care";
RUN;
TITLE;
*checking to make sure observations where prenatal = 99 or 88 were deleted;

PROC FREQ DATA = births5; *this dataset only includes women known to have received prenatal care;
	TABLES prenatal;
	TITLE "Frequency among women who received prenatal care";
RUN;
TITLE;
*Among women known to have received prenatal care, 38% of women most commonly began prenatal care in 
month 3;


*Question B2.1;
PROC FORMAT;
	VALUE pnc5f
	. = "Missing"
	0 = "No"
	1 = "Yes";
RUN;

DATA births6; *dataset that includes the new pnc5 variable;
	SET births4n; 
	IF prenatal_num = 99 THEN pnc5 = .;
	ELSE IF prenatal_num in (88,6:9) THEN pnc5 = 0;
	ELSE IF 1 <= prenatal_num <= 5 THEN pnc5 = 1;
	LABEL prenatal_num = "Month in which prenatal care began (recoded)"
	pnc5 = "Prenatal Care in First 5 Months of Gestation";
	FORMAT pnc5 pnc5f.;
RUN; 
*pnc5 variable is based off prenatal variable (month of pregnancy when prenatal care began. pnc5 identifies
if an observation received prenatal care in the first 5 months of gestation. pnc5=0 if no prenatal care,
pnc5=1 if prenatal care received, pnc5=. if unknown.;

PROC PRINT DATA = births6 (OBS = 250) LABEL;
	VAR prenatal pnc5;
	TITLE "Prenatal Care Start Month and Prenatal Care in First 5 Months of Gestation";
RUN;
TITLE;
*checking to make sure variable does as intended;

PROC FREQ DATA = births6;
	TABLE prenatal*pnc5 / LIST MISSPRINT;
	TITLE 'Prenatal Care in First 20 Weeks, By Month in which Prenatal Care Began';
RUN;
	
*Question B2.2;
PROC FREQ DATA = births6; 
	TABLES pnc5 / MISSPRINT;
	TITLE "Overall prenatal care in first 5 months of gestation";
RUN;
TITLE;
*counts and proportions of observations in each category of pnc5 in the study population as a whole;

PROC FREQ DATA = births6; 
	TABLES pnc5 / MISSPRINT;
	WHERE preterm = 1;
	TITLE "Prenatal care in first 5 months of gestation where birth status is preterm";
RUN;
TITLE;
*counts and proportions of observations in each category of pnc5 in the study population when birth
status is preterm;

PROC FREQ DATA = births6; 
	TABLES pnc5 / MISSPRINT;
	WHERE preterm = 0;
	TITLE "Prenatal care in first 5 months of gestation where birth status is term";
RUN;
TITLE;
*counts and proportions of observations in each category of pnc5 in the study population when birth
status is term;

*BELOW IS ANOTHER WAY TO DO THIS;
PROC SORT DATA = births6 OUT = births6_sort; 
	BY preterm;
RUN;

*Examine counts and proportions for prenatal care BY preterm birth status;
PROC FREQ DATA = births6_sort;
	BY preterm;
	TABLE pnc5 / MISSING;
	TITLE 'Early prenatal care (in the first 20 weeks of gestation) by preterm birth status'; 
RUN;

*Percentage with preterm birth BY receipt of early prenatal care;
PROC SORT DATA = births6 OUT = births6_sort2; 
	BY pnc5; 
RUN;

PROC FREQ DATA = births6_sort2;
	BY pnc5;
	TABLE preterm / MISSING;
	TITLE 'Preterm birth status by early prenatal care (in the first 20 weeks of gestation)'; 
RUN;


*Question B2.3;
PROC FREQ DATA = births6_sort2;
	BY pnc5;
	TABLE preterm / MISSING;
	TITLE 'Preterm birth status by early prenatal care (in the first 20 weeks of gestation)'; 
RUN;
TITLE;

*Among women who received prenatal care during the first 5 months of gestation, 7.8% had a preterm birth;


*Question B2.4 (Question 8);
PROC FREQ DATA = births6_sort2;
	BY pnc5;
	TABLE preterm / MISSING;
	TITLE 'Preterm birth status by early prenatal care (in the first 20 weeks of gestation)'; 
RUN;
TITLE;

*Among women who did not receive prenatal care during the first 5 months of gestation, 12% had a 
preterm birth;


*Question C1.1;
PROC CONTENTS DATA = births6;
	TITLE "PROC CONTENTS of births6";
RUN;
TITLE;
*variable name for mother's age is in all caps; 
*MAGE is character variable;

PROC FREQ DATA = births6;
	TABLE MAGE;
	TITLE "PROC FREQ of age of mother";
RUN;
TITLE;
*no missing variables but some unknown age 99 that need to be accounted for;

DATA births7; *creating new dataset with numeric versions of MAGE variable;
	SET births6;
	mage_num = MAGE + 0;
	IF MAGE = 99 THEN mage_num = .;  
RUN;

PROC FREQ DATA = births7;
	TABLE mage_num / MISSING;
	TITLE "PROC FREQ of age of mother (recoded)";
RUN; 
TITLE;
*checking to make sure new variable is created and recoded correctly; 
 
PROC UNIVARIATE DATA = births7;
	VAR mage_num;
	TITLE "PROC UNIVARIATE of age of mother";
RUN;
TITLE;

PROC MEANS DATA = births7 N NMISS MEAN STD RANGE MEDIAN P5 P95; 
	VAR mage_num;
	TITLE "PROC MEANS of age of mother";
RUN;
TITLE;
*For maternal age in the whole population, there are no observations missing data.
One observation had unknown age coded as "99", which was recoded to missing "."
*The mean maternal age is 28 years old and the standard deviation is 5.8 years.;

PROC SORT DATA = births7 OUT = births7_sort; *sorting data by preterm;
	BY preterm; 
RUN;

PROC UNIVARIATE DATA = births7_sort;
	VAR mage_num;
	BY preterm;
	TITLE "PROC UNIVARIATE of age of mother by birth status";
RUN;
TITLE;

PROC MEANS DATA = births7_sort N NMISS MEAN STD RANGE MEDIAN P5 P95; 
	VAR mage_num;
	BY preterm;
	TITLE "PROC MEANS of age of mother by birth status";
RUN;
TITLE; 


*Question C1.2;
PROC SGPLOT DATA = births7;
	VBAR mage_num;
	YAXIS LABEL = "Number of Eligible Births" LABELATTRS = (size = 12);
	XAXIS FITPOLICY = THIN LABEL = "Maternal Age (years)" LABELATTRS = (size = 12);
	TITLE HEIGHT = 1.7 "Distribution of Maternal Age for";
	TITLE2 HEIGHT = 1.7 "North Carolina Births"; 
	FOOTNOTE HEIGHT = 1.1 "Figure 2. Maternal age was measured from a cohort study population of 
	61,446 North Carolina live births in 2015. All data were derived from North Carolina 
	Live Birth Certificate data for 2015. The study population included live singleton births without 
	congenital malformations that experienced the entire risk period for preterm birth (the 17-week 
	interval beginning with the 21st week of gestation and ending upon completion of the 37th week of 
	gestation) during 2015. Births with unknown gestational age were excluded. Maternal age in the total 
	population has a minimum of 11 years, maximum of 49 years, median and mean of 28 years, 
	and standard deviation of 5.8 years.";
RUN;
TITLE;
TITLE2;
FOOTNOTE;


*Question C2.1;
PROC MEANS DATA = births7 MEAN;
	WHERE mage_num in(44:50);
	VAR mage_num;
RUN;
*the mean is 44.7500 years;

PROC MEANS DATA = births7 MEAN;
	WHERE mage_num in(0:14);
	VAR mage_num;
RUN;
*the mean is 13.8260870 years;

PROC FREQ DATA = births7;
	TABLE mage_num;
RUN;
*hand calculating the mean age to check code;

DATA births8; *dataset that includes the new mage2 variable;
	SET births7; 
	IF missing(mage_num) or mage_num = 99 THEN mage2 = .;
	ELSE IF mage_num in (44:50) THEN mage2 = 44.7500;
	ELSE IF mage_num in (0:14) THEN mage2 = 13.8261;
	ELSE IF mage_num in (15:43) THEN mage2 = mage_num;
	LABEL mage2 = "Condensed maternal age (age 44 or older in a single category; age 14 or younger in 
	a single category)";
RUN; 

PROC FREQ DATA = births8;
	TABLE mage_num*mage2 / LIST MISSPRINT;
	TITLE 'Maternal age, By Condensed maternal age';
RUN;
TITLE;
*checking to make sure variable is created as intended;


*Question C2.2;
PROC UNIVARIATE DATA = births8;
	VAR mage2;
	TITLE "PROC UNIVARIATE of maternal age (condensed)";
RUN;
TITLE;
*The minimum value for mage2 is 14 years, and the maximum value for mage2 is 45 years;

PROC MEANS DATA = births8 N NMISS MEAN STD RANGE MEDIAN P5 P95; 
	VAR mage2;
	TITLE "PROC MEANS of maternal age (condensed)";
RUN;
TITLE;
*checking the descriptive statistics;

PROC UNIVARIATE DATA = births7;
	VAR mage_num;
	TITLE "PROC UNIVARIATE of age of mother";
RUN;
TITLE;

PROC MEANS DATA = births7 N NMISS MEAN STD RANGE MEDIAN P5 P95; 
	VAR mage_num;
	TITLE "PROC MEANS of age of mother";
RUN;
TITLE;
*comparing mage2 to mage;
*When rounded, the mean, standard deviation, median, 5th and 95th percentile for mage2 and mage is the same. 
The range is different because the minimum and maximum values differ between the two variables. The range
for mage is 38 and the range for mage2 is 31;

*Question C2.3;
PROC SGPLOT DATA = births8;
	VBAR mage2;
	YAXIS LABEL = "Number of Eligible Births" LABELATTRS = (size = 12);
	XAXIS FITPOLICY = ROTATETHIN LABEL = "Maternal Age (years)" LABELATTRS = (size = 12);
	TITLE HEIGHT = 1.7 "Distribution of Condensed Maternal Age for NC Births"; 
RUN;
TITLE;


*Question C3.1;
PROC FREQ DATA = births8;
	TABLE race;
RUN;

PROC CONTENTS DATA = births8;
RUN;
*viewing data. race is a character variable;

DATA births8n; *creating numeric versions of race variable;
	SET births8;
	race_num = race+0;
	LABEL race_num = "Race of mother/child (numeric)";
RUN;

PROC FORMAT;
	VALUE racef
	. = "Missing"
	1 = "White"
	2 = "African American"
	3 = "American Indian or Alaska Native"
	4 = "Other";
RUN;

PROC FREQ DATA = births8n;
	TABLE race_num;
	FORMAT race_num racef.;
RUN; 


*Question C3.2;
PROC UNIVARIATE DATA = births8n;
	VAR race_num;
RUN;
*there are no extreme or inplausible values for race. The range of values is 1-4, which is plausible;


*Question C4;
PROC MEANS DATA = births8n N NMISS MEAN STD RANGE MEDIAN P5 P95; 
	VAR race_num;
	TITLE "Descriptive statistics for race";
RUN;
TITLE;
*there is no missing data for race;

PROC FREQ DATA = births8n;
	TABLE race_num;
	TITLE "PROC FREQ of race";
RUN;
TITLE;
*counts and proportions of observations in each race category in population as a whole;

PROC SORT DATA = births8n OUT = births8n_sort; *sorting data by preterm;
	BY preterm; 
RUN;

PROC FREQ DATA = births8n_sort;
	TABLE race_num / MISSPRINT;
	BY preterm;
	TITLE "PROC FREQ of race by birth status";
RUN;
TITLE;
*counts and proportions of observations in each race category by birth status;
*no observations have missing data for the variable race;


*Question C5.1;
PROC FORMAT;
	VALUE race2f
	. = "Missing"
	0 = "White (referent)"
	1 = "African American"
	2 = "Other";
RUN;

DATA births9; *dataset that includes the new race2 variable;
	SET births8n; 
	IF missing(race_num) or race_num = . THEN race2 = .;
	ELSE IF race_num = 1 THEN race2 = 0;
	ELSE IF race_num = 2 THEN race2 = 1;
	ELSE IF race_num in (3, 4) THEN race2 = 2;
	LABEL race2 = "Race of mother/child (recoded)"
	race2 = "Race of mother/child recoded to compare white, african american, and other";
	FORMAT race2 race2f.;
RUN; 

PROC FREQ DATA = births9;
	TABLE race_num*race2 / LIST MISSPRINT;
	TITLE "PROC FREQ of recoded race of mother/child and race";
RUN;
TITLE;

PROC FREQ DATA = births9;
	TABLE race2 / LIST MISSPRINT;
	TITLE "PROC FREQ of recoded race of mother/child";
RUN;
TITLE;
*checking to make sure new variable was created as intended;

PROC FREQ DATA = births9;
	TABLE race2;
	TITLE "PROC FREQ of recoded race";
RUN;
TITLE;
*counts and proportions of observations in each new race category in population as a whole;

PROC SORT DATA = births9 OUT = births9_sort; *sorting data by preterm;
	BY preterm; 
RUN;

PROC FREQ DATA = births9_sort;
	TABLE race2;
	BY preterm;
	TITLE "PROC FREQ of recoded race by birth status";
RUN;
TITLE;
*counts and proportion of observation in each new race category by birth status;


*Question C6.1;
PROC CONTENTS DATA = births9;
RUN;
*viewing data. hispmom is character variable;

PROC FREQ DATA = births9;
	TABLE hispmom;
	TITLE "PROC FREQ of Hispanic origin of mother";
RUN;
TITLE;

PROC FORMAT;
	VALUE mhispf
	. = "Missing"
	0 = "non-Hispanic (referent)"
	1 = "Hispanic";
RUN;

DATA births10; *dataset that includes the new mhisp variable;
	SET births9; 
	IF missing(hispmom) or hispmom = "U" THEN mhisp = .;
	ELSE IF hispmom = "N" THEN mhisp = 0;
	ELSE IF hispmom = "Y" THEN mhisp = 1;
	LABEL mhisp = "Hispanic origin of mother (recoded)"
	mhisp = "Hispanic origin of mother recoded to compare Hispanic or non-Hispanic";
	FORMAT mhisp mhispf.;
RUN; 

PROC FREQ DATA = births10;
	TABLE hispmom*mhisp / LIST MISSPRINT;
	TITLE "PROC FREQ of recoded hispnic origin and original";
RUN;
TITLE;
*checking that new variable was created as intended;


*Question C6.2;
PROC FREQ DATA = births10;
	TABLE mhisp / MISSPRINT;
	TITLE "PROC FREQ of recoded Hispanic origin of mother";
RUN;
TITLE;
*counts and proportions of observations in each new race category in population as a whole;

PROC SORT DATA = births10 OUT = births10_sort; *sorting data by preterm;
	BY preterm; 
RUN;

PROC FREQ DATA = births10_sort;
	TABLE mhisp / MISSPRINT;
	BY preterm;
	TITLE "PROC FREQ of recoded Hispnic origin of mother by birth status";
RUN;
TITLE;
*counts and proportion of observation in each new race category by birth status;
*Among mothers in the study population with non-missing data concerning their Hispanic ethnicity, 
15% are of Hispanic origin;


*Question C7.1;
PROC FORMAT;
	VALUE racethf
	. = "Missing"
	0 = "White/non-Hispanic (referent)"
	1 = "White/Hispanic"
	2 = "African American/non-Hispanic"
	3 = "African American/Hispanic"
	4 = "Other/non-Hispanic"
	5 = "Other/Hispanic";
RUN;

DATA births11; *dataset that includes the new raceth variable;
	SET births10; 
	IF mhisp = . AND race2 = . THEN raceth = .;
	ELSE IF mhisp = 0 AND race2 = 0 THEN raceth = 0;
	ELSE IF mhisp = 1 AND race2 = 0 THEN raceth = 1;
	ELSE IF mhisp = 0 AND race2 = 1 THEN raceth = 2;
	ELSE IF mhisp = 1 AND race2 = 1 THEN raceth = 3;
	ELSE IF mhisp = 0 AND race2 = 2 THEN raceth = 4;
	ELSE IF mhisp = 1 AND race2 = 2 THEN raceth = 5;
	LABEL raceth = "Mothers race and ethnicity";
	FORMAT raceth racethf.;
RUN; 

PROC FREQ DATA = births11;
	TABLE mhisp*race2*raceth / LIST MISSPRINT;
	TITLE "PROC FREQ of race, ethnicity, and race/ethnicity";
RUN;
TITLE;
*checking that new variable is created as intended;


*Question C7.2;
PROC FREQ DATA = births11;
	TABLE raceth / MISSPRINT;
	TITLE "PROC FREQ of mother's race and ethnicity";
RUN;
TITLE;
*counts and proportions of observations in each new race category in population as a whole;

PROC SORT DATA = births11 OUT = births11_sort; *sorting data by preterm;
	BY preterm; 
RUN;

PROC FREQ DATA = births11_sort;
	TABLE raceth / MISSPRINT;
	BY preterm;
	TITLE "PROC FREQ of mother's race and ethnicity by birth status";
RUN;
TITLE;
*counts and proportion of observation in each new race category by birth status;


*Question C8;
PROC FORMAT;
	VALUE raceth2f
	. = "Missing"
	0 = "White/non-Hispanic"
	1 = "White/Hispanic"
	2 = "African American"
	3 = "Other";
RUN;

DATA births12; *dataset that includes the new raceth2 variable;
	SET births11; 
	IF mhisp = . AND race2 = 0 THEN raceth2 = .;
	ELSE IF mhisp = 0 AND race2 = 0 THEN raceth2 = 0;
	ELSE IF mhisp = 1 AND race2 = 0 THEN raceth2 = 1;
	ELSE IF race2 = 1 THEN raceth2 = 2;
	ELSE IF race2 = 2 THEN raceth2 = 3;
	LABEL raceth2 = "Mothers race and ethnicity (recoded)";
	FORMAT raceth2 raceth2f.;
RUN; 

PROC FREQ DATA = births12;
	TABLE mhisp*race2*raceth2 / LIST MISSPRINT;
	TITLE "PROC FREQ of race, ethnicity, and recoded race/ethnicity";
RUN;
TITLE;
*checking that new variable does as intended;

PROC FREQ DATA = births12;
	TABLE raceth2 / MISSPRINT;
	TITLE "PROC FREQ of mother's race and ethnicity (recoded)";
RUN;
TITLE;
*13 observations have missing data for raceth2;


*Question C9;
PROC CONTENTS DATA = births12;
RUN;
*cigdur is a character variable;

PROC FREQ DATA = births12;
	TABLE cigdur;
RUN;
*there are 22 unknown observations;

PROC FORMAT;
	VALUE smokerf
	. = "Missing"
	0 = "Non-smoker"
	1 = "Smoker";
RUN;

DATA births13; *dataset that includes the new smoker variable;
	SET births12; 
	IF missing(cigdur) or cigdur = "U" THEN smoker = .;
	ELSE IF cigdur = "N" THEN smoker = 0;
	ELSE IF cigdur = "Y" THEN smoker = 1;
	LABEL smoker = "Maternal smoking during pregnancy";
	FORMAT smoker smokerf.;
RUN; 

PROC FREQ DATA = births13;
	TABLE cigdur*smoker / LIST MISSPRINT;
	TITLE "PROC FREQ of cigdur and smoker";
RUN;
TITLE;
*checking that new variable created as intended;

PROC FREQ DATA = births13;
	TABLE smoker / MISSPRINT;
	TITLE "PROC FREQ of maternal smoking during pregnancy";
RUN;
TITLE;
*counts and proportions of observations in each new race category in population as a whole;

PROC SORT DATA = births13 OUT = births13_sort; *sorting data by preterm;
	BY preterm; 
RUN;

PROC FREQ DATA = births13_sort;
	TABLE smoker / MISSPRINT;
	BY preterm;
	TITLE "PROC FREQ of maternal smoking during pregnancy by birth status";
RUN;
TITLE;
*counts and proportion of observation in each new race category by birth status;


*Question C10;
PROC CONTENTS DATA = births13;
RUN;
*"SEX" is a character variable;

PROC FREQ DATA = births13;
	TABLE SEX;
RUN;
*there are no unknown sex (coded by 9 in data);

PROC FORMAT;
	VALUE sex_numf
	. = "Missing"
	1 = "Male"
	2 = "Female";
RUN;

DATA births14; *creating new dataset with numeric versions of SEX variable;
	SET births13;
	sex_num = SEX + 0;
	IF missing(SEX) or SEX = "9" THEN sex_num = .;
	LABEL sex_num = "Sex of child";
	FORMAT sex_num sex_numf.;
RUN;

PROC FREQ DATA = births14;
	TABLE SEX*sex_num / LIST MISSPRINT;
	TITLE "PROC FREQ of SEX and sex (recoded)";
RUN;
TITLE;
*checking variable created as intended;

PROC FREQ DATA = births14;
	TABLE sex_num / MISSPRINT;
	TITLE "PROC FREQ of sex of child";
RUN;
TITLE;
*counts and proportions of observations in each new race category in population as a whole;

PROC SORT DATA = births14 OUT = births14_sort; *sorting data by preterm;
	BY preterm; 
RUN;

PROC FREQ DATA = births14_sort;
	TABLE sex_num / MISSPRINT;
	BY preterm;
	TITLE "PROC FREQ of sex of child by birth status";
RUN;
TITLE;
*counts and proportion of observation in each new race category by birth status;


PROC TEMPLATE; *changing the RiskDiffCol1 and RiskDiffCol2 to have 10 decimal places;
EDIT Base.Freq.RiskDiff; 
DEFINE Risk; 
FORMAT = 12.10; END;
DEFINE ASE;
FORMAT = 12.10; END;
DEFINE LowerCL; 
FORMAT = 12.10; END;
DEFINE UpperCL; 
FORMAT = 12.10; END;
DEFINE ExactLowerCL; 
FORMAT = 12.10;END;
DEFINE ExactUpperCL; 
FORMAT = 12.10; END;
END; 
RUN;

PROC TEMPLATE; *changing CommonRelRisks table to have 10 decimal places;
EDIT Base.Freq.CommonRelRisks; 
DEFINE Value; 
FORMAT = 12.10; END;
DEFINE LowerCL; 
FORMAT = 12.10; END;
DEFINE UpperCL; 
FORMAT = 12.10; END;
END; 
RUN;


*A1 for Lab 5 from EPID 716;
PROC FORMAT;
	VALUE raceaaf
	. = "Missing"
	0 = "Non-African American (referent)"
	1 = "African American";
RUN;

PROC FORMAT;
	VALUE pnc5f
	1 = "Early Prenatal Care"
	0 = "No Early Prenatal Care";
RUN;

PROC FORMAT;
	VALUE pretermf
	1 = "Preterm Birth"
	0 = "Term Birth";

DATA lab5; *dataset that includes the new raceaa variable;
	SET births12; 
	IF raceth2 = . THEN raceaa = .;
	ELSE IF 0 <= raceth2 <= 1 THEN raceaa = 0;
	ELSE IF raceth2 = 3 THEN raceaa = 0;
	ELSE IF raceth2 = 2 THEN raceaa = 1;
	LABEL raceaa = "Dichotomized Mother's race (AA or not-AA)";
	FORMAT raceaa raceaaf.;
RUN; 


PROC FREQ DATA = lab5; *checking to make sure new variable raceaa was coded properly;
	TABLE raceth2*raceaa / LIST MISSPRINT;
	TITLE "PROC FREQ of raceth2, raceaa";
RUN;
TITLE;

*A1 for Lab 5 from EPID 716;
PROC FREQ DATA = lab5 ORDER = formatted;
	TABLES pnc5*preterm / CMH RISKDIFF NOPERCENT NOCOL NOROW LIST;
	WHERE raceaa in (0); 
	FORMAT preterm pretermf. pnc5 pnc5f. raceaa raceaaf.; *formatting to order the variables alphabetically;
	TITLE "A1 Contingency Table pnc5 & raceaa = Non-AA";
RUN;
TITLE;

PROC FREQ DATA = lab5 ORDER = formatted; *contingency table for all raceaa combined;
	TABLES raceaa*pnc5*preterm / CMH RISKDIFF NOPERCENT NOCOL NOROW LIST;
	FORMAT preterm pretermf. pnc5 pnc5f. raceaa raceaaf.; *formatting to order the variables alphabetically;
	TITLE "A1 Contingency Table pnc5 & raceaa";
RUN;
TITLE;

*A3 for Lab 5 from EPID 716;
PROC FREQ DATA = lab5 ORDER = formatted; *RD, RR and OR for pnc5 among non-AA;
	TABLES pnc5*preterm / CMH RISKDIFF NOPERCENT NOCOL NOROW LIST;
	WHERE raceaa IN (0);
	FORMAT preterm pretermf. pnc5 pnc5f. raceaa raceaaf.; *formatting to order the variables alphabetically;
	TITLE "A3 Contingency Table pnc5 & non-AA";
RUN;
TITLE;

PROC FREQ DATA = lab5 ORDER = formatted; *RD, RR and OR for pnc5 among AA;
	TABLES pnc5*preterm / CMH RISKDIFF NOPERCENT NOCOL NOROW LIST;
	WHERE raceaa IN (1);
	FORMAT preterm pretermf. pnc5 pnc5f. raceaa raceaaf.; *formatting to order the variables alphabetically;
	TITLE "A3 Contingency Table pnc5 & AA";
RUN;
TITLE;

PROC FREQ DATA = lab5 ORDER = formatted; *RD, RR and OR for raceaa among no early care;
	TABLES raceaa*preterm / CMH RISKDIFF NOPERCENT NOCOL NOROW LIST;
	WHERE pnc5 IN (0);
	FORMAT preterm pretermf. pnc5 pnc5f. raceaa raceaaf.; *formatting to order the variables alphabetically;
	TITLE "A3 Contingency Table raceaa & no early care";
RUN;
TITLE;

PROC FREQ DATA = lab5 ORDER = formatted; *RD, RR and OR for raceaa among early care;
	TABLES raceaa*preterm / CMH RISKDIFF NOPERCENT NOCOL NOROW LIST;
	WHERE pnc5 IN (1);
	FORMAT preterm pretermf. pnc5 pnc5f. raceaa raceaaf.; *formatting to order the variables alphabetically;
	TITLE "A3 Contingency Table raceaa & early care";
RUN;
TITLE;

*B1-B3 for Lab 5 from EPID 716;
PROC TEMPLATE; *changing Estimates to have 10 decimals;
EDIT Stat.Genmod.Estimates; 
DEFINE MeanEstimate; 
FORMAT = 12.10; END;
DEFINE StdErr;
FORMAT = 12.10; END;
DEFINE MeanLowerCL; 
FORMAT = 12.10; END;
DEFINE MeanUpperCL; 
FORMAT = 12.10; END;
DEFINE LBetaEstimate; 
FORMAT = 12.10; END;
DEFINE LBetaLowerCL; 
FORMAT = 12.10; END;
DEFINE LBetaUpperCL; 
FORMAT = 12.10; END;
END; 
RUN;

PROC TEMPLATE; *changing Parameter Estimates to have 10 decimals;
EDIT Stat.Genmod.ParameterEstimates; 
DEFINE Estimate; 
FORMAT = 12.10; END;
DEFINE StdErr;
FORMAT = 12.10; END;
DEFINE LowerWaldCL; 
FORMAT = 12.10; END;
DEFINE UpperWaldCL; 
FORMAT = 12.10; END;
END; 
RUN;

ODS TRACE ON;
PROC GENMOD DATA = lab5 ORDER = internal; *to get R, RD and CI;
	MODEL preterm =  pnc5 raceaa pnc5*raceaa / DIST = binomial LINK = identity;
	TITLE "Model 3: Linear risk model with interaction term";
	ESTIMATE 'Risk No Early Care, non-AA 00'int 1 pnc5 0 raceaa 0 pnc5*raceaa 0;
	ESTIMATE 'Risk No Early Care, AA 01' int 1 pnc5 0 raceaa 1 pnc5*raceaa 0;
	ESTIMATE 'Risk No Early Care, AA 01' int 1 pnc5 0 raceaa 1 pnc5*raceaa 0;
	ESTIMATE 'Risk Early Care, AA 11' int 1 pnc5 1 raceaa 1 pnc5*raceaa 1;
	ESTIMATE 'non-AA: RD Prenatal Care, 10 vs. 00' int 0 pnc5 1 raceaa 0 pnc5*raceaa 0;
	ESTIMATE 'AA: RD Prenatal Care, 11 vs. 01' int 0 pnc5 1 raceaa 0 pnc5*raceaa 1;
	ESTIMATE 'No Early Care: RD AA, 01 vs. 00' int 0 pnc5 0 raceaa 1 pnc5*raceaa 0;
	ESTIMATE 'Early Care: RD AA, 11 vs. 01' int 0 pnc5 0 raceaa 1 pnc5*raceaa 1;
	ESTIMATE "RD 10 vs 00" int 0 pnc5 1 raceaa 0 pnc5*raceaa 0;
	ESTIMATE "RD 01 vs 00" int 0 pnc5 0 raceaa 1 pnc5*raceaa 0;
	ESTIMATE "RD 11 vs 00" int 0 pnc5 1 raceaa 1 pnc5*raceaa 1; 
	ESTIMATE "RD 11 vs 01" int 0 pnc5 1 raceaa 0 pnc5*raceaa 1; 
	ESTIMATE "RD 11 vs 10" int 0 pnc5 0 raceaa 1 pnc5*raceaa 1; 
	ESTIMATE "Expected RD 11 vs 00" int 0 pnc5 1 raceaa 1 pnc5*raceaa 0;
	ESTIMATE "Interaction Contrast" int 0 pnc5 0 raceaa 0 pnc5*raceaa 1;
RUN;
TITLE; 
ODS TRACE OFF; 

PROC GENMOD DATA = lab5 ORDER = internal; *to get RR and CI;
	MODEL preterm =  pnc5 raceaa pnc5*raceaa / DIST = binomial LINK = log;
	TITLE "Model 3: Log risk model for preterm birth with interaction term";
	ESTIMATE "RR 10 vs 00" int 0 pnc5 1 raceaa 0 pnc5*raceaa 0 / EXP;
	ESTIMATE "RR 01 vs 00" int 0 pnc5 0 raceaa 1 pnc5*raceaa 0 / EXP;
	ESTIMATE "RR 11 vs 00" int 0 pnc5 1 raceaa 1 pnc5*raceaa 1 / EXP; 
	ESTIMATE "Expected RR 11 vs 00" int 0 pnc5 1 raceaa 1 pnc5*raceaa 0 / EXP;
	ESTIMATE "Interaction Contrast" int 0 pnc5 0 raceaa 0 pnc5*raceaa 1 / EXP;
RUN;
TITLE; 

PROC TEMPLATE; *changing Log Likelihood to have 10 decimals;
EDIT stat.genmod.ModelFit; 
DEFINE Value; 
FORMAT = 12.10; END;
END; 
RUN;

PROC GENMOD DATA = lab5; *to get log liklihood full;
	MODEL preterm = pnc5 raceaa pnc5*raceaa / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, raceaa, interaction pnc5*raceaa";
RUN; 
TITLE; 

PROC GENMOD DATA = lab5; *to get log liklihood reduced;
	MODEL preterm = pnc5 raceaa / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, raceaa";
RUN; 
TITLE;

*C1 for Lab 5 from EPID 716;
PROC FORMAT;
	VALUE raceaaf
	. = "Missing"
	0 = "Non-African American (referent)"
	1 = "African American";
RUN;

PROC FORMAT;
	VALUE pnc5f
	1 = "Early Prenatal Care"
	0 = "No Early Prenatal Care";
RUN;

PROC FORMAT;
	VALUE pncracef
	. = "Missing"
	0 = "Non-African American, no early prenatal care"
	1 = "Non-African American, early prenatal care"
	2 = "African American, no early prenatal care"
	3 = "African American, early prenatal care";
RUN;

DATA lab5v2; *dataset that includes the new pncrace variable;
	SET lab5; 
	IF raceaa = . AND pnc5 = . THEN pncrace = .;
	ELSE IF raceaa = 0 AND pnc5 = 0 THEN pncrace = 0;
	ELSE IF raceaa = 0 AND pnc5 = 1 THEN pncrace = 1;
	ELSE IF raceaa = 1 AND pnc5 = 0 THEN pncrace = 2;
	ELSE IF raceaa = 1 AND pnc5 = 1 THEN pncrace = 3;
	LABEL pncrace = "Indicator variable combining raceaa and pnc5";
	FORMAT pncrace pncracef.;
RUN; 

PROC FREQ DATA = lab5v2; *checking to make sure new variable pncrace was coded properly;
	TABLE pnc5*raceaa*pncrace / LIST MISSPRINT;
	TITLE "PROC FREQ of pnc5, raceaa, pncrace";
RUN;
TITLE;

DATA lab5v3; *dataset that includes the new pncrace1, pncrace2, pncrace3 variable;
	SET lab5v2; 
	IF pncrace = 1 THEN pncrace1 = 1;
	ELSE IF pncrace NE . THEN pncrace1 = 0;
	ELSE IF pncrace = . THEN pncrace1 = .;

	IF pncrace = 2 THEN pncrace2 = 1;
	ELSE IF pncrace NE . THEN pncrace2 = 0;
	ELSE IF pncrace = . THEN pncrace2 = .;
	
	IF pncrace = 3 THEN pncrace3 = 1;
	ELSE IF pncrace NE . THEN pncrace3 = 0;
	ELSE IF pncrace = . THEN pncrace3 = .;

RUN; 

PROC FREQ DATA = lab5v3; *checking to make sure variables pncrace1, pncrace2, pncrace3 was coded properly;
	TABLE pncrace*pncrace1*pncrace2*pncrace3 / LIST MISSPRINT;
	TITLE "PROC FREQ of pncrace1, pncrace2, pncrace3, pncrace";
RUN;
TITLE;

*C2 for Lab 5 from EPID 716;
PROC GENMOD DATA = lab5v2 ORDER = internal; *to get R, RD and CI;
	CLASS pncrace (PARAM = ref REF = "Non-African American, no early prenatal care");
	MODEL preterm = pncrace / DIST = binomial LINK = identity;
	TITLE "Linear model for preterm birth given pncrace";
	ESTIMATE "Risk 00 Non-AA, no early care" int 1 pncrace 0 0 0;
	ESTIMATE "Risk 10 Non-AA, early care" int 1 pncrace 1 0 0;
	ESTIMATE "Risk 01 AA, no early care" int 1 pncrace 0 1 0;
	ESTIMATE "Risk 11 AA, early care" int 1 pncrace 0 0 1;
	ESTIMATE "RD 00 vs 00" int 0 pncrace 0 0 0;
	ESTIMATE "RD 10 vs 00" int 0 pncrace 1 0 0;
	ESTIMATE "RD 01 vs 00" int 0 pncrace 0 1 0;
	ESTIMATE "RD 11 vs 00" int 0 pncrace 0 0 1;
	ESTIMATE "Expected RD 11 vs 00" int 0 pncrace 1 1 0;
RUN;
TITLE;

PROC GENMOD DATA = lab5v3 ORDER = internal; *double checking to get R, RD and CI;
	MODEL preterm = pncrace1 pncrace2 pncrace3 / DIST = binomial LINK = identity;
	TITLE "Linear model for preterm birth given pncrace";
	ESTIMATE "Risk 00 Non-AA, no early care" int 1 pncrace1 0 pncrace2 0 pncrace3 0;
	ESTIMATE "Risk 10 Non-AA, early care" int 1 pncrace1 1 pncrace2 0 pncrace3 0;
	ESTIMATE "Risk 01 AA, no early care" int 1 pncrace1 0 pncrace2 1 pncrace3 0;
	ESTIMATE "Risk 11 AA, early care" int 1 pncrace1 0 pncrace2 0 pncrace3 1;
	ESTIMATE "RD 00 vs 00" int 0 pncrace1 0 pncrace2 0 pncrace3 0;
	ESTIMATE "RD 10 vs 00" int 0 pncrace1 1 pncrace2 0 pncrace3 0;
	ESTIMATE "RD 01 vs 00" int 0 pncrace1 0 pncrace2 1 pncrace3 0;
	ESTIMATE "RD 11 vs 00" int 0 pncrace1 0 pncrace2 0 pncrace3 1;
	ESTIMATE 'non-AA: RD Prenatal Care, 10 vs 00' pncrace1 1;
	ESTIMATE 'AA: RD Prenatal Care, 11 vs 01' int 0 pncrace1 0 pncrace2 -1 pncrace3 1;
	ESTIMATE 'No Early Care: RD AA, 01 vs 00' int 0 pncrace1 0 pncrace2 1 pncrace3 0;
	ESTIMATE 'Early Care: RD AA, 11 vs 10' int 0 pncrace1 -1 pncrace2 0 pncrace3 1;
	ESTIMATE "Expected RD 11 vs 00" int 0 pncrace1 1 pncrace2 1 pncrace3 0;
	ESTIMATE 'Interaction Coefficient' pncrace3 1 pncrace1 -1 pncrace2 -1;
RUN;
TITLE;


PROC GENMOD DATA = lab5v3; *to get log liklihood full;
	MODEL preterm = pncrace1 pncrace2 pncrace3 / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pncrace1, pncrace2, pncrace3";
RUN; 
TITLE; 

PROC GENMOD DATA = lab5; *to get log liklihood reduced;
	MODEL preterm = pnc5 raceaa / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, raceaa";
RUN; 
TITLE;

*C3 for Lab 5 from EPID 716;
PROC GENMOD DATA = lab5v3 ORDER = internal; *to get RR and CI;
	MODEL preterm = pncrace1 pncrace2 pncrace3 / DIST = binomial LINK = log;
	TITLE "Linear model for preterm birth given pncrace";
	ESTIMATE "RR 00 vs 00" int 0 pncrace1 0 pncrace2 0 pncrace3 0 / EXP;
	ESTIMATE "RR 10 vs 00" int 0 pncrace1 1 pncrace2 0 pncrace3 0 / EXP;
	ESTIMATE "RR 01 vs 00" int 0 pncrace1 0 pncrace2 1 pncrace3 0 / EXP;
	ESTIMATE "RR 11 vs 00" int 0 pncrace1 0 pncrace2 0 pncrace3 1 / EXP;
	ESTIMATE "Expected RR 11 vs 00" int 0 pncrace1 1 pncrace2 1 pncrace3 0 / EXP;
	ESTIMATE 'Interaction Coefficient Ratio' pncrace3 1 pncrace1 -1 pncrace2 -1 / EXP;
RUN;
TITLE;

ODS OUTPUT ParameterEstimates = C3parm CovB = C3covb;
PROC GENMOD DATA = lab5v3; *to get variance covariance matrix;
	MODEL preterm = pncrace1 pncrace2 pncrace3 / LINK = log DIST = binomial COVB;
RUN; 
ODS OUTPUT CLOSE;

PROC PRINT DATA =C3covb NOOBS;
	FORMAT prm1 prm2 prm3 prm4 12.10;
RUN;

PROC PRINT DATA = C3parm NOOBS;
	FORMAT estimate stderr lowerwaldcl upperwaldcl 12.10;
RUN;

*D1 for Lab 5 from EPID 716;
PROC FORMAT;
	VALUE raceth2f
	. = "Missing"
	0 = "White/non-Hispanic"
	1 = "White/Hispanic"
	2 = "African American"
	3 = "Other";
RUN;

PROC FORMAT;
	VALUE pnc5f
	1 = "Early Prenatal Care"
	0 = "No Early Prenatal Care";
RUN;

PROC FORMAT;
	VALUE pncracethf
	. = "Missing"
	0 = "no early care, White/non-Hispanic"
	1 = "early care, White/non-Hispanic"
	2 = "no early care, White/Hispanic"
	3 = "early care, White/Hispanic"
	4 = "no early care, African American"
	5 = "early care, African American"
	6 = "no early care, Other"
	7 = "early care, Other";
RUN;

DATA lab5v4; *dataset that includes the new pncraceth variable;
	SET lab5v3; 
	IF pnc5 = . AND raceth2 = . THEN pncraceth = .;
	ELSE IF pnc5 = 0 AND raceth2 = 0 THEN pncraceth = 0;
	ELSE IF pnc5 = 1 AND raceth2 = 0 THEN pncraceth = 1;
	ELSE IF pnc5 = 0 AND raceth2 = 1 THEN pncraceth = 2;
	ELSE IF pnc5 = 1 AND raceth2 = 1 THEN pncraceth = 3;
	ELSE IF pnc5 = 0 AND raceth2 = 2 THEN pncraceth = 4;
	ELSE IF pnc5 = 1 AND raceth2 = 2 THEN pncraceth = 5;
	ELSE IF pnc5 = 0 AND raceth2 = 3 THEN pncraceth = 6;
	ELSE IF pnc5 = 1 AND raceth2 = 3 THEN pncraceth = 7;
	LABEL pncraceth = "Indicator variable combining raceth2 and pnc5";
	FORMAT pncraceth pncracethf.;
RUN; 

PROC FREQ DATA = lab5v4; *checking to make sure variable pncraceth was coded properly;
	TABLE pnc5*raceth2*pncraceth / LIST MISSPRINT;
	TITLE "PROC FREQ of pnc5, raceth2, pncraceth";
RUN;
TITLE;

DATA lab5v4; *dataset that includes the 7 new indicator variables for pncraceth variable;
	SET lab5v4; 
	IF pncraceth = 1 THEN pncraceth1 = 1;
	ELSE IF pncraceth NE . THEN pncraceth1 = 0;
	ELSE IF pncraceth = . THEN pncraceth1 = .;

	IF pncraceth = 2 THEN pncraceth2 = 1;
	ELSE IF pncraceth NE . THEN pncraceth2 = 0;
	ELSE IF pncraceth = . THEN pncraceth2 = .;
	
	IF pncraceth = 3 THEN pncraceth3 = 1;
	ELSE IF pncraceth NE . THEN pncraceth3 = 0;
	ELSE IF pncraceth = . THEN pncraceth3 = .;
	
	IF pncraceth = 4 THEN pncraceth4 = 1;
	ELSE IF pncraceth NE . THEN pncraceth4 = 0;
	ELSE IF pncraceth = . THEN pncraceth4 = .;
	
	IF pncraceth = 5 THEN pncraceth5 = 1;
	ELSE IF pncraceth NE . THEN pncraceth5 = 0;
	ELSE IF pncraceth = . THEN pncraceth5 = .;
	
	IF pncraceth = 6 THEN pncraceth6 = 1;
	ELSE IF pncraceth NE . THEN pncraceth6 = 0;
	ELSE IF pncraceth = . THEN pncraceth6 = .;
	
	IF pncraceth = 7 THEN pncraceth7 = 1;
	ELSE IF pncraceth NE . THEN pncraceth7 = 0;
	ELSE IF pncraceth = . THEN pncraceth7 = .;
RUN; 

PROC FREQ DATA = lab5v4; *checking to make sure variables was coded properly;
	TABLE pncraceth*pncraceth1*pncraceth2*pncraceth3*pncraceth4*pncraceth5*pncraceth6*pncraceth7 / LIST MISSPRINT;
	TITLE "PROC FREQ of pncraceth and its disjoint indicator variables";
RUN;
TITLE;

PROC FORMAT;
	VALUE raceth2f
	. = "Missing"
	0 = "White/non-Hispanic"
	1 = "White/Hispanic"
	2 = "African American"
	3 = "Other";
RUN;

PROC FORMAT;
	VALUE pnc5f
	1 = "Early Prenatal Care"
	0 = "No Early Prenatal Care";
RUN;

DATA lab5v4; *dataset that includes the 3 disjoint indicator variables for raceth2 variable;
	SET lab5v4; 
	IF raceth2 = 1 THEN racethwh = 1;
	ELSE IF raceth2 NE . THEN racethwh = 0;
	ELSE IF raceth2 = . THEN racethwh = .;
	
	IF raceth2 = 2 THEN racethb = 1;
	ELSE IF raceth2 NE . THEN racethb = 0;
	ELSE IF raceth2 = . THEN racethb = .;
	
	IF raceth2 = 3 THEN racetho = 1;
	ELSE IF raceth2 NE . THEN racetho = 0;
	ELSE IF raceth2 = . THEN racetho = .;
RUN;

PROC FREQ DATA = lab5v4; *checking to make sure variables was coded properly;
	TABLE raceth2*racethwh*racethb*racetho/ LIST MISSPRINT;
	TITLE "PROC FREQ of raceth2 and its disjoint indicator variables";
RUN;
TITLE;

PROC GENMOD DATA = lab5v4 ORDER = internal; *to get R, RD and CI;
	MODEL preterm = pncraceth1 pncraceth2 pncraceth3 pncraceth4 pncraceth5 pncraceth6
		pncraceth7 / DIST = binomial LINK = identity;
	TITLE "Linear model for preterm birth given pncraceth disjoint variables ";
	ESTIMATE "Risk 00 WNH, no early care" int 1 pncraceth1 0 pncraceth2 0 pncraceth3 0 pncraceth4 0 
		pncraceth5 0 pncraceth6 0 pncraceth7 0;
	ESTIMATE "Risk 10 WNH, early care" int 1 pncraceth1 1 pncraceth2 0 pncraceth3 0 pncraceth4 0 
		pncraceth5 0 pncraceth6 0 pncraceth7 0;
	ESTIMATE "Risk 01 WH, no early care" int 1 pncraceth1 0 pncraceth2 1 pncraceth3 0 pncraceth4 0 
		pncraceth5 0 pncraceth6 0 pncraceth7 0;
	ESTIMATE "Risk 11 WH, early care" int 1 pncraceth1 0 pncraceth2 0 pncraceth3 1 pncraceth4 0
		pncraceth5 0 pncraceth6 0 pncraceth7 0;
	ESTIMATE "Risk 02 AA, no early care" int 1 pncraceth1 0 pncraceth2 0 pncraceth3 0 pncraceth4 1
		pncraceth5 0 pncraceth6 0 pncraceth7 0;
	ESTIMATE "Risk 12 AA, early care" int 1 pncraceth1 0 pncraceth2 0 pncraceth3 0 pncraceth4 0
		pncraceth5 1 pncraceth6 0 pncraceth7 0;
	ESTIMATE "Risk 03 O, no early care" int 1 pncraceth1 0 pncraceth2 0 pncraceth3 0 pncraceth4 0
		pncraceth5 0 pncraceth6 1 pncraceth7 0;
	ESTIMATE "Risk 13 O, early care" int 1 pncraceth1 0 pncraceth2 0 pncraceth3 0 pncraceth4 0
		pncraceth5 0 pncraceth6 0 pncraceth7 1;
	ESTIMATE "RD 10 vs 00" int 0 pncraceth1 1 pncraceth2 0 pncraceth3 0 pncraceth4 0
		pncraceth5 0 pncraceth6 0 pncraceth7 0;
	ESTIMATE "RD 01 vs 00" int 0 pncraceth1 0 pncraceth2 1 pncraceth3 0 pncraceth4 0
		pncraceth5 0 pncraceth6 0 pncraceth7 0;
	ESTIMATE "RD 11 vs 00" int 0 pncraceth1 0 pncraceth2 0 pncraceth3 1 pncraceth4 0
		pncraceth5 0 pncraceth6 0 pncraceth7 0;
	ESTIMATE "RD 02 vs 00" int 0 pncraceth1 0 pncraceth2 0 pncraceth3 0 pncraceth4 1
		pncraceth5 0 pncraceth6 0 pncraceth7 0;
	ESTIMATE "RD 12 vs 00" int 0 pncraceth1 0 pncraceth2 0 pncraceth3 0 pncraceth4 0
		pncraceth5 1 pncraceth6 0 pncraceth7 0;
	ESTIMATE "RD 03 vs 00" int 0 pncraceth1 0 pncraceth2 0 pncraceth3 0 pncraceth4 0
		pncraceth5 0 pncraceth6 1 pncraceth7 0;
	ESTIMATE "RD 13 vs 00" int 0 pncraceth1 0 pncraceth2 0 pncraceth3 0 pncraceth4 0
		pncraceth5 0 pncraceth6 0 pncraceth7 1;
RUN;
TITLE;

PROC GENMOD DATA = lab5v4 ORDER = internal; *to get R, RD and CI - sanity check;
	MODEL preterm = pnc5 racethwh racethb racetho pnc5*racethwh pnc5*racethb
		pnc5*racetho / DIST = binomial LINK = identity;
	TITLE "Linear model for preterm birth given product interaction";
	ESTIMATE "Risk 11 WH, early care" int 1 pnc5 1 racethwh 1 racethb 0 racetho 0 pnc5*racethwh 1 
		pnc5*racethb 0 pnc5*racetho 0;
	ESTIMATE "RD 01 vs 00" int 0 pnc5 0 racethwh 1 racethb 0 racetho 0 pnc5*racethwh 0 
		pnc5*racethb 0 pnc5*racetho 0;
RUN;
TITLE;

PROC SORT DATA = lab5v4 OUT = lab5v4_sort; 
	BY raceth2;
RUN;

PROC FREQ DATA = lab5v4_sort; *to get frequency;
	TABLE pnc5*preterm / MISSPRINT NOPERCENT NOCOL NOROW;
	BY raceth2;
	TITLE "PROC FREQ of preterm birth by pnc5 and raceth2 = 0";
RUN;
TITLE;

PROC GENMOD DATA = lab5v4 ORDER = internal; *to get log liklihood full;
	MODEL preterm = pnc5 racethwh racethb racetho pnc5*racethwh pnc5*racethb
		pnc5*racetho / DIST = binomial LINK = identity;
	TITLE "Linear model for preterm birth given product interaction (full likelihood)";
RUN;
TITLE;

PROC GENMOD DATA = lab5v4 ORDER = internal; *to get log liklihood reduced;
	MODEL preterm = pnc5 racethwh racethb racetho / DIST = binomial LINK = identity;
	TITLE "Linear model for preterm birth given product interaction (reduced likelihood)";
RUN;
TITLE;

*D2 for Lab 5 from EPID 716;
PROC GENMOD DATA = lab5v4 ORDER = internal; *to get R, RD and CI: stratum specific;
	MODEL preterm = pncraceth1 pncraceth2 pncraceth3 pncraceth4 pncraceth5 pncraceth6
		pncraceth7 / DIST = binomial LINK = identity;
	TITLE "Linear model for preterm birth given pncraceth disjoint variables ";
	ESTIMATE "WNH: RD prenatal care 10 vs 00" int 0 pncraceth1 1 pncraceth2 0 pncraceth3 0 
		pncraceth4 0 pncraceth5 0 pncraceth6 0 pncraceth7 0;
	ESTIMATE "WH: RD prenatal care 11 vs 01" int 0 pncraceth1 0 pncraceth2 -1 pncraceth3 1 
		pncraceth4 0 pncraceth5 0 pncraceth6 0 pncraceth7 0;
	ESTIMATE "AA: RD prenatal care 12 vs 02" int 0 pncraceth1 0 pncraceth2 0 pncraceth3 0 
		pncraceth4 -1 pncraceth5 1 pncraceth6 0 pncraceth7 0;
	ESTIMATE "O: RD prenatal care 13 vs 03" int 0 pncraceth1 0 pncraceth2 0 pncraceth3 0 
		pncraceth4 0 pncraceth5 0 pncraceth6 -1 pncraceth7 1;
RUN;
TITLE;

PROC GENMOD DATA = lab5v4 ORDER = internal; *to get R, RD and CI:stratum specific - sanity check;
	MODEL preterm = pnc5 racethwh racethb racetho pnc5*racethwh pnc5*racethb
		pnc5*racetho / DIST = binomial LINK = identity;
	TITLE "Linear model for preterm birth given product interaction";
	ESTIMATE "WNH: RD prenatal care 11 vs 01" int 0 pnc5 1 racethwh 0 racethb 0 racetho 0 
		pnc5*racethwh 1 pnc5*racethb 0 pnc5*racetho 0;
	ESTIMATE "O: RD prenatal care 13 vs 03" int 0 pnc5 1 racethwh 0 racethb 0 racetho 0 
		pnc5*racethwh 0 pnc5*racethb 0 pnc5*racetho 1;
RUN;
TITLE;

*D3 for Lab 5 from EPID 716;
PROC GENMOD DATA = lab5v4 ORDER = internal; *to get R, RR and CI;
	MODEL preterm = pncraceth1 pncraceth2 pncraceth3 pncraceth4 pncraceth5 pncraceth6
		pncraceth7 / DIST = binomial LINK = log;
	TITLE "Linear model for preterm birth given pncraceth disjoint variables ";
	ESTIMATE "RR 10 vs 00" int 0 pncraceth1 1 pncraceth2 0 pncraceth3 0 pncraceth4 0
		pncraceth5 0 pncraceth6 0 pncraceth7 0 / EXP;
	ESTIMATE "RR 01 vs 00" int 0 pncraceth1 0 pncraceth2 1 pncraceth3 0 pncraceth4 0
		pncraceth5 0 pncraceth6 0 pncraceth7 0 / EXP;
	ESTIMATE "RR 11 vs 00" int 0 pncraceth1 0 pncraceth2 0 pncraceth3 1 pncraceth4 0
		pncraceth5 0 pncraceth6 0 pncraceth7 0 / EXP;
	ESTIMATE "RR 02 vs 00" int 0 pncraceth1 0 pncraceth2 0 pncraceth3 0 pncraceth4 1
		pncraceth5 0 pncraceth6 0 pncraceth7 0 / EXP;
	ESTIMATE "RR 12 vs 00" int 0 pncraceth1 0 pncraceth2 0 pncraceth3 0 pncraceth4 0
		pncraceth5 1 pncraceth6 0 pncraceth7 0 / EXP;
	ESTIMATE "RR 03 vs 00" int 0 pncraceth1 0 pncraceth2 0 pncraceth3 0 pncraceth4 0
		pncraceth5 0 pncraceth6 1 pncraceth7 0 / EXP;
	ESTIMATE "RR 13 vs 00" int 0 pncraceth1 0 pncraceth2 0 pncraceth3 0 pncraceth4 0
		pncraceth5 0 pncraceth6 0 pncraceth7 1 / EXP;
RUN;
TITLE;

ODS OUTPUT ParameterEstimates = C3parm CovB = C3covb;
PROC GENMOD DATA = lab5v4; *to get variance covariance matrix;
	MODEL preterm = pncraceth1 pncraceth2 pncraceth3 pncraceth4 pncraceth5 pncraceth6
		pncraceth7 / DIST = binomial LINK = log COVB;
RUN; 
ODS OUTPUT CLOSE;

PROC PRINT DATA =C3covb NOOBS;
	FORMAT prm1 prm2 prm3 prm4 prm5 prm6 prm7 prm8 12.10;
RUN;

PROC PRINT DATA = C3parm NOOBS;
	FORMAT estimate stderr lowerwaldcl upperwaldcl 12.10;
RUN;









