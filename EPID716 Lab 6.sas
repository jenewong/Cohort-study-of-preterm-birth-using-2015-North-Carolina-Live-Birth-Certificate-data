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



	

