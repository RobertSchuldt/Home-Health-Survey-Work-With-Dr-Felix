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

%let path = C:\Users\3043340\Box\Home Health Survey Felix;

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

proc import datafile = "&path\PA HHA response database 2.xlsx"
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


proc freq; 
table 







