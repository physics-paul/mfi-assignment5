This project seeks to analyze the distance to default (DD) and probability of default (PD) of publicly-traded companies for year year from 1970-2015. The goal is to see how the DD and PD change from each year to the next and how these to measures related to the overall health of the economy. This is given by various financial stress indices, such as the NBER Recession Index, Moody's BAA-Fed Fund Spread, and the Cleveland Financial Stress Index. 

In calculating the DD and PD, there are three main methods, with each method being more accurate and more complex. The three methods are the naive, the direct, and the iterative method, which will be explained in more detail.

Thus, this task is divided into six parts: 

1. Downloading the Data
2. Calculating the DD and PD with the Naive Method
3. Calculating the DD and PD with the Direct Method
4. Calculating the DD and PD with the Indirect Method
5. Comparison of the Methods
6. Comparison with Financial Stress Indices

### 1. Downloading the Data

There were a few main sources of data used for this project:
  
a. DSF : The daily stock returns and volume, along with shares outstanding, were obtained by analyzing the DSF SAS file which was obtained through the QCF server. This data file had company information in the form of the CUSIP number and was used to obtain the share price, the return from the previous year, number of shares, and the volatility of the firm's equity value.

b. FUNDA : This company-specific data information file contained information on the outstanding debt held by each company and the link between CUSIP and the CIK number. This was used with DSF in order to calculate the distance to default. 
  
c. DAILYFED : This dataset contained the 3-month treasury bond yield, which was used as the risk-free interest rate, This risk-free rate was then used in methods 2 and 3 to calculate the distance to default.
  
d. NBER Recession Data : This information regarding recessions contains two values: 0 to indicate an expansionary period, and 1 to indicate a recessionary period. The link is here: [NBER Recession Data](https://research.stlouisfed.org/fred2/series/USREC).

e. Moody's BAA-Fed Fund Spread : This data file contains the spread between BAA Corporate Bond yields and the Fed Funds rate. When in a recessionary period, this spread tends to be high, because the BAA Corporate Bond yields are closely linked to the probability of default for firms in this same riskiness level. The link is here: [Moody's BAA-Fed Fund Spread](https://fred.stlouisfed.org/series/BAAFFM).

f. Cleveland Financial Stress Index : This dataset is similarly a gauge of the financial stress in the US financial system, with a high score indicating significant stress, and a low score indicates a low-stress period. However, it needs to be takes with a degree of cautions, because as the authors note themselves, the calculation of this index contains errors. The link is here: [Cleveland Financial Stress Index](https://fred.stlouisfed.org/series/CFSI).

In actually scraping and extracting the data, the SAS Software was used in order to prepare the data. SAS was necessary in order to deal with the sheer size of the DSF and FUNDA dataset would make it infeasable for direct analysis in the R Statistical Package.

### Calculating the DD and the PD with the Naive Method

The naive method calculates the distance to default (DD) as:

<p align="center">
  <img src="https://raw.githubusercontent.com/physics-paul/mfi-assignment5/master/calculationsNaive.png">
</p>

where

<p align="center">
  <img src="https://raw.githubusercontent.com/physics-paul/mfi-assignment5/master/calculationsNaive2.png">
</p>




This task sought to look at the CIK and filing date pair from the previous section to determine the cumulative abnormal return (CAR) and cumulative abnormal volume (CAV) for each CIK/filing date pair. The abnormal return (AR) is defined as the return in excess of the CAPM market return, regressed from -315 to -91 days from the event or filing date. The 'cumulative' part of the definition arises from summing the rolling window of abnormal returns around the event date. For instance, the three-day window consists of the day prior to the event date, the event date, and the day after the event date. The one-day, three-day, and five-day rolling window was calculated for both CAR and CAV.

We can define the CAV as the normalized trading volume, calibrated to -71 to -11 days before the event date and taken on a log scale. For clarification, suppose the range of -71 to -11 days was not quite a volatile range of trading, while the cumulative three-day rolling window around the event date was very volatile, then the CAV would be a large number, scaled by a standard deviation or more from the mean of the past -71 to -11 day rolling window.

The table below shows the descriptive statistics for the CAR and CAV rolling windows over the sample period 1995:2018.

| --- | CAR(1)  | CAR(3) | CAR(5) | CAV(1) | CAV(3) | CAV (5) |
| Mean | -0.001508 |	-0.002782	| -0.003579 |	0.526526	| 1.206844	| 1.863234 | 
|Standard Deviation	|0.061269 |	0.096360 |	0.124626 |	1.513595 |	3.473083 |	6.329492 |
| Minimum |	-0.732448 |	-0.807893	| -0.934338 |	-8.344340	| -19.990874	| -27.465825 |
|25%	|-0.018018 |	-0.029812	| -0.043501	| -0.423825	| -1.007499 | -2.104361 |
|50%	|-0.000766 |	-0.001695	| -0.002122	| 0.387644	| 0.844627 |	1.365758 |
|75%	|0.014817	| 0.024814 |	0.035890 |	1.236411	| 2.974241	| 5.078070 |
| Maximum |	1.105913 | 1.936429 |	1.787982 |	12.774111 |	23.541118	| 42.558456|

Additionally we can plot the distribution of both measures, given first by the cumulative abnormal return (CAR):

<p align="center">
  <img width="400" height="300" src="https://raw.githubusercontent.com/physics-paul/mfi-assignment8/master/part2car.png">
</p>

Notice what this might be saying: from 1995-2018, the CAR trends slightly upward and is definitely non-zero, meaning the returns experienced over the event date are slightly different than what the CAPM model would suggest. However, considering the mean is roughly zero, this indicates the CAPM does a fairly good job at predicting returns.

For the cumulative abnormal volume, the distribution is given by:

<p align="center">
  <img width="400" height="300" src="https://raw.githubusercontent.com/physics-paul/mfi-assignment8/master/part2cav.png">
</p>

Notice here one interesting tidbit, is the CAV has a slight trend upwards, possibly indicating the volatility in the future is greater than the past would predict.

This Python script can be seen in the GitHub pages as 'eventStudies.py'. Be cautioned though, this code takes around ~1hr to run, because of the intensive process in calculating the CAV and CAR for each event study. 

This code produces the final 'sentimentAnalysisAndEventStudies.csv' data file to obtain all information for each event study.

### Rudimentary Sentiment Analysis

The main task for this section was to compute the abnormal stock returns and abnormal trading volume around 8-K filings, and study how these measure vary depending on the number of positive and negative words included in the filing.

In obtaining the positivity and negativity of the document, these results can be sorted into quintiles. If we calculate the descriptive statistics for the CAR and CAV in the highest vs. lowest percentile, we obtain the following charts:

CAR(0) plotted with the upper and lower quintiles:

<p align="center">
  <img width="400" height="300" src="https://raw.githubusercontent.com/physics-paul/mfi-assignment8/master/part3car0.png">
</p>

CAR(5) plotted with the upper and lower quintiles:

<p align="center">
  <img width="400" height="300" src="https://raw.githubusercontent.com/physics-paul/mfi-assignment8/master/part3car5.png">
</p>

CAV(0) plotted with the upper and lower qunitiles:

<p align="center">
  <img width="400" height="300" src="https://raw.githubusercontent.com/physics-paul/mfi-assignment8/master/part3cav0.png">
</p>

CAV(5) plotted with the upper and lower quintiles:

<p align="center">
  <img width="400" height="300" src="https://raw.githubusercontent.com/physics-paul/mfi-assignment8/master/part3cav5.png">
</p>

These results are very interesting! It seems the sentiment of the 8-K from this rudimentary analysis doesn't capture the overall effect of CAR and CAV, because it is hard to see any trend. The upper and lower quintiles seems to follow the same general pattern, except for a few exceptions or so. The one noticeable difference is in the CAR(0) upper quintile around 2001. This may simply be due to some noise, but it is remarkably higher in this time period. Could this be some effect due to the 'dot com' bubble burst of 2000? It is not clear, as an analysis of the more robust sentiment analysis could give more insight.

This Python script can be seen in the GitHub pages as 'sentimentAnalysis.py', and is combined with the section below.

### Advanced Sentiment Analysis

In this section, a more thorough analysis of the 'tone' of the 8-K is performed by looking at the tonality of each sentence in the document, rather than merely counting positive and negative words. The natural language toolkit provided by the 'NLTK' module in Python was an excellent resource to complete this task.

The first thing to notice in this section is difficult in cleaning up an html file. Even with the best tools, it can sill be an imprecise tool. However, how I went about this task was to clean the html string in a series of steps:

1. Use the 'BeautifulSoup' module to remove all white spaces in the document and only extract the body of the html file.
2. Use the 'RegexpTokenAnalyzer' function in the NLTK toolkit to grab only words and words which ended with a standard sentence ending (.!?).
3. Use the 'sent_tokenize' function in the NLTK toolkit to split the string into sentences.
4. Assign a tonality to each sentence by the ' ' function in the NLTK toolkit to analyze the tonality of each sentence.
5. Sum up the overall tonality and divide by the total number of sentences to grab the offical 'tone' of the 8-K.

After this, it was relatively easy to sort the 8-K documents into quintiles and generate the descriptive statistics for the upper and lower quintile. Specifically, when calculating the mean, the result is:

CAR(0) plotted with the upper and lower quintiles:

<p align="center">
  <img width="400" height="300" src="https://raw.githubusercontent.com/physics-paul/mfi-assignment8/master/part4car0.png">
</p>

CAR(5) plotted with the upper and lower quintiles:

<p align="center">
  <img width="400" height="300" src="https://raw.githubusercontent.com/physics-paul/mfi-assignment8/master/part4car5.png">
</p>

CAV(0) plotted with the upper and lower qunitiles:

<p align="center">
  <img width="400" height="300" src="https://raw.githubusercontent.com/physics-paul/mfi-assignment8/master/part4cav0.png">
</p>

CAV(5) plotted with the upper and lower quintiles:

<p align="center">
  <img width="400" height="300" src="https://raw.githubusercontent.com/physics-paul/mfi-assignment8/master/part4cav5.png">
</p>

The results seem a little underwhelming. By and large it seems the sentiment of the 8-K plays little role in actually generating abnormal returns, except for a few years. However, it is hard to tell which years these will be, as some years the lower quintile has a larger abnormal return, and some years the upper quintile has the larger abnormal return.

Some descriptive statistics are given in the following table for the five-day rolling window:

| --- | CAR(5) Upper | CAR(5) Lower | CAV(5) Upper | CAV(5) Lower | 
| Mean | 0.00460 |	-0.00407	| 1.6278 |	1.9775	| 
|Standard Deviation	| 0.10961 |	0.12776 |	5.90024 | 6.9308 |

This chart highlights what was seen in the plots above. There is a slight advantage to a more positive tone to the 8-K, by almost 1%. However, by looking at the time series data, it is hard to discern when this will happen. All which can be said is, on average, there is a slight advantage to a more positive tone in the 8-K. So talk positive!

This Python script can be seen in the GitHub pages as 'sentimentAnalysis.py'. Be cautioned though, this code takes around ~1hr to run, due to the time-intensive process of analyzing each 8-K.

This code produces the 'sentimentAnalysis.csv' data file, which is used by the 'eventStudies.py' script in order to obtain the final output.

