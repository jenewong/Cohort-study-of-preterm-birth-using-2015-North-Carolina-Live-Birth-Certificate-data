LIBNAME epid795 "/home/u59075382/epid795/Data";

*Mean, standard deviation, range, median, and 5th and 95th percentiles for gestational age at birth;
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


*Graph the proportional distribution of gestational age at birth;
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

*Mean, standard deviation, range, median, and 5th and 95th percentiles for weeknum;
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

*Graph the distribution of week of birth in the study population - confirm that weeknum is defined and coded correctly; 
PROC SGPLOT DATA = epid795.birthscohort;
	HISTOGRAM weeknum / BINWIDTH = 1;
	TITLE "Distribution of week of births in 2015";
RUN;
TITLE;

*The data for weeknum does not have extreme, out of range, or inplausible values.;

*Examine the relation between gestational age (weeks) and the 2015 week of birth (weeknum);
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


*Create a new variable (pwk) that classifies each birth according to person-weeks at risk;
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

*range, mean, median, standard deviation, and the 25th and 75th percentiles of person-weeks 
at risk among preterm births;
PROC UNIVARIATE DATA = births3;
	VAR pwk;
	WHERE . < pwk < 17;
	TITLE "Descriptive statistics for person-time at risk";
RUN;
TITLE;
*Among preterm births, the mean of person-time at risk is 14 person-weeks and the standard deviation 
is 3.4 person-weeks.;

*Create binary indicator variable for preterm birth (preterm) based on the variable weeks;
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

*Proportions of births that are term and preterm;
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

*Frequencies and proportions of observations with each possible value of prenatal ; 
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

*Determine what month of pregnancy (1 through 9) did women most commonly begin prenatal care;
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


*Create a new variable (pnc5) based on prenatal;
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
	
*counts and proportions of observations in each category of pnc5 in the study population as a whole, 
and according to preterm birth status;
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


*percentage had a preterm birth among those who received prenatal care during the first 
20 weeks of gestation;
PROC FREQ DATA = births6_sort2;
	BY pnc5;
	TABLE preterm / MISSING;
	TITLE 'Preterm birth status by early prenatal care (in the first 20 weeks of gestation)'; 
RUN;
TITLE;

*Among women who received prenatal care during the first 5 months of gestation, 7.8% had a preterm birth;


*percentage had a preterm birth among those who did not receive prenatal care within the 
first 20 weeks;
PROC FREQ DATA = births6_sort2;
	BY pnc5;
	TABLE preterm / MISSING;
	TITLE 'Preterm birth status by early prenatal care (in the first 20 weeks of gestation)'; 
RUN;
TITLE;

*Among women who did not receive prenatal care during the first 5 months of gestation, 12% had a 
preterm birth;


*mean, standard deviation, range, median, 5th and 95th percentiles, and the number of observations 
with missing data for mother’s age (mage) in the population as a whole and according to preterm 
birth status;
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


*Graph the number of eligible births (i.e., births in the study population) according to maternal 
age in the total population ;
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


*new variable (mage2) where observations with maternal age of 44 and older are combined into a 
single category, and observations with known maternal age of 14 or less are combined into a 
single category.;
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


*mean, standard deviation, range, median, 5th and 95th percentiles of mage2.;
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

*Graph the number of eligible births according to mage2 - confirm that mage2 has been defined 
and coded correctly.;
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

*meaningful format for values of the variable race;
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


*Check for extreme, out of range or implausible values for race;
PROC UNIVARIATE DATA = births8n;
	VAR race_num;
RUN;
*there are no extreme or inplausible values for race. The range of values is 1-4, which is plausible;


*missing data for the variable race;
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


*Create a new variable for race (race2) based on race,;
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

*Examine counts and proportions of observations in each category of race2 in the population as a 
whole and according to preterm birth status;
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


*Create a new variable for mother’s Hispanic ethnicity (mhisp) based on hispmom;
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


*Examine counts and proportions of observations in each category of mhisp in the population as a 
whole and according to preterm birth status;
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


*Create a new variable that classifies mothers according to race and Hispanic ethnicity (raceth);
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


*Examine counts and proportions of observations in each category of raceth in the population as a 
whole and according to preterm birth status. ;
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


*Create a new variable (raceth2);
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


*Create a new variable (smoker) based on cigdur;
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

*Examine counts and proportions of observations in each category of smoker in the study population as a 
whole, and according to preterm birth status.;
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


*Report counts and proportions of observations in each category of sex in the study population as a 
whole, and according to preterm birth status;
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


*total number of observations that have missing data for any of the covariates;
PROC CONTENTS DATA = births14;
RUN;
*variables of interest are pnc5, race_num, mhisp, mage_num, smoker, and sex_num;

DATA births15; *new dataset that has variable calculating any missing numeric values;
	SET births14;
	IF NMISS(OF pnc5, race_num, mhisp, mage_num, smoker, sex_num) > 0 THEN anymissnum = "Yes";
		ELSE anymissnum = "No";
	LABEL anymissnum = "Any missing numeric value for pnc5, race_num, mhisp, mage_num, smoker, and sex_
	num";
RUN;

PROC FREQ DATA = births15;
	TABLES anymissnum;
	TITLE "PROC FREQ of any missing numeric value for pnc5, race_num, mhisp, mage_num, smoker, and sex_
	num";
RUN;
TITLE;
*The total number of observations that have missing values for any of the 6 covariates is 652 observations.;

*covariates with the greatest number of missing values;
PROC FREQ DATA = births15; 
	TABLES pnc5 / MISSPRINT; 
	TABLES race_num / MISSPRINT;
	TABLES mhisp / MISSPRINT; 
	TABLES mage_num / MISSPRINT;
	TABLES smoker / MISSPRINT;
	TABLES sex_num / MISSPRINT; 
	TITLE "PROC FREQ of prenatal care, race, Hispanic ethnicity, maternal age, smoking during pregnancy, 
	and child's sex";
RUN;
TITLE;

PROC FREQ DATA = births15; 
	TABLES pnc5 / MISSING; 
	TABLES prenatal / MISSING;
	TITLE "PROC FREQ of prenatal care";
RUN;
TITLE;
*The name of the covariate in the original birthscohort.sas7bdat data set that has the greatest number 
of missing values is "prenatal". It has 606 missing values. The percentage with missing data for the 
covariate "prenatal" is 0.99%.;


*term births with any missing covariate data; 
PROC FREQ DATA = births15;
	TABLES anymissnum*preterm / MISSING NOCOL NOROW;
	WHERE preterm = 0;
	TITLE "PROC FREQ of missing numeric values for 6 covariates among term births";
RUN;
*N = 54, 0.97% term births with any missing covariate data; 


*preterm births with any missing covariate data;
PROC FREQ DATA = births15;
	TABLES anymissnum*preterm / MISSING NOCOL NOROW;
	WHERE preterm = 1;
	TITLE "PROC FREQ of missing numeric values for 6 covariates among preterm births";
RUN;
*N = 107, 2.1% preterm births with any missing covariate data; 


*term births with missing values for two or more covariates; 
DATA births16; *new dataset that has variable calculating 2 or more missing numeric values;
	SET births15;
	IF NMISS(OF pnc5, race_num, mhisp, mage_num, smoker, sex_num) >= 2 THEN anymissnum2 = "Yes";
		ELSE anymissnum2 = "No";
	LABEL anymissnum2 = "2 or more missing numeric value for pnc5, race_num, mhisp, mage_num, smoker, 
	and sex_num";
RUN;

PROC FREQ DATA = births16;
	TABLES anymissnum2;
	TITLE "PROC FREQ of 2 or more missing numeric value for pnc5, race_num, mhisp, mage_num, smoker, 
	and sex_num";
RUN;
TITLE;
*checking that new variable was created as intended;

PROC FREQ DATA = births16;
	TABLES anymissnum2*preterm / MISSING NOCOL NOROW;
	WHERE preterm = 0;
	TITLE "PROC FREQ of 2 or more missing numeric values for 6 covariates among term births";
RUN;
TITLE;
*4 term births were missing values for two or more covariates;


*preterm births with missing values for two or more covariates; 
PROC FREQ DATA = births16;
	TABLES anymissnum2*preterm / MISSING NOCOL NOROW;
	WHERE preterm = 1;
	TITLE "PROC FREQ of 2 or more missing numeric values for 6 covariates among preterm births";
RUN;
TITLE;
*2 preterm births were missing values for two or more covariates;


*observed combinations of missing covariates;
DATA births17; *new dataset of only observations with 2 or more missing covariate values; 
	SET births16; 
	WHERE anymissnum2 = "Yes";
RUN; 

PROC PRINT DATA = births17;
	VAR pnc5 mage_num mhisp smoker race_num sex_num;
TITLE "PROC FREQ of 2 or more missing numeric values for 6 covariate combinations";
RUN;
TITLE;

*Part A;
*No observed combinations of missing prenatal care and maternal age;

*Part B;
*2 observed combinations of missing prenatal care and Hispanic ethnicity;

*Part C; 
*3 observed combinations of missing prenatal care and smoking during pregnancy;

*Part D; 
*No observed combinations of missing race and smoking during pregnancy;

*Part E;
*3 observed combinations of missing Hispanic ethnicity and smoking during pregnancy;

*Part F; 
*1 observed combinations of missing prenatal care, Hispanic ethnicity, and smoking during pregnancy;

*Part G; 
*No observed combinations of missing prenatal care, smoking during pregnancy, and maternal age;

*B, C, E, and F are observed combinations of missing covariates;

*Table 1;
PROC CONTENTS DATA = births16; 
RUN;

PROC FREQ DATA = births16; 
	TABLES pnc5 / MISSPRINT; 
	TABLES raceth/ MISSPRINT; 
	TABLES smoker / MISSPRINT;
	TABLES sex_num / MISSPRINT; 
	TITLE "PROC FREQ of prenatal care, race/ethnicity, smoking during pregnancy, and child's sex";
RUN;
TITLE;

PROC SORT DATA = births16 OUT = births16_sort; *sorting data by preterm;
	BY preterm; 
RUN;

PROC FREQ DATA = births16_sort; 
	BY preterm;
	TABLES pnc5 / MISSPRINT; 
	TABLES raceth/ MISSPRINT;
	TABLES smoker / MISSPRINT;
	TABLES sex_num / MISSPRINT; 
	TITLE "PROC FREQ of prenatal care, race/ethnicity, smoking during pregnancy, and child's sex by
	birth status";
RUN;
TITLE;

*examine how model assumptions influence estimated risks, RD, RR and the observed 
dose-response relation between maternal age and preterm birth;

*linear risk regression model to examine the association between preterm and maternal age 
modeled using disjoint indicator variables to represent each possible value of mage2. 
Graph maternal age versus estimated risk of preterm according to this model;
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


*log-risk regression model of preterm and maternal age modeled using the 30 disjoint indicator 
variables to represent each possible value of mage2, omitting age 26 as the referent group.;
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

*linear risk regression model to examine the association between preterm and maternal age as a 
simple continuous variable (mage2). Graph maternal age versus estimated risk of preterm ;
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

*log-risk regression model of preterm and mage2;
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


*linear-risk model that includes mage2 plus a second order term representing mage22 (magesq);
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

*log-risk model that includes mage2 plus a second order term representing mage22 (magesq).
Graph maternal age versus estimated risk of preterm;
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

*log-risk model with linear spline terms for maternal age. Graph maternal age versus estimated 
risk of preterm ;
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

*log-risk model with quadratic spline terms for maternal age. 
Graph maternal age versus estimated risk of preterm ;
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

*log-risk model with restricted quadratic spline terms for maternal age.
Graph maternal age versus estimated risk of preterm ;
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


*Crude Analyses using Generalized Linear Models;
ODS TRACE ON; *looking to see names of which tables to pull to expand decimals for; 
PROC GENMOD DATA = births6;
	MODEL preterm = pnc5 / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given prenatal care status";
	ESTIMATE "Risk (unexposed)" int 1 pnc5 0;
	ESTIMATE "Risk (exposed)" int 1 pnc5 1;
	ESTIMATE "RD (exposed vs. unexposed)" int 0 pnc5 1;
RUN;
TITLE;
ODS TRACE OFF; *Estimates is the desired table;

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

**linear risk regression model to a) estimate 17-week risks of preterm birth for births 
with early prenatal care (pnc5 = 1) and births without early prenatal care (pnc5 = 0), and b) 
estimate the RD (and 95% CI) for early care vs. no early care;;
PROC GENMOD DATA = births6; *to get risks, RD, and CI;
	MODEL preterm = pnc5 / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given prenatal care status";
	ESTIMATE "Risk (unexposed)" int 1 pnc5 0;
	ESTIMATE "Risk (exposed)" int 1 pnc5 1;
	ESTIMATE "RD (exposed vs. unexposed)" int 0 pnc5 1;
RUN;
TITLE;

*log-risk regression model to estimate as above;
PROC GENMOD DATA = births6; *to get R, RR and CI;
	MODEL preterm = pnc5 / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given prenatal care status";
	ESTIMATE "Risk (unexposed)" int 1 pnc5 0 / EXP;
	ESTIMATE "Risk (exposed)" int 1 pnc5 1 / EXP;
	ESTIMATE "RR (exposed vs. unexposed)" int 0 pnc5 1 / EXP;
RUN;
TITLE;

*Disjoint Indicator Variable;
PROC FREQ DATA = births12 ORDER = formatted; *to get total number missing for Table 1;
	TABLES raceth2*preterm / MISSING CMH RISKDIFF NOPERCENT NOCOL NOROW LIST;
	FORMAT preterm pretermf. raceth2 raceth2f.; *formatting to order the variables alphabetically;
	TITLE "C2 Contingency Table of missing, white/NH, white/H, AA, Other";
RUN;
TITLE;

*linear risk regression model to a) estimate 17-week risks of preterm birth for “Other race” births 
(raceth2 = 3), AA births (raceth2 = 2), White/Hispanic births (raceth2 = 1) and White/non-Hispanic 
births (raceth2 = 0) and b) estimate the RD (and 95% CI) for other births vs. White/non-Hispanic 
births, for AA vs. White/non-Hispanic births, and for White/Hispanic births vs. White/non-Hispanic
births;
PROC GENMOD DATA = births12 ORDER = internal; *to get risks;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = raceth2 / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given race";
	ESTIMATE "Risk W/NH" int 1 raceth2 0 0 0;
	ESTIMATE "Risk W/H" int 1 raceth2 1 0 0;
	ESTIMATE "Risk AA" int 1 raceth2 0 1 0;
	ESTIMATE "Risk Other" int 1 raceth2 0 0 1;
RUN;
TITLE;

PROC GENMOD DATA = births12 ORDER = internal; *to get RD and CI;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = raceth2 / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given race";
	ESTIMATE "RD (Other vs. W/NH)" int 0 raceth2 0 0 1;
	ESTIMATE "RD (AA vs. W/NH)" int 0 raceth2 0 1 0;
	ESTIMATE "RD (W/H vs W/NH)" int 0 raceth2 1 0 0;
RUN;
TITLE;

*log-risk regression model to estimate the RR (and 95% CI) for for other births vs. 
White/non-Hispanic births, for AA vs. White/non-Hispanic births, and for White/Hispanic births vs. 
White/non-Hispanic births;
PROC GENMOD DATA = births12 ORDER = internal; *to get R, RR and CI;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = raceth2 / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given race";
	ESTIMATE "Risk W/NH" int 1 raceth2 0 0 0 / EXP;
	ESTIMATE "Risk W/H" int 1 raceth2 1 0 0 / EXP;
	ESTIMATE "Risk AA" int 1 raceth2 0 1 0 / EXP;
	ESTIMATE "Risk Other" int 1 raceth2 0 0 1 / EXP;
	ESTIMATE "RR (Other vs. W/NH)" int 0 raceth2 0 0 1 / EXP;
	ESTIMATE "RR (AA vs. W/NH)" int 0 raceth2 0 1 0 / EXP;
	ESTIMATE "RR (W/H vs W/NH)" int 0 raceth2 1 0 0 / EXP;
RUN;
TITLE;

*logistic regression model to estimate the IOR (and 95% CI) for for other births vs. 
White/non-Hispanic births, for AA vs. White/non-Hispanic births, and for White/Hispanic births vs. 
White/non-Hispanic births.;
PROC GENMOD DATA = births12 ORDER = internal; *to get R, IOR and CI;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = raceth2 / DIST = binomial LINK = logit;
	TITLE "Logistic model for preterm birth given race";
	ESTIMATE "Risk W/NH" int 1 raceth2 0 0 0 / EXP;
	ESTIMATE "Risk W/H" int 1 raceth2 1 0 0 / EXP;
	ESTIMATE "Risk AA" int 1 raceth2 0 1 0 / EXP;
	ESTIMATE "Risk Other" int 1 raceth2 0 0 1 / EXP;
	ESTIMATE "IOR (Other vs. W/NH)" int 0 raceth2 0 0 1 / EXP;
	ESTIMATE "IOR (AA vs. W/NH)" int 0 raceth2 0 1 0 / EXP;
	ESTIMATE "IOR (W/H vs W/NH)" int 0 raceth2 1 0 0 / EXP;
RUN;
TITLE;

*Confounding;
*crude RD and RR (with 95% CI) estimates for preterm in association with pnc5. confidence limit 
differences (CLD) for the RD and confidence limit ratios (CLR) for the RR using linear risk and 
log risk models to generate 95% CI estimates for the RD and RR;
PROC GENMOD DATA = births6; *to get crude risks, RD, and CI;
	MODEL preterm = pnc5 / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given prenatal care status";
	ESTIMATE "Risk (unexposed)" int 1 pnc5 0;
	ESTIMATE "Risk (exposed)" int 1 pnc5 1;
	ESTIMATE "RD (exposed vs. unexposed)" int 0 pnc5 1;
RUN;
TITLE;

PROC GENMOD DATA = births6; *to get crude R, RR and CI;
	MODEL preterm = pnc5 / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given prenatal care status";
	ESTIMATE "Risk (unexposed)" int 1 pnc5 0 / EXP;
	ESTIMATE "Risk (exposed)" int 1 pnc5 1 / EXP;
	ESTIMATE "RR (exposed vs. unexposed)" int 0 pnc5 1 / EXP;
RUN;
TITLE;

*numbers of preterm births and the 17-week risk of preterm birth according to prenatal care 
status and maternal smoking and maternal race/ethnicity. RD and RR (with 95% CI and CLD/CLR) for 
preterm in association with pnc5 within each covariate stratum;
PROC SORT DATA = births13 OUT = births13_sort2; *sorting data by smoker;
	BY smoker; 
RUN;

PROC FREQ DATA = births13_sort2; *to get frequency;
	TABLE preterm*pnc5 / MISSPRINT NOPERCENT NOCOL NOROW;
	BY smoker;
	TITLE "PROC FREQ of maternal smoking during pregnancy by birth status and prenatal care";
RUN;
TITLE;

PROC GENMOD DATA = births13_sort2; *to get risks, RD, and CI stratified by smoker;
	BY smoker;
	MODEL preterm = pnc5 / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given prenatal care status and maternal smoking";
	ESTIMATE "Risk (unexposed)" int 1 pnc5 0;
	ESTIMATE "Risk (exposed)" int 1 pnc5 1;
	ESTIMATE "RD (exposed vs. unexposed)" int 0 pnc5 1;
RUN;
TITLE;

PROC GENMOD DATA = births13_sort2; *to get R, RR and CI stratified by smoker;
	BY smoker;
	MODEL preterm = pnc5 / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given prenatal care status and maternal smoking";
	ESTIMATE "Risk (unexposed)" int 1 pnc5 0 / EXP;
	ESTIMATE "Risk (exposed)" int 1 pnc5 1 / EXP;
	ESTIMATE "RR (exposed vs. unexposed)" int 0 pnc5 1 / EXP;
RUN;
TITLE;

PROC SORT DATA = births12 OUT = births12_sort; *sorting data by raceth2;
	BY raceth2; 
RUN;

PROC FREQ DATA = births12_sort; *to get frequency;
	TABLE preterm*pnc5 / MISSPRINT NOPERCENT NOCOL NOROW;
	BY raceth2;
	TITLE "PROC FREQ of maternal smoking during pregnancy by birth status and maternal race/ethnicity";
RUN;
TITLE;

PROC GENMOD DATA = births12_sort; *to get risks, RD, and CI stratified by maternal race/ethnicity;
	BY raceth2;
	MODEL preterm = pnc5 / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given prenatal care status and maternal race/ethnicity";
	ESTIMATE "Risk (unexposed)" int 1 pnc5 0;
	ESTIMATE "Risk (exposed)" int 1 pnc5 1;
	ESTIMATE "RD (exposed vs. unexposed)" int 0 pnc5 1;
RUN;
TITLE;

PROC FREQ DATA = births12_sort ORDER = formatted; *double checking R and RD;
	TABLES raceth2*pnc5*preterm / MISSING CMH RISKDIFF NOPERCENT NOCOL NOROW LIST;
	FORMAT preterm pretermf. raceth2 raceth2f.; *formatting to order the variables alphabetically;
	WHERE raceth2 ne . and pnc5 ne .;
	TITLE "C2 Contingency Table";
RUN;
TITLE;

PROC GENMOD DATA = births12_sort; *to get R, RR and CI stratified by maternal race/ethnicity;
	BY raceth2;
	MODEL preterm = pnc5 / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given prenatal care status and maternal race/ethnicity";
	ESTIMATE "Risk (unexposed)" int 1 pnc5 0 / EXP;
	ESTIMATE "Risk (exposed)" int 1 pnc5 1 / EXP;
	ESTIMATE "RR (exposed vs. unexposed)" int 0 pnc5 1 / EXP;
RUN;
TITLE;

*Calculate the variance of the RD for prenatal care in each stratum of smoker;
PROC UNIVARIATE DATA = births13_sort2;
	VAR pnc5 preterm;
	BY smoker;
	TITLE "Descriptive statistics for preterm birth by smoker";
RUN;
TITLE;

PROC FREQ DATA = births13_sort2; *to get frequency;
	TABLE preterm*pnc5 / MISSPRINT NOPERCENT NOCOL NOROW;
	BY smoker;
	TITLE "PROC FREQ of maternal smoking during pregnancy by birth status and prenatal care";
RUN;
TITLE;

*product term and lower order linear risk models;
PROC GENMOD DATA = births13; *to get adjusted R, RD and CI;
	MODEL preterm = pnc5 smoker / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, smoker: adjusted";
	ESTIMATE "Non-smokers: Risk (No early care)" int 1 pnc5 0 smoker 0;
	ESTIMATE "Non-smokers: Risk (Early care" int 1 pnc5 1 smoker 0;
	ESTIMATE "Smokers: Risk (No early care)" int 1 pnc5 0 smoker 1;
	ESTIMATE "Smokers: Risk (Early care)" int 1 pnc5 1 smoker 1;
	ESTIMATE "Non-smokers: RD" int 0 pnc5 1 smoker 0;
	ESTIMATE "Smokers: RD" int 0 pnc5 1 smoker 0;
	ESTIMATE "Adjusted RD" int 0 pnc5 1 smoker 0;
RUN; 
TITLE; 

PROC TEMPLATE; *changing Log Likelihood to have 10 decimals;
EDIT stat.genmod.ModelFit; 
DEFINE Value; 
FORMAT = 12.10; END;
END; 
RUN;

ODS TRACE ON;
PROC GENMOD DATA = births13; *to get log liklihood reduced;
	MODEL preterm = pnc5 smoker / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, smoker: adjusted";
RUN; 
TITLE; 
ODS TRACE OFF;

PROC GENMOD DATA = births13; *to get log liklihood full;
	MODEL preterm = pnc5 smoker pnc5*smoker / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, smoker, interaction pnc5*smoker: adjusted";
RUN; 
TITLE; 

*product term log risk model and a second log risk model with pnc5 and smoker only;
PROC GENMOD DATA = births13; *to get adjusted R, RR and CI;
	MODEL preterm = pnc5 smoker / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given pnc5, smoker: adjusted";
	ESTIMATE "Non-smokers: Risk (No early care)" int 1 pnc5 0 smoker 0 / EXP;
	ESTIMATE "Non-smokers: Risk (Early care" int 1 pnc5 1 smoker 0 / EXP;
	ESTIMATE "Smokers: Risk (No early care)" int 1 pnc5 0 smoker 1 / EXP;
	ESTIMATE "Smokers: Risk (Early care)" int 1 pnc5 1 smoker 1 / EXP;
	ESTIMATE "Non-smokers: RR" int 0 pnc5 1 smoker 0 / EXP;
	ESTIMATE "Smokers: RR" int 0 pnc5 1 smoker 0 / EXP;
	ESTIMATE "Adjusted RR" int 0 pnc5 1 smoker 0 / EXP;
RUN; 
TITLE; 

PROC GENMOD DATA = births13; *to get log liklihood reduced;
	MODEL preterm = pnc5 smoker / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given pnc5, smoker: adjusted";
RUN; 
TITLE; 

PROC GENMOD DATA = births13; *to get log liklihood full;
	MODEL preterm = pnc5 smoker pnc5*smoker / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given pnc5, smoker, interaction pnc5*smoker: adjusted";
RUN; 
TITLE; 

*product term and lower order linear risk models ;
PROC GENMOD DATA = births12 ORDER = internal; *to get log liklihood reduced;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm =  pnc5 raceth2 / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, race: adjusted";
RUN;
TITLE; 

PROC GENMOD DATA = births12 ORDER = internal; *to get log liklihood full;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm =  pnc5 raceth2 pnc5*raceth2 / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, race: adjusted";
RUN;
TITLE;

PROC GENMOD DATA = births12 ORDER = internal; *to get adjusted R, RD and CI;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = pnc5 raceth2 / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, raceth2: adjusted";
	ESTIMATE "W/NH: Risk (No early care)" int 1 pnc5 0 raceth2 0 0 0; 
	ESTIMATE "W/NH: Risk (Early care)" int 1 pnc5 1 raceth2 0 0 0; 
	ESTIMATE "W/H: Risk (No early care)" int 1 pnc5 0 raceth2 1 0 0; 
	ESTIMATE "W/H: Risk (Early care)" int 1 pnc5 1 raceth2 1 0 0; 
	ESTIMATE "AA: Risk (No early care)" int 1 pnc5 0 raceth2 0 1 0;
	ESTIMATE "AA: Risk (Early care)" int 1 pnc5 1 raceth2 0 1 0; 
	ESTIMATE "Other: Risk (No early care)" int 1 pnc5 0 raceth2 0 0 1; 
	ESTIMATE "Other: Risk (Early care)" int 1 pnc5 1 raceth2 0 0 1; 
	ESTIMATE "W/NH: RD" int 0 pnc5 1 raceth2 0 0 0;
	ESTIMATE "W/H: RD" int 0 pnc5 1 raceth2 0 0 0;
	ESTIMATE "AA: RD" int 0 pnc5 1 raceth2 0 0 0;
	ESTIMATE "Other: RD" int 0 pnc5 1 raceth2 0 0 0;
	ESTIMATE "Adjusted RD" int 0 pnc5 1 raceth2 0 0 0;
RUN; 
TITLE; 

*product term and lower order log risk models.;
PROC GENMOD DATA = births12 ORDER = internal; *to get log liklihood reduced;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm =  pnc5 raceth2 / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given pnc5, race: adjusted";
RUN;
TITLE; 

PROC GENMOD DATA = births12 ORDER = internal; *to get log liklihood full;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm =  pnc5 raceth2 pnc5*raceth2 / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given pnc5, race: adjusted";
RUN;
TITLE;

PROC GENMOD DATA = births12 ORDER = internal; *to get adjusted R, RR and CI;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = pnc5 raceth2 / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given pnc5, raceth2: adjusted";
	ESTIMATE "W/NH: Risk (No early care)" int 1 pnc5 0 raceth2 0 0 0 / EXP; 
	ESTIMATE "W/NH: Risk (Early care)" int 1 pnc5 1 raceth2 0 0 0 / EXP; 
	ESTIMATE "W/H: Risk (No early care)" int 1 pnc5 0 raceth2 1 0 0 / EXP; 
	ESTIMATE "W/H: Risk (Early care)" int 1 pnc5 1 raceth2 1 0 0 / EXP; 
	ESTIMATE "AA: Risk (No early care)" int 1 pnc5 0 raceth2 0 1 0 / EXP;
	ESTIMATE "AA: Risk (Early care)" int 1 pnc5 1 raceth2 0 1 0 / EXP; 
	ESTIMATE "Other: Risk (No early care)" int 1 pnc5 0 raceth2 0 0 1 / EXP; 
	ESTIMATE "Other: Risk (Early care)" int 1 pnc5 1 raceth2 0 0 1 / EXP; 
	ESTIMATE "W/NH: RR" int 0 pnc5 1 raceth2 0 0 0 / EXP;
	ESTIMATE "W/H: RR" int 0 pnc5 1 raceth2 0 0 0 / EXP;
	ESTIMATE "AA: RR" int 0 pnc5 1 raceth2 0 0 0 / EXP;
	ESTIMATE "Other: RR" int 0 pnc5 1 raceth2 0 0 0 / EXP;
	ESTIMATE "Adjusted RR" int 0 pnc5 1 raceth2 0 0 0 / EXP;
RUN; 
TITLE; 

*product term and lower order linear risk models ;
*creating variable magesq to represent mage2*mage2;
DATA births8_2; *new dataset with magesq variable;
	SET births8;
	magesq = mage2*mage2;
RUN;

PROC FREQ DATA = births8_2; *confirming new variable was created as intended;
	TABLE magesq*mage2 / LIST MISSPRINT;
	TITLE "PROC FREQ of new magesq variable";
RUN;
TITLE;

PROC GENMOD DATA = births8_2; *to get log liklihood reduced;
	MODEL preterm = pnc5 mage2 magesq / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, mage2, magesq: adjusted";
RUN; 
TITLE; 

PROC GENMOD DATA = births8_2; *to get log liklihood full;
	MODEL preterm = pnc5 mage2 magesq pnc5*mage2 pnc5*magesq / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, mage2, magesq, interaction pnc5*mage & pnc5*magesq: adjusted";
RUN; 
TITLE;

PROC GENMOD DATA = births8_2; *to get adjusted R, RD and CI;
	MODEL preterm = pnc5 mage2 magesq / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, mage2, magesq: adjusted";
	ESTIMATE "Adjusted RD" int 0 pnc5 1 mage2 0 magesq 0;
RUN; 
TITLE;

*product term and lower order log risk models;
PROC GENMOD DATA = births8_2; *to get log liklihood reduced;
	MODEL preterm = pnc5 mage2 magesq / DIST = binomial LINK = log;
	ESTIMATE "Adjusted RR" int 0 pnc5 1 mage2 0 magesq 0;
	TITLE "Log risk model for preterm birth given pnc5, mage2, magesq: adjusted";
RUN; 
TITLE; 

PROC GENMOD DATA = births8_2; *to get log liklihood full;
	MODEL preterm = pnc5 mage2 magesq pnc5*mage2 pnc5*magesq / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given pnc5, mage2, magesq, interaction pnc5*mage & pnc5*magesq: adjusted";
RUN; 
TITLE;

*E1.1 for Lab 4 from EPID 716;
DATA births13_2; *new dataset with magesq variable;
	SET births13;
	magesq = mage2*mage2;
RUN;

PROC FREQ DATA = births13_2; *confirming new variable was created as intended;
	TABLE magesq*mage2 / LIST MISSPRINT;
	TITLE "PROC FREQ of new magesq variable";
RUN;
TITLE;

PROC GENMOD DATA = births13_2 ORDER = internal; *to get adjusted RD;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = pnc5 raceth2 smoker mage2 magesq / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, raceth, smoker, mage2, magesq: adjusted";
	ESTIMATE "Full model E1.1 (Early care vs. no early care)" int 0 pnc5 1;
RUN; 
TITLE; 

*E1.2 for Lab 4 from EPID 716;
PROC GENMOD DATA = births13_2 ORDER = internal; *to get adjusted RD;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = pnc5 raceth2 smoker / DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, racetch, smoker: adjusted";
	ESTIMATE "Reduced model E1.2 (Early care vs. no early care)" int 0 pnc5 1;
RUN; 
TITLE; 

*E1.3 for Lab 4 from EPID 716;
PROC GENMOD DATA = births13_2 ORDER = internal; *to get adjusted RD;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = pnc5 raceth2 mage2 magesq/ DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, raceth, mage2, magesq: adjusted";
	ESTIMATE "Reduced model E1.3 (Early care vs. no early care)" int 0 pnc5 1;
RUN; 
TITLE; 

*E1.4 for Lab 4 from EPID 716;
PROC GENMOD DATA = births13_2 ORDER = internal; *to get adjusted RD;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = pnc5 smoker mage2 magesq/ DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, smoker, mage2, magesq: adjusted";
	ESTIMATE "Reduced model E1.4 (Early care vs. no early care)" int 0 pnc5 1;
RUN; 
TITLE; 

*E1.5 for Lab 4 from EPID 716;
PROC GENMOD DATA = births13_2 ORDER = internal; *to get adjusted RD;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = pnc5 raceth2/ DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, raceth2: adjusted";
	ESTIMATE "Reduced model E1.5 (Early care vs. no early care)" int 0 pnc5 1;
RUN; 
TITLE; 

*E1.6 for Lab 4 from EPID 716;
PROC GENMOD DATA = births13_2 ORDER = internal; *to get adjusted RD;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = pnc5 mage2 magesq/ DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, mage2, magesq: adjusted";
	ESTIMATE "Reduced model E1.6 (Early care vs. no early care)" int 0 pnc5 1;
RUN; 
TITLE; 

*E1.7 for Lab 4 from EPID 716;
PROC GENMOD DATA = births13_2 ORDER = internal; *to get adjusted RD;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = pnc5 smoker/ DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5, smoker: adjusted";
	ESTIMATE "Reduced model E1.7 (Early care vs. no early care)" int 0 pnc5 1;
RUN; 
TITLE; 

*E1.8 for Lab 4 from EPID 716;
PROC GENMOD DATA = births13_2 ORDER = internal; *to get adjusted RD;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = pnc5/ DIST = binomial LINK = identity;
	TITLE "Linear risk model for preterm birth given pnc5: adjusted";
	ESTIMATE "Reduced model E1.8 (Early care vs. no early care)" int 0 pnc5 1;
RUN; 
TITLE; 

*E2.1 for Lab 4 from EPID 716;
PROC GENMOD DATA = births13_2 ORDER = internal; *to get adjusted RR;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = pnc5 raceth2 smoker mage2 magesq / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given pnc5, racetch, smoker, mage2, magesq: adjusted";
	ESTIMATE "Full model E2.1 (Early care vs. no early care)" int 0 pnc5 1 / EXP;
RUN; 
TITLE; 

*E2.2 for Lab 4 from EPID 716;
PROC GENMOD DATA = births13_2 ORDER = internal; *to get adjusted RR;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = pnc5 raceth2 smoker / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given pnc5, racetch, smoker: adjusted";
	ESTIMATE "Reduced model E2.2 (Early care vs. no early care)" int 0 pnc5 1 / EXP;
RUN; 
TITLE; 

*E2.3 for Lab 4 from EPID 716;
PROC GENMOD DATA = births13_2 ORDER = internal; *to get adjusted RR;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = pnc5 raceth2 mage2 magesq / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given pnc5, racetch, mage2, magesq: adjusted";
	ESTIMATE "Reduced model E2.3 (Early care vs. no early care)" int 0 pnc5 1 / EXP;
RUN; 
TITLE; 

*E2.4 for Lab 4 from EPID 716;
PROC GENMOD DATA = births13_2 ORDER = internal; *to get adjusted RR;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = pnc5 smoker mage2 magesq / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given pnc5, smoker, mage2, magesq: adjusted";
	ESTIMATE "Reduced model E2.4 (Early care vs. no early care)" int 0 pnc5 1 / EXP;
RUN; 
TITLE; 

*E2.5 for Lab 4 from EPID 716;
PROC GENMOD DATA = births13_2 ORDER = internal; *to get adjusted RR;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = pnc5 raceth2 / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given pnc5, raceth2: adjusted";
	ESTIMATE "Reduced model E2.5 (Early care vs. no early care)" int 0 pnc5 1 / EXP;
RUN; 
TITLE; 

*E2.6 for Lab 4 from EPID 716;
PROC GENMOD DATA = births13_2 ORDER = internal; *to get adjusted RR;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = pnc5 mage2 magesq / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given pnc5, mage2, magesq: adjusted";
	ESTIMATE "Reduced model E2.6 (Early care vs. no early care)" int 0 pnc5 1 / EXP;
RUN; 
TITLE; 

*E2.7 for Lab 4 from EPID 716;
PROC GENMOD DATA = births13_2 ORDER = internal; *to get adjusted RR;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = pnc5 smoker / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given pnc5, smoker: adjusted";
	ESTIMATE "Reduced model E2.7 (Early care vs. no early care)" int 0 pnc5 1 / EXP;
RUN; 
TITLE; 

*E2.8 for Lab 4 from EPID 716;
PROC GENMOD DATA = births13_2 ORDER = internal; *to get adjusted RR;
	CLASS raceth2 (PARAM = ref REF = "White/non-Hispanic");
	MODEL preterm = pnc5 / DIST = binomial LINK = log;
	TITLE "Log risk model for preterm birth given pnc5: adjusted";
	ESTIMATE "Reduced model E2.8 (Early care vs. no early care)" int 0 pnc5 1 / EXP;
RUN; 
TITLE; 

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

*sensitivity analysis for assignment 6 in EPID 716;
*first create a trapezoidal distribution defined by a bounded zone of indifference from which we can draw;
%MACRO trap(data=, min=, mode1=, mode2=, max=, p=, seed=);
DATA &data;
		DO j = 1 TO 10000;
		p=RANUNI(&seed);
		*this code was extracted from the macro referenced in the Fox & Lash 2005 Article;
			&DATA = (p*(&max+&mode2-&min-&mode1)+(&min + &mode1))/2;
				IF &data < &mode1 THEN DO; 
					&DATA = &min+sqrt((&mode1-&min)*(2*&data-&min-&mode1));
				END;
				ELSE IF &data > &mode2 THEN DO; 
					&DATA = &max-sqrt(2*(&max-&mode2)*(&data-&mode2));
				END;
		*--------------------------------------------------------------------;
		OUTPUT;
	END;
RUN;
%MEND;

/* Use these numbers to get random values from three specified trapezoidal distributions
   I've completed the first command */
%TRAP(data = rrconf, min = 0.9, mode1 = 1.1, mode2 = 1.7, max = 1.8, seed = 65487);
/* You need to enter the parameters for the next 2 commands. DO NOT CHANGE THE SEED VALUES! */
%TRAP(data = p0, min = 0.25, mode1 = 0.28, mode2 = 0.32, max = 0.35, seed = 12398); 
%TRAP(data = p1, min = 0.55, mode1 = 0.58, mode2 = 0.62, max = 0.65, seed = 98561);

/* Need to merge the 3 datasets together */
PROC SORT DATA = rrconf;
	BY j;
RUN;
PROC SORT DATA = p0;
	BY j;
RUN;
PROC SORT DATA = p1;
	BY j;
RUN; 

DATA all; 
	MERGE rrconf p0 p1; 
	BY j; 
RUN;

*
  Additional tasks for you:
	* Describe the distributions of RRconf, p1, and p0 across the 10,000 random iterations;
PROC MEANS DATA = all N MEAN STDDEV MIN MAX MAXDEC = 10;
	VAR rrconf p1 p0;
RUN;

ODS GRAPHICS ON;
PROC UNIVARIATE DATA = all; *histograms of rrconf;
	VAR rrconf;
	HISTOGRAM / ENDPOINTS = 0.9 to 1.8 by 0.05 ;
	TITLE "Distribution of RRconf Values from Monte Carlo Simulation";
	LABEL rrconf = 'Values of RRconf';
RUN;

PROC SGPLOT DATA = all; *histograms of rrconf;
	HISTOGRAM rrconf / BINWIDTH = 0.05 BINSTART = 0.9 ;
	TITLE "Distribution of RRconf Values from Monte Carlo Simulation";
	XAXIS LABEL = "Values of RRconf" LABELATTRS = (size = 12);
	YAXIS LABEL = "Percent(%)" LABELATTRS = (size = 12);
RUN;
TITLE;


PROC UNIVARIATE DATA = all; *histograms of p1;
	VAR p1;
	HISTOGRAM / ENDPOINTS = 0.55 to 0.65 by 0.01;
	LABEL p1 = 'Values of p1';
RUN;

PROC SGPLOT DATA = all; *histograms of p1;
	HISTOGRAM p1 / BINWIDTH = 0.01 BINSTART = 0.55 ;
	TITLE "Distribution of p1 Values from Monte Carlo Simulation";
	XAXIS LABEL = "Values of p1" LABELATTRS = (size = 12);
	YAXIS LABEL = "Percent(%)" LABELATTRS = (size = 12);
RUN;
TITLE;

PROC UNIVARIATE DATA = all; *histograms of p0;
	VAR p0;
	HISTOGRAM / ENDPOINTS = 0.25 to 0.35 by 0.01;
	LABEL p0 = 'Values of p0';
RUN;

PROC SGPLOT DATA = all; *histograms of p0;
	HISTOGRAM p0 / BINWIDTH = 0.01 BINSTART = 0.25 ;
	TITLE "Distribution of p0 Values from Monte Carlo Simulation";
	XAXIS LABEL = "Values of p0" LABELATTRS = (size = 12);
	YAXIS LABEL = "Percent(%)" LABELATTRS = (size = 12);
RUN;
TITLE;

DATA all0; *Calculate adjusted RR for each of the 10,000 random combinations of RRconf, p1, and p0;
	SET all;
	rradj = (0.66315) / (((p1*(rrconf-1)+1)) / ((p0*(rrconf-1)+1)));
RUN;

PROC MEANS DATA = all0 N MEDIAN MIN MAX;
	VAR rradj;
RUN;

PROC STDIZE DATA = all0 PCTLMTD = ORD_STAT OUTSTAT = percentiles
	PCTLPTS = 2.5, 97.5;
	VAR rradj;
RUN;
PROC PRINT DATA = percentiles NOOBS; *to get the 2.5th and 97.5th percentile of dist of RRadj;
	WHERE _type_ =: 'P';
RUN;


