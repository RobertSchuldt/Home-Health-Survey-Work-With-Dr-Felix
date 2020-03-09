/* Home Healthcare Survey Data for work with Dr. Holly Felix

This study is comparing surveys in PA and AR to investigate practice patterns between the two 
states. We will be looking at survey responses and possible inclusion of data from the Home Health
Compare Files for quality measures.

Program: Robert Schuldt
Email: rschuldt@uams.edu

January 2020

******************************************************************************************************
*****************************************************************************************************/
/*Pathway for libraries*/

%let path = C:\Users\3043340\Box\Home Health Survey Felix\Original;

/*Import my sorting program*/
%include "D:\SAS Macros\infile macros\sort.sas";

/*create library*/
libname felix "&path";

/*Pull in the Arkansas HHA*/
proc import datafile = "&path\HHA Responses_Final_Quant.xlsx"
dbms = XLSX out = ar_hha replace;
run;

/*Pull in PA HHA. This data ste is a bit messier. I need to import and then merge
by the survey ID in order to get ownership type*/
proc import datafile = "&path\PA HHA response database.xlsx"
dbms = XLSX out = pa_hha replace;
run;

proc import datafile = "&path\PA Home Health Agencies2.xlsx"
dbms = XLSX out = pa_hha_2 replace;
run;

%sort(pa_hha, SID)
%sort(pa_hha_2, SID)

data pa_hha_survey;
	merge pa_hha (in = a) pa_hha_2 (in = b);
	by SID;
	if a;
	if b;
run;

/* Now grab the changed file that I made where I adjusted the base files so they are hopefully comparable
this took quite a bit of time because these are two very different looking files*/

proc import datafile = "C:\Users\3043340\Box\Home Health Survey Felix\PA AR Surveys Manual.xlsx"
dbms = XLSX out = hha_clean replace;
run;

/* Check to see the ownership types that we have in the file*/

proc freq data = hha_clean;
title 'Types of Ownership';
table Ownership;
run;

data hha_ownership;
	set hha_clean;
	ProviderName = upcase(name);
	if Ownership in ("State/County" , "Local") then gov = 1;
		else gov = 0;

	if Ownership in ("Proprietary") then for_profit = 1;
		else for_profit = 0;

	if Ownership in ( "Religious Affiliations", "Private" , "Other") then nfp = 1;
		else nfp = 0; 


	if Q1 ne . then response = 1  ;
		else response = 0;
run; 

proc freq data = hha_ownership;
title 'Reponse Rate by Ownership';
table (gov for_profit nfp)*response response;
run;

proc import datafile = 'C:\Users\3043340\Box\Home Health Survey Felix\2012 hosp.csv'
dbms = csv out = hosp_12 replace;
proc import datafile = 'C:\Users\3043340\Box\Home Health Survey Felix\2012 other.csv'
dbms = csv out = other_12 replace;
run;

%sort(hosp_12, ProviderNum)
%sort(other_12, ProviderNum)

data quality;
merge other_12 (in = a) hosp_12 (in = b);
by ProviderNum;
if a; if b; 
if State not in ("AR" ,"PA") then delete;
run;

%sort(hha_ownership, ProviderName)
%sort(quality, ProviderName)

data survey_quality;
	merge hha_ownership (in = a) quality (in = b);
	by ProviderName;
	if a; 
run;
proc export data = survey_quality
outfile = 'C:\Users\3043340\Box\Home Health Survey Felix\Survey Quality.dta'
dbms = dta 
replace;
run;

data check_match;
	set survey_quality;
		if Nursing_Care = "Y" then check = 1;
			else check = 0;
		run;
proc freq data = check_match;
	table response*check;
	run;

data check_missing;
	set check_match;
	where response = 1 and check = 0;
	run;

