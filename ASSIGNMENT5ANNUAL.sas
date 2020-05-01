/* PAUL SANDERS       */
/* SAS DATA WRANGLING */
/* MERGE WRANGLING    */

/********************************************/
/* WRANGLE FUNDA                            */
/********************************************/

libname path "C:\Users\psanders8\Documents\SASDATASETS"; /* fill with your path */

%let VARIABLES = INDFMT DATAFMT POPSRC CONSOL FYEAR CUSIP DLC DLTT; 

DATA FUNDA_WRANGLED;
	set path.FUNDA(keep = &variables);
	if INDFMT = 'INDL' and DATAFMT = 'STD' and POPSRC = 'D' and CONSOL = 'C';
	if 1970 <= FYEAR <= 2015;
	RENAME FYEAR = YEAR;
	CUSIP = SUBSTRN(CUSIP,1,8);
	if CMISS(of _all_) THEN DELETE;
	DLC = DLC*1000000;
	DLTT = DLTT*1000000;
	F = DLC + 0.5*DLTT;
	DROP INDFMT DATAFMT POPSRC CONSOL DLC DLTT;
RUN;

/********************************************/
/* WRANGLE DSF CONVERT FROM DAILY TO ANNUAL */
/********************************************/

libname path "C:\Users\psanders8\Documents\SASDATASETS"; /* fill with your path */

%let VARIABLES = CUSIP DATE PRC RET SHROUT;

DATA DSF_DAILY;
	set path.dsf(keep = &variables);
	YEAR = YEAR(DATE);
	IF 1970 <= YEAR <= 2015;
	IF CMISS(of _all_) then DELETE;
	SHROUT = SHROUT * 1000.0;
	E = ABS(PRC) * SHROUT;
	DROP PRC SHROUT;
RUN;

PROC SORT DATA = DSF_DAILY; BY CUSIP DATE; RUN;

PROC SQL;
	CREATE TABLE DSF_ANNUAL AS
	SELECT CUSIP, YEAR,
		MAX(DATE) as LASTDATE format = mmddyy10.,
		EXP(sum(LOG(1.0+RET))) as CUMRET,
		std(RET)*sqrt(250) as STDEV
	FROM DSF_DAILY
	GROUP BY CUSIP, YEAR;
QUIT;

PROC SQL;
	CREATE TABLE DSF_WRANGLED AS
	SELECT L.CUSIP, 
		YEAR(R.DATE) as YEAR, 
		CUMRET, STDEV, E  
	FROM DSF_ANNUAL as L
	INNER JOIN DSF_DAILY as R
	ON L.CUSIP = R.CUSIP and L.LASTDATE = R.DATE;
QUIT;

PROC DELETE data=DSF_ANNUAL;
RUN;

/********************************************/
/* MERGE FUNDA WITH DSF (ANNUAL)            */
/********************************************/

PROC SQL;
	CREATE TABLE DSF_FUNDA AS
	SELECT L.CUSIP, L.YEAR + 1 as YEAR, CUMRET, STDEV, E, F
	FROM DSF_WRANGLED as L
	INNER JOIN FUNDA_WRANGLED as R
	ON L.CUSIP = R.CUSIP and L.YEAR = R.YEAR;
QUIT;

PROC DELETE data=DSF_WRANGLED;
RUN;

PROC DELETE data=FUNDA_WRANGLED;
RUN;

PROC SORT DATA = DSF_FUNDA; BY YEAR CUSIP; RUN;

/********************************************/
/* GRAB 200 RANDOM SAMPLES FROM EACH YEAR   */
/********************************************/

PROC surveyselect data=DSF_FUNDA method=SRS n=200
			seed=1975 OUT=DSF_FUNDA_SAMPLED;
		strata YEAR;
RUN;

%let VARIABLES = YEAR CUSIP CUMRET STDEV E F;

/********************************************/
/* EXPORT THE RESULTS                       */
/********************************************/

PROC EXPORT DATA = DSF_FUNDA_SAMPLED(DROP = SelectionProb SamplingWeight) OUTFILE = "C:\Users\psanders8\Documents\SASDATASETS\ASSIGNMENT5\dsf_funda.csv" dbms = csv replace;
RUN;
