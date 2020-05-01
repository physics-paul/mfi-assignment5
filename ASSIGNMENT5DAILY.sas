/* PAUL SANDERS       */
/* SAS DATA WRANGLING */
/* MERGE WRANGLING    */

/********************************************/
/* IMPORT DSF_FUNDA (ANNUAL)                */
/********************************************/

PROC IMPORT datafile = "C:\Users\psanders8\Documents\SASDATASETS\ASSIGNMENT5\dsf_funda.csv" out = DSF_FUNDA dbms = csv replace;
RUN;

/********************************************/
/* WRANGLE DSF                              */
/********************************************/

libname path "C:\Users\psanders8\Documents\SASDATASETS"; /* fill with your path */

%let VARIABLES = CUSIP DATE PRC SHROUT;

DATA DSF_DAILY;
	set path.dsf(keep = &variables);
	IF 1970 <= YEAR(DATE) <= 2015;
	IF CMISS(of _all_) then DELETE;
	SHROUT = SHROUT * 1000.0;
	E = ABS(PRC) * SHROUT;
	YEAR = YEAR(DATE) + 1;
	DROP PRC SHROUT;
RUN;

PROC SORT DATA = DSF_DAILY; BY CUSIP DATE; RUN;

/********************************************/
/* MERGE DSF (DAILY) WITH DSF (ANNUAL)      */
/********************************************/

PROC SQL;
	CREATE TABLE DSF_FUNDA_ANNUAL AS
	SELECT L.CUSIP, L.YEAR, R.DATE, CUMRET, STDEV, R.E, F
	FROM DSF_FUNDA as L
	INNER JOIN DSF_DAILY as R
	ON L.CUSIP = R.CUSIP and L.YEAR = R.YEAR;
QUIT;

PROC DELETE data=DSF_DAILY;
RUN;

PROC DELETE data=DSF_FUNDA;
RUN;

PROC SORT DATA = DSF_FUNDA_ANNUAL; BY YEAR CUSIP DATE; RUN;

/********************************************/
/* EXPORT THE RESULTS                       */
/********************************************/

PROC EXPORT DATA = DSF_FUNDA_ANNUAL OUTFILE = "C:\Users\psanders8\Documents\SASDATASETS\ASSIGNMENT5\dsf_funda_annual.csv" dbms = csv replace;
RUN;
