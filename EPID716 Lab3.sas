LIBNAME epid795 "/home/u59075382/epid795/Data";

*Question A1.1;
PROC CONTENTS DATA = epid795.birthscohort;
TITLE "birthscohort data";
RUN;
TITLE;
*checking dataset - 61447 total observations, 9 variables;

PROC UNIVARIATE DATA = epid795.birthscohort;
	VAR weeks;
	TITLE "Descriptive statistics for gestional age at birth";
RUN;
TITLE;

*For gestational age at birth (variable "weeks"), there are no observations missing data
or any extreme, out of range, and implausible values. All observations for gestional age
fall between the plausible values of 20 weeks and 43 weeks.;
*The mean gestational age is 39 weeks and the standard deviation is 2.1 weeks.;

PROC MEANS DATA = epid795.birthscohort N NMISS MEAN STD RANGE MEDIAN P5 P95; 
	VAR weeks;
	TITLE "Descriptive statistics for gestional age at birth";
RUN;
TITLE;
*checking for any missing observations, mean, std dev, range, median, 5th and 9th percentile;

PROC FREQ DATA = epid795.birthscohort;
	TABLES weeks / MISSING;
	TITLE "Frequency of gestional age at birth";
RUN;
TITLE;
*checking for any extreme, out of range, and implausible values for gestional age (weeks);


*Question A1.2;
PROC SGPLOT DATA = epid795.birthscohort;
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
PROC UNIVARIATE DATA = epid795.birthscohort;
	VAR weeknum;
	TITLE "Descriptive statistics for week of birth in the year 2015";
RUN;
TITLE;

*The median week of birth (weeknum) is the 33rd week of the year 2015. There are no observations
with missing data for weeknum and the range of data is consistent with what is expected. There are 53 
weeks in the year 2015, and the range of data for weeknum is week 2 to week 50.;

PROC MEANS DATA = epid795.birthscohort N NMISS MEAN STD RANGE MEDIAN P5 P95; 
	VAR weeknum;
	TITLE "Descriptive statistics for week of birth in 2015";
RUN;
TITLE;
*checking for any missing observations, mean, std dev, range, median, 5th and 9th percentile;

PROC FREQ DATA = epid795.birthscohort;
	TABLE weeknum / MISSING;
	TITLE 'PROC FREQ of Year 2015 Week of Birth'; 
RUN;
*checking range of data;

*Question A2.2; 
PROC SGPLOT DATA = epid795.birthscohort;
	HISTOGRAM weeknum / BINWIDTH = 1;
	TITLE "Distribution of week of births in 2015";
RUN;
TITLE;

*The data for weeknum does not have extreme, out of range, or inplausible values.;

*Question A2.3;
PROC SORT DATA = epid795.birthscohort OUT = births2; *new dataset sorting by weeks;
	BY weeks;
RUN;

PROC SGPLOT DATA = epid795.birthscohort;
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
	SET epid795.birthscohort;
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

PROC PRINT DATA = epid795.birthscohort (OBS = 10);
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


*A1.1 for Lab 3 from EPID 716;
DATA lab3; *new dataset with 30 disjoint indicator variables for age;
	SET births8;
	IF 0 < mage <= 14 THEN mage14 = 1;
	IF 98 > mage > 14 then mage14 = 0;
	IF mage = . THEN mage14 = .;

	IF 98 > mage >= 44 THEN mage44 = 1;
	IF 0 < mage < 44 THEN mage44 = 0;
	IF mage = . THEN mage44 = .;

	ARRAY mageAr [29] mage15 - mage43;

	DO i = 1 TO 29;
		IF mage = . THEN mageAr[i] = .;
      	IF mage = i+14 THEN mageAr[i] = 1;
		IF 0 < mage < i+14 THEN mageAr[i] = 0;
	  	IF 98 > mage > i+14 THEN mageAr[i] = 0;
END;
RUN;

PROC GENMOD DATA = lab3; 
MODEL preterm = mage14 - mage25 mage27-mage44 / LINK = identity DIST = binomial;
	OUTPUT OUT = A1_1 PRED = pred l = l95m u = u95m;
	ESTIMATE "Risk (Age 16)" int 1 mage16 1;
	ESTIMATE "Risk (Age 26)" int 1;
	ESTIMATE "Risk (Age 40)" int 1 mage40 1;
	TITLE 'Linear Risk Model for 31 Categories of Age';
RUN;
TITLE;

PROC SORT DATA = A1_1; 
	BY mage2;
RUN;

*plot risk (95% CI) of preterm birth by maternal age (years) (31 categories);
*one way;
ods listing;
filename graphout "/home/u59075382/epid716/Labs/Lab 3";
goptions reset=all gsfname=graphout device=gif rotate=landscape ftitle=swiss ftext=swiss gunit=pct 
	htitle=3 htext=2 gsfmode=replace;
	symbol1 v=dot i=j l=1 w=1 height=2;
	symbol2 v=dot i=j l=33 w=1 height=2;
	axis1 label=('Maternal age (years)') w=3 order=(10 to 50 by 10);
	axis2 label=(a=90 'Estimated risk (95% CI) of preterm birth') w=3 order=(0.00 to 0.40 by 0.05);
proc gplot data=A1_1;
	plot pred*mage2=1 l95m*mage2=2 u95m*mage2=2 / overlay frame vaxis=axis2 haxis=axis1;

*another way;
ODS LISTING GPATH = "/home/u59075382/epid716/Labs/Lab 3";
ODS GRAPHICS / RESET = all LINEPATTERNOBSMAX = 61500 ANTIALIASMAX = 68000 IMAGENAME = "mage_A1_1" 
	IMAGEFMT = jpeg HEIGHT = 6in WIDTH = 9in NOBORDER; 

PROC SGPLOT DATA = A1_1;  
	SERIES x = mage2 y = pred / MARKERS MARKERATTRS = (SYMBOL = "circlefilled" size = 5) 
		LINEATTRS = (THICKNESS = 2);
	SERIES x = mage2 y =l95m / LINEATTRS = (PATTERN = 2 COLOR = "red") 
		LEGENDLABEL = "Lower 95% CI";
	SERIES x = mage2 y =u95m / LINEATTRS = (PATTERN = 2 COLOR = "red") 
		LEGENDLABEL = "Upper 95% CI";
	XAXIS LABEL = "Maternal Age (Years)" VALUES = (10 to 50 by 10);
	YAXIS LABEL = "Risk (95% CI) of preterm birth" VALUES = (0.00 to 0.40 by 0.05);
	TITLE1 "Risk (95% CI) of Preterm Birth by Maternal Age (years)";
	TITLE2 "A1. Maternal Age Modeled as a Categorical Variable with 31 Categories"; 
RUN;
TITLE1;
TITLE2;


*A1.2 for Lab 3 from EPID 716;
PROC GENMOD DATA = lab3; *to get R, RR and CI using disjoint indicator (31 categories);
	MODEL preterm = mage14 - mage25 mage27-mage44 / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth by maternal age (31 categories)";
	ESTIMATE "Risk (Age 16)" int 1 mage16 1 / EXP;
	ESTIMATE "Risk (Age 26)" int 1 / EXP;
	ESTIMATE "Risk (Age 40)" int 1 mage40 1 / EXP;
	ESTIMATE "RR (Age 16 vs. Age 26)" int 0 mage16 1 / EXP;
	ESTIMATE "RR (Age 40 vs Age 26)" int 0 mage40 1 / EXP;
RUN;
TITLE;

*A2.1 for Lab 3 from EPID 716;
PROC GENMOD DATA = lab3; *to get R, RD and CI using linear continuous;
	MODEL preterm = mage2 / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth by maternal age (simple linear)";
	ESTIMATE "Risk (Age 16)" int 1 mage2 16;
	ESTIMATE "Risk (Age 26)" int 1 mage2 26;
	ESTIMATE "Risk (Age 40)" int 1 mage2 40;
	ESTIMATE "RD (Age 16 vs. Age 26)" int 0 mage2 -10;
	ESTIMATE "RD (Age 40 vs Age 26)" int 0 mage2 14;
	OUTPUT OUT = A2_1 PRED = pred l = l95m u = u95m;
RUN;
TITLE;


PROC GENMOD DATA = lab3; 
	MODEL preterm = mage2 / LINK = identity DIST = binomial;
	OUTPUT OUT = A2_1 PRED = pred l = l95m u = u95m;
	TITLE 'Linear Risk Model for Maternal Age (simple linear)';
RUN;
TITLE;

PROC SORT DATA = A2_1; 
	BY mage2;
RUN;

ODS LISTING GPATH = "/home/u59075382/epid716/Labs/Lab 3";
ODS GRAPHICS / RESET = all LINEPATTERNOBSMAX = 61500 ANTIALIASMAX = 68000 IMAGENAME = "mage_A2_1" 
	IMAGEFMT = jpeg HEIGHT = 6in WIDTH = 9in NOBORDER; 

PROC SGPLOT DATA = A2_1;  
	SERIES x = mage2 y = pred / MARKERS MARKERATTRS = (SYMBOL = "circlefilled" size = 5) 
		LINEATTRS = (THICKNESS = 2);
	SERIES x = mage2 y =l95m / LINEATTRS = (PATTERN = 2 COLOR = "red") 
		LEGENDLABEL = "Lower 95% CI";
	SERIES x = mage2 y =u95m / LINEATTRS = (PATTERN = 2 COLOR = "red") 
		LEGENDLABEL = "Upper 95% CI";
	XAXIS LABEL = "Maternal Age (Years)" VALUES = (10 to 50 by 10);
	YAXIS LABEL = "Risk (95% CI) of preterm birth" VALUES = (0.00 to 0.40 by 0.05);
	TITLE1 "Risk (95% CI) of Preterm Birth by Maternal Age (years)";
	TITLE2 "A2. Maternal Age Modeled as Simple Linear"; 
RUN;
TITLE1;
TITLE2;

*A2.2 for Lab 3 from EPID 716;
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

PROC GENMOD DATA = lab3; *to get R, RR and CI using linear continuous;
	MODEL preterm = mage2 / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth by maternal age (simple linear)";
	ESTIMATE "Risk (Age 16)" int 1 mage2 16 / EXP;
	ESTIMATE "Risk (Age 26)" int 1 mage2 26 / EXP;
	ESTIMATE "Risk (Age 40)" int 1 mage2 40 / EXP;
	ESTIMATE "RR (Age 16 vs. Age 26)" int 0 mage2 -10 / EXP;
	ESTIMATE "RR (Age 40 vs Age 26)" int 0 mage2 14 / EXP;
RUN;
TITLE;


*A3.1 for Lab 3 from EPID 716;
PROC GENMOD DATA = lab3; *to get R, RD and CI using quadratic continuous;
	MODEL preterm = mage2 mage2*mage2 / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth by maternal age (quadratic linear)";
	ESTIMATE "Risk (Age 16)" int 1 mage2 16 mage2*mage2 256;
	ESTIMATE "Risk (Age 26)" int 1 mage2 26 mage2*mage2 676;
	ESTIMATE "Risk (Age 40)" int 1 mage2 40 mage2*mage2 1600;
	ESTIMATE "RD (Age 16 vs. Age 26)" int 0 mage2 -10 mage2*mage2 -420;
	ESTIMATE "RD (Age 40 vs Age 26)" int 0 mage2 14 mage2*mage2 924;
	OUTPUT OUT = A3_1 PRED = pred l = l95m u = u95m;
RUN;
TITLE;

*A3.2 for Lab 3 from EPID 716;
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
PROC GENMOD DATA = lab3; *to get R, RR and CI using quadratic continuous;
	MODEL preterm = mage2 mage2*mage2 / DIST = binomial LINK = log;
	TITLE "Linear risk model for preterm birth by maternal age (quadratic linear)";
	ESTIMATE "Risk (Age 16)" int 1 mage2 16 mage2*mage2 256 / EXP;
	ESTIMATE "Risk (Age 26)" int 1 mage2 26 mage2*mage2 676 / EXP;
	ESTIMATE "Risk (Age 40)" int 1 mage2 40 mage2*mage2 1600 / EXP;
	ESTIMATE "RR (Age 16 vs. Age 26)" int 0 mage2 -10 mage2*mage2 -420 / EXP;
	ESTIMATE "RR (Age 40 vs Age 26)" int 0 mage2 14 mage2*mage2 924 / EXP;
	OUTPUT OUT = A3_2 PRED = pred l = l95m u = u95m;
RUN;
TITLE;
ODS TRACE OFF;

PROC SORT DATA = A3_2; 
	BY mage2;
RUN;

ODS LISTING GPATH = "/home/u59075382/epid716/Labs/Lab 3";
ODS GRAPHICS / RESET = all LINEPATTERNOBSMAX = 61500 ANTIALIASMAX = 68000 IMAGENAME = "mage_A3_2" 
	IMAGEFMT = jpeg HEIGHT = 6in WIDTH = 9in NOBORDER; 

PROC SGPLOT DATA = A3_2;  
	SERIES x = mage2 y = pred / MARKERS MARKERATTRS = (SYMBOL = "circlefilled" size = 5) 
		LINEATTRS = (THICKNESS = 2);
	SERIES x = mage2 y =l95m / LINEATTRS = (PATTERN = 2 COLOR = "red") 
		LEGENDLABEL = "Lower 95% CI";
	SERIES x = mage2 y =u95m / LINEATTRS = (PATTERN = 2 COLOR = "red") 
		LEGENDLABEL = "Upper 95% CI";
	XAXIS LABEL = "Maternal Age (Years)" VALUES = (10 to 50 by 10);
	YAXIS LABEL = "Risk (95% CI) of preterm birth" VALUES = (0.00 to 0.40 by 0.05);
	TITLE1 "Risk (95% CI) of Preterm Birth by Maternal Age (years)";
	TITLE2 "A3. Maternal Age Modeled as Quadratic"; 
RUN;
TITLE1;
TITLE2;


PROC FREQ DATA = lab3;
	TABLE mage2;
RUN;


*creating variable magesq to represent mage2*mage2;
DATA lab3_2; *new dataset with magesq variable;
	SET lab3;
	magesq = mage2*mage2;
RUN;

PROC FREQ DATA = lab3_2; *confirming new variable was created as intended;
	TABLE magesq*mage2 / LIST MISSPRINT;
	TITLE "PROC FREQ of new magesq variable";
RUN;
TITLE;

*double checking new variable again;
PROC GENMOD DATA = lab3; *to get R, RD and CI using quadratic continuous;
	MODEL preterm = mage2 mage2*mage2 / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth by maternal age (quadratic linear)";
	ESTIMATE "Risk (Age 16)" int 1 mage2 16 mage2*mage2 256;
	ESTIMATE "Risk (Age 26)" int 1 mage2 26 mage2*mage2 676;
	ESTIMATE "Risk (Age 40)" int 1 mage2 40 mage2*mage2 1600;
	ESTIMATE "RD (Age 16 vs. Age 26)" int 0 mage2 -10 mage2*mage2 -420;
	ESTIMATE "RD (Age 40 vs Age 26)" int 0 mage2 14 mage2*mage2 924;
RUN;
TITLE;

PROC GENMOD DATA = lab3_2; *to get R, RD and CI using quadratic continuous;
	MODEL preterm = mage2 magesq / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth by maternal age (quadratic linear)";
	ESTIMATE "Risk (Age 16)" int 1 mage2 16 magesq 256;
	ESTIMATE "Risk (Age 26)" int 1 mage2 26 magesq 676;
	ESTIMATE "Risk (Age 40)" int 1 mage2 40 magesq 1600;
	ESTIMATE "RD (Age 16 vs. Age 26)" int 0 mage2 -10 magesq -420;
	ESTIMATE "RD (Age 40 vs Age 26)" int 0 mage2 14 magesq 924;
RUN;
TITLE;

*A4.1 for Lab 3 from EPID 716;
DATA lab3_3; *new dataset with magels18, magels29, magls35 variable;
	SET lab3_2;
	IF mage2 > 18 THEN magels18 = mage2-18;   ELSE magels18 = 0;
	IF mage2 > 29 THEN magels29 = mage2-29;   ELSE magels29 = 0;
	IF mage2 > 35 THEN magels35 = mage2-35;   ELSE magels35 = 0;
RUN;

PROC FREQ DATA = lab3_3; *confirming new variable was created as intended;
	TABLE mage2*magels18*magels29*magels35 / LIST MISSPRINT;
	TITLE "PROC FREQ of new variables";
RUN;
TITLE;

PROC GENMOD DATA = lab3_3; 
	MODEL preterm = mage2 magels18 magels29 magels35 / LINK = log DIST = binomial;
	OUTPUT OUT = A4_1 PRED = pred l = l95m u = u95m;
	TITLE 'Linear Risk Model for Linear Spline';
RUN;
TITLE;

PROC SORT DATA = A4_1; 
	BY mage2;
RUN;

ODS LISTING GPATH = "/home/u59075382/epid716/Labs/Lab 3";
ODS GRAPHICS / RESET = all LINEPATTERNOBSMAX = 61500 ANTIALIASMAX = 68000 IMAGENAME = "mage_A4_1" 
	IMAGEFMT = jpeg HEIGHT = 6in WIDTH = 9in NOBORDER; 

PROC SGPLOT DATA = A4_1;  
	SERIES x = mage2 y = pred / MARKERS MARKERATTRS = (SYMBOL = "circlefilled" size = 5) 
		LINEATTRS = (THICKNESS = 2);
	SERIES x = mage2 y =l95m / LINEATTRS = (PATTERN = 2 COLOR = "red") 
		LEGENDLABEL = "Lower 95% CI";
	SERIES x = mage2 y =u95m / LINEATTRS = (PATTERN = 2 COLOR = "red") 
		LEGENDLABEL = "Upper 95% CI";
	XAXIS LABEL = "Maternal Age (Years)" VALUES = (10 to 50 by 10);
	YAXIS LABEL = "Risk (95% CI) of preterm birth" VALUES = (0.00 to 0.40 by 0.05);
	TITLE1 "Risk (95% CI) of Preterm Birth by Maternal Age (years)";
	TITLE2 "A4. Maternal Age Modeled as a Linear Spline"; 
RUN;
TITLE1;
TITLE2;

*A5.1 for Lab 3 from EPID 716;
DATA lab3_4; *new dataset with magesq18, magesq29, magesq35 variable;
	SET lab3_3;
	IF mage2 > 18 THEN magesq18 = (mage2-18)*(mage2-18); ELSE magesq18 = 0;
	IF mage2 > 29 THEN magesq29 = (mage2-29)*(mage2-29); ELSE magesq29 = 0;
	IF mage2 > 35 THEN magesq35 = (mage2-35)*(mage2-35); ELSE magesq35 = 0;
RUN;

PROC FREQ DATA = lab3_4; *confirming new variable was created as intended;
	TABLE mage2*magesq*magesq18*magesq29*magesq35 / LIST MISSPRINT;
	TITLE "PROC FREQ of new variables";
RUN;
TITLE;

PROC GENMOD DATA = lab3_4; 
	MODEL preterm = mage2 magesq magesq18 magesq29 magesq35 / LINK = log DIST = binomial;
	OUTPUT OUT = A5_1 PRED = pred l = l95m u = u95m;
	TITLE 'Quadratic Risk Model for Quadratic Spline';
RUN;
TITLE;

PROC SORT DATA = A5_1; 
	BY mage2;
RUN;

ODS LISTING GPATH = "/home/u59075382/epid716/Labs/Lab 3";
ODS GRAPHICS / RESET = all LINEPATTERNOBSMAX = 61500 ANTIALIASMAX = 68000 IMAGENAME = "mage_A5_1" 
	IMAGEFMT = jpeg HEIGHT = 6in WIDTH = 9in NOBORDER; 

PROC SGPLOT DATA = A5_1;  
	SERIES x = mage2 y = pred / MARKERS MARKERATTRS = (SYMBOL = "circlefilled" size = 5) 
		LINEATTRS = (THICKNESS = 2);
	SERIES x = mage2 y =l95m / LINEATTRS = (PATTERN = 2 COLOR = "red") 
		LEGENDLABEL = "Lower 95% CI";
	SERIES x = mage2 y =u95m / LINEATTRS = (PATTERN = 2 COLOR = "red") 
		LEGENDLABEL = "Upper 95% CI";
	XAXIS LABEL = "Maternal Age (Years)" VALUES = (10 to 50 by 10);
	YAXIS LABEL = "Risk (95% CI) of preterm birth" VALUES = (0.00 to 0.40 by 0.05);
	TITLE1 "Risk (95% CI) of Preterm Birth by Maternal Age (years)";
	TITLE2 "A5. Maternal Age Modeled as a Quadratic Spline"; 
RUN;
TITLE1;
TITLE2;

*A6.1 for Lab 3 from EPID 716;
DATA lab3_5; *new dataset with magesq18, magesq29, magesq35 variable;
	SET lab3_4;
	IF mage2 > 18 THEN magers18 = (magesq18)-(magesq35); ELSE magers18 = 0;
	IF mage2 > 29 THEN magers29 = (magesq29)-(magesq35); ELSE magers29 = 0;

RUN;

PROC FREQ DATA = lab3_5; *confirming new variable was created as intended;
	TABLE mage2*magers18*magers29 / LIST MISSPRINT MISSING;
	TITLE "PROC FREQ of new variables";
RUN;
TITLE;

PROC GENMOD DATA = lab3_5; *to get R, RR and CI using restricted quadratic spline;
	MODEL preterm = mage2 magers18 magers29 / LINK = log DIST = binomial;
	OUTPUT OUT = A6_1 PRED = pred l = l95m u = u95m;
	TITLE 'Quadratic Risk Model for Restricted Quadratic Spline';
	ESTIMATE "Risk (Age 16)" int 1 mage2 16 magers18 0 magers29 0 / EXP;
	ESTIMATE "Risk (Age 26)" int 1 mage2 26 magers18 64 magers29 0 / EXP;
	ESTIMATE "Risk (Age 40)" int 1 mage2 40 magers18 459 magers29 96 / EXP;
	ESTIMATE "RR(Age 16 vs Age 26)" int 0 mage2 -10 magers18 -64 magers29 0 / EXP;
	ESTIMATE "RR (Age 40 vs Age 26)" int 0 mage2 14 magers18 395 magers29 96 / EXP;
RUN;
TITLE;

PROC SORT DATA = A6_1; 
	BY mage2;
RUN;

ODS LISTING GPATH = "/home/u59075382/epid716/Labs/Lab 3";
ODS GRAPHICS / RESET = all LINEPATTERNOBSMAX = 61500 ANTIALIASMAX = 68000 IMAGENAME = "mage_A6_1" 
	IMAGEFMT = jpeg HEIGHT = 6in WIDTH = 9in NOBORDER;
	
PROC SGPLOT DATA = A6_1;  
	SERIES x = mage2 y = pred / MARKERS MARKERATTRS = (SYMBOL = "circlefilled" size = 5) 
		LINEATTRS = (THICKNESS = 2);
	SERIES x = mage2 y =l95m / LINEATTRS = (PATTERN = 2 COLOR = "red") 
		LEGENDLABEL = "Lower 95% CI";
	SERIES x = mage2 y =u95m / LINEATTRS = (PATTERN = 2 COLOR = "red") 
		LEGENDLABEL = "Upper 95% CI";
	XAXIS LABEL = "Maternal Age (Years)" VALUES = (10 to 50 by 10);
	YAXIS LABEL = "Risk (95% CI) of preterm birth" VALUES = (0.00 to 0.40 by 0.05);
	TITLE1 "Risk (95% CI) of Preterm Birth by Maternal Age (years)";
	TITLE2 "A6. Maternal Age Modeled as a Restricted Quadratic Spline"; 
RUN;
TITLE1;
TITLE2;



