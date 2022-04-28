



********************************************************************************
**# Various Measures
********************************************************************************

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"

*** Income measure for housing demand measure


cd $data\ipums_micro
u 1990_2000_2010_temp , clear

drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork==0
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

g wage_real=inctot_real/(52*40)

g inc_mean1990=inctot_real if year==1990
g inc_mean2000=inctot_real if year==2000
g inc_mean2010=inctot_real if year==2010

g wage_real1990=wage_real if year==1990
g wage_real2000=wage_real if year==2000
g wage_real2010=wage_real if year==2010

bysort occ2010 year: egen count=count(perwt) 

g count1990=count if year==1990
g count2000=count if year==2000
g count2010=count if year==2010

collapse (mean) count1990 count2000 count2010 inc_mean1990 inc_mean2000 inc_mean2010 wage_real1990 wage_real2000 wage_real2010  [w=perwt], by(occ2010)
cd $data\temp_files
save inc_occ_1990_2000_2010, replace


*** Occupation METAREA count


cd $data\ipums_micro
u 1990_2000_2010_temp , clear

drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork<30
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

bysort metarea occ2010 year: egen count=total(perwt) 

g count1990=count if year==1990
g count2000=count if year==2000
g count2010=count if year==2010

collapse (mean) count1990 count2000 count2010 [w=perwt], by(metarea occ2010)

cd $data\temp_files

save count_metarea, replace
******************************

cd $data\ipums_micro
u 1990_2000_2010_temp , clear

drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork<30
keep if age>=25 & age<=65
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999


g count1990=perwt if year==1990
g count2000=perwt if year==2000
g count2010=perwt if year==2010

collapse (count) count1990 count2010, by(occ2010)

replace count1990=. if count1990==0
replace count2010=. if count2010==0

cd $data\temp_files

save occ2010_count, replace


****************************
cd $data\ipums_micro
u 1990_2000_2010_temp , clear

drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

keep if sex==1
drop if uhrswork<30
keep if age>=25 & age<=65
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999


g count1990=perwt if year==1990
g count2000=perwt if year==2000
g count2010=perwt if year==2010

collapse (count) count1990 count2010, by(occ2010)

replace count1990=. if count1990==0
replace count2010=. if count2010==0

cd $data\temp_files

save occ2010_count_male, replace

*******************
*** Welfare calculate earnings level


*** compute log wage for every state
cd $data\ipums_micro
u 1990_2000_2010_temp, clear

keep if uhrswork>=30

keep if year==1990 | year==2010

drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork==0
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

replace inctot_real=inctot_real/52
replace inctot_real=ln(inctot_real)

collapse inctot_real (count) count=inctot_real, by(occ2010 year)

reshape wide inctot_real count, i(occ2010) j(year)

drop if inctot_real1990==.
drop if inctot_real2010==.
drop count*

cd $data\temp_files
save val_time_weekly_earnings_total, replace



********************************************************************************
**# Data Prep Long Hour Premium
********************************************************************************

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"

cd $data\ipums_micro

u 1990_2000_2010_temp, clear

drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork<40
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

replace inctot_real=inctot_real/52

replace inctot_real=ln(inctot_real)
drop occ met2013 city puma rentgrs valueh bpl occsoc incwage puma1990 greaterthan40 datanum serial pernum rank ind ind2000 hhwt statefip marst inctot occ1990

g val_2010=.
g se_2010=.
g val_2000=.
g se_2000=.
g val_1990=.
g se_1990=.
g dval=.
g se_dval=.
g hours1990=0
g hours2000=0
g hours2010=0
replace hours1990=uhrswork if year==1990
replace hours2000=uhrswork if year==2000
replace hours2010=uhrswork if year==2010

# delimit
foreach num of numlist 
30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3710 3740 3800 3820 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520
5540 5550 5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;
# delimit cr
display `num'
qui reghdfe inctot_real hours1990 hours2000 hours2010 if occ2010==`num' & uhrswork>=40 & uhrswork<=60 [w=perwt], absorb(i.age#i.year i.sex#i.year i.educ#i.year i.race#i.year i.hispan#i.year i.ind1990#i.year) cluster(metarea)
replace val_1990=_b[hours1990] if occ2010==`num'
replace se_1990=_se[hours1990] if occ2010==`num'
replace val_2000=_b[hours2000] if occ2010==`num'
replace se_2000=_se[hours2000] if occ2010==`num'
replace val_2010=_b[hours2010] if occ2010==`num'
replace se_2010=_se[hours2010] if occ2010==`num'
}

collapse (firstnm) val_1990 se_1990 val_2000 se_2000 val_2010 se_2010, by(occ2010)


cd $data\temp_files

save val_40_60_total_1990_2000_2010, replace

********************************************************************************
**# Data Prep Job Distribution
********************************************************************************


clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"

***
* generate occupation share per industry by year using the IPUMS microdata
cd $data\ipums_micro
use 1990_2000_2010_temp, clear

cd $data\temp_files

collapse (sum) pop=perwt, by(year ind1990 occ2010)
save ind1990_2010, replace
collapse (sum) pop_ind1990=pop, by(year ind1990)
merge 1:m year ind1990 using ind1990_2010
drop _merge
drop if ind1990==0
g occ_share=pop/pop_ind1990
drop pop pop_ind1990
sort year ind1990 occ2010
save occ_share_perind, replace

u occ_share_perind, clear
keep if year==1990
save occ_share_perind1990, replace

u occ_share_perind, clear
keep if year==2000
save occ_share_perind2000, replace

u occ_share_perind, clear
keep if year==2010
save occ_share_perind2010, replace


***
******************************************
******************************************
** decompose the cic-NAICS crosswalk

cd $data\zbp
import excel cic1990_naics97.xlsx, sheet("Sheet1") firstrow clear
tostring NAICS, g(naics)
unique naics
duplicates tag naics, g(tag)
drop if tag>=1
drop NAICS

destring Census, g(ind1990)
ren Census2000CategoryTitle naics_descr
keep ind1990 naics  naics_descr
g digit=length(naics)

cd $data\temp_files
save cic1990_naics97, replace

u cic1990_naics97, clear
keep if digit==6
save cic1990_naics97_6digit, replace

u cic1990_naics97, clear
keep if digit==5
ren naics naics5
save cic1990_naics97_5digit, replace

u cic1990_naics97, clear
keep if digit==4
ren naics naics4
save cic1990_naics97_4digit, replace

u cic1990_naics97, clear
keep if digit==3
ren naics naics3
save cic1990_naics97_3digit, replace

u cic1990_naics97, clear
keep if digit==2
ren naics naics2
save cic1990_naics97_2digit, replace

******************************************
******************************************
** decompose the cic-sic crosswalk

cd $data\zbp
import excel cic_sic_crosswalk.xlsx, sheet("Sheet1") firstrow allstring clear
destring cic_code, g(ind1990)
drop cic_code

g digit=length(sic)

cd $data\temp_files
save cic_sic_crosswalk, replace

u cic_sic_crosswalk, clear
keep if digit==4
ren sic sic4
drop digit
save cic_sic_crosswalk4digit, replace

u cic_sic_crosswalk, clear
keep if digit==3
ren sic sic3
drop digit
save cic_sic_crosswalk3digit, replace

u cic_sic_crosswalk, clear
keep if digit==2
ren sic sic2
drop digit
save cic_sic_crosswalk2digit, replace




cd $data\zbp
u zip94detail, clear

g n1_4_num=2.5*n1_4
g n5_9_num=7*n5_9
g n10_19_num=14.5*n10_19
g n20_49_num=34.5*n20_49
g n50_99_num=74.5*n50_99
g n100_249_num=174.5*n100_249
g n250_499_num=374.5*n250_499
g n500_999_num=749.5*n500_999
g n1000_num=1500*n1000
g est_num=n1_4_num+n5_9_num+n10_19_num+n20_49_num+n50_99_num+n100_249_num+n250_499_num+n500_999_num+n1000_num


g lastdigit=substr(sic,4,1)
drop if lastdigit=="-"
drop if lastdigit=="\"

g sic4=sic

cd $data\temp_files
merge m:1 sic4 using cic_sic_crosswalk4digit
ren _merge _merge_4digit
ren ind1990 ind1990_4digit

g sic3=substr(sic,1,3)
merge m:1 sic3 using cic_sic_crosswalk3digit
ren _merge _merge_3digit
ren ind1990 ind1990_3digit

g sic2=substr(sic,1,2)
merge m:1 sic2 using cic_sic_crosswalk2digit
ren _merge _merge_2digit
ren ind1990 ind1990_2digit

g ind1990=ind1990_2digit if _merge_2digit==3
replace ind1990=ind1990_3digit if _merge_3digit==3
replace ind1990=ind1990_4digit if _merge_4digit==3

drop _merge_2digit ind1990_2digit sic2 _merge_3digit ind1990_3digit sic3 _merge_4digit ind1990_4digit sic4 lastdigit
drop if ind1990==.
drop if zip==.

collapse (sum) est_num, by(zip ind1990)

cd $data\temp_files
save temp, replace

cd $data\temp_files
u temp, clear
keep if zip<20000
joinby ind1990 using occ_share_perind1990
replace est_num=est_num*occ_share
collapse (sum) est_num, by(zip occ2010)
save temp0_20000, replace

u temp, clear
keep if zip>=20000 & zip<40000
joinby ind1990 using occ_share_perind1990
replace est_num=est_num*occ_share
collapse (sum) est_num, by(zip occ2010)
save temp20000_40000, replace

u temp, clear
keep if zip>=40000 & zip<60000
joinby ind1990 using occ_share_perind1990
replace est_num=est_num*occ_share
collapse (sum) est_num, by(zip occ2010)
save temp40000_60000, replace

u temp, clear
keep if zip>=60000 & zip<80000
joinby ind1990 using occ_share_perind1990
replace est_num=est_num*occ_share
collapse (sum) est_num, by(zip occ2010)
save temp60000_80000, replace

u temp, clear
keep if zip>=80000 & zip<100000
joinby ind1990 using occ_share_perind1990
replace est_num=est_num*occ_share
collapse (sum) est_num, by(zip occ2010)
save temp80000_100000, replace

clear all
append using temp0_20000
append using temp20000_40000
append using temp40000_60000
append using temp60000_80000
append using temp80000_100000
*g year=1990

save occ_emp_1994, replace



***2000
cd $data\zbp
u zip00detail, clear

g n1_4_num=2.5*n1_4
g n5_9_num=7*n5_9
g n10_19_num=14.5*n10_19
g n20_49_num=34.5*n20_49
g n50_99_num=74.5*n50_99
g n100_249_num=174.5*n100_249
g n250_499_num=374.5*n250_499
g n500_999_num=749.5*n500_999
g n1000_num=1500*n1000
g est_num=n1_4_num+n5_9_num+n10_19_num+n20_49_num+n50_99_num+n100_249_num+n250_499_num+n500_999_num+n1000_num

g lastdigit=substr(naics,6,1)
drop if lastdigit=="-"
drop lastdigit

sort naics
cd $data\temp_files
merge m:1 naics using cic1990_naics97_6digit
ren _merge _merge_6digit
ren ind1990 ind1990_6digit
drop digit naics_descr

g naics5=substr(naics,1,5)
merge m:1 naics5 using cic1990_naics97_5digit
ren ind1990 ind1990_5digit
drop naics5 digit naics_descr
ren _merge _merge_5digit

g naics4=substr(naics,1,4)
merge m:1 naics4 using cic1990_naics97_4digit
ren ind1990 ind1990_4digit
drop naics4 digit naics_descr
ren _merge _merge_4digit

g naics3=substr(naics,1,3)
merge m:1 naics3 using cic1990_naics97_3digit
ren ind1990 ind1990_3digit
drop naics3 digit naics_descr
ren _merge _merge_3digit

g naics2=substr(naics,1,2)
merge m:1 naics2 using cic1990_naics97_2digit
ren ind1990 ind1990_2digit
drop naics2 digit naics_descr
ren _merge _merge_2digit

g ind1990=ind1990_2digit if _merge_2digit==3
replace ind1990=ind1990_3digit if _merge_3digit==3
replace ind1990=ind1990_4digit if _merge_4digit==3
replace ind1990=ind1990_5digit if _merge_5digit==3
replace ind1990=ind1990_6digit if _merge_6digit==3

drop ind1990_6digit _merge_6digit ind1990_5digit _merge_5digit ind1990_4digit _merge_4digit ind1990_3digit _merge_3digit ind1990_2digit _merge_2digit

drop if ind1990==.
drop if zip==.

collapse (sum) est_num, by(zip ind1990)
save temp, replace

u temp, clear
keep if zip<20000
joinby ind1990 using occ_share_perind2000
replace est_num=est_num*occ_share
collapse (sum) est_num, by(zip occ2010)
save temp0_20000, replace

u temp, clear
keep if zip>=20000 & zip<40000
joinby ind1990 using occ_share_perind2000
replace est_num=est_num*occ_share
collapse (sum) est_num, by(zip occ2010)
save temp20000_40000, replace

u temp, clear
keep if zip>=40000 & zip<60000
joinby ind1990 using occ_share_perind2000
replace est_num=est_num*occ_share
collapse (sum) est_num, by(zip occ2010)
save temp40000_60000, replace

u temp, clear
keep if zip>=60000 & zip<80000
joinby ind1990 using occ_share_perind2000
replace est_num=est_num*occ_share
collapse (sum) est_num, by(zip occ2010)
save temp60000_80000, replace

u temp, clear
keep if zip>=80000 & zip<100000
joinby ind1990 using occ_share_perind2000
replace est_num=est_num*occ_share
collapse (sum) est_num, by(zip occ2010)
save temp80000_100000, replace

clear all
append using temp0_20000
append using temp20000_40000
append using temp40000_60000
append using temp60000_80000
append using temp80000_100000
g year=2000
save occ_emp_2000, replace

***2010
cd $data\zbp
u zip10detail, clear

g n1_4_num=2.5*n1_4
g n5_9_num=7*n5_9
g n10_19_num=14.5*n10_19
g n20_49_num=34.5*n20_49
g n50_99_num=74.5*n50_99
g n100_249_num=174.5*n100_249
g n250_499_num=374.5*n250_499
g n500_999_num=749.5*n500_999
g n1000_num=1500*n1000
g est_num=n1_4_num+n5_9_num+n10_19_num+n20_49_num+n50_99_num+n100_249_num+n250_499_num+n500_999_num+n1000_num

g lastdigit=substr(naics,6,1)
drop if lastdigit=="-"
drop lastdigit

sort naics
cd $data\temp_files
merge m:1 naics using cic1990_naics97_6digit
ren _merge _merge_6digit
ren ind1990 ind1990_6digit
drop digit naics_descr

g naics5=substr(naics,1,5)
merge m:1 naics5 using cic1990_naics97_5digit
ren ind1990 ind1990_5digit
drop naics5 digit naics_descr
ren _merge _merge_5digit

g naics4=substr(naics,1,4)
merge m:1 naics4 using cic1990_naics97_4digit
ren ind1990 ind1990_4digit
drop naics4 digit naics_descr
ren _merge _merge_4digit

g naics3=substr(naics,1,3)
merge m:1 naics3 using cic1990_naics97_3digit
ren ind1990 ind1990_3digit
drop naics3 digit naics_descr
ren _merge _merge_3digit

g naics2=substr(naics,1,2)
merge m:1 naics2 using cic1990_naics97_2digit
ren ind1990 ind1990_2digit
drop naics2 digit naics_descr
ren _merge _merge_2digit

g ind1990=ind1990_2digit if _merge_2digit==3
replace ind1990=ind1990_3digit if _merge_3digit==3
replace ind1990=ind1990_4digit if _merge_4digit==3
replace ind1990=ind1990_5digit if _merge_5digit==3
replace ind1990=ind1990_6digit if _merge_6digit==3

drop ind1990_6digit _merge_6digit ind1990_5digit _merge_5digit ind1990_4digit _merge_4digit ind1990_3digit _merge_3digit ind1990_2digit _merge_2digit

drop if ind1990==.
drop if zip==.

collapse (sum) est_num, by(zip ind1990)
save temp, replace

u temp, clear
keep if zip<20000
joinby ind1990 using occ_share_perind2010
replace est_num=est_num*occ_share
collapse (sum) est_num, by(zip occ2010)
save temp0_20000, replace

u temp, clear
keep if zip>=20000 & zip<40000
joinby ind1990 using occ_share_perind2010
replace est_num=est_num*occ_share
collapse (sum) est_num, by(zip occ2010)
save temp20000_40000, replace

u temp, clear
keep if zip>=40000 & zip<60000
joinby ind1990 using occ_share_perind2010
replace est_num=est_num*occ_share
collapse (sum) est_num, by(zip occ2010)
save temp40000_60000, replace

u temp, clear
keep if zip>=60000 & zip<80000
joinby ind1990 using occ_share_perind2010
replace est_num=est_num*occ_share
collapse (sum) est_num, by(zip occ2010)
save temp60000_80000, replace

u temp, clear
keep if zip>=80000 & zip<100000
joinby ind1990 using occ_share_perind2010
replace est_num=est_num*occ_share
collapse (sum) est_num, by(zip occ2010)
save temp80000_100000, replace

clear all
append using temp0_20000
append using temp20000_40000
append using temp40000_60000
append using temp60000_80000
append using temp80000_100000
g year=2010
save occ_emp_2010, replace


*******************************************


*** generate zip level employment share among its respective METAREA
cd $data\temp_files
u occ_emp_1994, clear

cd $data\geographic
merge m:1 zip using zip1990_metarea
keep if _merge==3
drop _merge
cd $data\temp_files
save temp, replace

collapse (sum) est_num_total=est_num, by(occ2010 metarea)

merge 1:m occ2010 metarea using temp
drop _merge
g share=est_num/est_num_total
keep share zip occ2010 metarea

save occ_emp_share_1994, replace

**2000
cd $data\temp_files
u occ_emp_2000, clear

cd $data\geographic
merge m:1 zip using zip2000_metarea
keep if _merge==3
drop _merge
cd $data\temp_files
save temp, replace

collapse (sum) est_num_total=est_num, by(occ2010 metarea)

merge 1:m occ2010 metarea using temp
drop _merge
g share=est_num/est_num_total
keep share zip occ2010 metarea

save occ_emp_share_2000, replace

** 2010
cd $data\temp_files
u occ_emp_2010, clear

cd $data\geographic
merge m:1 zip using zip2010_metarea
keep if _merge==3
drop _merge
cd $data\temp_files
save temp, replace

collapse (sum) est_num_total=est_num, by(occ2010 metarea)

merge 1:m occ2010 metarea using temp
drop _merge
g share=est_num/est_num_total
keep share zip occ2010 metarea

save occ_emp_share_2010, replace

********************************************************************************
**# Data Prep Impute Travel Time
********************************************************************************

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"

** NHTS data 1995
cd $data\travel

u nhts, clear

*** Automobile
keep if TRPTRANS>=1 & TRPTRANS<=5

** Monday - Friday
keep if TRAVDAY>=2 & TRAVDAY<=6
** To and from home
keep if WHYTO==17 | WHYFROM==17
** Miles per hour
replace TRPMILES=. if TRPMILES>=9000
replace TRVL_MIN=. if TRVL_MIN>=9000
g speed=TRPMILES/(TRVL_MIN/60)

g log_distance=ln(TRPMILES)

g log_speed=ln(speed)

g log_time=ln(TRVL_MIN/60)

*** Population density
replace HTPPOPDN=. if HTPPOPDN>90000
g pop_den=HTPPOPDN

** unit density
replace HTHRESDN=. if HTHRESDN>7000
g unit_den=HTHRESDN

** median income 
replace HTHINMED=. if HTHINMED>100000
g inc=HTHINMED
** Percentage of working pop
replace HTINDRET=. if HTINDRET>100
g working=HTINDRET
** log distance squared
g log_distance2=log_distance^2
*** create MSA dummy
g metarea_d=998

replace HHMSA=HHMSA/10
# delimit
foreach num of numlist 52 72 112 128 152 160 164 168 184 192
208 216 268 312 336 348 376 448 492 500
508 512 519 536 556 560 572 588 596 616
620 628 644 678 684 692 704 724 732 736
740 760 828 884 {;
# delimit cr

replace metarea_d=`num' if HHMSA==`num'
}

*** Rush hour
g rush=1
replace rush=0 if STRTTIME<630
replace rush=0 if STRTTIME>1030 & STRTTIME<1630
replace rush=0 if STRTTIME>2030

keep if rush==1

xi i.pop_den i.inc i.working
*reg log_speed log_distance log_distance2 _Ipop_den_* _Iinc_* _Iworking_*, r
reg log_speed log_distance log_distance2 _Ipop_den_* _Iinc_* _Iworking_*, r
estimates store speed_results
**************************************************************
**** recreate the neighborhood characteristics on the census tract map

** Get the land area for each census tract
clear
cd $data\geographic
import delimited tract1990_area.csv, varname(1) clear 

keep gisjoin area_sm
ren area_sm area

cd $data\geographic

sort gisjoin 
save area_sqmile, replace

*** Get the median income for each census tract
clear
cd $data\nhgis
import delimited nhgis0031_ds123_1990_tract.csv, clear
keep gisjoin e4u001
ren e4u001 median_income
sort gisjoin
cd $data\temp_files
save median_income1990, replace

*** Get the percentage of working population
clear 
cd $data\nhgis\working_pop
import delimited nhgis0016_ds123_1990_tract.csv, clear
egen working_pop=rowtotal(e4i001 e4i002 e4i005 e4i006)
keep gisjoin working_pop

cd $data\temp_files
merge 1:1 gisjoin using population1990
drop _merge
g share_working=working_pop/population
drop if share_working==.
replace share_working=1 if share_working>1

keep gisjoin share_working
sort gisjoin

save working_pop1990, replace


*** Get the population density
cd $data\temp_files
u population1990, clear
cd $data\geographic
merge 1:1 gisjoin using area_sqmile
keep if _merge==3
drop _merge

destring area, g(area_num) ignore(",")
drop area 
ren area_num area

g density=population/area
cd $data\geographic
keep gisjoin density
sort gisjoin
save density, replace

*** Create spatial data at census tract level
cd $data\geographic

u density, clear

cd $data\temp_files

merge 1:1 gisjoin using working_pop1990
keep if _merge==3
drop _merge
cd $data\temp_files
merge 1:1 gisjoin using median_income1990
keep if _merge==3
drop _merge

sort gisjoin
cd $data\temp_files
save tract1990_char, replace


** create average char within 2 miles for each census tract
cd $data\geographic

u tract1990_tract1990_2mi, clear

cd $data\temp_files

ren gisjoin2 gisjoin

merge m:1 gisjoin using tract1990_char
keep if _merge==3
drop _merge
ren gisjoin gisjoin2
ren gisjoin1 gisjoin
cd $data\temp_files
save temp, replace

cd $data\temp_files
u tract1990_char, clear
g gisjoin2=gisjoin
append using temp

collapse density share_working median_income, by(gisjoin)
cd $data\temp_files
save tract1990_char_2mi, replace

** Create average char within 2 miles for each zip code
cd $data\geographic
import delimited zip1990_tract1990_nearest.csv, varnames(1) clear
ren in_fid fid
cd $data\geographic
merge m:1 fid using zip1990
keep if _merge==3
drop _merge

drop fid
ren near_fid fid
merge m:1 fid using tract1990 
keep if _merge==3
drop _merge

keep gisjoin zip 
save zip1990_tract1990_nearest, replace

append using tract1990_zip1990_2mi
duplicates drop gisjoin zip, force
*** finished with the crosswalk, now merge with characteristics file

cd $data\temp_files

sort zip gisjoin

merge m:1 gisjoin using tract1990_char
keep if _merge==3
drop _merge

collapse density share_working median_income, by(zip)
save zip1990_char_2mi, replace



cd $data\geographic
import delimited tract1990_zip1990_leftover.csv, varnames(1) clear 
cd $data\geographic
ren input_fid fid
merge m:1 fid using tract1990

keep if _merge==3
drop _merge

drop fid

ren near_fid fid
merge m:1 fid using zip1990
keep if _merge==3
drop _merge

keep gisjoin zip distance
destring distance, g(distance_num) ignore(",")
drop distance
ren distance_num distance

replace distance=distance

replace distance=distance*1.6
g time=3600*distance/(35*1609.34)
cd $data\temp_files
save temp, replace

*** rank>=51
cd $data\geographic
import delimited tract1990_zip1990_leftover_51.csv, varnames(1) clear 
cd $data\geographic
ren input_fid fid
merge m:1 fid using tract1990

keep if _merge==3
drop _merge

drop fid

ren near_fid fid
merge m:1 fid using zip1990
keep if _merge==3
drop _merge

keep gisjoin zip distance
destring distance, g(distance_num) ignore(",")
drop distance
ren distance_num distance

replace distance=distance

replace distance=distance*1.6
g time=3600*distance/(35*1609.34)
cd $data\temp_files
save temp_51, replace

*** call the travel matrix
cd $data\travel
u travel_time, clear
cd $data\temp_files
merge 1:1 gisjoin zip using temp
drop if _merge==2
drop _merge

g leftover=1 if travel_time==-1 | travel_dist==-1 | travel_time==0 | travel_dist==0 | travel_time==. | travel_dist==.
replace travel_time=time if time!=. & leftover==1
replace travel_dist=distance if  distance!=. & leftover==1

drop leftover time distance

merge 1:1 gisjoin zip using temp_51
drop if _merge==2
drop _merge

g leftover=1 if travel_time==-1 | travel_dist==-1 | travel_time==0 | travel_dist==0 | travel_time==. | travel_dist==.
replace travel_time=time if time!=. & leftover==1
replace travel_dist=distance if  distance!=. & leftover==1

drop if zip==93562

drop time distance leftover

cd $data\temp_files
merge m:1 gisjoin using tract1990_char_2mi
drop if _merge==2
drop _merge
ren density density1
ren share_working share_working1
ren median_income median_income1

merge m:1 zip using zip1990_char_2mi
drop if _merge==2
drop _merge

ren density density2
ren share_working share_working2
ren median_income median_income2

*** fill the missing observations

replace density1=5267.096 if density1==.
replace share_working1=.4599274 if share_working1==.
replace median_income1=30438.35 if median_income1==.

replace density2=5267.096 if density2==.
replace share_working2=.4599274 if share_working2==.
replace median_income2=30438.35 if median_income2==.

**
g density=(density1+density2)/2
g share_working=(share_working1+share_working2)/2
g median_income=(median_income1+median_income2)/2

drop *1 *2
** population density

g pop_den=.
replace pop_den=50 if density>=0 & density<100
replace pop_den=300 if density>=100 & density<500
replace pop_den=750 if density>=500 & density<1000
replace pop_den=1500 if density>=1000 & density<2000
replace pop_den=3000 if density>=2000 & density<4000
replace pop_den=7000 if density>=4000 & density<10000
replace pop_den=17000 if density>=10000 & density<25000
replace pop_den=35000 if density>=25000

drop density

***Median income
g inc=.
replace inc=15000 if median_income>=0 & median_income<20000
replace inc=22000 if median_income>=20000 & median_income<25000
replace inc=27000 if median_income>=25000 & median_income<30000
replace inc=32000 if median_income>=30000 & median_income<35000
replace inc=37000 if median_income>=35000 & median_income<40000
replace inc=45000 if median_income>=40000 & median_income<50000
replace inc=60000 if median_income>=50000 & median_income<70000
replace inc=80000 if median_income>=70000
drop median_income
***
g working=.
replace working=0 if share_working>=0 & share_working<0.05
replace working=10 if share_working>=0.05 & share_working<0.15
replace working=20 if share_working>=0.15 & share_working<0.25
replace working=30 if share_working>=0.25 & share_working<0.35
replace working=40 if share_working>=0.35 & share_working<0.45
replace working=50 if share_working>=0.45 & share_working<0.55
replace working=60 if share_working>=0.55 & share_working<0.65
replace working=70 if share_working>=0.65 & share_working<0.75
replace working=80 if share_working>=0.75 & share_working<0.85
replace working=90 if share_working>=0.85 & share_working<0.95
replace working=95 if share_working>=0.95 & share_working<=1
drop share_working

xi i.pop_den i.inc i.working

g log_distance=ln(travel_dist/1609.34)
g log_distance2=log_distance^2

g log_speed=ln((travel_dist/1609.34)/(travel_time/3600))

reg log_speed log_distance log_distance2 _Ipop_den_* _Iinc_* _Iworking_*, r
predict fixed_effects, residual

estimates restore speed_results

# delimit 
predict log_speed_hat, xb;
# delimit cr

replace log_speed_hat=log_speed_hat+fixed_effects
g speed_hat=exp(log_speed_hat)

g travel_time_hat=(travel_dist/1609.34)/speed_hat

keep gisjoin zip travel_time_hat

cd $data\travel
save travel_time_hat, replace


*************************************+*************************************+****
**# Data Prep -  Expected Commute
*************************************+*************************************+****

clear all
global data="C:\Users\alen\Documents\Dropbox\paper_folder"

cd $data\temp_files

u occ_emp_share_1994, clear

cd $data\geographic

merge m:1 metarea using 1990_rank
drop _merge

cd $data\temp_files
save occ_emp_share_temp, replace


# delimit

foreach num of numlist  30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 
2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3740 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520
5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;

# delimit cr
cd $data\temp_files
u occ_emp_share_temp, clear
keep if occ2010==`num'
drop serial year rank
cd $data\travel

merge 1:m zip using travel_time_hat
keep if _merge==3
drop _merge

ren travel_time_hat travel_time
** commuting hours per work week
replace travel_time=10*travel_time

g discount=exp(-0.3425*travel_time)
g pi=share*discount
sort gisjoin
by gisjoin: egen pi_total=sum(pi)

g  share_tilda=pi/pi_total

g travel_time_share=travel_time*share_tilda

collapse (sum) expected_commute=travel_time_share, by(gisjoin)

cd $data\temp_files\commute
sort expected

save commute_`num', replace
}

cd $data\temp_files\commute
clear
# delimit
foreach num of numlist 30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3740 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520 5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;
# delimit cr

u commute_`num', replace
g occ2010=`num'
save commute_`num'_temp, replace

}

clear
# delimit
foreach num of numlist 30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3740 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520 5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;
# delimit cr

append using commute_`num'_temp

}
cd $data\temp_files\commute
save commute, replace




*** all employment

foreach num of numlist 1(1)21 {
cd $data\temp_files
u occ_emp_1994, clear

* MANAGEMENT, BUSINESS, SCIENCE, AND ARTS
g occ_group=1 if occ2010>=10 & occ2010<=430
* BUSINESS OPERATIONS SPECIALISTS
replace occ_group=2 if occ2010>=500 & occ2010<=730
* FINANCIAL SPECIALISTS
replace occ_group=3 if occ2010>=800 & occ2010<=950
* COMPUTER AND MATHEMATICAL
replace occ_group=4 if occ2010>=1000 & occ2010<=1240
* ARCHITECTURE AND ENGINEERING
replace occ_group=5 if occ2010>=1300 & occ2010<=1540
* TECHNICIANS
replace occ_group=6 if occ2010>=1550 & occ2010<=1560
* LIFE, PHYSICAL, AND SOCIAL SCIENCE
replace occ_group=7 if occ2010>=1600 & occ2010<=1980
* COMMUNITY AND SOCIAL SERVICES
replace occ_group=8 if occ2010>=2000 & occ2010<=2060
* LEGAL
replace occ_group=9 if occ2010>=2100 & occ2010<=2150
* EDUCATION, TRAINING, AND LIBRARY
replace occ_group=10 if occ2010>=2200 & occ2010<=2550
* ARTS, DESIGN, ENTERTAINMENT, SPORTS, AND MEDIA
replace occ_group=11 if occ2010>=2600 & occ2010<=2920
* HEALTHCARE PRACTITIONERS AND TECHNICAL
replace occ_group=12 if occ2010>=3000 & occ2010<=3540
* HEALTHCARE SUPPORT
replace occ_group=13 if occ2010>=3600 & occ2010<=3650
* PROTECTIVE SERVICE
replace occ_group=14 if occ2010>=3700 & occ2010<=3950
* FOOD PREPARATION AND SERVING
replace occ_group=15 if occ2010>=4000 & occ2010<=4150
* BUILDING AND GROUNDS CLEANING AND MAINTENANCE
replace occ_group=16 if occ2010>=4200 & occ2010<=4250
* PERSONAL CARE AND SERVICE
replace occ_group=17 if occ2010>=4300 & occ2010<=4650
* SALES AND RELATED
replace occ_group=18 if occ2010>=4700 & occ2010<=4965
* OFFICE AND ADMINISTRATIVE SUPPORT
replace occ_group=19 if occ2010>=5000 & occ2010<=5940
* FARMING, FISHING, AND FORESTRY
replace occ_group=20 if occ2010>=6005 & occ2010<=6130
* CONSTRUCTION
replace occ_group=21 if occ2010>=6200 & occ2010<=6765
* EXTRACTION
replace occ_group=22 if occ2010>=6800 & occ2010<=6940
* INSTALLATION, MAINTENANCE, AND REPAIR
replace occ_group=23 if occ2010>=7000 & occ2010<=7630
* PRODUCTION
replace occ_group=24 if occ2010>=7700 & occ2010<=8965
* TRANSPORTATION AND MATERIAL MOVING
replace occ_group=25 if occ2010>=9000 & occ2010<=9750

keep if occ_group!=`num'

collapse (sum) est_num, by(zip)

cd $data\geographic
merge m:1 zip using zip1990_metarea
keep if _merge==3
drop _merge

sort metarea
by metarea: egen est_num_total=sum(est_num)

g share=est_num/est_num_total
keep share zip metarea

cd $data\geographic

merge m:1 metarea using 1990_rank
drop _merge

drop serial year rank
cd $data\travel

merge 1:m zip using travel_time_hat
keep if _merge==3
drop _merge


ren travel_time_hat travel_time

** commuting hours per work week
replace travel_time=10*travel_time

g discount=exp(-0.3425*travel_time)
g pi=share*discount

sort gisjoin
by gisjoin: egen pi_total=sum(pi)


g  share_tilda=pi/pi_total

g travel_time_share=travel_time*share_tilda

collapse (sum) expected_commute=travel_time_share, by(gisjoin)


sort expected

ren expected_commute total_commute
cd $data\temp_files\commute
save commute_total`num', replace
}


foreach num of numlist 23(1)25 {
cd $data\temp_files
u occ_emp_1994, clear

* MANAGEMENT, BUSINESS, SCIENCE, AND ARTS
g occ_group=1 if occ2010>=10 & occ2010<=430
* BUSINESS OPERATIONS SPECIALISTS
replace occ_group=2 if occ2010>=500 & occ2010<=730
* FINANCIAL SPECIALISTS
replace occ_group=3 if occ2010>=800 & occ2010<=950
* COMPUTER AND MATHEMATICAL
replace occ_group=4 if occ2010>=1000 & occ2010<=1240
* ARCHITECTURE AND ENGINEERING
replace occ_group=5 if occ2010>=1300 & occ2010<=1540
* TECHNICIANS
replace occ_group=6 if occ2010>=1550 & occ2010<=1560
* LIFE, PHYSICAL, AND SOCIAL SCIENCE
replace occ_group=7 if occ2010>=1600 & occ2010<=1980
* COMMUNITY AND SOCIAL SERVICES
replace occ_group=8 if occ2010>=2000 & occ2010<=2060
* LEGAL
replace occ_group=9 if occ2010>=2100 & occ2010<=2150
* EDUCATION, TRAINING, AND LIBRARY
replace occ_group=10 if occ2010>=2200 & occ2010<=2550
* ARTS, DESIGN, ENTERTAINMENT, SPORTS, AND MEDIA
replace occ_group=11 if occ2010>=2600 & occ2010<=2920
* HEALTHCARE PRACTITIONERS AND TECHNICAL
replace occ_group=12 if occ2010>=3000 & occ2010<=3540
* HEALTHCARE SUPPORT
replace occ_group=13 if occ2010>=3600 & occ2010<=3650
* PROTECTIVE SERVICE
replace occ_group=14 if occ2010>=3700 & occ2010<=3950
* FOOD PREPARATION AND SERVING
replace occ_group=15 if occ2010>=4000 & occ2010<=4150
* BUILDING AND GROUNDS CLEANING AND MAINTENANCE
replace occ_group=16 if occ2010>=4200 & occ2010<=4250
* PERSONAL CARE AND SERVICE
replace occ_group=17 if occ2010>=4300 & occ2010<=4650
* SALES AND RELATED
replace occ_group=18 if occ2010>=4700 & occ2010<=4965
* OFFICE AND ADMINISTRATIVE SUPPORT
replace occ_group=19 if occ2010>=5000 & occ2010<=5940
* FARMING, FISHING, AND FORESTRY
replace occ_group=20 if occ2010>=6005 & occ2010<=6130
* CONSTRUCTION
replace occ_group=21 if occ2010>=6200 & occ2010<=6765
* EXTRACTION
replace occ_group=22 if occ2010>=6800 & occ2010<=6940
* INSTALLATION, MAINTENANCE, AND REPAIR
replace occ_group=23 if occ2010>=7000 & occ2010<=7630
* PRODUCTION
replace occ_group=24 if occ2010>=7700 & occ2010<=8965
* TRANSPORTATION AND MATERIAL MOVING
replace occ_group=25 if occ2010>=9000 & occ2010<=9750

keep if occ_group!=`num'

collapse (sum) est_num, by(zip)

cd $data\geographic
merge m:1 zip using zip1990_metarea
keep if _merge==3
drop _merge

sort metarea
by metarea: egen est_num_total=sum(est_num)

g share=est_num/est_num_total
keep share zip metarea

cd $data\geographic

merge m:1 metarea using 1990_rank
drop _merge

drop serial year rank

cd $data\travel
merge 1:m zip using travel_time_hat
keep if _merge==3
drop _merge

ren travel_time_hat travel_time

** commuting hours per work week

replace travel_time=10*travel_time

g discount=exp(-0.3425*travel_time)
g pi=share*discount

sort gisjoin
by gisjoin: egen pi_total=sum(pi)


g  share_tilda=pi/pi_total

g travel_time_share=travel_time*share_tilda

collapse (sum) expected_commute=travel_time_share, by(gisjoin)


sort expected

ren expected_commute total_commute
cd $data\temp_files\commute

save commute_total`num', replace
}

clear
foreach num of numlist 1(1)21 {
u commute_total`num', clear
g occ_group=`num'
save commute_total`num', replace
}
foreach num of numlist 23(1)25 {
u commute_total`num', clear
g occ_group=`num'
save commute_total`num', replace
}

clear
foreach num of numlist 1(1)21 {
append using commute_total`num'
}
foreach num of numlist 23(1)25 {
append using commute_total`num'
}

save commute_total, replace

*************************************+*************************************+****
**# Data Prep -  Location Choice Data
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"

*** Generate crosswalk between occupation group and occupation
*** 1990's crosswalk between occupation group and 1990's occupation
cd $data\ipums_micro
u 1990_2000_2010_temp if year==1990, clear

*** generate occupation groups that link occ1990 to the nhgis 1990 version occupation group
cd $data\temp_files

g occ1990_group=1 if occ1990>=0 & occ1990<=42
replace occ1990_group=2 if occ1990>=43 & occ1990<=202
replace occ1990_group=3 if occ1990>=203 & occ1990<=242
replace occ1990_group=4 if occ1990>=243 & occ1990<=302
replace occ1990_group=5 if occ1990>=303 & occ1990<=402
replace occ1990_group=6 if occ1990>=403 & occ1990<=412
replace occ1990_group=7 if occ1990>=413 & occ1990<=432
replace occ1990_group=8 if occ1990>=433 & occ1990<=472
replace occ1990_group=9 if occ1990>=473 & occ1990<=502
replace occ1990_group=10 if occ1990>=503 & occ1990<=702
replace occ1990_group=11 if occ1990>=703 & occ1990<=802
replace occ1990_group=12 if occ1990>=803 & occ1990<=863
replace occ1990_group=13 if occ1990>=864 & occ1990<=902
replace occ1990_group=14 if occ1990==999

cd $data\temp_files
save temp, replace
**
cd $data\temp_files
u temp, clear
collapse (count) count=serial, by(statefip puma1990 occ2010 occ1990_group)
drop if occ2010==9920
drop if occ1990_group==.
save temp1, replace

collapse (sum) count_occ=count, by(statefip puma1990 occ1990_group)
merge 1:m statefip puma1990 occ1990_group using temp1
drop _merge

g occ_group_share=count/ count_occ
keep statefip puma1990 occ2010 occ1990_group occ_group_share

cd $data\temp_files
save occ_group_share1990, replace


*** generate occ2010- occ1990_group crosswalk (dropping the uncommon linkage) (make sure for each occ2010, I can map it into a unique occ1990_group)
cd $data\temp_files
u temp, clear
g a=1
collapse (count) count=a, by(occ2010 occ1990_group)
sort occ2010 count
by occ2010: g max=_N
by occ2010: g rank=_n
keep if max==rank
keep occ2010 occ1990_group
sort occ2010 occ1990_group
save occ_occ_group1990, replace


***************************
***************************
**2000

cd $data\ipums_micro
u 1990_2000_2010_temp if year==2000, clear

*** generate occupation groups that link occ1990 to the nhgis 1990 version occupation group


*** generate occupation group
*** management
g occ2000_group=1 if occ>=1 & occ<=95
** professional
replace occ2000_group=2 if occ>=100 & occ<=354
*** health care
replace occ2000_group=3 if occ>=360 & occ<=365
** protective
replace occ2000_group=4 if occ>=370 & occ<=395
** Food preparation
replace occ2000_group=5 if occ>=400 & occ<=413
*** Building clean and maintenance
replace occ2000_group=6 if occ>=420 & occ<=425
** Personal care
replace occ2000_group=7 if occ>=430 & occ<=465
** sales
replace occ2000_group=8 if occ>=470 & occ<=496
** Office and administrative
replace occ2000_group=9 if occ>=500 & occ<=593
** Farming 
replace occ2000_group=10 if occ>=600 & occ<=605
** fishing
replace occ2000_group=11 if occ>=610 & occ<=613
** Construction and extraction
replace occ2000_group=12 if occ>=620 & occ<=694
** Installation
replace occ2000_group=13 if occ>=700 & occ<=762
** Production 
replace occ2000_group=14 if occ>=770 & occ<=896
** Transportation
replace occ2000_group=15 if occ>=900 & occ<=975

cd $data\temp_files
save temp, replace
**
cd $data\temp_files
u temp, clear
collapse (count) count=serial, by(statefip puma occ2010 occ2000_group)
drop if occ2010==9920
drop if occ2000_group==.
save temp1, replace

collapse (sum) count_occ=count, by(statefip puma occ2000_group)
merge 1:m statefip puma occ2000_group using temp1
drop _merge

g occ_group_share=count/ count_occ
keep statefip puma occ2010 occ2000_group occ_group_share

cd $data\temp_files
save occ_group_share2000, replace



*** generate occ2010- occ2000_group crosswalk (dropping the uncommon linkage)
cd $data\temp_files
u temp, clear
g a=1
collapse (count) count=a, by(occ2010 occ2000_group)
sort occ2010 count
by occ2010: g max=_N
by occ2010: g rank=_n
keep if max==rank
keep occ2010 occ2000_group
sort occ2010 occ2000_group
save occ_occ_group2000, replace


******************************
******************************
** 2010
cd $data\ipums_micro

u 1990_2000_2010_temp if year==2010, clear

g occ2010_group=5 if occ2010>=10 & occ2010<=430 & year==2010
** Business and financial
replace occ2010_group=6 if occ2010>=500 & occ2010<=950 & year==2010
*** Computer and mathematical
replace occ2010_group=8 if occ2010>=1000 & occ2010<=1240 & year==2010
** Architecture and engineering
replace occ2010_group=9 if occ2010>=1300 & occ2010<=1560 & year==2010
** Life, physical, and social science
replace occ2010_group=10 if occ2010>=1600 & occ2010<=1980 & year==2010
*** Community and social service
replace occ2010_group=12 if occ2010>=2000 & occ2010<=2060 & year==2010
** legal
replace occ2010_group=13 if occ2010>=2100 & occ2010<=2150 & year==2010
** Education, training, and library
replace occ2010_group=14 if occ2010>=2200 & occ2010<=2550 & year==2010
**Arts, design, entertainment, sports, and media 
replace occ2010_group=15 if occ2010>=2600 & occ2010<=2920 & year==2010
**Health diagnosing and treating practitioners and other technical 
replace occ2010_group=16 if occ2010>=3000 & occ2010<=3540 & year==2010
** Health technologists and technicians
replace occ2010_group=20 if occ2010>=3600 & occ2010<=3650 & year==2010
** Fire fighting and prevention, and other protective service 
replace occ2010_group=21 if occ2010>=3700 & occ2010<=3950 & year==2010
** Food preparation and serving related
replace occ2010_group=24 if occ2010>=4000 & occ2010<=4150 & year==2010
** Building and grounds cleaning and maintenance 
replace occ2010_group=25 if occ2010>=4200 & occ2010<=4250 & year==2010
** Personal care and service
replace occ2010_group=26 if occ2010>=4300 & occ2010<=4650 & year==2010
** Sales and related
replace occ2010_group=28 if occ2010>=4700 & occ2010<=4965 & year==2010
** Office and administrative support
replace occ2010_group=29 if occ2010>=5000 & occ2010<=5940 & year==2010
** Farming, fishing and forestry
replace occ2010_group=31 if occ2010>=6005 & occ2010<=6130 & year==2010
** Construction and extraction 
replace occ2010_group=32 if occ2010>=6200 & occ2010<=6940 & year==2010
** Installation, maintenance, and repair 
replace occ2010_group=33 if occ2010>=7000 & occ2010<=7630 & year==2010
** Production occupations
replace occ2010_group=35 if occ2010>=7700 & occ2010<=8965 & year==2010
** Transportation occupations
replace occ2010_group=36 if occ2010>=9000 & occ2010<=9420 & year==2010
** Material moving occupations
replace occ2010_group=37 if occ2010>=9510 & occ2010<=9750 & year==2010
** unemployed
replace occ2010_group=38 if occ2010==9920 & year==2010

cd $data\temp_files
save temp, replace
**

cd $data\temp_files
u temp, clear
collapse (count) count=serial, by(statefip puma occ2010 occ2010_group)
drop if occ2010==9920
drop if occ2010_group==.
save temp1, replace

collapse (sum) count_occ=count, by(statefip puma occ2010_group)
merge 1:m statefip puma occ2010_group using temp1
drop _merge

g occ_group_share=count/ count_occ
keep statefip puma occ2010 occ2010_group occ_group_share

cd $data\temp_files
save occ_group_share2010, replace

*** generate occ2010- occ1990_group crosswalk (dropping the uncommon linkage)
cd $data\temp_files
u temp, clear
g a=1
collapse (count) count=a, by(occ2010 occ2010_group)
sort occ2010 count
by occ2010: g max=_N
by occ2010: g rank=_n
keep if max==rank
keep occ2010 occ2010_group
sort occ2010 occ2010_group
save occ_occ_group2010, replace


************************************************************************
************************************************************************
**** Construct location choice
*****
**1990
cd $data\nhgis\occupation
import delimited nhgis0013_ds123_1990_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
cd $data\geographic
merge 1:1 gisjoin using puma1990_tract1990
keep if _merge==3
drop _merge
drop anrca county year res_onlya trusta aianhha res_trsta blck_grpa tracta cda c_citya countya cty_suba divisiona msa_cmsaa placea pmsaa regiona state statea urbrurala urb_areaa zipa cd103a anpsadpi

foreach num of numlist 1(1)9 {
g occ1990_group`num'=e4q00`num'
}
foreach num of numlist 10(1)13 {
g occ1990_group`num'=e4q0`num'
}

drop e4p* e4q*

sort gisjoin

cd $data\temp_files
save occ_tract1990, replace

*** employment number by census tract

cd $data\temp_files
u occ_tract1990, clear
ren puma puma1990
keep gisjoin statefip puma1990 occ1990*


reshape long occ1990_group, i(gisjoin statefip puma1990) j(group)
ren occ1990_group number_occ1990
ren group occ1990_group

collapse (sum) number_tract=number_occ1990, by(gisjoin statefip puma1990)
save number_tract1990, replace

*** merge
cd $data\temp_files
u occ_tract1990, clear

ren puma puma1990
keep gisjoin statefip puma1990 occ1990*


reshape long occ1990_group, i(gisjoin statefip puma1990) j(group)
ren occ1990_group number_occ1990
ren group occ1990_group

cd $data\temp_files
joinby statefip puma1990 occ1990_group using occ_group_share1990

g impute=number_occ1990*occ_group_share

collapse (sum) impute, by(gisjoin statefip puma1990 occ2010)


keep gisjoin statefip puma1990 occ2010 impute
merge m:1 occ2010 using occ_occ_group1990
keep if _merge==3
drop _merge


fillin gisjoin occ2010

replace impute=0 if impute==.
drop _fillin
drop statefip puma1990 occ1990_group
replace impute=round(impute)
save tract_impute1990, replace


*** 2000

*********************
***2000

cd $data\nhgis\occupation

import delimited nhgis0014_ds153_2000_tract.csv, clear 

drop year regiona divisiona state statea county countya cty_suba placea tracta trbl_cta blck_grpa trbl_bga c_citya res_onlya trusta aianhha trbl_suba anrca msa_cmsaa pmsaa necmaa urb_areaa cd106a cd108a cd109a zip3a zctaa name
sort gisjoin

cd $data\geographic
merge 1:m gisjoin using tract1990_tract2000

keep if _merge==3
drop _merge


foreach num of numlist 1(1)9 {
replace h0400`num'=h0400`num'*percentage
}

foreach num of numlist 10(1)30 {
replace h040`num'=h040`num'*percentage
}


drop gisjoin
ren gisjoin_1 gisjoin
collapse (sum) h04001 h04002 h04003 h04004 h04005 h04006 h04007 h04008 h04009 h04010 h04011 h04012 h04013 h04014 h04015 h04016 h04017 h04018 h04019 h04020 h04021 h04022 h04023 h04024 h04025 h04026 h04027 h04028 h04029 h04030 , by(gisjoin)

g occ2000_group1=h04001 + h04016
g occ2000_group2=h04002 + h04017
g occ2000_group3=h04003 + h04018
g occ2000_group4=h04004 + h04019
g occ2000_group5=h04005 + h04020
g occ2000_group6=h04006 + h04021
g occ2000_group7=h04007 + h04022
g occ2000_group8=h04008 + h04023
g occ2000_group9=h04009 + h04024
g occ2000_group10=h04010 + h04025
g occ2000_group11=h04011 + h04026
g occ2000_group12=h04012 + h04027
g occ2000_group13=h04013 + h04028
g occ2000_group14=h04014 + h04029
g occ2000_group15=h04015 + h04030

foreach num of numlist 1(1)15 {
replace occ2000_group`num'=round(occ2000_group`num')
}


drop h04* 

sort gisjoin

cd $data\geographic
merge 1:1 gisjoin using puma_tract1990
keep if _merge==3
drop _merge

cd $data\temp_files
save occ_tract2000, replace

*** employment number by census tract

u occ_tract2000, clear
keep gisjoin statefip puma occ2000*


reshape long occ2000_group, i(gisjoin statefip puma) j(group)
ren occ2000_group number_occ2000
ren group occ2000_group

collapse (sum) number_tract=number_occ2000, by(gisjoin statefip puma)
save number_tract2000, replace

*** merge
u occ_tract2000, clear

keep gisjoin statefip puma occ2000*


reshape long occ2000_group, i(gisjoin statefip puma) j(group)
ren occ2000_group number_occ2000
ren group occ2000_group

cd $data\temp_files
joinby statefip puma occ2000_group using occ_group_share2000

g impute=number_occ2000*occ_group_share

collapse (sum) impute, by(gisjoin statefip puma occ2010)


keep gisjoin statefip puma occ2010 impute

merge m:1 occ2010 using occ_occ_group2000
keep if _merge==3
drop _merge

replace impute=round(impute)
keep gisjoin occ2010 impute 

fillin gisjoin occ2010

replace impute=0 if impute==.
drop _fillin
save tract_impute2000, replace

***************************

*********************
***2010

cd $data\nhgis\occupation

import delimited nhgis0013_ds184_20115_2011_tract.csv, clear 

drop year regiona divisiona state statea county countya name_m cousuba placea tracta blkgrpa concita aianhha res_onlya trusta aitscea anrca cbsaa csaa metdiva nectaa cnectaa nectadiva uaa cdcurra sldua sldla zcta5a submcda sdelma sdseca sdunia puma5a bttra btbga name_e

cd $data\geographic
merge 1:m gisjoin using tract1990_tract2010
keep if _merge==3
drop _merge

foreach num of numlist 1(1)9 {
replace mspe00`num'=mspe00`num'*percentage
}

foreach num of numlist 10(1)73 {
replace mspe0`num'=mspe0`num'*percentage
}


foreach num of numlist 1(1)9 {
replace ms0e00`num'=ms0e00`num'*percentage
}

foreach num of numlist 10(1)55 {
replace ms0e0`num'=ms0e0`num'*percentage
}

drop gisjoin
ren gisjoin_1 gisjoin

collapse (sum) mspe001 mspe002 mspe003 mspe004 mspe005 mspe006 mspe007 mspe008 mspe009 mspe010 mspe011 mspe012 mspe013 mspe014 mspe015 mspe016 mspe017 mspe018 mspe019 mspe020 mspe021 mspe022 mspe023 mspe024 mspe025 mspe026 mspe027 mspe028 mspe029 mspe030 mspe031 mspe032 mspe033 mspe034 mspe035 mspe036 mspe037 mspe038 mspe039 mspe040 mspe041 mspe042 mspe043 mspe044 mspe045 mspe046 mspe047 mspe048 mspe049 mspe050 mspe051 mspe052 mspe053 mspe054 mspe055 mspe056 mspe057 mspe058 mspe059 mspe060 mspe061 mspe062 mspe063 mspe064 mspe065 mspe066 mspe067 mspe068 mspe069 mspe070 mspe071 mspe072 mspe073 , by(gisjoin)


g occ2010_group1=mspe001
g occ2010_group2=mspe002+mspe038
g occ2010_group3=mspe003+mspe039
g occ2010_group4=mspe004+mspe040
g occ2010_group5=mspe005+mspe041
g occ2010_group6=mspe006+mspe042
g occ2010_group7=mspe007+mspe043
g occ2010_group8=mspe008+mspe044
g occ2010_group9=mspe009+mspe045
g occ2010_group10=mspe010+mspe046
g occ2010_group11=mspe011+mspe047
g occ2010_group12=mspe012+mspe048
g occ2010_group13=mspe013+mspe049
g occ2010_group14=mspe014+mspe050
g occ2010_group15=mspe015+mspe051
g occ2010_group16=mspe016+mspe052
g occ2010_group17=mspe017+mspe053
g occ2010_group18=mspe018+mspe054
g occ2010_group19=mspe019+mspe055
g occ2010_group20=mspe020+mspe056
g occ2010_group21=mspe021+mspe057
g occ2010_group22=mspe022+mspe058
g occ2010_group23=mspe023+mspe059
g occ2010_group24=mspe024+mspe060
g occ2010_group25=mspe025+mspe061
g occ2010_group26=mspe026+mspe062
g occ2010_group27=mspe027+mspe063
g occ2010_group28=mspe028+mspe064
g occ2010_group29=mspe029+mspe065
g occ2010_group30=mspe030+mspe066
g occ2010_group31=mspe031+mspe067
g occ2010_group32=mspe032+mspe068
g occ2010_group33=mspe033+mspe069
g occ2010_group34=mspe034+mspe070
g occ2010_group35=mspe035+mspe071
g occ2010_group36=mspe036+mspe072
g occ2010_group37=mspe037+mspe073


drop mspe*
drop occ2010_group1 occ2010_group2

foreach num of numlist 3(1)37 {
replace occ2010_group`num'=round(occ2010_group`num')
}

sort gisjoin

cd $data\geographic
merge 1:1 gisjoin using puma_tract1990
keep if _merge==3
drop _merge

cd $data\temp_files
save occ_tract2010, replace

*** employment number by census tract
cd $data\temp_files
u occ_tract2010, clear
keep gisjoin statefip puma occ2010*


reshape long occ2010_group, i(gisjoin statefip puma) j(group)
ren occ2010_group number_occ2010
ren group occ2010_group

collapse (sum) number_tract=number_occ2010, by(gisjoin statefip puma)
cd $data\temp_files
save number_tract2010, replace

*** merge
cd $data\temp_files
u occ_tract2010, clear

keep gisjoin statefip puma occ2010*


reshape long occ2010_group, i(gisjoin statefip puma) j(group)
ren occ2010_group number_occ2010
ren group occ2010_group

joinby statefip puma occ2010_group using occ_group_share2010

g impute=number_occ2010*occ_group_share

collapse (sum) impute, by(gisjoin statefip puma occ2010)


keep gisjoin statefip puma occ2010 impute
merge m:1 occ2010 using occ_occ_group2010
keep if _merge==3
drop _merge

replace impute=round(impute)
keep gisjoin occ2010 impute 
sort gisjoin occ2010

fillin gisjoin occ2010

replace impute=0 if impute==.
drop _fillin
cd $data\temp_files
save tract_impute2010, replace




**** Combining all the data

u tract_impute1990, clear

ren impute impute1990

merge 1:1 occ2010 gisjoin using tract_impute2000
drop _merge

ren impute impute2000

merge 1:1 occ2010 gisjoin using tract_impute2010
drop _merge

ren impute impute2010

replace impute1990=0 if impute1990==.
replace impute2000=0 if impute2000==.
replace impute2010=0 if impute2010==.

*** Make sure the observations are consistent across three periods
cd $data\temp_files
merge m:1 occ2010 using occ2010_count
keep if _merge==3
drop _merge
drop count*
cd $data\geographic
merge m:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

*** Add one to all census tract to smooth over zero observations. 
cd $data\temp_files
replace impute1990=impute1990+1
replace impute2000=impute2000+1
replace impute2010=impute2010+1
save tract_impute, replace


cd $data\temp_files
u tract_impute, clear
collapse (sum) impute_total1990=impute1990 impute_total2000=impute2000 impute_total2010=impute2010, by(occ2010 metarea)

merge 1:m occ2010 metarea using tract_impute
drop _merge

g impute_share1990=impute1990/impute_total1990
g impute_share2000=impute2000/impute_total2000
g impute_share2010=impute2010/impute_total2010
keep occ2010 metarea gisjoin impute_share1990 impute_share2000 impute_share2010
save tract_impute_share, replace

*************************************+*************************************+****
**# Data Prep -  High Skill Share
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"

cd $data\ipums_micro

u 1990_2000_2010_temp, clear

keep if year==1990
keep if uhrswork>=30
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

replace inctot_real=inctot_real/52

g college=0
replace college=1 if educ>=10 & educ<.

collapse college, by(occ2010)

ren college college_share
g high_skill=0
replace high_skill=1 if college_share>=0.4
cd $data\temp_files

save high_skill, replace

***
cd $data\ipums_micro

u 1990_2000_2010_temp, clear

keep if year==1990
keep if uhrswork>=30
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

replace inctot_real=inctot_real/52

g college=0
replace college=1 if educ>=10 & educ<.

collapse college, by(occ2010)

ren college college_share
g high_skill=0
replace high_skill=1 if college_share>=0.3
cd $data\temp_files

save high_skill_30, replace

cd $data\ipums_micro

u 1990_2000_2010_temp, clear

keep if year==1990
keep if uhrswork>=30
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

replace inctot_real=inctot_real/52

g college=0
replace college=1 if educ>=10 & educ<.

collapse college, by(occ2010)

ren college college_share
g high_skill=0
replace high_skill=1 if college_share>=0.5
cd $data\temp_files

save high_skill_50, replace

*************************************+*************************************+****
**# Data Prep -  Skill Ratio
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"


cd $data\temp_files
u tract_impute_share, clear

cd $data\temp_files
merge m:1 occ2010 metarea using wage_metarea
keep if _merge==3
drop _merge
drop count*

cd $data\temp_files
merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute2000_high=impute_share2000*count2000*high_skill
g impute2000_low=impute_share2000*count2000*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

collapse (sum) impute2010_high impute2010_low impute2000_high impute2000_low impute1990_high impute1990_low, by(metarea gisjoin)
cd $data\temp_files
save skill_pop, replace


cd $data\temp_files
u skill_pop, clear

g dratio=ln( impute2010_high/ impute2010_low)-ln( impute1990_high/ impute1990_low)
keep gisjoin dratio
save skill_ratio_occupation, replace


*************************************+*************************************+****
**# Data Prep -  Rent
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"


cd $data\nhgis

import delimited nhgis0018_ds120_1990_tract.csv, clear

ren est001 hp
ren es6001 rent
keep gisjoin hp rent
sort gisjoin
replace hp=hp*218.056/130.7
replace rent=rent*218.056/130.7

cd $data\temp_files
save rent1990, replace

cd $data\nhgis
import delimited nhgis0018_ds151_2000_tract.csv, clear

ren gb7001 hp
ren gbg001 rent
keep gisjoin hp rent
sort gisjoin
replace hp=hp*218.056/172.2
replace rent=rent*218.056/172.2
cd $data\temp_files

save rent2000, replace

cd $data\nhgis
import delimited nhgis0018_ds184_20115_2011_tract.csv, clear 
ren muje001 rent
ren mu2e001 hp
keep gisjoin hp rent
sort gisjoin
cd $data\temp_files

save rent2010, replace



cd $data\geographic

u tract1990_tract2010_nearest, clear

ren gisjoin1 gisjoin

cd $data\temp_files
merge m:1 gisjoin using rent1990
keep if _merge==3
drop _merge
ren gisjoin gisjoin1
ren rent rent1990
ren gisjoin2 gisjoin

merge m:1 gisjoin using rent2010
keep if _merge==3
drop _merge
ren rent rent2010

drop gisjoin

cd $data\geographic
merge 1:1 gisjoin1 using tract1990_tract2000_nearest
keep if _merge==3
drop _merge

ren gisjoin2 gisjoin
cd $data\temp_files
merge m:1 gisjoin using rent2000
keep if _merge==3
drop _merge 
ren rent rent2000

drop gisjoin
ren gisjoin1 gisjoin
keep gisjoin rent*
save rent, replace


*** fill in the rent with MSA-level average rent
cd $data\temp_files
u rent, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_metarea
cd $data\temp_files
keep if _merge==3
drop _merge

save temp, replace

collapse mean_rent1990=rent1990 mean_rent2000=rent2000 mean_rent2010=rent2010, by(metarea)
save rent_metarea, replace

merge 1:m metarea using temp
drop _merge

replace rent1990=mean_rent1990 if rent1990==0
replace rent2000=mean_rent2000 if rent2000==0
replace rent2010=mean_rent2010 if rent2010==0

replace rent1990=mean_rent1990 if rent1990==.
replace rent2000=mean_rent2000 if rent2000==.
replace rent2010=mean_rent2010 if rent2010==.

keep gisjoin rent2010 rent2000 rent1990
sort gisjoin

save rent, replace

*************************************+*************************************+****
**# Data Prep -  IV 1990-2010 main
*************************************+*************************************+****


clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"


** Commute time data
cd $data\temp_files\commute

u commute, clear

cd $data\geographic\

merge m:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

cd $data\temp_files
merge m:1 occ2010 using val_40_60_total_1990_2000_2010
keep if _merge==3
drop _merge

drop se_1990 se_2010


* MANAGEMENT, BUSINESS, SCIENCE, AND ARTS
g occ_group=1 if occ2010>=10 & occ2010<=430
* BUSINESS OPERATIONS SPECIALISTS
replace occ_group=2 if occ2010>=500 & occ2010<=730
* FINANCIAL SPECIALISTS
replace occ_group=3 if occ2010>=800 & occ2010<=950
* COMPUTER AND MATHEMATICAL
replace occ_group=4 if occ2010>=1000 & occ2010<=1240
* ARCHITECTURE AND ENGINEERING
replace occ_group=5 if occ2010>=1300 & occ2010<=1540
* TECHNICIANS
replace occ_group=6 if occ2010>=1550 & occ2010<=1560
* LIFE, PHYSICAL, AND SOCIAL SCIENCE
replace occ_group=7 if occ2010>=1600 & occ2010<=1980
* COMMUNITY AND SOCIAL SERVICES
replace occ_group=8 if occ2010>=2000 & occ2010<=2060
* LEGAL
replace occ_group=9 if occ2010>=2100 & occ2010<=2150
* EDUCATION, TRAINING, AND LIBRARY
replace occ_group=10 if occ2010>=2200 & occ2010<=2550
* ARTS, DESIGN, ENTERTAINMENT, SPORTS, AND MEDIA
replace occ_group=11 if occ2010>=2600 & occ2010<=2920
* HEALTHCARE PRACTITIONERS AND TECHNICAL
replace occ_group=12 if occ2010>=3000 & occ2010<=3540
* HEALTHCARE SUPPORT
replace occ_group=13 if occ2010>=3600 & occ2010<=3650
* PROTECTIVE SERVICE
replace occ_group=14 if occ2010>=3700 & occ2010<=3950
* FOOD PREPARATION AND SERVING
replace occ_group=15 if occ2010>=4000 & occ2010<=4150
* BUILDING AND GROUNDS CLEANING AND MAINTENANCE
replace occ_group=16 if occ2010>=4200 & occ2010<=4250
* PERSONAL CARE AND SERVICE
replace occ_group=17 if occ2010>=4300 & occ2010<=4650
* SALES AND RELATED
replace occ_group=18 if occ2010>=4700 & occ2010<=4965
* OFFICE AND ADMINISTRATIVE SUPPORT
replace occ_group=19 if occ2010>=5000 & occ2010<=5940
* FARMING, FISHING, AND FORESTRY
replace occ_group=20 if occ2010>=6005 & occ2010<=6130
* CONSTRUCTION
replace occ_group=21 if occ2010>=6200 & occ2010<=6765
* EXTRACTION
replace occ_group=22 if occ2010>=6800 & occ2010<=6940
* INSTALLATION, MAINTENANCE, AND REPAIR
replace occ_group=23 if occ2010>=7000 & occ2010<=7630
* PRODUCTION
replace occ_group=24 if occ2010>=7700 & occ2010<=8965
* TRANSPORTATION AND MATERIAL MOVING
replace occ_group=25 if occ2010>=9000 & occ2010<=9750


cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

drop if count1990==.

cd $data\temp_files
merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

cd $data\temp_files

merge m:1 occ2010 gisjoin using tract_impute_share
keep if _merge==3
drop _merge

drop count2000 
cd $data\temp_files
save temp, replace

***

foreach num of numlist 1(1)21 {
cd $data\temp_files
u temp if occ_group!=`num', clear

g a1990=exp( log(impute_share1990))
g a2010=exp( log(impute_share1990)+7.204779*val_1990*expected_commute-7.204779*val_2010*expected_commute)

sort occ2010 metarea
by occ2010 metarea: egen sim1990=sum(a1990)
by occ2010 metarea: egen sim2010=sum(a2010)

replace sim1990=a1990/sim1990
replace sim2010=a2010/sim2010

replace sim1990=sim1990*count1990
replace sim2010=sim2010*count1990

cd $data\inter_files\demographic\education

g sim1990_high=sim1990 if high_skill==1
g sim1990_low=sim1990 if high_skill==0

g sim2010_high=sim2010 if high_skill==1
g sim2010_low=sim2010 if high_skill==0

collapse (sum) sim1990_high  (sum) sim1990_low (sum) sim2010_high (sum) sim2010_low (sum) count=count1990,by(gisjoin metarea)


g dln_sim_low=ln(sim2010_low)-ln(sim1990_low)
g dln_sim_high=ln(sim2010_high)-ln(sim1990_high)
g dln_sim=ln(sim2010_high+sim2010_low)-ln(sim1990_high+sim1990_low)

keep gisjoin dln_sim_low dln_sim_high dln_sim
g occ_group=`num'
cd $data\temp_files\iv
save sim_iv`num', replace
}


foreach num of numlist 23(1)25 {
cd $data\temp_files
u temp if occ_group!=`num', clear

g a1990=exp( log(impute_share1990))
g a2010=exp( log(impute_share1990)+7.204779*val_1990*expected_commute-7.204779*val_2010*expected_commute)


sort occ2010 metarea
by occ2010 metarea: egen sim1990=sum(a1990)
by occ2010 metarea: egen sim2010=sum(a2010)

replace sim1990=a1990/sim1990
replace sim2010=a2010/sim2010

replace sim1990=sim1990*count1990
replace sim2010=sim2010*count1990

g sim1990_high=sim1990 if high_skill==1
g sim1990_low=sim1990 if high_skill==0

g sim2010_high=sim2010 if high_skill==1
g sim2010_low=sim2010 if high_skill==0

collapse (sum) sim1990_high  (sum) sim1990_low (sum) sim2010_high (sum) sim2010_low (sum) count=count1990,by(gisjoin metarea)

g dln_sim_low=ln(sim2010_low)-ln(sim1990_low)
g dln_sim_high=ln(sim2010_high)-ln(sim1990_high)
g dln_sim=ln(sim2010_high+sim2010_low)-ln(sim1990_high+sim1990_low)

keep gisjoin dln_sim_low dln_sim_high dln_sim
g occ_group=`num'
cd $data\temp_files\iv
save sim_iv`num', replace
}


clear all
foreach num of numlist 1(1)21 {
append using sim_iv`num'
}

foreach num of numlist 23(1)25 {
append using sim_iv`num'
}

save sim_iv, replace


*** total instrument for housing rent

cd $data\temp_files
u temp, clear
g a1990=exp( log(impute_share1990))
g a2010=exp( log(impute_share1990)+8.934139*val_1990*expected_commute-8.934139*val_2010*expected_commute)


sort occ2010 metarea
by occ2010 metarea: egen sim1990=sum(a1990)
by occ2010 metarea: egen sim2010=sum(a2010)

replace sim1990=a1990/sim1990
replace sim2010=a2010/sim2010

replace sim1990=sim1990*count1990
replace sim2010=sim2010*count1990

g sim1990_high=sim1990 if high_skill==1
g sim1990_low=sim1990 if high_skill==0

g sim2010_high=sim2010 if high_skill==1
g sim2010_low=sim2010 if high_skill==0

collapse (sum) sim1990_high  (sum) sim1990_low (sum) sim2010_high (sum) sim2010_low (sum) count=count1990,by(gisjoin metarea)


g dln_sim_low=ln(sim2010_low)-ln(sim1990_low)
g dln_sim_high=ln(sim2010_high)-ln(sim1990_high)
g dln_sim=ln(sim2010_high+sim2010_low)-ln(sim1990_high+sim1990_low)

keep gisjoin dln_sim_low dln_sim_high dln_sim
ren dln_sim_low dln_sim_low_total
ren dln_sim_high dln_sim_high_total
ren dln_sim dln_sim_total
cd $data\temp_files\iv
save sim_iv_total, replace


*** Ingredient for instrument for amenity shock

cd $data\temp_files
u temp, clear

g a1990=exp( log(impute_share1990))
g a2010=exp( log(impute_share1990)+8.934139*val_1990*expected_commute-8.934139*val_2010*expected_commute)

sort occ2010 metarea
by occ2010 metarea: egen sim1990=sum(a1990)
by occ2010 metarea: egen sim2010=sum(a2010)

replace sim1990=a1990/sim1990
replace sim2010=a2010/sim2010

replace sim1990=sim1990*count1990
replace sim2010=sim2010*count1990

cd $data\inter_files\demographic\education

g sim1990_high=sim1990 if high_skill==1
g sim1990_low=sim1990 if high_skill==0

g sim2010_high=sim2010 if high_skill==1
g sim2010_low=sim2010 if high_skill==0

collapse (sum) sim1990_high  (sum) sim1990_low (sum) sim2010_high (sum) sim2010_low,by(gisjoin)

cd $data\temp_files\iv

save ingredient_for_iv_amenity, replace



*************************************+*************************************+****
**# Data Prep -  Housing Demand
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"


cd $data\temp_files
u tract_impute_share, clear

cd $data\temp_files
merge m:1 occ2010 using inc_occ_1990_2000_2010
keep if _merge==3
drop _merge
drop count* wage_real1990 wage_real2000 wage_real2010

cd $data\temp_files
merge m:1 occ2010 metarea using wage_metarea
keep if _merge==3
drop _merge

g inc1990=impute_share1990*inc_mean1990*count1990
g inc2010=impute_share2010*inc_mean2010*count2010

collapse (sum) inc1990 inc2010, by(gisjoin metarea)
g ddemand=ln(inc2010)-ln(inc1990)
keep gisjoin ddemand
cd $data\temp_files
save ddemand, replace


*************************************+*************************************+****
**# Data Prep -  Housing Density
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"
*** import area (1980 census tract)
cd $data\geographic
import delimited UStract1980.csv, varnames(1) clear 

keep gisjoin area_sm
destring area_sm, g(area) ignore(",")

keep gisjoin area
cd $data\geographic
save area1980, replace


*** housing in the 1980s
cd $data\nhgis
import delimited nhgis0034_ds107_1980_tract.csv, clear
ren def001 room

keep gisjoin room
sort gisjoin
cd $data\temp_files
save room1980, replace


** Create room density (using 1980 housing data)
cd $data\geographic
u tract1990_tract1980_1mi, clear

ren gisjoin2 gisjoin
cd $data\geographic
merge m:1 gisjoin using area1980
drop _merge
cd $data\temp_files
merge m:1 gisjoin using room1980
drop _merge

collapse (sum) area room, by(gisjoin1)

g room_density_1mi_3mi=(room)/(area)
replace room_density_1mi_3mi=0 if room_density_1mi_3mi==.
ren gisjoin1 gisjoin

save room_density1980_1mi, replace

*************************************+*************************************+****
**# Data Prep -  Counterfactual Value
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"

****************
** Create value for employment proximity term in 1990
cd $data\temp_files
u occ_emp_share_1994, clear
cd $data\temp_files
merge m:1 occ2010 using val_40_60_total_1990_2000_2010
keep if _merge==3
drop _merge

cd $data\temp_files
merge m:1 occ2010 using high_skill
drop if _merge==2
drop _merge

drop se_1990 se_2010
cd $data\temp_files
save occ_emp_share_temp, replace

***

***
# delimit

foreach num of numlist 30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 
2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3740 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520
5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 
 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;

# delimit cr
cd $data\temp_files
u occ_emp_share_temp, clear
keep if occ2010==`num'
cd $data\temp_files

merge 1:m zip using travel_time_hat
keep if _merge==3
drop _merge

ren travel_time_hat travel_time

** commuting hours per work week
replace travel_time=travel_time*10

g value1990=exp(-1.408819*val_1990*travel_time*(1-high_skill) -6.002858*high_skill*val_1990*travel_time)

sort zip

replace value1990=value1990*share

collapse (sum) counterfactual_share=value1990, by(gisjoin)

g occ2010=`num'
cd $data\temp_files\counterfactual
save value_term1990_`num', replace
}



cd $data\temp_files\counterfactual
clear
# delimit
foreach num of numlist 30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3740 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520 5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;
# delimit cr


append using value_term1990_`num'

}

save value_term1990, replace

****


# delimit

foreach num of numlist 30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 
2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3740 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520
5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 
 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;

# delimit cr
cd $data\temp_files\
u occ_emp_share_temp, clear
keep if occ2010==`num'
cd $data\temp_files\

merge 1:m zip using travel_time_hat
keep if _merge==3
drop _merge

ren travel_time_hat travel_time

** commuting hours per work week
replace travel_time=travel_time*10

g value2000=exp(-1.408819*val_2000*travel_time*(1-high_skill) -6.002858*high_skill*val_2000*travel_time)

sort zip

replace value2000=value2000*share

collapse (sum) counterfactual_share=value2000, by(gisjoin)

g occ2010=`num'
cd $data\temp_files\counterfactual
save value_term2000_`num', replace
}

cd $data\temp_files\counterfactual
clear
# delimit
foreach num of numlist 30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3740 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520 5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;
# delimit cr

append using value_term2000_`num'

}

save value_term2000, replace


****

# delimit

foreach num of numlist 30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 
2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3740 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520
5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 
 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;

# delimit cr
cd $data\temp_files\
u occ_emp_share_temp, clear
keep if occ2010==`num'
cd $data\temp_files\

merge 1:m zip using travel_time_hat
keep if _merge==3
drop _merge

ren travel_time_hat travel_time

** commuting hours per work week
replace travel_time=travel_time*10

g value2010=exp(-1.408819*val_2010*travel_time*(1-high_skill) -6.002858*high_skill*val_2010*travel_time)

sort zip

replace value2010=value2010*share

collapse (sum) counterfactual_share=value2010, by(gisjoin)

g occ2010=`num'
cd $data\temp_files\counterfactual
save value_term2010_`num', replace
}

cd $data\temp_files\counterfactual
clear
# delimit
foreach num of numlist 30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3740 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520 5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;
# delimit cr

append using value_term2010_`num'

}

save value_term2010, replace


*********************************


****************
** Create value for employment proximity term in 1990
cd $data\temp_files
u occ_emp_share_1994, clear
cd $data\temp_files
merge m:1 metarea occ2010 using val_40_60_total_1990_2000_2010
drop _merge

cd $data\temp_files
merge m:1 occ2010 using high_skill_30
drop if _merge==2
drop _merge

cd $data\temp_files
save occ_emp_share_temp_30, replace

***

***
# delimit

foreach num of numlist 30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 
2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3740 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520
5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 
 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;

# delimit cr
cd $data\temp_files
u occ_emp_share_temp_30, clear
keep if occ2010==`num'
cd $data\temp_files
drop if zip==.
merge 1:m zip using travel_time_hat
keep if _merge==3
drop _merge

ren travel_time_hat travel_time

** commuting hours per work week
replace travel_time=travel_time*10

g value1990=exp(-2.128*val_1990*travel_time*(1-high_skill) -6.184*high_skill*val_1990*travel_time)

sort zip

replace value1990=value1990*share

collapse (sum) counterfactual_share=value1990, by(gisjoin)

g occ2010=`num'
cd $data\temp_files\counterfactual
save value_term1990_30_`num', replace
}



cd $data\temp_files\counterfactual
clear
# delimit
foreach num of numlist 30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3740 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520 5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;
# delimit cr


append using value_term1990_30_`num'

}

save value_term1990_high30, replace

****
****

# delimit

foreach num of numlist 30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 
2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3740 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520
5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 
 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;

# delimit cr
cd $data\temp_files\
u occ_emp_share_temp_30, clear
keep if occ2010==`num'
cd $data\temp_files\
drop if zip==.
merge 1:m zip using travel_time_hat
keep if _merge==3
drop _merge

ren travel_time_hat travel_time

** commuting hours per work week
replace travel_time=travel_time*10

g value2010=exp(-2.128*val_2010*travel_time*(1-high_skill) -6.184*high_skill*val_2010*travel_time)

sort zip

replace value2010=value2010*share

collapse (sum) counterfactual_share=value2010, by(gisjoin)

g occ2010=`num'
cd $data\temp_files\counterfactual
save value_term2010_30_`num', replace
}

cd $data\temp_files\counterfactual
clear
# delimit
foreach num of numlist 30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3740 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520 5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;
# delimit cr

append using value_term2010_30_`num'

}

save value_term2010_high30, replace


********************************


****************
** Create value for employment proximity term in 1990
cd $data\temp_files
u occ_emp_share_1994, clear
cd $data\temp_files
merge m:1 occ2010 using val_40_60_total_1990_2000_2010
keep if _merge==3
drop _merge

cd $data\temp_files
merge m:1 occ2010 using high_skill_50
drop if _merge==2
drop _merge

cd $data\temp_files
save occ_emp_share_temp_50, replace

***

***
# delimit

foreach num of numlist 30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 
2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3740 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520
5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 
 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;

# delimit cr
cd $data\temp_files
u occ_emp_share_temp_50, clear
keep if occ2010==`num'
cd $data\temp_files
drop if zip==.
merge 1:m zip using travel_time_hat
keep if _merge==3
drop _merge

ren travel_time_hat travel_time

** commuting hours per work week
replace travel_time=travel_time*10

g value1990=exp(-3.431*val_1990*travel_time*(1-high_skill) -9.494*high_skill*val_1990*travel_time)

sort zip

replace value1990=value1990*share

collapse (sum) counterfactual_share=value1990, by(gisjoin)

g occ2010=`num'
cd $data\temp_files\counterfactual
save value_term1990_50_`num', replace
}



cd $data\temp_files\counterfactual
clear
# delimit
foreach num of numlist 30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3740 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520 5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;
# delimit cr


append using value_term1990_50_`num'

}

save value_term1990_high50, replace

****
****

# delimit

foreach num of numlist 30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 
2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3740 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520
5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 
 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;

# delimit cr
cd $data\temp_files\
u occ_emp_share_temp_50, clear
keep if occ2010==`num'
cd $data\temp_files\
drop if zip==.
merge 1:m zip using travel_time_hat
keep if _merge==3
drop _merge

ren travel_time_hat travel_time

** commuting hours per work week
replace travel_time=travel_time*10

g value2010=exp(-3.431*val_2010*travel_time*(1-high_skill) -9.494*high_skill*val_2010*travel_time)

sort zip

replace value2010=value2010*share

collapse (sum) counterfactual_share=value2010, by(gisjoin)

g occ2010=`num'
cd $data\temp_files\counterfactual
save value_term2010_50_`num', replace
}

cd $data\temp_files\counterfactual
clear
# delimit
foreach num of numlist 30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3740 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520 5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;
# delimit cr

append using value_term2010_50_`num'

}

save value_term2010_high50, replace


*************************************+*************************************+****
**# Output -  Amenities
*************************************+*************************************+****

  
clear all
global data="/Users/linagomez/Documents/Stata/Economía Urbana/132721-V1/data"

***** pick out establishments of interest and generate zip code statistics to plot. 
**1. Restaurant 2. grocery store 3. gym  4. personal care

cd $data\zbp
*** restaurant
u zip94detail, clear
keep if sic=="5812" | sic=="5813"
collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
cd $data\temp_files
save restaurant94,replace

cd $data\zbp
u zip00detail, clear
g lastthreedigit=substr(naics,4,3)
g lasttwodigit=substr(naics,5,2)
g lastdigit=substr(naics,6,1)
drop if lastthreedigit=="---"
drop if lasttwodigit=="--"
drop if lastdigit=="-"
g naics_3=substr(naics,1,3)
keep if naics_3=="722"
collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
cd $data\temp_files
save restaurant00,replace

cd $data\zbp
u zip10detail, clear
g lastthreedigit=substr(naics,4,3)
g lasttwodigit=substr(naics,5,2)
g lastdigit=substr(naics,6,1)
drop if lastthreedigit=="---"
drop if lasttwodigit=="--"
drop if lastdigit=="-"
g naics_3=substr(naics,1,3)
keep if naics_3=="722"
collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
cd $data\temp_files
save restaurant10,replace


*** grocery store 

cd $data\zbp
u zip94detail, clear
g lasttwodigit=substr(sic,3,2)
g lastdigit=substr(sic,4,1)
drop if lasttwodigit=="--"
drop if lastdigit=="-"
g sic_2=substr(sic,1,2)
keep if sic_2=="54"
collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
cd $data\temp_files
save grocery94, replace

cd $data\zbp
u zip00detail, clear
g lastthreedigit=substr(naics,4,3)
g lasttwodigit=substr(naics,5,2)
g lastdigit=substr(naics,6,1)
drop if lastthreedigit=="---"
drop if lasttwodigit=="--"
drop if lastdigit=="-"
g naics_3=substr(naics,1,3)
keep if naics_3=="445"
collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
cd $data\temp_files
save grocery00, replace

cd $data\zbp
u zip10detail, clear
g lastthreedigit=substr(naics,4,3)
g lasttwodigit=substr(naics,5,2)
g lastdigit=substr(naics,6,1)
drop if lastthreedigit=="---"
drop if lasttwodigit=="--"
drop if lastdigit=="-"
g naics_3=substr(naics,1,3)
keep if naics_3=="445"
collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
cd $data\temp_files
save grocery10, replace

*** gym
cd $data\zbp
u zip94detail, clear
keep if sic=="7991"
collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
cd $data\temp_files
save gym94, replace

cd $data\zbp
u zip00detail, clear
g lastdigit=substr(naics,6,1)
drop if lastdigit=="-"
g naics_5=substr(naics,1,5)
keep if naics_5=="71394"
collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
cd $data\temp_files
save gym00, replace

cd $data\zbp
u zip10detail, clear
g lastdigit=substr(naics,6,1)
drop if lastdigit=="-"
g naics_5=substr(naics,1,5)
keep if naics_5=="71394"
collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
cd $data\temp_files
save gym10, replace


** personal care services
cd $data\zbp
u zip94detail, clear
keep if sic=="7230" | sic=="7240" | sic=="7299"
collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
cd $data\temp_files
save personal94, replace

cd $data\zbp
u zip00detail, clear
g lasttwodigit=substr(naics,5,2)
g lastdigit=substr(naics,6,1)
drop if lasttwodigit=="--"
drop if lastdigit=="-"
g naics_4=substr(naics,1,4)
keep if naics_4=="8121"
collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
cd $data\temp_files
save personal00, replace

cd $data\zbp
u zip10detail, clear
g lasttwodigit=substr(naics,5,2)
g lastdigit=substr(naics,6,1)
drop if lasttwodigit=="--"
drop if lastdigit=="-"
g naics_4=substr(naics,1,4)
keep if naics_4=="8121"
collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
cd $data\temp_files
save personal10, replace


**** make it tract level

*** restaurant
cd $data\temp_files
u restaurant94, clear
egen est_small= rowtotal(n1_4 n5_9)
egen est_large= rowtotal(n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000)
keep zip est_small est_large
cd $data\geographic
merge 1:m zip using tract1990_zip1990_1mi
keep if _merge==3
drop _merge
capture collapse (sum) est_small est_large, by(gisjoin)
cd $data\temp_files
save tract_restaurant94, replace

cd $data\geographic
u tract1990_zip1990_nearest, clear
cd $data\temp_files
merge m:1 zip using restaurant94
egen est_small= rowtotal(n1_4 n5_9)
egen est_large= rowtotal(n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000)
keep gisjoin est_small est_large
capture collapse (sum) est_small_nearest=est_small est_large_nearest=est_large, by(gisjoin)
merge 1:1 gisjoin using tract_restaurant94
drop _merge
replace est_small=est_small_nearest if est_small==.
replace est_large=est_large_nearest if est_large==.
keep gisjoin est_small est_large
drop if gisjoin==""
save tract_restaurant94, replace

** 2000
cd $data\temp_files
u restaurant00, clear
egen est_small= rowtotal(n1_4 n5_9)
egen est_large= rowtotal(n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000)
keep zip est_small est_large
cd $data\geographic
merge 1:m zip using tract1990_zip2000_1mi
keep if _merge==3
drop _merge
capture collapse (sum) est_small est_large, by(gisjoin)
cd $data\temp_files
save tract_restaurant00, replace

cd $data\geographic
u tract1990_zip2000_nearest, clear
cd $data\temp_files
merge m:1 zip using restaurant00
egen est_small= rowtotal(n1_4 n5_9)
egen est_large= rowtotal(n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000)
keep gisjoin est_small est_large
capture collapse (sum) est_small_nearest=est_small est_large_nearest=est_large, by(gisjoin)
merge 1:1 gisjoin using tract_restaurant00
drop _merge
replace est_small=est_small_nearest if est_small==.
replace est_large=est_large_nearest if est_large==.
keep gisjoin est_small est_large
drop if gisjoin==""
save tract_restaurant00, replace

** 2010
cd $data\temp_files
u restaurant10, clear
egen est_small= rowtotal(n1_4 n5_9)
egen est_large= rowtotal(n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000)
keep zip est_small est_large
cd $data\geographic
merge 1:m zip using tract1990_zip2010_1mi
keep if _merge==3
drop _merge
capture collapse (sum) est_small est_large, by(gisjoin)
cd $data\temp_files
save tract_restaurant10, replace

cd $data\geographic
u tract1990_zip2010_nearest, clear
cd $data\temp_files
merge m:1 zip using restaurant10
egen est_small= rowtotal(n1_4 n5_9)
egen est_large= rowtotal(n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000)
keep gisjoin est_small est_large
capture collapse (sum) est_small_nearest=est_small est_large_nearest=est_large, by(gisjoin)
merge 1:1 gisjoin using tract_restaurant10
drop _merge
replace est_small=est_small_nearest if est_small==.
replace est_large=est_large_nearest if est_large==.
keep gisjoin est_small est_large
drop if gisjoin==""
save tract_restaurant10, replace



*** grocery
cd $data\temp_files
u grocery94, clear
egen est_small= rowtotal(n1_4 n5_9 n10_19 n20_49)
egen est_large= rowtotal( n50_99 n100_249 n250_499 n500_999 n1000)
keep zip est_small est_large
cd $data\geographic
merge 1:m zip using tract1990_zip1990_1mi
keep if _merge==3
drop _merge
capture collapse (sum) est_small est_large, by(gisjoin)
cd $data\temp_files
save tract_grocery94, replace

cd $data\geographic
u tract1990_zip1990_nearest, clear
cd $data\temp_files
merge m:1 zip using grocery94
egen est_small= rowtotal(n1_4 n5_9 n10_19 n20_49)
egen est_large= rowtotal( n50_99 n100_249 n250_499 n500_999 n1000)
keep gisjoin est_small est_large
capture collapse (sum) est_small_nearest=est_small est_large_nearest=est_large, by(gisjoin)
merge 1:1 gisjoin using tract_grocery94
drop _merge
replace est_small=est_small_nearest if est_small==.
replace est_large=est_large_nearest if est_large==.
keep gisjoin est_small est_large
drop if gisjoin==""
save tract_grocery94, replace

** 2000
cd $data\temp_files
u grocery00, clear
egen est_small= rowtotal(n1_4 n5_9 n10_19 n20_49 )
egen est_large= rowtotal(n50_99 n100_249 n250_499 n500_999 n1000)
keep zip est_small est_large
cd $data\geographic
merge 1:m zip using tract1990_zip2000_1mi
keep if _merge==3
drop _merge
capture collapse (sum) est_small est_large, by(gisjoin)
cd $data\temp_files
save tract_grocery00, replace

cd $data\geographic
u tract1990_zip2000_nearest, clear
cd $data\temp_files
merge m:1 zip using grocery00
egen est_small= rowtotal(n1_4 n5_9 n10_19 n20_49)
egen est_large= rowtotal( n50_99 n100_249 n250_499 n500_999 n1000)
keep gisjoin est_small est_large
capture collapse (sum) est_small_nearest=est_small est_large_nearest=est_large, by(gisjoin)
merge 1:1 gisjoin using tract_grocery00
drop _merge
replace est_small=est_small_nearest if est_small==.
replace est_large=est_large_nearest if est_large==.
keep gisjoin est_small est_large
drop if gisjoin==""
save tract_grocery00, replace

** 2010
cd $data\temp_files
u grocery10, clear
egen est_small= rowtotal(n1_4 n5_9 n10_19 n20_49)
egen est_large= rowtotal( n50_99 n100_249 n250_499 n500_999 n1000)
keep zip est_small est_large
cd $data\geographic
merge 1:m zip using tract1990_zip2010_1mi
keep if _merge==3
drop _merge
capture collapse (sum) est_small est_large, by(gisjoin)
cd $data\temp_files
save tract_grocery10, replace

cd $data\geographic
u tract1990_zip2010_nearest, clear
cd $data\temp_files
merge m:1 zip using grocery10
egen est_small= rowtotal(n1_4 n5_9 n10_19 n20_49)
egen est_large= rowtotal( n50_99 n100_249 n250_499 n500_999 n1000)
keep gisjoin est_small est_large
capture collapse (sum) est_small_nearest=est_small est_large_nearest=est_large, by(gisjoin)
merge 1:1 gisjoin using tract_grocery10
drop _merge
replace est_small=est_small_nearest if est_small==.
replace est_large=est_large_nearest if est_large==.
keep gisjoin est_small est_large
drop if gisjoin==""
save tract_grocery10, replace


*** gym
cd $data\temp_files
u gym94, clear
keep zip est
cd $data\geographic
merge 1:m zip using tract1990_zip1990_1mi
keep if _merge==3
drop _merge
capture collapse (sum) est, by(gisjoin)
cd $data\temp_files
save tract_gym94, replace

cd $data\geographic
u tract1990_zip1990_nearest, clear
cd $data\temp_files
merge m:1 zip using gym94

keep gisjoin est
capture collapse (sum) est_nearest=est, by(gisjoin)
merge 1:1 gisjoin using tract_gym94
drop _merge
replace est=est_nearest if est==.
keep gisjoin est
drop if gisjoin==""
save tract_gym94, replace

** 2000
cd $data\temp_files
u gym00, clear
keep zip est
cd $data\geographic
merge 1:m zip using tract1990_zip2000_1mi
keep if _merge==3
drop _merge
capture collapse (sum) est, by(gisjoin)
cd $data\temp_files
save tract_gym00, replace

cd $data\geographic
u tract1990_zip2000_nearest, clear
cd $data\temp_files
merge m:1 zip using gym00

keep gisjoin est
capture collapse (sum) est_nearest=est, by(gisjoin)
merge 1:1 gisjoin using tract_gym00
drop _merge
replace est=est_nearest if est==.
keep gisjoin est
drop if gisjoin==""
save tract_gym00, replace

** 2010
cd $data\temp_files
u gym10, clear
keep zip est
cd $data\geographic
merge 1:m zip using tract1990_zip2010_1mi
keep if _merge==3
drop _merge
capture collapse (sum) est, by(gisjoin)
cd $data\temp_files
save tract_gym10, replace

cd $data\geographic
u tract1990_zip2010_nearest, clear
cd $data\temp_files
merge m:1 zip using gym10

keep gisjoin est
capture collapse (sum) est_nearest=est, by(gisjoin)
merge 1:1 gisjoin using tract_gym10
drop _merge
replace est=est_nearest if est==.
keep gisjoin est
drop if gisjoin==""
save tract_gym10, replace

*** personal
cd $data\temp_files
u personal94, clear
egen est_small= rowtotal(n1_4 n5_9)
egen est_large= rowtotal(n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000)
keep zip est_small est_large
cd $data\geographic
merge 1:m zip using tract1990_zip1990_1mi
keep if _merge==3
drop _merge
capture collapse (sum) est_small est_large, by(gisjoin)
cd $data\temp_files
save tract_personal94, replace

cd $data\geographic
u tract1990_zip1990_nearest, clear
cd $data\temp_files
merge m:1 zip using personal94
egen est_small= rowtotal(n1_4 n5_9)
egen est_large= rowtotal(n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000)
keep gisjoin est_small est_large
capture collapse (sum) est_small_nearest=est_small est_large_nearest=est_large, by(gisjoin)
merge 1:1 gisjoin using tract_personal94
drop _merge
replace est_small=est_small_nearest if est_small==.
replace est_large=est_large_nearest if est_large==.
keep gisjoin est_small est_large
drop if gisjoin==""
save tract_personal94, replace

** 2000
cd $data\temp_files
u personal00, clear
egen est_small= rowtotal(n1_4 n5_9)
egen est_large= rowtotal(n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000)
keep zip est_small est_large
cd $data\geographic
merge 1:m zip using tract1990_zip2000_1mi
keep if _merge==3
drop _merge
capture collapse (sum) est_small est_large, by(gisjoin)
cd $data\temp_files
save tract_personal00, replace

cd $data\geographic
u tract1990_zip2000_nearest, clear
cd $data\temp_files
merge m:1 zip using personal00
egen est_small= rowtotal(n1_4 n5_9)
egen est_large= rowtotal(n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000)
keep gisjoin est_small est_large
capture collapse (sum) est_small_nearest=est_small est_large_nearest=est_large, by(gisjoin)
merge 1:1 gisjoin using tract_personal00
drop _merge
replace est_small=est_small_nearest if est_small==.
replace est_large=est_large_nearest if est_large==.
keep gisjoin est_small est_large
drop if gisjoin==""
save tract_personal00, replace

** 2010
cd $data\temp_files
u personal10, clear
egen est_small= rowtotal(n1_4 n5_9)
egen est_large= rowtotal(n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000)
keep zip est_small est_large
cd $data\geographic
merge 1:m zip using tract1990_zip2010_1mi
keep if _merge==3
drop _merge
capture collapse (sum) est_small est_large, by(gisjoin)
cd $data\temp_files
save tract_personal10, replace

cd $data\geographic
u tract1990_zip2010_nearest, clear
cd $data\temp_files
merge m:1 zip using personal10
egen est_small= rowtotal(n1_4 n5_9)
egen est_large= rowtotal(n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000)
keep gisjoin est_small est_large
capture collapse (sum) est_small_nearest=est_small est_large_nearest=est_large, by(gisjoin)
merge 1:1 gisjoin using tract_personal10
drop _merge
replace est_small=est_small_nearest if est_small==.
replace est_large=est_large_nearest if est_large==.
keep gisjoin est_small est_large
drop if gisjoin==""
save tract_personal10, replace


*** merge
* restaurant
cd $data\temp_files
u tract_restaurant94, clear
ren est_small est_small_restaurant1990
ren est_large est_large_restaurant1990

merge 1:1 gisjoin using tract_restaurant00
drop _merge
ren est_small est_small_restaurant2000
ren est_large est_large_restaurant2000

merge 1:1 gisjoin using tract_restaurant10
drop _merge
ren est_small est_small_restaurant2010
ren est_large est_large_restaurant2010

save tract_restaurant, replace

** grocery
u tract_grocery94, clear
ren est_small est_small_grocery1990
ren est_large est_large_grocery1990

merge 1:1 gisjoin using tract_grocery00
drop _merge
ren est_small est_small_grocery2000
ren est_large est_large_grocery2000

merge 1:1 gisjoin using tract_grocery10
drop _merge
ren est_small est_small_grocery2010
ren est_large est_large_grocery2010

save tract_grocery, replace

*** gym
u tract_gym94, clear
ren est est_gym1990
merge 1:1 gisjoin using tract_gym00
drop _merge
ren est est_gym2000
merge 1:1 gisjoin using tract_gym10
drop _merge
ren est est_gym2010
save tract_gym, replace

** personal
u tract_personal94, clear
ren est_small est_small_personal1990
ren est_large est_large_personal1990

merge 1:1 gisjoin using tract_personal00
drop _merge
ren est_small est_small_personal2000
ren est_large est_large_personal2000

merge 1:1 gisjoin using tract_personal10
drop _merge
ren est_small est_small_personal2010
ren est_large est_large_personal2010

save tract_personal, replace

*** 
u tract_restaurant, clear

merge 1:1 gisjoin using tract_grocery
drop _merge
merge 1:1 gisjoin using tract_gym
drop _merge
merge 1:1 gisjoin using tract_personal
drop _merge


sort gisjoin
save tract_amenities, replace

****************************** Code above generates intermediate files (intermediate files are already generated in the folders)
********************************************************************************************
****************************** Code below generates Table 1 and 6 (Code below can be run directly without running the above code)
**** Regress the change of local neighborhood amenities on local skill ratio

cd $data\geographic
u tract1990_tract1990_2mi, clear

keep if dist<=1610
cd $data\temp_files

ren gisjoin2 gisjoin

merge m:1 gisjoin using population1990
keep if _merge==3
drop _merge

ren population population1990

merge m:1 gisjoin using population2010
keep if _merge==3
drop _merge

drop gisjoin
ren gisjoin1 gisjoin

cd $data\temp_files

merge m:1 gisjoin using skill_pop_1mi
keep if _merge==3
drop _merge

*** Merge the ingredient to compute the instrumental variable for local skill ratio
cd $data\temp_files\iv
merge m:1 gisjoin using ingredient_for_iv_amenity
keep if _merge==3
drop _merge


collapse (sum) population1990 population2010 impute2010_high impute2010_low impute1990_high impute1990_low sim1990_high sim1990_low sim2010_high sim2010_low, by(gisjoin)

cd $data\temp_files

merge 1:1 gisjoin using tract_amenities
keep if _merge==3
drop _merge

cd $data\geographic

merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

** restaurant
g d_large_restaurant=ln( (est_large_restaurant2010+1)/(population2010+1))-ln( (est_large_restaurant1990+1)/(population1990+1))
g d_small_restaurant=ln( (est_small_restaurant2010+1)/(population2010+1))-ln( (est_small_restaurant1990+1)/(population1990+1))
g d_restaurant=ln((est_small_restaurant2010+est_large_restaurant2010+1)/(population2010+1))-ln((est_small_restaurant1990+est_large_restaurant1990+1)/(population1990+1))

** grocery stores
g d_large_grocery=ln( (est_large_grocery2010+1)/(population2010+1))-ln( (est_large_grocery1990+1)/(population1990+1))
g d_small_grocery=ln( (est_small_grocery2010+1)/(population2010+1))-ln( (est_small_grocery1990+1)/(population1990+1))

g d_grocery=ln( (est_small_grocery2010+est_large_grocery2010+1)/(population2010+1))-ln( (est_small_grocery1990+est_large_grocery1990+1)/(population1990+1))
** gym
g d_gym=ln( (est_gym2010+1)/(population2010+1))-ln( (est_gym1990+1)/(population1990+1))

** personal services
g d_large_personal=ln( (est_large_personal2010+1)/(population2010+1))-ln( (est_large_personal1990+1)/(population1990+1))
g d_small_personal=ln( (est_small_personal2010+1)/(population2010+1))-ln( (est_small_personal1990+1)/(population1990+1))

g d_personal=ln( (est_small_personal2010+est_large_personal2010+1)/(population2010+1))-ln( (est_small_personal1990+est_large_personal1990+1)/(population1990+1))

g dratio=ln((impute2010_high+1)/(impute2010_low+1))-ln((impute1990_high+1)/(impute1990_low+1))

g dratio_sim=ln(sim2010_high/sim2010_low)- ln(sim1990_high/sim1990_low)
g dln_sim_high=ln(sim2010_high)- ln(sim1990_high)
g dln_sim_low=ln(sim2010_low)- ln(sim1990_low)

duplicates drop gisjoin, force
cd $data\temp_files
egen tract_id=group(gisjoin)

save data_matlab, replace



**** Regressions
* Column (1-4) of Table 1
cd $data\temp_files

u data_matlab, clear

reghdfe d_restaurant dratio, absorb(metarea) vce(robust)
reghdfe d_grocery dratio, absorb(metarea) vce(robust)
reghdfe d_gym dratio, absorb(metarea) vce(robust)
reghdfe d_personal dratio, absorb(metarea) vce(robust)

*** IV regression for amenity equation
* Column (1-4) of Table 6
******
ivreghdfe d_restaurant (dratio=dln_sim_high dln_sim_low), absorb(metarea) robust
ivreghdfe d_grocery (dratio=dln_sim_high dln_sim_low), absorb(metarea) robust
ivreghdfe d_gym (dratio= dln_sim_high dln_sim_low), absorb(metarea) robust
ivreghdfe d_personal (dratio= dln_sim_high dln_sim_low), absorb(metarea) robust

****
** crime amenity

clear all
cd $data\crime
import delimited crime_place2013_tract1990.csv , varnames(1) clear

keep gisjoin crime_violent_rate1990 crime_property_rate1990 crime_violent_rate2010 crime_property_rate2010 gisjoin_1

ren gisjoin gisjoin_muni
ren gisjoin_1 gisjoin

cd $data\temp_files

merge 1:1 gisjoin using population1990
keep if _merge==3
drop _merge

merge 1:1 gisjoin using population2010
keep if _merge==3
drop _merge

cd $data\temp_files

merge 1:1 gisjoin using skill_pop
keep if _merge==3
drop _merge

cd $data\temp_files\iv
merge m:1 gisjoin using ingredient_for_iv_amenity
drop if _merge==2
drop _merge

cd $data\geographic

merge m:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge


collapse (sum) impute2010_high impute2010_low impute1990_high impute1990_low population population2010 sim1990_high sim1990_low sim2010_high sim2010_low (mean) crime_violent_rate* crime_property_rate* , by(gisjoin_muni metarea)

g dratio=ln((impute2010_high+1)/(impute2010_low+1))-ln((impute1990_high+1)/(impute1990_low+1))
g dratio_sim=ln(sim2010_high/sim2010_low)- ln(sim1990_high/sim1990_low)
g dviolent=ln( crime_violent_rate2010+0.1)-ln( crime_violent_rate1990+0.1)
g dproperty=ln( crime_property_rate2010+0.1)-ln( crime_property_rate1990+0.1)


g dln_sim_high=ln(sim2010_high)- ln(sim1990_high)
g dln_sim_low=ln(sim2010_low)- ln(sim1990_low)

*** Column 5-6 of Table 1
reghdfe dproperty dratio [w=population] if dln_sim_high!=., absorb(metarea) vce(robust)
reghdfe dviolent dratio [w=population] if dln_sim_high!=., absorb(metarea)  vce(robust)
*** Column 5-6 of Table 6
ivreghdfe dproperty (dratio=dln_sim_high dln_sim_low) [w=population] , absorb(metarea) robust
ivreghdfe dviolent (dratio=dln_sim_high dln_sim_low) [w=population], absorb(metarea) robust
  


*************************************+*************************************+****
**# Output -  Motivation
*************************************+*************************************+****


clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"


cd $data\ipums_micro
u 1990_2000_2010_temp , clear

keep if uhrswork>=30

keep if sex==1
keep if age>=25 & age<=65
keep if year==1990 | year==2010

drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork==0
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

replace inctot_real=inctot_real/52

g greaterthan50=0
replace greaterthan50=1 if uhrswork>=50
collapse greaterthan50, by(year occ2010)

reshape wide greaterthan50, i(occ2010) j(year)

g ln_d=ln( greaterthan502010)-ln( greaterthan501990)

cd $data\temp_files

merge 1:1 occ2010 using inc_occ_1990_2000_2010
drop _merge

drop inc_mean1990 inc_mean2000 inc_mean2010 wage_real1990 wage_real2000 wage_real2010

cd $data\temp_files

merge 1:1 occ2010 using val_40_60_total_1990_2000_2010
drop _merge

g dval=val_2010-val_1990


cd $data\temp_files

save reduced_form, replace
*****
*** Regress change in long hours on long hour premium 
cd $data\temp_files
u reduced_form, clear
** Table 3
* Column 1
reg ln_d dval [w=count1990] if dval!=., r


**** Change in central city share on change in long hours

cd $data\temp_files
 u tract_impute.dta, clear
 cd $data\geographic
 merge m:1 gisjoin using tract1990_downtown5mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge

cd $data\geographic

merge m:1 metarea using 1990_rank
keep if _merge==3
drop _merge

drop serial year

collapse (sum) impute1990 impute2000 impute2010, by(occ2010 metarea rank downtown)
by occ2010 metarea: g ratio1990=impute1990/(impute1990+impute1990[_n-1])
by occ2010 metarea: g ratio2000=impute2000/(impute2000+impute2000[_n-1])
by occ2010 metarea: g ratio2010=impute2010/(impute2010+impute2010[_n-1])

keep occ2010 metarea downtown ratio1990 ratio2000 ratio2010 rank

g dratio=ln(ratio2010)-ln(ratio1990)

cd $data\temp_files
merge m:1 occ2010 using reduced_form
keep if _merge==3
drop _merge

drop count*
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

* Table 2
* Column 1 - 3 
reg dratio i.metarea ln_d [ w=count1990] if dval!=. & rank<=10 & downtown==1, cluster(metarea)
reg dratio i.metarea ln_d [ w=count1990] if dval!=. & rank<=25 & downtown==1, cluster(metarea)
reg dratio i.metarea ln_d [ w=count1990] if dval!=. & downtown==1, cluster(metarea)

** Table 3
* Column 2-4
reg dratio i.metarea dval [ w=count1990] if dval!=. & downtown==1 & rank<=10, cluster(metarea)
reg dratio i.metarea dval [ w=count1990] if dval!=. & downtown==1 & rank<=25, cluster(metarea)
reg dratio i.metarea dval [ w=count1990] if dval!=. & downtown==1, cluster(metarea)


**** Commute time on change in long hours

cd $data\ipums_micro
u 1990_2000_2010_temp , clear

keep if uhrswork>=30

*keep if rank<=25
keep if sex==1
keep if age>=25 & age<=65
keep if year==1990 | year==2010

replace trantime=ln(trantime)
collapse trantime, by(year occ2010 metarea rank)

reshape wide trantime, i(occ2010 metarea) j(year)

g dtran= trantime2010-trantime1990

cd $data\temp_files
merge m:1 occ2010 using reduced_form
drop _merge

drop count*
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

* Table 2
* Column 4-6 
reg dtran i.metarea ln_d [w=count1990] if dval!=. & rank<=10, cluster(metarea)
reg dtran i.metarea ln_d [w=count1990] if dval!=. & rank<=25, cluster(metarea)
reg dtran i.metarea ln_d [w=count1990] if dval!=., cluster(metarea)

* Table 3
* Column 5-7 
reg dtran i.metarea dval [w=count1990] if dval!=. & rank<=10, cluster(metarea)
reg dtran i.metarea dval [w=count1990] if dval!=. & rank<=25, cluster(metarea)
reg dtran i.metarea dval [w=count1990] if dval!=., cluster(metarea)


*************************************+*************************************+****
**# Output -  Summary Statistics
*************************************+*************************************+****


clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"

**** Summary statistics

*** Rent

cd $data\temp_files
u data, clear

duplicates drop gisjoin, force

g ln_rent1990=ln(rent1990)
g ln_rent2010=ln(rent2010)

sum ln_rent1990, d
sum ln_rent2010, d

*** Skill ratio

cd $data\final_data
u data, clear

duplicates drop gisjoin, force

keep gisjoin

cd $data\inter_files\demographic\education

merge 1:1 gisjoin using skill_pop
keep if _merge==3
drop _merge
g ln_ratio_1990=ln( impute1990_high/ impute1990_low)
sum ln_ratio_1990, d
g ln_ratio_2010=ln( impute2010_high/ impute2010_low)
sum ln_ratio_2010, d
g dratio= ln_ratio_2010- ln_ratio_1990
sum dratio, d

*** Value of time (Long-hour premium)

cd $data\raw_data\ipums_raw
u 1990_2000_2010_temp , clear

keep if uhrswork>=30

keep if sex==1
keep if age>=25 & age<=65
keep if year==1990 | year==2010

drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork==0
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

replace inctot_real=inctot_real/52

g greaterthan50=0
replace greaterthan50=1 if uhrswork>=50
collapse greaterthan50, by(year occ2010)

reshape wide greaterthan50, i(occ2010) j(year)

g ln_d=ln( greaterthan502010)-ln( greaterthan501990)

cd $data\inter_files\ipums

merge 1:1 occ2010 using inc_occ_1990_2000_2010
drop _merge

drop inc_mean1990 inc_mean2000 inc_mean2010 wage_real1990 wage_real2000 wage_real2010

cd $data\inter_files\ipums\value_of_time

g metarea=112

merge 1:1 occ2010 using val_40_60_total_1990_2000_2010
drop _merge

merge 1:1 metarea occ2010 using val_time_log_wage
drop if _merge==2
drop _merge

g dwage=wage_real2010-wage_real1990

merge 1:1 metarea occ2010 using val_time_sd_earning
drop if _merge==2
drop _merge

g dsd=sd_inctot2010-sd_inctot1990

drop count1990 count2000 count2010

cd $data\inter_files\ipums
merge 1:1 metarea occ2010 using count_metarea
keep if _merge==3
drop _merge

g dval=val_2010-val_1990

cd $data\inter_files\demographic\education
merge m:1 occ2010 using high_skill
drop if _merge==2
drop _merge

keep val_1990 val_2010 dval high_skill

drop if dval==.

sum val_1990 if high_skill==1
sum val_2010 if high_skill==1
sum dval if high_skill==1

sum val_1990 if high_skill==0
sum val_2010 if high_skill==0
sum dval if high_skill==0

sum val_1990
sum val_2010
sum dval


*** Amenities

cd $data\inter_files\geographic
u tract1990_tract1990_2mi, clear

keep if dist<=1610
cd $data\inter_files\demographic\population

ren gisjoin2 gisjoin

merge m:1 gisjoin using population1990
keep if _merge==3
drop _merge

ren population population1990

merge m:1 gisjoin using population2010
keep if _merge==3
drop _merge

drop gisjoin
ren gisjoin1 gisjoin

cd $data\inter_files\demographic\education

merge m:1 gisjoin using skill_pop_1mi
keep if _merge==3
drop _merge

*** Merge the ingredient to compute the instrumental variable for local skill ratio
cd $data\inter_files\instrument
merge m:1 gisjoin using ingredient_for_iv_amenity
keep if _merge==3
drop _merge


collapse (sum) population1990 population2010 impute2010_high impute2010_low impute1990_high impute1990_low sim1990_high sim1990_low sim2010_high sim2010_low, by(gisjoin)

cd $data\inter_files\amenities

merge 1:1 gisjoin using tract_amenities
keep if _merge==3
drop _merge

cd $data\inter_files\geographic

merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

** restaurant
g d_large_restaurant=ln( (est_large_restaurant2010+1)/(population2010+1))-ln( (est_large_restaurant1990+1)/(population1990+1))
g d_small_restaurant=ln( (est_small_restaurant2010+1)/(population2010+1))-ln( (est_small_restaurant1990+1)/(population1990+1))
g d_restaurant=ln((est_small_restaurant2010+est_large_restaurant2010+1)/(population2010+1))-ln((est_small_restaurant1990+est_large_restaurant1990+1)/(population1990+1))

** grocery stores
g d_large_grocery=ln( (est_large_grocery2010+1)/(population2010+1))-ln( (est_large_grocery1990+1)/(population1990+1))
g d_small_grocery=ln( (est_small_grocery2010+1)/(population2010+1))-ln( (est_small_grocery1990+1)/(population1990+1))

g d_grocery=ln( (est_small_grocery2010+est_large_grocery2010+1)/(population2010+1))-ln( (est_small_grocery1990+est_large_grocery1990+1)/(population1990+1))
** gym
g d_gym=ln( (est_gym2010+1)/(population2010+1))-ln( (est_gym1990+1)/(population1990+1))

** personal services
g d_large_personal=ln( (est_large_personal2010+1)/(population2010+1))-ln( (est_large_personal1990+1)/(population1990+1))
g d_small_personal=ln( (est_small_personal2010+1)/(population2010+1))-ln( (est_small_personal1990+1)/(population1990+1))

g d_personal=ln( (est_small_personal2010+est_large_personal2010+1)/(population2010+1))-ln( (est_small_personal1990+est_large_personal1990+1)/(population1990+1))

g dratio=ln((impute2010_high+1)/(impute2010_low+1))-ln((impute1990_high+1)/(impute1990_low+1))

g dratio_sim=ln(sim2010_high/sim2010_low)- ln(sim1990_high/sim1990_low)
g dln_sim_high=ln(sim2010_high)- ln(sim1990_high)
g dln_sim_low=ln(sim2010_low)- ln(sim1990_low)

duplicates drop gisjoin, force
cd $data\inter_files\amenities
egen tract_id=group(gisjoin)

g ln_restaurant_1990=ln((est_small_restaurant1990+est_large_restaurant1990+1)/(population1990+1))
g ln_restaurant_2010=ln((est_small_restaurant2010+est_large_restaurant2010+1)/(population2010+1))

g ln_grocery_1990=ln( (est_small_grocery1990+est_large_grocery1990+1)/(population1990+1))
g ln_grocery_2010=ln( (est_small_grocery2010+est_large_grocery2010+1)/(population2010+1))

g ln_gym_1990=ln( (est_gym1990+1)/(population1990+1))
g ln_gym_2010=ln( (est_gym2010+1)/(population2010+1))

g ln_personal_1990=ln( (est_small_personal1990+est_large_personal1990+1)/(population1990+1))
g ln_personal_2010=ln( (est_small_personal2010+est_large_personal2010+1)/(population2010+1))


*** Crime 
* crime amenity

clear all
cd $data\raw_data\geographic_raw\place_tract
import delimited crime_place2013_tract1990.csv , varnames(1) clear

keep gisjoin crime_violent_rate1990 crime_property_rate1990 crime_violent_rate2010 crime_property_rate2010 gisjoin_1

ren gisjoin gisjoin_muni
ren gisjoin_1 gisjoin

cd $data\inter_files\demographic\population

merge 1:1 gisjoin using population1990
keep if _merge==3
drop _merge

merge 1:1 gisjoin using population2010
keep if _merge==3
drop _merge

cd $data\inter_files\demographic\education

merge 1:1 gisjoin using skill_pop
keep if _merge==3
drop _merge

cd $data\inter_files\instrument
merge m:1 gisjoin using ingredient_for_iv_amenity
drop if _merge==2
drop _merge

cd $data\inter_files\geographic

merge m:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge


collapse (sum) impute2010_high impute2010_low impute1990_high impute1990_low population population2010 sim1990_high sim1990_low sim2010_high sim2010_low (mean) crime_violent_rate* crime_property_rate* , by(gisjoin_muni metarea)

g dratio=ln((impute2010_high+1)/(impute2010_low+1))-ln((impute1990_high+1)/(impute1990_low+1))
g dratio_sim=ln(sim2010_high/sim2010_low)- ln(sim1990_high/sim1990_low)
g dviolent=ln( crime_violent_rate2010+0.1)-ln( crime_violent_rate1990+0.1)
g dproperty=ln( crime_property_rate2010+0.1)-ln( crime_property_rate1990+0.1)

g ln_violent_1990=ln( crime_violent_rate1990+0.1)

g ln_violent_2010=ln( crime_violent_rate2010+0.1)

g ln_property_1990=ln( crime_property_rate1990+0.1)

g ln_property_2010=ln( crime_property_rate2010+0.1)
*************************************+*************************************+****
**# Output - Main Regression
*************************************+*************************************+****
 
  
  clear all
global data="/Users/linagomez/Documents/Stata/Economía Urbana/132721-V1/data"


** residential data
cd "$data/temp_files"
u tract_impute_share, clear

** Commute time data
cd "$data/temp_files/commute"

merge 1:m gisjoin occ2010 using commute
keep if _merge==3
drop _merge

ren expected_commute expected_commute_1990

merge 1:m gisjoin occ2010 using commute2010
keep if _merge==3
drop _merge

ren expected_commute expected_commute_2010
ren expected_commute_1990 expected_commute

g dexpected=expected_commute_2010-expected_commute

*** value of time data
cd "$data/temp_files"
merge m:1 occ2010 using val_40_60_total_1990_2000_2010
keep if _merge==3
drop _merge

drop se_1990 se_2000

*** rent
cd "$data/temp_files"
merge m:1 gisjoin using rent
drop if _merge==2
drop _merge

*** instrument for location demand


* MANAGEMENT, BUSINESS, SCIENCE, AND ARTS
g occ_group=1 if occ2010>=10 & occ2010<=430
* BUSINESS OPERATIONS SPECIALISTS
replace occ_group=2 if occ2010>=500 & occ2010<=730
* FINANCIAL SPECIALISTS
replace occ_group=3 if occ2010>=800 & occ2010<=950
* COMPUTER AND MATHEMATICAL
replace occ_group=4 if occ2010>=1000 & occ2010<=1240
* ARCHITECTURE AND ENGINEERING
replace occ_group=5 if occ2010>=1300 & occ2010<=1540
* TECHNICIANS
replace occ_group=6 if occ2010>=1550 & occ2010<=1560
* LIFE, PHYSICAL, AND SOCIAL SCIENCE
replace occ_group=7 if occ2010>=1600 & occ2010<=1980
* COMMUNITY AND SOCIAL SERVICES
replace occ_group=8 if occ2010>=2000 & occ2010<=2060
* LEGAL
replace occ_group=9 if occ2010>=2100 & occ2010<=2150
* EDUCATION, TRAINING, AND LIBRARY
replace occ_group=10 if occ2010>=2200 & occ2010<=2550
* ARTS, DESIGN, ENTERTAINMENT, SPORTS, AND MEDIA
replace occ_group=11 if occ2010>=2600 & occ2010<=2920
* HEALTHCARE PRACTITIONERS AND TECHNICAL
replace occ_group=12 if occ2010>=3000 & occ2010<=3540
* HEALTHCARE SUPPORT
replace occ_group=13 if occ2010>=3600 & occ2010<=3650
* PROTECTIVE SERVICE
replace occ_group=14 if occ2010>=3700 & occ2010<=3950
* FOOD PREPARATION AND SERVING
replace occ_group=15 if occ2010>=4000 & occ2010<=4150
* BUILDING AND GROUNDS CLEANING AND MAINTENANCE
replace occ_group=16 if occ2010>=4200 & occ2010<=4250
* PERSONAL CARE AND SERVICE
replace occ_group=17 if occ2010>=4300 & occ2010<=4650
* SALES AND RELATED
replace occ_group=18 if occ2010>=4700 & occ2010<=4965
* OFFICE AND ADMINISTRATIVE SUPPORT
replace occ_group=19 if occ2010>=5000 & occ2010<=5940
* FARMING, FISHING, AND FORESTRY
replace occ_group=20 if occ2010>=6005 & occ2010<=6130
* CONSTRUCTION
replace occ_group=21 if occ2010>=6200 & occ2010<=6765
* EXTRACTION
replace occ_group=22 if occ2010>=6800 & occ2010<=6940
* INSTALLATION, MAINTENANCE, AND REPAIR
replace occ_group=23 if occ2010>=7000 & occ2010<=7630
* PRODUCTION
replace occ_group=24 if occ2010>=7700 & occ2010<=8965
* TRANSPORTATION AND MATERIAL MOVING
replace occ_group=25 if occ2010>=9000 & occ2010<=9750

cd "$data/temp_files/commute"
merge m:1 gisjoin occ_group using commute_total
drop _merge


cd "$data/temp_files/iv"
merge m:1 gisjoin occ_group using sim_iv
keep if _merge==3
drop _merge

merge m:1 gisjoin using sim_iv_total
keep if _merge==3
drop _merge

cd "$data/temp_files"
merge m:1 gisjoin using skill_ratio_occupation
keep if _merge==3
drop _merge

cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge

cd "$data/temp_files"
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

drop if count1990==.

g dimpute=ln(impute_share2010)-ln(impute_share1990)
egen tract_id=group(gisjoin)
egen metarea_occ=group(metarea occ2010)
drop year serial
drop  count2000 count2010

g dval=val_2010-val_1990

g dval_expected_commute=dval*expected_commute

g drent=ln(rent2010+1)-ln(rent1990+1)

ren count1990 count

cd "$data/temp_files"
merge m:1 occ2010 using high_skill
drop if _merge==2
drop _merge


cd "$data/temp_files"
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66


g high_skill_dratio=high_skill*dratio

g high_skill_dln_sim_high=high_skill* dln_sim_high

g high_skill_dln_sim_low=high_skill* dln_sim_low

g high_skill_dln_sim=high_skill*dln_sim

g dln_sim_density=dln_sim*room_density_1mi_3mi

g dln_sim_high_density=dln_sim_high*room_density_1mi_3mi

g dln_sim_low_density=dln_sim_low*room_density_1mi_3mi

g dln_sim_total_density=dln_sim_total*room_density_1mi_3mi

g dln_sim_high_total_density=dln_sim_high_total*room_density_1mi_3mi

g dln_sim_low_total_density=dln_sim_low_total*room_density_1mi_3mi


***
g high_skill_drent= high_skill*drent
g high_skill_dln_sim_density = high_skill*dln_sim_density
g high_skill_dln_sim_high_density= high_skill*dln_sim_high_density 
g high_skill_dln_sim_low_density =high_skill*dln_sim_low_density
g high_skill_room_density_1mi_3mi= high_skill*room_density_1mi_3mi
g high_skill_expected_commute=high_skill*expected_commute
g high_dval_expected_commute=high_skill*dval_expected_commute
*** construct rent equation variable
cd "$data/temp_files"
merge m:1 gisjoin using ddemand
keep if _merge==3
drop _merge

cd "$data/temp_files"
merge m:1 metarea occ2010 using trantime_metarea_occ2010
drop _merge

g dtran_expected_commute=dtran*expected_commute
g high_dtran_expected_commute= high_skill*dtran_expected_commute

merge m:1 occ2010 using val_time_sd_earning_total_standard
drop _merge

merge m:1 occ2010 using val_greaterthan50
drop _merge

replace ln_d=ln(greaterthan502010)-ln(greaterthan501990)

g dsd_expected_commute=(sd_inctot2010-sd_inctot1990)*expected_commute
g high_dsd_expected_commute=high_skill*dsd_expected_commute

g ln_d_expected_commute=ln_d*expected_commute
g high_ln_d_expected_commute=high_skill*ln_d_expected_commute

cd "$temp_files"
save data, replace

**** Regress 
cd "$data/temp_files"
u data, clear

 g ddemand_density=room_density_1mi_3mi*ddemand
 ******************************************************************
 *** Main specification (Table 5)
 
 ** Panel A
 ** Worker's residential location demand
  *ivreghdfe es regresión variable instrumental con múltiples niveles de efectos fijos.
  # delimit
ivreghdfe dimpute expected_commute high_skill_expected_commute dval_expected_commute high_dval_expected_commute 
(dratio high_skill_dratio drent high_skill_drent=  dln_sim_high dln_sim_low high_skill_dln_sim_high high_skill_dln_sim_low dln_sim_density dln_sim_high_density dln_sim_low_density high_skill_dln_sim_density high_skill_dln_sim_high_density high_skill_dln_sim_low_density high_skill_room_density_1mi_3mi room_density_1mi_3mi)
[w=count] , absorb(i.metarea_occ i.occ2010#c.dexpected i.occ2010#c.total_commute) cluster(tract_id) gmm2s;
 # delimit cr

 * Commute cost
 
* High-skilled
*lincom - linear combination of parameters. After fitting a model and obtaining estimates for coefficients B1, B2,... you may want to view estimates for linear combinations of the  Bi. lincom can display estimates for any linear combination of the form c0 + c1 1 + c2 2 + ... + ck k.
lincom dval_expected_commute + high_dval_expected_commute
* Low-skilled
lincom dval_expected_commute

* Amenities

* High-skilled
lincom dratio + high_skill_dratio
* low-skilled
lincom dratio

* Rent

* High_skilled
lincom drent + high_skill_drent
* Low-skilled
lincom drent

 
 * Panel B
 ** Housing supply equation
  ivreghdfe drent room_density_1mi_3mi (ddemand_density =dln_sim_total_density dln_sim_low_total_density dln_sim_high_total_density)[w=count], absorb(i.metarea) cluster(tract_id) gmm2s

 
 *** robustness checks (Table 7)
 
 * Column 1
 
 *** Commute only
   # delimit
reghdfe dimpute expected_commute high_skill_expected_commute dval_expected_commute high_dval_expected_commute [w=count] , absorb(i.metarea_occ i.occ2010#c.dexpected i.occ2010#c.total_commute) cluster(tract_id);
 # delimit cr
 
 * Commute cost
 
* High-skilled
lincom dval_expected_commute+ high_dval_expected_commute
* Low-skilled
lincom dval_expected_commute
 
 ** Column 2
 * Commute and amenities
 
  # delimit
ivreghdfe dimpute expected_commute high_skill_expected_commute dval_expected_commute high_dval_expected_commute (dratio high_skill_dratio=  dln_sim_high dln_sim_low high_skill_dln_sim_high high_skill_dln_sim_low ) [w=count] , absorb(i.metarea_occ i.occ2010#c.dexpected i.occ2010#c.total_commute) cluster(tract_id) gmm2s;
 # delimit cr
 
** Commute cost
 
* High-skilled
lincom dval_expected_commute+ high_dval_expected_commute
 * Low-skilled
lincom dval_expected_commute
 
** Amenities
 
* High-skilled
lincom dratio + high_skill_dratio
* Low-skilled
lincom dratio

 ** Column 3
 ** Commute and rents
 
   # delimit
ivreghdfe dimpute expected_commute high_skill_expected_commute dval_expected_commute high_dval_expected_commute  (drent high_skill_drent=   dln_sim_density dln_sim_high_density dln_sim_low_density high_skill_dln_sim_density high_skill_dln_sim_high_density high_skill_dln_sim_low_density high_skill_room_density_1mi_3mi room_density_1mi_3mi) [w=count] , absorb(i.metarea_occ i.occ2010#c.dexpected i.occ2010#c.total_commute) cluster(tract_id) gmm2s;
 # delimit cr
 
 ** Commute cost
 
* High-skilled
lincom dval_expected_commute+ high_dval_expected_commute
 * Low-skilled
lincom dval_expected_commute

*  Rent
* High-skilled
lincom drent + high_skill_drent
* Low-skilled
lincom drent

** Column 4
** Residual log earnings dispersion
  # delimit
ivreghdfe dimpute expected_commute high_skill_expected_commute dsd_expected_commute high_dsd_expected_commute (dratio high_skill_dratio drent high_skill_drent=  dln_sim_high dln_sim_low high_skill_dln_sim_high high_skill_dln_sim_low dln_sim_density dln_sim_high_density dln_sim_low_density high_skill_dln_sim_density high_skill_dln_sim_high_density high_skill_dln_sim_low_density high_skill_room_density_1mi_3mi room_density_1mi_3mi) [w=count] , absorb(i.metarea_occ i.occ2010#c.dexpected i.occ2010#c.total_commute) cluster(tract_id) gmm2s;
 # delimit cr
 
 ** Commute cost
 
* High-skilled
lincom dsd_expected_commute+ high_dsd_expected_commute
 * Low-skilled
lincom dsd_expected_commute

* Amenities
* High-skilled
lincom dratio + high_skill_dratio
* Low-skilled
lincom dratio
 
*  Rent
* High-skilled
lincom drent + high_skill_drent
* Low-skilled
lincom drent

 ** Column 5
 ** Change in prevalence in long hours
 
    # delimit
ivreghdfe dimpute expected_commute high_skill_expected_commute ln_d_expected_commute high_ln_d_expected_commute (dratio high_skill_dratio drent high_skill_drent=  dln_sim_high dln_sim_low high_skill_dln_sim_high high_skill_dln_sim_low dln_sim_density dln_sim_high_density dln_sim_low_density high_skill_dln_sim_density high_skill_dln_sim_high_density high_skill_dln_sim_low_density high_skill_room_density_1mi_3mi room_density_1mi_3mi) [w=count] , absorb(i.metarea_occ i.occ2010#c.dexpected i.occ2010#c.total_commute) cluster(tract_id) gmm2s;
 # delimit cr
 
 
 ** Commute cost
 
 * High-skilled
lincom ln_d_expected_commute+ high_ln_d_expected_commute
 * Low-skilled
lincom ln_d_expected_commute

** Amenities

* High-skilled
lincom dratio + high_skill_dratio
* Low-skilled
lincom dratio
 
*  Rent
* High-skilled
lincom drent + high_skill_drent
* Low-skilled
lincom drent
 
 ** Column 6
 ** Change in observed commute time
 
   # delimit
ivreghdfe dimpute expected_commute high_skill_expected_commute dtran_expected_commute high_dtran_expected_commute (dratio high_skill_dratio drent high_skill_drent=  dln_sim_high dln_sim_low high_skill_dln_sim_high high_skill_dln_sim_low dln_sim_density dln_sim_high_density dln_sim_low_density high_skill_dln_sim_density high_skill_dln_sim_high_density high_skill_dln_sim_low_density high_skill_room_density_1mi_3mi room_density_1mi_3mi) [w=count] , absorb(i.metarea_occ i.occ2010#c.dexpected i.occ2010#c.total_commute) cluster(tract_id) gmm2s;
 # delimit cr
 
  ** Commute cost
 
 * High-skilled
lincom dtran_expected_commute+ high_dtran_expected_commute
 * Low-skilled
lincom dtran_expected_commute

** Amenities

* High-skilled
lincom dratio + high_skill_dratio
* Low-skilled
lincom dratio
 
*  Rent
* High-skilled
lincom drent + high_skill_drent
* Low-skilled
lincom drent
 
** Column 7 and 8 are conducted in "output_regression_robustness_skill30.do", "output_regression_robustness_skill50.do"
 
 *** Reduced form results (Table A5)
 
 # delimit
reghdfe dimpute expected_commute high_skill_expected_commute dval_expected_commute high_dval_expected_commute  dln_sim_high dln_sim_low high_skill_dln_sim_high high_skill_dln_sim_low dln_sim_density dln_sim_high_density dln_sim_low_density high_skill_dln_sim_density high_skill_dln_sim_high_density high_skill_dln_sim_low_density high_skill_room_density_1mi_3mi room_density_1mi_3mi [w=count] , absorb(i.metarea_occ i.occ2010#c.dexpected i.occ2010#c.total_commute) cluster(tract_id);
 # delimit cr
 
 * dv*E(c)
 * high-skilled
lincom dval_expected_commute+ high_dval_expected_commute 
 * low-skilled
lincom dval_expected_commute 

 * dln(N_H)
 * high-skilled
lincom dln_sim_high+ high_skill_dln_sim_high
 * low-skilled
lincom dln_sim_high
 
 * dln(N_L)
 * high-skilled
lincom dln_sim_low+ high_skill_dln_sim_low
 * low-skilled
lincom dln_sim_low

 * dln(N_H)* den
 * high-skilled
lincom dln_sim_high_density + high_skill_dln_sim_high_density
 * low-skilled
lincom dln_sim_high_density
 
 * dln(N_L)* den
 * high-skilled
lincom dln_sim_low_density + high_skill_dln_sim_low_density
 * low-skilled
lincom dln_sim_low_density
 
 * dln(N_H+N_L)* den
 * high-skilled
lincom dln_sim_density + high_skill_dln_sim_density
 * low-skilled
lincom dln_sim_density
 
 * den
 * high-skilled
lincom room_density_1mi_3mi + high_skill_room_density_1mi_3mi 
 * low-skilled
lincom room_density_1mi_3mi





******************************************************************************************************
******************************************************************************************************
******************************************************************************************************
******************************************************************************************************
******************************************************************************************************
******************************************************************************************************
******************************************************************************************************
******************************************************************************************************
******************************************************************************************************
******************************************************************************************************


**** Summary statistics (Table 4)


*** Long hour premium
cd "$data/temp_files"
u val_40_60_total_1990_2000_2010, clear

g dval=val_2010-val_1990

merge m:1 occ2010 using high_skill
drop if _merge==2
drop _merge

keep val_1990 val_2010 dval high_skill

drop if dval==.

** Long hour premium
sum val_1990
sum val_2010
sum dval

sum val_1990 if high_skill==1
sum val_2010 if high_skill==1
sum dval if high_skill==1

sum val_1990 if high_skill==0
sum val_2010 if high_skill==0
sum dval if high_skill==0


*** Skill ratio

cd "$data/temp_files"
u data, clear

duplicates drop gisjoin, force

keep gisjoin

merge 1:1 gisjoin using skill_pop
keep if _merge==3
drop _merge
g ln_ratio_1990=ln( impute1990_high/ impute1990_low)
g ln_ratio_2010=ln( impute2010_high/ impute2010_low)
g dratio= ln_ratio_2010- ln_ratio_1990
sum ln_ratio_1990
sum ln_ratio_2010
sum dratio

*** Rent

cd "$data/temp_files"
u data, clear

duplicates drop gisjoin, force


g ln_rent1990=ln(rent1990)
g ln_rent2010=ln(rent2010)
sum ln_rent1990
sum ln_rent2010
sum drent

*** Amenities

cd "$data/geographic"
u tract1990_tract1990_2mi, clear

keep if dist<=1610
cd "$data/temp_files"

ren gisjoin2 gisjoin

merge m:1 gisjoin using population1990
keep if _merge==3
drop _merge

ren population population1990

merge m:1 gisjoin using population2010
keep if _merge==3
drop _merge

drop gisjoin
ren gisjoin1 gisjoin

cd "$data/temp_files"

merge m:1 gisjoin using skill_pop_1mi
keep if _merge==3
drop _merge

*** Merge the ingredient to compute the instrumental variable for local skill ratio
cd "$data/temp_files"\iv
merge m:1 gisjoin using ingredient_for_iv_amenity
keep if _merge==3
drop _merge


collapse (sum) population1990 population2010 impute2010_high impute2010_low impute1990_high impute1990_low sim1990_high sim1990_low sim2010_high sim2010_low, by(gisjoin)

cd "$data/temp_files"

merge 1:1 gisjoin using tract_amenities
keep if _merge==3
drop _merge

cd "$data/geographic"

merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

** restaurant
g d_large_restaurant=ln( (est_large_restaurant2010+1)/(population2010+1))-ln( (est_large_restaurant1990+1)/(population1990+1))
g d_small_restaurant=ln( (est_small_restaurant2010+1)/(population2010+1))-ln( (est_small_restaurant1990+1)/(population1990+1))
g d_restaurant=ln((est_small_restaurant2010+est_large_restaurant2010+1)/(population2010+1))-ln((est_small_restaurant1990+est_large_restaurant1990+1)/(population1990+1))

** grocery stores
g d_large_grocery=ln( (est_large_grocery2010+1)/(population2010+1))-ln( (est_large_grocery1990+1)/(population1990+1))
g d_small_grocery=ln( (est_small_grocery2010+1)/(population2010+1))-ln( (est_small_grocery1990+1)/(population1990+1))

g d_grocery=ln( (est_small_grocery2010+est_large_grocery2010+1)/(population2010+1))-ln( (est_small_grocery1990+est_large_grocery1990+1)/(population1990+1))
** gym
g d_gym=ln( (est_gym2010+1)/(population2010+1))-ln( (est_gym1990+1)/(population1990+1))

** personal services
g d_large_personal=ln( (est_large_personal2010+1)/(population2010+1))-ln( (est_large_personal1990+1)/(population1990+1))
g d_small_personal=ln( (est_small_personal2010+1)/(population2010+1))-ln( (est_small_personal1990+1)/(population1990+1))

g d_personal=ln( (est_small_personal2010+est_large_personal2010+1)/(population2010+1))-ln( (est_small_personal1990+est_large_personal1990+1)/(population1990+1))

g dratio=ln((impute2010_high+1)/(impute2010_low+1))-ln((impute1990_high+1)/(impute1990_low+1))

g dratio_sim=ln(sim2010_high/sim2010_low)- ln(sim1990_high/sim1990_low)
g dln_sim_high=ln(sim2010_high)- ln(sim1990_high)
g dln_sim_low=ln(sim2010_low)- ln(sim1990_low)

duplicates drop gisjoin, force

egen tract_id=group(gisjoin)

g ln_restaurant_1990=ln((est_small_restaurant1990+est_large_restaurant1990+1)/(population1990+1))
g ln_restaurant_2010=ln((est_small_restaurant2010+est_large_restaurant2010+1)/(population2010+1))
g dln_restaurant=ln_restaurant_2010-ln_restaurant_1990

g ln_grocery_1990=ln( (est_small_grocery1990+est_large_grocery1990+1)/(population1990+1))
g ln_grocery_2010=ln( (est_small_grocery2010+est_large_grocery2010+1)/(population2010+1))
g dln_grocery=ln_grocery_2010-ln_grocery_1990

g ln_gym_1990=ln( (est_gym1990+1)/(population1990+1))
g ln_gym_2010=ln( (est_gym2010+1)/(population2010+1))
g dln_gym=ln_gym_2010-ln_gym_1990

g ln_personal_1990=ln( (est_small_personal1990+est_large_personal1990+1)/(population1990+1))
g ln_personal_2010=ln( (est_small_personal2010+est_large_personal2010+1)/(population2010+1))
g dln_personal=ln_personal_2010-ln_personal_1990

** Table 4

** Amenities

** Restaurants

sum ln_restaurant_1990
sum ln_restaurant_2010
sum dln_restaurant

** Grocery

sum ln_grocery_1990
sum ln_grocery_2010
sum dln_grocery

** Gym

sum ln_gym_1990
sum ln_gym_2010
sum dln_gym

** Personal

sum ln_personal_1990
sum ln_personal_2010
sum dln_personal

*** Crime 
* crime amenity

clear all
cd "$data/crime"
import delimited crime_place2013_tract1990.csv , varnames(1) clear

keep gisjoin crime_violent_rate1990 crime_property_rate1990 crime_violent_rate2010 crime_property_rate2010 gisjoin_1

ren gisjoin gisjoin_muni
ren gisjoin_1 gisjoin

cd "$data/temp_files"

merge 1:1 gisjoin using population1990
keep if _merge==3
drop _merge

merge 1:1 gisjoin using population2010
keep if _merge==3
drop _merge

merge 1:1 gisjoin using skill_pop
keep if _merge==3
drop _merge

cd "$data/temp_files"\iv
merge m:1 gisjoin using ingredient_for_iv_amenity
drop if _merge==2
drop _merge

cd "$data/geographic"

merge m:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge


collapse (sum) impute2010_high impute2010_low impute1990_high impute1990_low population population2010 sim1990_high sim1990_low sim2010_high sim2010_low (mean) crime_violent_rate* crime_property_rate* , by(gisjoin_muni metarea)

g dratio=ln((impute2010_high+1)/(impute2010_low+1))-ln((impute1990_high+1)/(impute1990_low+1))
g dratio_sim=ln(sim2010_high/sim2010_low)- ln(sim1990_high/sim1990_low)
g dviolent=ln( crime_violent_rate2010+0.1)-ln( crime_violent_rate1990+0.1)
g dproperty=ln( crime_property_rate2010+0.1)-ln( crime_property_rate1990+0.1)

g ln_violent_1990=ln( crime_violent_rate1990+0.1)

g ln_violent_2010=ln( crime_violent_rate2010+0.1)

g ln_property_1990=ln( crime_property_rate1990+0.1)

g ln_property_2010=ln( crime_property_rate2010+0.1)

g dln_violent=ln_violent_2010-ln_violent_1990
g dln_property=ln_property_2010-ln_property_1990


*** Table 4 
** Violent crime
sum ln_violent_1990
sum ln_violent_2010
sum dln_violent

** Property crime

sum ln_property_1990
sum ln_property_2010
sum dln_property

*************************************+*************************************+****
**# Output - Regression Robustness Skills
*************************************+*************************************+****

clear all
global data="C:\Users\alen_\Dropbox\paper_folder\replication\data"


** residential data
cd $data\temp_files
u tract_impute_share, clear

** Commute time data
cd $data\temp_files\commute

merge 1:m gisjoin occ2010 using commute
keep if _merge==3
drop _merge

ren expected_commute expected_commute_1990

merge 1:m gisjoin occ2010 using commute2010
keep if _merge==3
drop _merge

ren expected_commute expected_commute_2010
ren expected_commute_1990 expected_commute

g dexpected=expected_commute_2010-expected_commute

*** value of time data
cd $data\temp_files
merge m:1 occ2010 using val_40_60_total_1990_2000_2010
keep if _merge==3
drop _merge

drop se_1990 se_2000

*** rent
cd $data\temp_files
merge m:1 gisjoin using rent
drop if _merge==2
drop _merge

*** instrument for location demand


* MANAGEMENT, BUSINESS, SCIENCE, AND ARTS
g occ_group=1 if occ2010>=10 & occ2010<=430
* BUSINESS OPERATIONS SPECIALISTS
replace occ_group=2 if occ2010>=500 & occ2010<=730
* FINANCIAL SPECIALISTS
replace occ_group=3 if occ2010>=800 & occ2010<=950
* COMPUTER AND MATHEMATICAL
replace occ_group=4 if occ2010>=1000 & occ2010<=1240
* ARCHITECTURE AND ENGINEERING
replace occ_group=5 if occ2010>=1300 & occ2010<=1540
* TECHNICIANS
replace occ_group=6 if occ2010>=1550 & occ2010<=1560
* LIFE, PHYSICAL, AND SOCIAL SCIENCE
replace occ_group=7 if occ2010>=1600 & occ2010<=1980
* COMMUNITY AND SOCIAL SERVICES
replace occ_group=8 if occ2010>=2000 & occ2010<=2060
* LEGAL
replace occ_group=9 if occ2010>=2100 & occ2010<=2150
* EDUCATION, TRAINING, AND LIBRARY
replace occ_group=10 if occ2010>=2200 & occ2010<=2550
* ARTS, DESIGN, ENTERTAINMENT, SPORTS, AND MEDIA
replace occ_group=11 if occ2010>=2600 & occ2010<=2920
* HEALTHCARE PRACTITIONERS AND TECHNICAL
replace occ_group=12 if occ2010>=3000 & occ2010<=3540
* HEALTHCARE SUPPORT
replace occ_group=13 if occ2010>=3600 & occ2010<=3650
* PROTECTIVE SERVICE
replace occ_group=14 if occ2010>=3700 & occ2010<=3950
* FOOD PREPARATION AND SERVING
replace occ_group=15 if occ2010>=4000 & occ2010<=4150
* BUILDING AND GROUNDS CLEANING AND MAINTENANCE
replace occ_group=16 if occ2010>=4200 & occ2010<=4250
* PERSONAL CARE AND SERVICE
replace occ_group=17 if occ2010>=4300 & occ2010<=4650
* SALES AND RELATED
replace occ_group=18 if occ2010>=4700 & occ2010<=4965
* OFFICE AND ADMINISTRATIVE SUPPORT
replace occ_group=19 if occ2010>=5000 & occ2010<=5940
* FARMING, FISHING, AND FORESTRY
replace occ_group=20 if occ2010>=6005 & occ2010<=6130
* CONSTRUCTION
replace occ_group=21 if occ2010>=6200 & occ2010<=6765
* EXTRACTION
replace occ_group=22 if occ2010>=6800 & occ2010<=6940
* INSTALLATION, MAINTENANCE, AND REPAIR
replace occ_group=23 if occ2010>=7000 & occ2010<=7630
* PRODUCTION
replace occ_group=24 if occ2010>=7700 & occ2010<=8965
* TRANSPORTATION AND MATERIAL MOVING
replace occ_group=25 if occ2010>=9000 & occ2010<=9750

cd $data\temp_files\commute
merge m:1 gisjoin occ_group using commute_total
drop _merge


cd $data\temp_files\iv
merge m:1 gisjoin occ_group using sim_iv
keep if _merge==3
drop _merge

merge m:1 gisjoin using sim_iv_total
keep if _merge==3
drop _merge

cd $data\temp_files
merge m:1 gisjoin using skill_ratio_occupation
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

drop if count1990==.

g dimpute=ln(impute_share2010)-ln(impute_share1990)
egen tract_id=group(gisjoin)
egen metarea_occ=group(metarea occ2010)
drop year serial
drop  count2000 count2010

g dval=val_2010-val_1990

g dval_expected_commute=dval*expected_commute

g drent=ln(rent2010+1)-ln(rent1990+1)

ren count1990 count

cd $data\temp_files
merge m:1 occ2010 using high_skill_30
drop if _merge==2
drop _merge


cd $data\temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66


g high_skill_dratio=high_skill*dratio

g high_skill_dln_sim_high=high_skill* dln_sim_high

g high_skill_dln_sim_low=high_skill* dln_sim_low

g high_skill_dln_sim=high_skill*dln_sim

g dln_sim_density=dln_sim*room_density_1mi_3mi

g dln_sim_high_density=dln_sim_high*room_density_1mi_3mi

g dln_sim_low_density=dln_sim_low*room_density_1mi_3mi

g dln_sim_total_density=dln_sim_total*room_density_1mi_3mi

g dln_sim_high_total_density=dln_sim_high_total*room_density_1mi_3mi

g dln_sim_low_total_density=dln_sim_low_total*room_density_1mi_3mi


***
g high_skill_drent= high_skill*drent
g high_skill_dln_sim_density = high_skill*dln_sim_density
g high_skill_dln_sim_high_density= high_skill*dln_sim_high_density 
g high_skill_dln_sim_low_density =high_skill*dln_sim_low_density
g high_skill_room_density_1mi_3mi= high_skill*room_density_1mi_3mi
g high_skill_expected_commute=high_skill*expected_commute
g high_dval_expected_commute=high_skill*dval_expected_commute
*** construct rent equation variable
cd $data\temp_files
merge m:1 gisjoin using ddemand
keep if _merge==3
drop _merge

cd $temp_files
save data_30, replace

**** Regress 
cd $data\temp_files
u data_30, clear

 g ddemand_density=room_density_1mi_3mi*ddemand
 *** Main specification (Table 7)
 ** Column 7
  # delimit
ivreghdfe dimpute expected_commute high_skill_expected_commute dval_expected_commute high_dval_expected_commute (dratio high_skill_dratio drent high_skill_drent=  dln_sim_high dln_sim_low high_skill_dln_sim_high high_skill_dln_sim_low dln_sim_density dln_sim_high_density dln_sim_low_density high_skill_dln_sim_density high_skill_dln_sim_high_density high_skill_dln_sim_low_density high_skill_room_density_1mi_3mi room_density_1mi_3mi) [w=count] , absorb(i.metarea_occ i.occ2010#c.dexpected i.occ2010#c.total_commute) cluster(tract_id) gmm2s;
 # delimit cr
 
 
 * Commute cost
 
* High-skilled
lincom dval_expected_commute+ high_dval_expected_commute
* Low-skilled
lincom dval_expected_commute

* Amenities

* High-skilled
lincom dratio + high_skill_dratio
* low-skilled
lincom dratio

* Rent

* High_skilled
lincom drent + high_skill_drent
* Low-skilled
lincom drent


*************************************+*************************************+****
**# Output - Regression Robustness Skills
*************************************+*************************************+****

clear all
global data="C:\Users\alen_\Dropbox\paper_folder\replication\data"


** residential data
cd $data\temp_files
u tract_impute_share, clear

** Commute time data
cd $data\temp_files\commute

merge 1:m gisjoin occ2010 using commute
keep if _merge==3
drop _merge

ren expected_commute expected_commute_1990

merge 1:m gisjoin occ2010 using commute2010
keep if _merge==3
drop _merge

ren expected_commute expected_commute_2010
ren expected_commute_1990 expected_commute

g dexpected=expected_commute_2010-expected_commute

*** value of time data
cd $data\temp_files
merge m:1 occ2010 using val_40_60_total_1990_2000_2010
keep if _merge==3
drop _merge

drop se_1990 se_2000

*** rent
cd $data\temp_files
merge m:1 gisjoin using rent
drop if _merge==2
drop _merge

*** instrument for location demand


* MANAGEMENT, BUSINESS, SCIENCE, AND ARTS
g occ_group=1 if occ2010>=10 & occ2010<=430
* BUSINESS OPERATIONS SPECIALISTS
replace occ_group=2 if occ2010>=500 & occ2010<=730
* FINANCIAL SPECIALISTS
replace occ_group=3 if occ2010>=800 & occ2010<=950
* COMPUTER AND MATHEMATICAL
replace occ_group=4 if occ2010>=1000 & occ2010<=1240
* ARCHITECTURE AND ENGINEERING
replace occ_group=5 if occ2010>=1300 & occ2010<=1540
* TECHNICIANS
replace occ_group=6 if occ2010>=1550 & occ2010<=1560
* LIFE, PHYSICAL, AND SOCIAL SCIENCE
replace occ_group=7 if occ2010>=1600 & occ2010<=1980
* COMMUNITY AND SOCIAL SERVICES
replace occ_group=8 if occ2010>=2000 & occ2010<=2060
* LEGAL
replace occ_group=9 if occ2010>=2100 & occ2010<=2150
* EDUCATION, TRAINING, AND LIBRARY
replace occ_group=10 if occ2010>=2200 & occ2010<=2550
* ARTS, DESIGN, ENTERTAINMENT, SPORTS, AND MEDIA
replace occ_group=11 if occ2010>=2600 & occ2010<=2920
* HEALTHCARE PRACTITIONERS AND TECHNICAL
replace occ_group=12 if occ2010>=3000 & occ2010<=3540
* HEALTHCARE SUPPORT
replace occ_group=13 if occ2010>=3600 & occ2010<=3650
* PROTECTIVE SERVICE
replace occ_group=14 if occ2010>=3700 & occ2010<=3950
* FOOD PREPARATION AND SERVING
replace occ_group=15 if occ2010>=4000 & occ2010<=4150
* BUILDING AND GROUNDS CLEANING AND MAINTENANCE
replace occ_group=16 if occ2010>=4200 & occ2010<=4250
* PERSONAL CARE AND SERVICE
replace occ_group=17 if occ2010>=4300 & occ2010<=4650
* SALES AND RELATED
replace occ_group=18 if occ2010>=4700 & occ2010<=4965
* OFFICE AND ADMINISTRATIVE SUPPORT
replace occ_group=19 if occ2010>=5000 & occ2010<=5940
* FARMING, FISHING, AND FORESTRY
replace occ_group=20 if occ2010>=6005 & occ2010<=6130
* CONSTRUCTION
replace occ_group=21 if occ2010>=6200 & occ2010<=6765
* EXTRACTION
replace occ_group=22 if occ2010>=6800 & occ2010<=6940
* INSTALLATION, MAINTENANCE, AND REPAIR
replace occ_group=23 if occ2010>=7000 & occ2010<=7630
* PRODUCTION
replace occ_group=24 if occ2010>=7700 & occ2010<=8965
* TRANSPORTATION AND MATERIAL MOVING
replace occ_group=25 if occ2010>=9000 & occ2010<=9750

cd $data\temp_files\commute
merge m:1 gisjoin occ_group using commute_total
drop _merge


cd $data\temp_files\iv
merge m:1 gisjoin occ_group using sim_iv
keep if _merge==3
drop _merge

merge m:1 gisjoin using sim_iv_total
keep if _merge==3
drop _merge

cd $data\temp_files
merge m:1 gisjoin using skill_ratio_occupation
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

drop if count1990==.

g dimpute=ln(impute_share2010)-ln(impute_share1990)
egen tract_id=group(gisjoin)
egen metarea_occ=group(metarea occ2010)
drop year serial
drop  count2000 count2010

g dval=val_2010-val_1990

g dval_expected_commute=dval*expected_commute

g drent=ln(rent2010+1)-ln(rent1990+1)

ren count1990 count

cd $data\temp_files
merge m:1 occ2010 using high_skill_50
drop if _merge==2
drop _merge


cd $data\temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66


g high_skill_dratio=high_skill*dratio

g high_skill_dln_sim_high=high_skill* dln_sim_high

g high_skill_dln_sim_low=high_skill* dln_sim_low

g high_skill_dln_sim=high_skill*dln_sim

g dln_sim_density=dln_sim*room_density_1mi_3mi

g dln_sim_high_density=dln_sim_high*room_density_1mi_3mi

g dln_sim_low_density=dln_sim_low*room_density_1mi_3mi

g dln_sim_total_density=dln_sim_total*room_density_1mi_3mi

g dln_sim_high_total_density=dln_sim_high_total*room_density_1mi_3mi

g dln_sim_low_total_density=dln_sim_low_total*room_density_1mi_3mi


***
g high_skill_drent= high_skill*drent
g high_skill_dln_sim_density = high_skill*dln_sim_density
g high_skill_dln_sim_high_density= high_skill*dln_sim_high_density 
g high_skill_dln_sim_low_density =high_skill*dln_sim_low_density
g high_skill_room_density_1mi_3mi= high_skill*room_density_1mi_3mi
g high_skill_expected_commute=high_skill*expected_commute
g high_dval_expected_commute=high_skill*dval_expected_commute
*** construct rent equation variable
cd $data\temp_files
merge m:1 gisjoin using ddemand
keep if _merge==3
drop _merge

cd $temp_files
save data_50, replace

**** Regress 
cd $data\temp_files
u data_50, clear

 g ddemand_density=room_density_1mi_3mi*ddemand
 *** Main specification (Table 7)
 ** Column 8
  # delimit
ivreghdfe dimpute expected_commute high_skill_expected_commute dval_expected_commute high_dval_expected_commute (dratio high_skill_dratio drent high_skill_drent=  dln_sim_high dln_sim_low high_skill_dln_sim_high high_skill_dln_sim_low dln_sim_density dln_sim_high_density dln_sim_low_density high_skill_dln_sim_density high_skill_dln_sim_high_density high_skill_dln_sim_low_density high_skill_room_density_1mi_3mi room_density_1mi_3mi) [w=count] , absorb(i.metarea_occ i.occ2010#c.dexpected i.occ2010#c.total_commute) cluster(tract_id) gmm2s;
 # delimit cr
 
 
 * Commute cost
 
* High-skilled
lincom dval_expected_commute+ high_dval_expected_commute
* Low-skilled
lincom dval_expected_commute

* Amenities

* High-skilled
lincom dratio + high_skill_dratio
* low-skilled
lincom dratio

* Rent

* High_skilled
lincom drent + high_skill_drent
* Low-skilled
lincom drent


*************************************+*************************************+****
**# Output - Counterfactual Main
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"

*** create counterfatual location share in 2010

cd $data\temp_files
u tract_impute_share, clear


cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2010
keep if _merge==3
drop _merge
ren counterfactual_share value_term2010

replace value_term1990=ln(value_term1990)
replace value_term2010=ln(value_term2010)

g sim2010=exp(ln(impute_share1990)-value_term1990+value_term2010)
sort occ2010 metarea gisjoin

by occ2010 metarea: egen total_sim2010=sum(sim2010)

g counterfactual_share=sim2010/total_sim2010
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data\temp_files

merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data\temp_files
merge m:1 occ2010 using inc_occ_1990_2000_2010
keep if _merge==3
drop _merge
drop count1990 count2000 count2010 wage_real1990 wage_real2000 wage_real2010

ren count1990_2 count1990
ren count2000_2 count2000
ren count2010_2 count2010

g impute2010_high_cf=counterfactual_share*count1990*high_skill
g impute2010_low_cf=counterfactual_share*count1990*(1-high_skill)

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

g inc1990=impute_share1990*inc_mean1990*count1990
g inc2010_cf=counterfactual_share*inc_mean1990*count1990

collapse (sum) impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low inc1990 inc2010_cf, by(metarea gisjoin)


cd $data\temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data\temp_files
u impute, clear

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace


**************************************
**** Three Mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

** Table 8
* column 1 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* column 4 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50



**************************************
**** Five Mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown5mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

** Table 8
* column 1 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* column 4 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50

********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************

*** counterfactual when skill ratio can change and rent can change, too. 
cd $data\temp_files
u impute, clear

g dln_sim_high_total  = ln(impute2010_high_cf)- ln(impute1990_high)
g dln_sim_low_total =ln(impute2010_low_cf)-ln(impute1990_low)

g drent_predict=0.099514*(ln(inc2010_cf)-ln(inc1990)) + 0.01814*room_density_1mi_3mi

g ratio1990=impute1990_high/impute1990_low
g ratio2010=impute2010_high/impute2010_low
g dratio=ln(ratio2010)-ln(ratio1990)


keep gisjoin dln_sim_high_total dln_sim_low_total ratio1990 ratio2010 dratio drent_predict

cd $data\geographic
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

*** rent
cd $data\temp_files
merge m:1 gisjoin using rent
drop if _merge==2
drop _merge

g drent=ln(rent2010)-ln(rent1990)

g dln_ratio=dln_sim_high_total -dln_sim_low_total

reg dratio i.metarea  dln_ratio [w=population]

predict dln_ratio_cf, xb
drop dln_ratio

reg drent i.metarea drent_predict  [w=population]

predict drent_cf, xb
drop drent


keep gisjoin dln_ratio_cf drent_cf
cd $data\temp_files
save counterfactual_I_pre_merge, replace

cd $data\temp_files
u data, clear

cd $data\temp_files
merge m:1 gisjoin using counterfactual_I_pre_merge
keep if _merge==3
drop _merge

cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2010
keep if _merge==3
drop _merge
ren counterfactual_share value_term2010

replace value_term1990=ln(value_term1990)
replace value_term2010=ln(value_term2010)


g sim2010=exp(ln(impute_share1990)-value_term1990 + value_term2010 + 0.34529*dln_ratio_cf*(1-high_skill) + 1.6172921*dln_ratio_cf*high_skill  -0.43598*drent_cf*(1-high_skill) - 0.5732421*drent_cf*high_skill)
sort occ2010 metarea gisjoin

by occ2010 metarea: egen total_sim2010=sum(sim2010)

g counterfactual_share=sim2010/total_sim2010

drop count 
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge


g counterfactual=count1990*counterfactual_share

cd $data\temp_files

merge m:1 occ2010 using college_share
keep if _merge==3
drop _merge


g impute2010_high_cf=counterfactual*high_skill
g impute2010_low_cf=counterfactual*(1-high_skill)

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

collapse (sum) impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low, by(metarea gisjoin)

*************************
cd $data\temp_files

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace



*****************************************
**** Three mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)


cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

** Table 8
* column 2 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* column 5 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50


*****************************************
**** Five mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown5mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)


cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]


** Table 8
* column 2 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* column 5 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50
********************************
********************************
********************************
********************************
********************************
********************************
********************************
**********************

*** counterfactual when skill ratio can change and rent does not change. 
cd $data\temp_files
u impute, clear

g dln_sim_high_total  = ln(impute2010_high_cf)- ln(impute1990_high)
g dln_sim_low_total =ln(impute2010_low_cf)-ln(impute1990_low)

g drent_predict=0.099514*(ln(inc2010_cf)-ln(inc1990)) + 0.01814*room_density_1mi_3mi


g ratio1990=impute1990_high/impute1990_low
g ratio2010=impute2010_high/impute2010_low
g dratio=ln(ratio2010)-ln(ratio1990)


keep gisjoin dln_sim_high_total dln_sim_low_total ratio1990 ratio2010 dratio drent_predict

cd $data\geographic
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

*** rent
cd $data\temp_files
merge m:1 gisjoin using rent
drop if _merge==2
drop _merge

g drent=ln(rent2010)-ln(rent1990)

g dln_ratio=dln_sim_high_total -dln_sim_low_total

reg dratio i.metarea  dln_ratio [w=population]

predict dln_ratio_cf, xb
drop dln_ratio

reg drent i.metarea drent_predict  [w=population]

predict drent_cf, xb
drop drent


keep gisjoin dln_ratio_cf drent_cf
cd $data\temp_files
save counterfactual_I_pre_merge, replace

cd $data\temp_files
u data, clear

cd $data\temp_files
merge m:1 gisjoin using counterfactual_I_pre_merge
keep if _merge==3
drop _merge

cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2010
keep if _merge==3
drop _merge
ren counterfactual_share value_term2010

replace value_term1990=ln(value_term1990)
replace value_term2010=ln(value_term2010)


g sim2010=exp(ln(impute_share1990)-value_term1990 + value_term2010 + 0.34529*dln_ratio_cf*(1-high_skill) + 1.6172921*dln_ratio_cf*high_skill )
sort occ2010 metarea gisjoin

by occ2010 metarea: egen total_sim2010=sum(sim2010)

g counterfactual_share=sim2010/total_sim2010

drop count 
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge


g counterfactual=count1990*counterfactual_share

cd $data\temp_files

merge m:1 occ2010 using college_share
keep if _merge==3
drop _merge


g impute2010_high_cf=counterfactual*high_skill
g impute2010_low_cf=counterfactual*(1-high_skill)

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

collapse (sum) impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low, by(metarea gisjoin)

*************************
cd $data\temp_files

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

** counterfactual ratio and actual ratio (by changing value of time and amenity predicted by the value of time shock and rent)
save temp, replace


*****************

*****************************************************
*** Three miles evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)


cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]


** Table 8 

* Column 3 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* Column 6 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50


*****************************************************
*** Five miles evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown5mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln(ratio2010)-ln(ratio1990)


cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

** Table 8 

* Column 3 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* Column 6 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50


*************************************+*************************************+****
**# Output - Selection
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"


** value of time overall (without controling for education)
cd $data\ipums_micro

u 1990_2000_2010_temp, clear

drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork<40
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

replace inctot_real=inctot_real/52

replace inctot_real=ln(inctot_real)
drop occ met2013 city puma rentgrs valueh bpl occsoc incwage puma1990 greaterthan40 datanum serial pernum rank ind ind2000 hhwt statefip marst inctot occ1990

g val_2010=.
g se_2010=.
g val_1990=.
g se_1990=.
g dval=.
g se_dval=.
g hours1990=0
g hours2010=0
replace hours1990=uhrswork if year==1990
replace hours2010=uhrswork if year==2010
# delimit
foreach num of numlist 
30 120 130 150 205 230 310
350 410 430 520 530 540 560 620 710 730 800
860 1000 1010 1220 1300 1320 1350 1360 1410
1430 1460 1530 1540 1550 1560 1610 1720
1740 1820 1920 1960 2000 2010 2040 2060 2100 2140
2200 2300 2310 2320 2340 2430 2540 2600 2630 2700 2720
2750 2810 2825 2840 2850 2910 3010 3030 3050 3060 3130
3160 3220 3230 3240 3300 3310 3410 3500 3530 3640
3650 3710 3740 3800 3820 3930 3940 3950 4000 4010 4030 4040
4060 4110 4130 4200 4210 4220 4230 4250
4320 4350 4430 4500 4510 4600 4620 4700
4720 4740  4750 4760 4800 4810 4820
4840 4850 4900  4950 4965 5000 5020 5100
5110 5120 5140 5160 5260 5300 5310 5320
5330 5350 5360 5400 5410 5420 5510 5520
5540 5550 5600 5610 5620 5630 5700 5800 5810 5820 5850
5860 5900 5940 6050 6200 6220 6230 6240 6250 6260 6320
6330 6355 6420 6440 6515 6520 6530 6600 6660 7000
7010 7020 7140 7150 7200 7210 7220 7315 7330
7340 7700 7720 7750 7800 7810 7950 8030 8130  8140
8220 8230 8300 8320 8350 8500 8610 8650 8710 8740
8760 8800 8810 8830 8965
9000 9030 9050 9100 9130 9140 9350
9510 9600 9610 9620 9640 {;
# delimit cr
display `num'
qui reghdfe inctot_real hours1990 hours2010 if occ2010==`num' & uhrswork>=40 & uhrswork<=60 [w=perwt], absorb(i.age#i.year i.sex#i.year i.race#i.year i.hispan#i.year i.ind1990#i.year) cluster(metarea)
replace val_1990=_b[hours1990] if occ2010==`num'
replace se_1990=_se[hours1990] if occ2010==`num'
replace val_2010=_b[hours2010] if occ2010==`num'
replace se_2010=_se[hours2010] if occ2010==`num'
lincom hours2010-hours1990
replace dval=r(estimate) if occ2010==`num'
replace se_dval=r(se) if occ2010==`num'
}

collapse (firstnm) val_1990 se_1990 val_2010 se_2010 dval se_dval, by(occ2010)


cd $data\temp_files

save val_40_60_total_noeduc, replace

*** show that selection only occurs at level estimate but not change
cd $data\temp_files

u val_40_60_total_noeduc, clear

keep occ2010 dval val_1990 val_2010
ren dval dval_noeduc
ren val_1990 val_1990_noeduc
ren val_2010 val_2010_noeduc

merge m:1 occ2010 using val_40_60_total_1990_2000_2010
drop _merge

cd $data\temp_files
merge m:1 occ2010 using high_skill
drop _merge

g dval=val_2010-val_1990

*** plot the degree of selection on observables on skill content of the job
*** The worry is that high-skilled job exhibit increasing cross-sectional relation between earnings and hours due to skill biased technical change
*** One implication of that is that high skill jobs exhibit increasing selection by ability
g ddval=dval_noeduc-dval
g dval_2010=val_2010_noeduc-val_2010
g dval_1990=val_1990_noeduc-val_1990

cd $data\graph
# delimit
graph twoway (scatter ddval college_share) (lfit ddval college_share)
, graphregion(color(white)) xtitle(Skill content - share of college grad in 1990) ytitle(Change in selection on the observable skill)
legend(lab(1 "Occupation") lab(2 "Linear fit"));
# delimit cr
graph export change_in_selection.emf, replace

# delimit
graph twoway (scatter dval_2010 college_share) (lfit dval_2010 college_share) if dval!=.
,  graphregion(color(white)) xtitle(Skill content - share of college grad in 1990) ytitle(Selection on the observable skill)
legend(lab(1 "Occupation") lab(2 "Linear fit"));
# delimit cr
graph export selection2010.emf, replace

# delimit
graph twoway (scatter dval_1990 college_share) (lfit dval_1990 college_share) if dval!=.
,  graphregion(color(white)) xtitle(Skill content - share of college grad in 1990) ytitle(Selection on the observable skill)
legend(lab(1 "Occupation") lab(2 "Linear fit"));
# delimit cr
graph export selection1990.emf, replace


*** Appendix Table A1
edit occ2010 val_1990_noeduc val_2010_noeduc dval_noeduc dval_noeduc val_1990 val_2010 dval if occ2010==30
edit occ2010 val_1990_noeduc val_2010_noeduc dval_noeduc dval_noeduc val_1990 val_2010 dval if occ2010==120
edit occ2010 val_1990_noeduc val_2010_noeduc dval_noeduc dval_noeduc val_1990 val_2010 dval if occ2010==800
edit occ2010 val_1990_noeduc val_2010_noeduc dval_noeduc dval_noeduc val_1990 val_2010 dval if occ2010==1000
edit occ2010 val_1990_noeduc val_2010_noeduc dval_noeduc dval_noeduc val_1990 val_2010 dval if occ2010==2100
edit occ2010 val_1990_noeduc val_2010_noeduc dval_noeduc dval_noeduc val_1990 val_2010 dval if occ2010==2320
edit occ2010 val_1990_noeduc val_2010_noeduc dval_noeduc dval_noeduc val_1990 val_2010 dval if occ2010==4820
edit occ2010 val_1990_noeduc val_2010_noeduc dval_noeduc dval_noeduc val_1990 val_2010 dval if occ2010==5700





*************************************+*************************************+****
**# Appendix - Counterfactual Regression Appendix
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"

****************

*** create counterfatual location share in 2010

cd $data\temp_files
u tract_impute_share, clear


cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2010
keep if _merge==3
drop _merge
ren counterfactual_share value_term2010

replace value_term1990=ln(value_term1990)
replace value_term2010=ln(value_term2010)

g sim2010=exp(ln(impute_share1990)-value_term1990+value_term2010)
sort occ2010 metarea gisjoin

by occ2010 metarea: egen total_sim2010=sum(sim2010)

g counterfactual_share=sim2010/total_sim2010
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data\temp_files

merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data\temp_files
merge m:1 occ2010 using inc_occ_1990_2000_2010
keep if _merge==3
drop _merge
drop count1990 count2000 count2010 wage_real1990 wage_real2000 wage_real2010

ren count1990_2 count1990
ren count2000_2 count2000
ren count2010_2 count2010

g impute2010_high_cf=counterfactual_share*count1990*high_skill
g impute2010_low_cf=counterfactual_share*count1990*(1-high_skill)

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

g inc1990=impute_share1990*inc_mean1990*count1990
g inc2010_cf=counterfactual_share*inc_mean1990*count1990

collapse (sum) impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low inc1990 inc2010_cf, by(metarea gisjoin)


cd $data\temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data\temp_files
u impute, clear

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace


**************************************
**** Three Mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

* Table A2

* Column 1
reg dln_ratio_ratio dln_ratio_ratio_cf  [w=population] if downtown==1, r
********************************
********************************
********************************
********************************
********************************
********************************
********************************

********************************
********************************
********************************
********************************
********************************
********************************
********************************

**** Actual 1990-2000 on predicted 1990-2010


cd $data\temp_files
u tract_impute_share, clear


cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2010
keep if _merge==3
drop _merge
ren counterfactual_share value_term2010

replace value_term1990=ln(value_term1990)
replace value_term2010=ln(value_term2010)

g sim2010=exp(ln(impute_share1990)-value_term1990+value_term2010)
sort occ2010 metarea gisjoin

by occ2010 metarea: egen total_sim2010=sum(sim2010)

g counterfactual_share=sim2010/total_sim2010
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data\temp_files

merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data\temp_files
merge m:1 occ2010 using inc_occ_1990_2000_2010
keep if _merge==3
drop _merge
drop count1990 count2000 count2010 wage_real1990 wage_real2000 wage_real2010

ren count1990_2 count1990
ren count2000_2 count2000
ren count2010_2 count2010

g impute2010_high_cf=counterfactual_share*count1990*high_skill
g impute2010_low_cf=counterfactual_share*count1990*(1-high_skill)

g impute2010_high=impute_share2000*count2000*high_skill
g impute2010_low=impute_share2000*count2000*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

g inc1990=impute_share1990*inc_mean1990*count1990
g inc2010_cf=counterfactual_share*inc_mean1990*count1990

collapse (sum) impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low inc1990 inc2010_cf, by(metarea gisjoin)


cd $data\temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data\temp_files
u impute, clear

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace


**************************************
**** Three Mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]


* Table A2

* Column 2

reg dln_ratio_ratio dln_ratio_ratio_cf  [w=population] if downtown==1, r


********************************
********************************
********************************
*******************************

**** Actual 2000-2010 on predicted 1990-2010

cd $data\temp_files
u tract_impute_share, clear


cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2010
keep if _merge==3
drop _merge
ren counterfactual_share value_term2010

replace value_term1990=ln(value_term1990)
replace value_term2010=ln(value_term2010)

g sim2010=exp(ln(impute_share1990)-value_term1990+value_term2010)
sort occ2010 metarea gisjoin

by occ2010 metarea: egen total_sim2010=sum(sim2010)

g counterfactual_share=sim2010/total_sim2010
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data\temp_files

merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data\temp_files
merge m:1 occ2010 using inc_occ_1990_2000_2010
keep if _merge==3
drop _merge
drop count1990 count2000 count2010 wage_real1990 wage_real2000 wage_real2010

ren count1990_2 count1990
ren count2000_2 count2000
ren count2010_2 count2010

g impute2010_high_cf=counterfactual_share*count1990*high_skill
g impute2010_low_cf=counterfactual_share*count1990*(1-high_skill)

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute2000_high=impute_share2000*count2000*high_skill
g impute2000_low=impute_share2000*count2000*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

g inc1990=impute_share1990*inc_mean1990*count1990
g inc2010_cf=counterfactual_share*inc_mean1990*count1990

collapse (sum) impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute2000_high impute2000_low impute1990_high impute1990_low inc1990 inc2010_cf, by(metarea gisjoin)


cd $data\temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data\temp_files
u impute, clear

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace


**************************************
**** Three Mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute2000_high impute2000_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio2000=impute2000_high/(impute2000_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio2000)

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

* Table A2

* Column 4
reg dln_ratio_ratio dln_ratio_ratio_cf  [w=population] if downtown==1, r


*******************************
*******************************
*******************************


**** Actual 1990-2000 on predicted 1990-2000


cd $data\temp_files
u tract_impute_share, clear


cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2000
keep if _merge==3
drop _merge
ren counterfactual_share value_term2000

replace value_term1990=ln(value_term1990)
replace value_term2000=ln(value_term2000)

g sim2000=exp(ln(impute_share1990)-value_term1990+value_term2000)
sort occ2010 metarea gisjoin

by occ2010 metarea: egen total_sim2000=sum(sim2000)

g counterfactual_share=sim2000/total_sim2000
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data\temp_files

merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data\temp_files
merge m:1 occ2010 using inc_occ_1990_2000_2010
keep if _merge==3
drop _merge
drop count1990 count2000 count2010 wage_real1990 wage_real2000 wage_real2010

ren count1990_2 count1990
ren count2000_2 count2000
ren count2010_2 count2010

g impute2000_high_cf=counterfactual_share*count1990*high_skill
g impute2000_low_cf=counterfactual_share*count1990*(1-high_skill)

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute2000_high=impute_share2000*count2000*high_skill
g impute2000_low=impute_share2000*count2000*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

g inc1990=impute_share1990*inc_mean1990*count1990
g inc2010_cf=counterfactual_share*inc_mean1990*count1990

collapse (sum) impute2000_high_cf impute2000_low_cf impute2000_high impute2000_low impute1990_high impute1990_low inc1990 inc2010_cf, by(metarea gisjoin)


cd $data\temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data\temp_files
u impute, clear

g predict2000_high_cf=impute2000_high_cf
g predict2000_low_cf=impute2000_low_cf

save temp, replace


**************************************
**** Three Mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2000_high_cf predict2000_low_cf impute2000_high_cf impute2000_low_cf impute2000_high impute2000_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2000_cf=predict2000_high_cf/(predict2000_low_cf)
g ratio2000=impute2000_high/(impute2000_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2000_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2000)-ln(ratio1990)

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

* Table A2

* Column 3
reg dln_ratio_ratio dln_ratio_ratio_cf  [w=population] if downtown==1, r

***************************************
***************************************
***************************************


**** Actual 2000 - 2010 on predicted 2000 - 2010 


cd $data\temp_files
u tract_impute_share, clear


cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2000
keep if _merge==3
drop _merge

ren counterfactual_share value_term2000
cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2010
keep if _merge==3
drop _merge
ren counterfactual_share value_term2010

replace value_term2000=ln(value_term2000)
replace value_term2010=ln(value_term2010)

g sim2010=exp(ln(impute_share2000)-value_term2000+value_term2010)
sort occ2010 metarea gisjoin

by occ2010 metarea: egen total_sim2010=sum(sim2010)

g counterfactual_share=sim2010/total_sim2010
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data\temp_files

merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data\temp_files
merge m:1 occ2010 using inc_occ_1990_2000_2010
keep if _merge==3
drop _merge
drop count1990 count2000 count2010 wage_real1990 wage_real2000 wage_real2010

ren count1990_2 count1990
ren count2000_2 count2000
ren count2010_2 count2010

g impute2010_high_cf=counterfactual_share*count2000*high_skill
g impute2010_low_cf=counterfactual_share*count2000*(1-high_skill)

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute2000_high=impute_share2000*count2000*high_skill
g impute2000_low=impute_share2000*count2000*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

g inc1990=impute_share1990*inc_mean1990*count1990
g inc2010_cf=counterfactual_share*inc_mean1990*count1990

collapse (sum) impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute2000_high impute2000_low inc1990 inc2010_cf, by(metarea gisjoin)


cd $data\temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data\temp_files
u impute, clear

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace


**************************************
**** Three Mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute2000_high impute2000_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio2000=impute2000_high/(impute2000_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio2000)
g dln_ratio=ln( ratio2010)-ln(ratio2000)

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

* Table A2

* Column 5

reg dln_ratio_ratio dln_ratio_ratio_cf  [w=population] if downtown==1, r



*************************************+*************************************+****
**# Appendix - Exogeneity
*************************************+*************************************+****

clear all
global data="C:\Users\alen_\Dropbox\paper_folder\replication\data"

*** Regressing change in incidence of working long hours in the suburbs and central cities
cd $data\ipums_micro
u 1990_2000_2010_temp , clear

keep if uhrswork>=30

keep if sex==1
keep if age>=25 & age<=65
keep if year==1990 | year==2010

drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork==0
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

replace inctot_real=inctot_real/52

g greaterthan50=0
replace greaterthan50=1 if uhrswork>=50


cd $data\geographic
merge m:1 statefip puma1990 using puma1990_downtown_5mi
g downtown=0
replace downtown=1 if _merge==3
drop _merge

merge m:1 statefip puma using puma_downtown_5mi
replace downtown=1 if _merge==3
drop _merge

collapse greaterthan50, by(year occ2010 downtown)
drop if year==.
reshape wide greaterthan50, i(occ2010 downtown) j(year)


g ln_d=ln( greaterthan502010)-ln( greaterthan501990)

drop greaterthan501990 greaterthan502010
reshape wide ln_d, i(occ2010) j(downtown)
reg ln_d1 ln_d0


cd $data\temp_files
merge 1:1 occ2010 using occ2010_count
drop _merge


******** Table A3
*** Regressing change in incidence of working long hour on changing LHP
cd $data\temp_files

merge 1:1 occ2010 using val_40_60_total_1990_2000_2010
drop _merge

g dval=val_2010-val_1990 

** Column 1
reg ln_d1 dval [w=count1990] if dval!=., r

** Column 2
reg ln_d0 dval [w=count1990] if dval!=., r

** Column 3
reg ln_d1 ln_d0 [w=count1990] if dval!=., r


*************************************+*************************************+****
**# Output - First Stage Regression
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"


cd $data\temp_files

u skill_pop, clear
 cd $data\temp_files\iv
merge m:1 gisjoin using sim_iv_total
keep if _merge==3
drop _merge

g dratio=ln(impute2010_high/impute2010_low)-ln(impute1990_high/impute1990_low)
g dratio_sim=dln_sim_high_total - dln_sim_low_total 

** Table A4
** First Stage
* Column 1

reghdfe dratio dratio_sim, absorb(metarea) vce(robust)
* Column 2
reghdfe dratio dln_sim_low_total dln_sim_high_total, absorb(metarea) vce(robust)


*************************************+*************************************+****
**# Output - Counterfactual Adjusted MSA
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"


*** create counterfatual location share in 2010

cd $data\temp_files
u tract_impute_share, clear


cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2010
keep if _merge==3
drop _merge
ren counterfactual_share value_term2010

replace value_term1990=ln(value_term1990)
replace value_term2010=ln(value_term2010)

g sim2010=exp(ln(impute_share1990)-value_term1990+value_term2010)
sort occ2010 metarea gisjoin

by occ2010 metarea: egen total_sim2010=sum(sim2010)

g counterfactual_share=sim2010/total_sim2010
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data\temp_files

merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data\temp_files
merge m:1 occ2010 using inc_occ_1990_2000_2010
keep if _merge==3
drop _merge
drop count1990 count2000 count2010 wage_real1990 wage_real2000 wage_real2010

ren count1990_2 count1990
ren count2000_2 count2000
ren count2010_2 count2010

g impute2010_high_cf=counterfactual_share*count2010*high_skill
g impute2010_low_cf=counterfactual_share*count2010*(1-high_skill)

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

g inc1990=impute_share1990*inc_mean1990*count1990
g inc2010_cf=counterfactual_share*inc_mean1990*count1990

collapse (sum) impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low inc1990 inc2010_cf, by(metarea gisjoin)


cd $data\temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data\temp_files
u impute, clear

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace


**************************************
**** Three Mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]


** Table A6

* Column 1 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* Column 4 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50



**************************************
**** Five Mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown5mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

** Table A6

* Column 1 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* Column 4 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50



********************************
********************************
********************************
********************************
********************************
********************************
********************************

********************************
********************************
********************************
********************************
********************************
********************************
********************************

*** counterfactual when skill ratio can change and rent can change, too. 
cd $data\temp_files
u impute, clear

g dln_sim_high_total  = ln(impute2010_high_cf)- ln(impute1990_high)
g dln_sim_low_total =ln(impute2010_low_cf)-ln(impute1990_low)

g drent_predict=0.099514*(ln(inc2010_cf)-ln(inc1990)) + 0.01814*room_density_1mi_3mi


g ratio1990=impute1990_high/impute1990_low
g ratio2010=impute2010_high/impute2010_low
g dratio=ln(ratio2010)-ln(ratio1990)


keep gisjoin dln_sim_high_total dln_sim_low_total ratio1990 ratio2010 dratio drent_predict

cd $data\geographic
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

*** rent
cd $data\temp_files
merge m:1 gisjoin using rent
drop if _merge==2
drop _merge

g drent=ln(rent2010)-ln(rent1990)

g dln_ratio=dln_sim_high_total -dln_sim_low_total

reg dratio i.metarea  dln_ratio [w=population]

predict dln_ratio_cf, xb
drop dln_ratio

reg drent i.metarea drent_predict  [w=population]

predict drent_cf, xb
drop drent


keep gisjoin dln_ratio_cf drent_cf
cd $data\temp_files
save counterfactual_I_pre_merge, replace

cd $data\temp_files
u data, clear

cd $data\temp_files
merge m:1 gisjoin using counterfactual_I_pre_merge
keep if _merge==3
drop _merge

cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2010
keep if _merge==3
drop _merge
ren counterfactual_share value_term2010

replace value_term1990=ln(value_term1990)
replace value_term2010=ln(value_term2010)


g sim2010=exp(ln(impute_share1990)-value_term1990 + value_term2010 + 0.34529*dln_ratio_cf*(1-high_skill) + 1.6172921*dln_ratio_cf*high_skill  -0.43598*drent_cf*(1-high_skill) - 0.5732421*drent_cf*high_skill)
sort occ2010 metarea gisjoin

by occ2010 metarea: egen total_sim2010=sum(sim2010)

g counterfactual_share=sim2010/total_sim2010

drop count 
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge


g counterfactual=count2010*counterfactual_share

cd $data\temp_files

merge m:1 occ2010 using college_share
keep if _merge==3
drop _merge


g impute2010_high_cf=counterfactual*high_skill
g impute2010_low_cf=counterfactual*(1-high_skill)

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

collapse (sum) impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low, by(metarea gisjoin)

*************************
cd $data\temp_files

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace



*****************************************
**** Three mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)


cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

** Table A6

* Column 2 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* Column 5 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50


*****************************************
**** Five mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown5mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)


cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]


** Table A6

* Column 2 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* Column 5 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50
********************************
********************************
********************************
********************************
********************************
********************************
********************************
**********************

*** counterfactual when skill ratio can change and rent does not change. 
cd $data\temp_files
u impute, clear

g dln_sim_high_total  = ln(impute2010_high_cf)- ln(impute1990_high)
g dln_sim_low_total =ln(impute2010_low_cf)-ln(impute1990_low)

g drent_predict=0.099514*(ln(inc2010_cf)-ln(inc1990)) + 0.01814*room_density_1mi_3mi


g ratio1990=impute1990_high/impute1990_low
g ratio2010=impute2010_high/impute2010_low
g dratio=ln(ratio2010)-ln(ratio1990)


keep gisjoin dln_sim_high_total dln_sim_low_total ratio1990 ratio2010 dratio drent_predict

cd $data\geographic
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

*** rent
cd $data\temp_files
merge m:1 gisjoin using rent
drop if _merge==2
drop _merge

g drent=ln(rent2010)-ln(rent1990)

g dln_ratio=dln_sim_high_total -dln_sim_low_total

reg dratio i.metarea  dln_ratio [w=population]

predict dln_ratio_cf, xb
drop dln_ratio

reg drent i.metarea drent_predict  [w=population]

predict drent_cf, xb
drop drent


keep gisjoin dln_ratio_cf drent_cf
cd $data\temp_files
save counterfactual_I_pre_merge, replace

cd $data\temp_files
u data, clear

cd $data\temp_files
merge m:1 gisjoin using counterfactual_I_pre_merge
keep if _merge==3
drop _merge

cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2010
keep if _merge==3
drop _merge
ren counterfactual_share value_term2010

replace value_term1990=ln(value_term1990)
replace value_term2010=ln(value_term2010)


g sim2010=exp(ln(impute_share1990)-value_term1990 + value_term2010 + 0.34529*dln_ratio_cf*(1-high_skill) + 1.6172921*dln_ratio_cf*high_skill )
sort occ2010 metarea gisjoin

by occ2010 metarea: egen total_sim2010=sum(sim2010)

g counterfactual_share=sim2010/total_sim2010

drop count 
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge


g counterfactual=count2010*counterfactual_share

cd $data\temp_files

merge m:1 occ2010 using college_share
keep if _merge==3
drop _merge


g impute2010_high_cf=counterfactual*high_skill
g impute2010_low_cf=counterfactual*(1-high_skill)

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

collapse (sum) impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low, by(metarea gisjoin)

*************************
cd $data\temp_files

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

** counterfactual ratio and actual ratio (by changing value of time and amenity predicted by the value of time shock and rent)
save temp, replace


*****************************************************
*** Three miles evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)


cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]


** Table A6

* Column 3 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* Column 6 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50




*****************************************************
*** Five miles evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown5mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)


cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

** Table A6

* Column 3 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* Column 6 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50


*****************

*************************************+*************************************+****
**# Output - Counterfactual 30
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"


*** create counterfatual location share in 2010

cd $data\temp_files
u tract_impute_share, clear


cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term1990_high30
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2010_high30
keep if _merge==3
drop _merge
ren counterfactual_share value_term2010

replace value_term1990=ln(value_term1990)
replace value_term2010=ln(value_term2010)

g sim2010=exp(ln(impute_share1990)-value_term1990+value_term2010)
sort occ2010 metarea gisjoin

by occ2010 metarea: egen total_sim2010=sum(sim2010)

g counterfactual_share=sim2010/total_sim2010
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data\temp_files

merge m:1 occ2010 using high_skill_30
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data\temp_files
merge m:1 occ2010 using inc_occ_1990_2000_2010
keep if _merge==3
drop _merge
drop count1990 count2000 count2010 wage_real1990 wage_real2000 wage_real2010

ren count1990_2 count1990
ren count2000_2 count2000
ren count2010_2 count2010

g impute2010_high_cf=counterfactual_share*count1990*high_skill
g impute2010_low_cf=counterfactual_share*count1990*(1-high_skill)

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

g inc1990=impute_share1990*inc_mean1990*count1990
g inc2010_cf=counterfactual_share*inc_mean1990*count1990

collapse (sum) impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low inc1990 inc2010_cf, by(metarea gisjoin)


cd $data\temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data\temp_files
u impute, clear

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace


**************************************
**** Three Mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

** Table A7

* Column 1 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25
* Column 4 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50

**************************************
**** Five Mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown5mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

** Table A7

* Column 1 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25
* Column 4 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50
********************************

********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************

*** counterfactual when skill ratio can change and rent can change, too. 
cd $data\temp_files
u impute, clear

g dln_sim_high_total  = ln(impute2010_high_cf)- ln(impute1990_high)
g dln_sim_low_total =ln(impute2010_low_cf)-ln(impute1990_low)

g drent_predict=0.099514*(ln(inc2010_cf)-ln(inc1990)) + 0.01814*room_density_1mi_3mi

g ratio1990=impute1990_high/impute1990_low
g ratio2010=impute2010_high/impute2010_low
g dratio=ln(ratio2010)-ln(ratio1990)


keep gisjoin dln_sim_high_total dln_sim_low_total ratio1990 ratio2010 dratio drent_predict

cd $data\geographic
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

*** rent
cd $data\temp_files
merge m:1 gisjoin using rent
drop if _merge==2
drop _merge

g drent=ln(rent2010)-ln(rent1990)

g dln_ratio=dln_sim_high_total -dln_sim_low_total

reg dratio i.metarea  dln_ratio [w=population]

predict dln_ratio_cf, xb
drop dln_ratio

reg drent i.metarea drent_predict  [w=population]

predict drent_cf, xb
drop drent


keep gisjoin dln_ratio_cf drent_cf
cd $data\temp_files
save counterfactual_I_pre_merge, replace

cd $data\temp_files
u data, clear

cd $data\temp_files
merge m:1 gisjoin using counterfactual_I_pre_merge
keep if _merge==3
drop _merge

cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term1990_high30
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2010_high30
keep if _merge==3
drop _merge
ren counterfactual_share value_term2010

replace value_term1990=ln(value_term1990)
replace value_term2010=ln(value_term2010)


g sim2010=exp(ln(impute_share1990)-value_term1990 + value_term2010 + 0.34529*dln_ratio_cf*(1-high_skill) + 1.6172921*dln_ratio_cf*high_skill  -0.43598*drent_cf*(1-high_skill) - 0.5732421*drent_cf*high_skill)
sort occ2010 metarea gisjoin

by occ2010 metarea: egen total_sim2010=sum(sim2010)

g counterfactual_share=sim2010/total_sim2010

drop count 
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge


g counterfactual=count1990*counterfactual_share

cd $data\temp_files

merge m:1 occ2010 using college_share
keep if _merge==3
drop _merge


g impute2010_high_cf=counterfactual*high_skill
g impute2010_low_cf=counterfactual*(1-high_skill)

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

collapse (sum) impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low, by(metarea gisjoin)

*************************
cd $data\temp_files

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace



*****************************************
**** Three mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)


cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

** Table A7
* column 2 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* column 5 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50


*****************************************
**** Five mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown5mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)


cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]


** Table A7
* column 2 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* column 5 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50
********************************
********************************
********************************
********************************
********************************
********************************
********************************
**********************

*** counterfactual when skill ratio can change and rent does not change. 
cd $data\temp_files
u impute, clear

g dln_sim_high_total  = ln(impute2010_high_cf)- ln(impute1990_high)
g dln_sim_low_total =ln(impute2010_low_cf)-ln(impute1990_low)

g drent_predict=0.099514*(ln(inc2010_cf)-ln(inc1990)) + 0.01814*room_density_1mi_3mi


g ratio1990=impute1990_high/impute1990_low
g ratio2010=impute2010_high/impute2010_low
g dratio=ln(ratio2010)-ln(ratio1990)


keep gisjoin dln_sim_high_total dln_sim_low_total ratio1990 ratio2010 dratio drent_predict

cd $data\geographic
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

*** rent
cd $data\temp_files
merge m:1 gisjoin using rent
drop if _merge==2
drop _merge

g drent=ln(rent2010)-ln(rent1990)

g dln_ratio=dln_sim_high_total -dln_sim_low_total

reg dratio i.metarea  dln_ratio [w=population]

predict dln_ratio_cf, xb
drop dln_ratio

reg drent i.metarea drent_predict  [w=population]

predict drent_cf, xb
drop drent


keep gisjoin dln_ratio_cf drent_cf
cd $data\temp_files
save counterfactual_I_pre_merge, replace

cd $data\temp_files
u data, clear

cd $data\temp_files
merge m:1 gisjoin using counterfactual_I_pre_merge
keep if _merge==3
drop _merge

cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term1990_high30
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2010_high30
keep if _merge==3
drop _merge
ren counterfactual_share value_term2010

replace value_term1990=ln(value_term1990)
replace value_term2010=ln(value_term2010)


g sim2010=exp(ln(impute_share1990)-value_term1990 + value_term2010 + 0.34529*dln_ratio_cf*(1-high_skill) + 1.6172921*dln_ratio_cf*high_skill )
sort occ2010 metarea gisjoin

by occ2010 metarea: egen total_sim2010=sum(sim2010)

g counterfactual_share=sim2010/total_sim2010

drop count 
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge


g counterfactual=count1990*counterfactual_share

cd $data\temp_files

merge m:1 occ2010 using college_share
keep if _merge==3
drop _merge


g impute2010_high_cf=counterfactual*high_skill
g impute2010_low_cf=counterfactual*(1-high_skill)

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

collapse (sum) impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low, by(metarea gisjoin)

*************************
cd $data\temp_files

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

** counterfactual ratio and actual ratio (by changing value of time and amenity predicted by the value of time shock and rent)
save temp, replace


*****************

*****************************************************
*** Three miles evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)


cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]


** Table A7 

* Column 3 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* Column 6 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50


*****************************************************
*** Five miles evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown5mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln(ratio2010)-ln(ratio1990)


cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

** Table A7 

* Column 3 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* Column 6 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50



*************************************+*************************************+****
**# Output - Counterfactual 50
*************************************+*************************************+****

clear all
global data="C:\Users\alen_\Dropbox\paper_folder\replication\data"


*** create counterfatual location share in 2010

cd $data\temp_files
u tract_impute_share, clear


cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term1990_high50
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2010_high50
keep if _merge==3
drop _merge
ren counterfactual_share value_term2010

replace value_term1990=ln(value_term1990)
replace value_term2010=ln(value_term2010)

g sim2010=exp(ln(impute_share1990)-value_term1990+value_term2010)
sort occ2010 metarea gisjoin

by occ2010 metarea: egen total_sim2010=sum(sim2010)

g counterfactual_share=sim2010/total_sim2010
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data\temp_files

merge m:1 occ2010 using high_skill_50
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data\temp_files
merge m:1 occ2010 using inc_occ_1990_2000_2010
keep if _merge==3
drop _merge
drop count1990 count2000 count2010 wage_real1990 wage_real2000 wage_real2010

ren count1990_2 count1990
ren count2000_2 count2000
ren count2010_2 count2010

g impute2010_high_cf=counterfactual_share*count1990*high_skill
g impute2010_low_cf=counterfactual_share*count1990*(1-high_skill)

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

g inc1990=impute_share1990*inc_mean1990*count1990
g inc2010_cf=counterfactual_share*inc_mean1990*count1990

collapse (sum) impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low inc1990 inc2010_cf, by(metarea gisjoin)


cd $data\temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data\temp_files
u impute, clear

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace


**************************************
**** Three Mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

** Table A8
* column 1 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25
* column 4 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50

**************************************
**** Five Mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown5mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

** Table A8
* column 1 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25
* column 4 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50

********************************


********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************
********************************

*** counterfactual when skill ratio can change and rent can change, too. 
cd $data\temp_files
u impute, clear

g dln_sim_high_total  = ln(impute2010_high_cf)- ln(impute1990_high)
g dln_sim_low_total =ln(impute2010_low_cf)-ln(impute1990_low)

g drent_predict=0.099514*(ln(inc2010_cf)-ln(inc1990)) + 0.01814*room_density_1mi_3mi

g ratio1990=impute1990_high/impute1990_low
g ratio2010=impute2010_high/impute2010_low
g dratio=ln(ratio2010)-ln(ratio1990)


keep gisjoin dln_sim_high_total dln_sim_low_total ratio1990 ratio2010 dratio drent_predict

cd $data\geographic
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

*** rent
cd $data\temp_files
merge m:1 gisjoin using rent
drop if _merge==2
drop _merge

g drent=ln(rent2010)-ln(rent1990)

g dln_ratio=dln_sim_high_total -dln_sim_low_total

reg dratio i.metarea  dln_ratio [w=population]

predict dln_ratio_cf, xb
drop dln_ratio

reg drent i.metarea drent_predict  [w=population]

predict drent_cf, xb
drop drent


keep gisjoin dln_ratio_cf drent_cf
cd $data\temp_files
save counterfactual_I_pre_merge, replace

cd $data\temp_files
u data, clear

cd $data\temp_files
merge m:1 gisjoin using counterfactual_I_pre_merge
keep if _merge==3
drop _merge

cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term1990_high50
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2010_high50
keep if _merge==3
drop _merge
ren counterfactual_share value_term2010

replace value_term1990=ln(value_term1990)
replace value_term2010=ln(value_term2010)


g sim2010=exp(ln(impute_share1990)-value_term1990 + value_term2010 + 0.34529*dln_ratio_cf*(1-high_skill) + 1.6172921*dln_ratio_cf*high_skill  -0.43598*drent_cf*(1-high_skill) - 0.5732421*drent_cf*high_skill)
sort occ2010 metarea gisjoin

by occ2010 metarea: egen total_sim2010=sum(sim2010)

g counterfactual_share=sim2010/total_sim2010

drop count 
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge


g counterfactual=count1990*counterfactual_share

cd $data\temp_files

merge m:1 occ2010 using college_share
keep if _merge==3
drop _merge


g impute2010_high_cf=counterfactual*high_skill
g impute2010_low_cf=counterfactual*(1-high_skill)

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

collapse (sum) impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low, by(metarea gisjoin)

*************************
cd $data\temp_files

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace



*****************************************
**** Three mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)


cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

** Table A8
* column 2 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* column 5 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50


*****************************************
**** Five mile evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown5mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)


cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]


** Table A8
* column 2 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* column 5 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50
********************************
********************************
********************************
********************************
********************************
********************************
********************************
**********************

*** counterfactual when skill ratio can change and rent does not change. 
cd $data\temp_files
u impute, clear

g dln_sim_high_total  = ln(impute2010_high_cf)- ln(impute1990_high)
g dln_sim_low_total =ln(impute2010_low_cf)-ln(impute1990_low)

g drent_predict=0.099514*(ln(inc2010_cf)-ln(inc1990)) + 0.01814*room_density_1mi_3mi


g ratio1990=impute1990_high/impute1990_low
g ratio2010=impute2010_high/impute2010_low
g dratio=ln(ratio2010)-ln(ratio1990)


keep gisjoin dln_sim_high_total dln_sim_low_total ratio1990 ratio2010 dratio drent_predict

cd $data\geographic
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

*** rent
cd $data\temp_files
merge m:1 gisjoin using rent
drop if _merge==2
drop _merge

g drent=ln(rent2010)-ln(rent1990)

g dln_ratio=dln_sim_high_total -dln_sim_low_total

reg dratio i.metarea  dln_ratio [w=population]

predict dln_ratio_cf, xb
drop dln_ratio

reg drent i.metarea drent_predict  [w=population]

predict drent_cf, xb
drop drent


keep gisjoin dln_ratio_cf drent_cf
cd $data\temp_files
save counterfactual_I_pre_merge, replace

cd $data\temp_files
u data, clear

cd $data\temp_files
merge m:1 gisjoin using counterfactual_I_pre_merge
keep if _merge==3
drop _merge

cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term1990_high50
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2010_high50
keep if _merge==3
drop _merge
ren counterfactual_share value_term2010

replace value_term1990=ln(value_term1990)
replace value_term2010=ln(value_term2010)


g sim2010=exp(ln(impute_share1990)-value_term1990 + value_term2010 + 0.34529*dln_ratio_cf*(1-high_skill) + 1.6172921*dln_ratio_cf*high_skill )
sort occ2010 metarea gisjoin

by occ2010 metarea: egen total_sim2010=sum(sim2010)

g counterfactual_share=sim2010/total_sim2010

drop count 
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge


g counterfactual=count1990*counterfactual_share

cd $data\temp_files

merge m:1 occ2010 using college_share
keep if _merge==3
drop _merge


g impute2010_high_cf=counterfactual*high_skill
g impute2010_low_cf=counterfactual*(1-high_skill)

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

collapse (sum) impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low, by(metarea gisjoin)

*************************
cd $data\temp_files

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

** counterfactual ratio and actual ratio (by changing value of time and amenity predicted by the value of time shock and rent)
save temp, replace


*****************

*****************************************************
*** Three miles evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)


cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]


** Table A8 

* Column 3 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* Column 6 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50


*****************************************************
*** Five miles evaluation
cd $data\temp_files
u temp, clear

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown5mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln(ratio2010)-ln(ratio1990)


cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

** Table A8 

* Column 3 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* Column 6 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50

*************************************+*************************************+****
**# Appendix - Reduced Form
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"

cd $data\ipums_micro

u 1990_2000_2010_temp, clear

keep if uhrswork>=30

keep if sex==1
keep if age>=25 & age<=65
keep if year==1990 | year==2010


*drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork==0

g greaterthan50=0
replace greaterthan50=1 if uhrswork>=50

collapse greaterthan50 [w=perwt], by(occ2010 year)

by occ2010: g dg_occ=greaterthan50-greaterthan50[_n-1]
keep if year==2010

drop year

cd $data\temp_files

save occ2010_dg, replace


****************************

cd $data\ipums_micro

u 1990_2000_2010_temp, clear

keep if uhrswork>=30

keep if sex==1
keep if age>=25 & age<=65
*keep if year==1990 | year==2010


*drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork==0

g greaterthan50=0
replace greaterthan50=1 if uhrswork>=50

cd $data\temp_files
merge m:1 occ2010 using val_40_60_total_1990_2000_2010
keep if _merge==3
drop _merge

g college=0
replace college=1 if educ>=10

g g1990= greaterthan50 if year==1990
g g2010=greaterthan50 if year==2010

g g1990_college= greaterthan50 if year==1990 & college==1
g g2010_college=greaterthan50 if year==2010 & college==1

g g1990_nocollege= greaterthan50 if year==1990 & college==0
g g2010_nocollege=greaterthan50 if year==2010 & college==0

g val_1990_college= val_1990 if year==1990 & college==1
g val_2010_college=val_2010 if year==2010 & college==1

g val_1990_nocollege= val_1990 if year==1990 & college==0
g val_2010_nocollege=val_2010 if year==2010 & college==0

merge m:1 occ2010 using occ2010_dg

collapse g1990* g2010* val_1990* val_2010* dg_occ [w=perwt], by(metarea)

cd $data\temp_files

save appendix_eval_reduced_form, replace


************************************************

*** create counterfatual location share in 2010

cd $data\temp_files
u tract_impute_share, clear


cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data\temp_files\counterfactual
merge 1:1 occ2010 gisjoin using value_term2010
keep if _merge==3
drop _merge
ren counterfactual_share value_term2010

replace value_term1990=ln(value_term1990)
replace value_term2010=ln(value_term2010)

g sim2010=exp(ln(impute_share1990)-value_term1990+value_term2010)
sort occ2010 metarea gisjoin

by occ2010 metarea: egen total_sim2010=sum(sim2010)

g counterfactual_share=sim2010/total_sim2010
cd $data\temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data\temp_files

merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data\temp_files
merge m:1 occ2010 using inc_occ_1990_2000_2010
keep if _merge==3
drop _merge
drop count1990 count2000 count2010 wage_real1990 wage_real2000 wage_real2010

ren count1990_2 count1990
ren count2000_2 count2000
ren count2010_2 count2010

g impute2010_high_cf=counterfactual_share*count1990*high_skill
g impute2010_low_cf=counterfactual_share*count1990*(1-high_skill)

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

g inc1990=impute_share1990*inc_mean1990*count1990
g inc2010_cf=counterfactual_share*inc_mean1990*count1990

collapse (sum) impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low inc1990 inc2010_cf, by(metarea gisjoin)


cd $data\temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data\temp_files
u impute, clear

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf


cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)

cd $data\temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

cd $data\temp_files
merge m:1 metarea using appendix_eval_reduced_form
keep if _merge==3
drop _merge

g dg= g2010- g1990

g dg_college= g2010_college- g1990_college
g dg_nocollege= g2010_nocollege- g1990_nocollege
g dval=val_2010-val_1990

*** First prediction
** Coefficient: 
reg dln_ratio_ratio dln_ratio_ratio_cf [w=population] if downtown==1
scalar cons=_b[_cons]
predict predict1, xb
replace predict1 = predict1-cons

** Predicted
sum predict1 [w=population] if downtown==1 & rank<=25
scalar predict1_mean=r(mean)
** Actual: 
sum dln_ratio_ratio [w=population] if downtown==1 & rank<=25

scalar share1=predict1_mean/r(mean)

** Percentage
display share1


*** Second Prediction

** Coefficient:
ivreg2 dln_ratio_ratio (dln_ratio_ratio_cf=dg) [w=population] if downtown==1
scalar cons=_b[_cons]
predict predict2, xb
replace predict2 = predict2-cons

** Predicted
sum predict2 [w=population] if downtown==1 & rank<=25
scalar predict2_mean=r(mean)
** Actual:
sum dln_ratio_ratio [w=population] if downtown==1 & rank<=25

scalar share2=predict2_mean/r(mean)
** Percentage
display share2


*** Third prediction
** Coefficient: 
ivreg2 dln_ratio_ratio (dln_ratio_ratio_cf=dg_college dg_nocollege) [w=population] if downtown==1
scalar cons=_b[_cons]
predict predict3, xb
replace predict3 = predict3-cons

** Predicted
sum predict3 [w=population] if downtown==1 & rank<=25
scalar predict3_mean=r(mean)

** Actual
sum dln_ratio_ratio [w=population] if downtown==1 & rank<=25

scalar share3=predict3_mean/r(mean)
** Percentage
display share3


*** fourth prediction
** Coefficient: 
ivreg2 dln_ratio_ratio (dg=dval) [w=population] if downtown==1
scalar cons=_b[_cons]
predict predict4, xb
replace predict4 = predict4-cons
** Predicted
sum predict4 [w=population] if downtown==1 & rank<=25
scalar predict4_mean=r(mean)
** Actual
sum dln_ratio_ratio [w=population] if downtown==1 & rank<=25

scalar share4=predict4_mean/r(mean)
** Percentage
display share4




*************************************+*************************************+****
**# Output - LHP Skill
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"

cd $data\temp_files

u val_40_60_total_1990_2000_2010, clear

merge 1:1 occ2010 using high_skill
keep if _merge==3
drop _merge

g dval=val_2010-val_1990
g neg_high_skill=-high_skill
sort neg_high_skill occ2010

order occ2010 val_1990 val_2000 val_2010 dval high_skill

** Table A10
edit occ2010 val_1990 val_2010 dval high_skill if val_1990!=. & val_2000!=. & val_2010!=.



*************************************+*************************************+****
**# Output - Income Ratio
*************************************+*************************************+****


clear all
global data="/Users/linagomez/Documents/Stata/Economía Urbana/132721-V1/data"


***********************************
*** income ratio (5 miles)
**********************************
cd "$data/nhgis"
import delimited nhgis0038_ds82_1950_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1950_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/geographic"
merge m:1 gisjoin using tract1950_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

cd "$data/temp_files"
save 1950, replace

**
cd "$data/nhgis"
import delimited nhgis0005_ds92_1960_tract.csv,  clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1960_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/geographic"
merge m:1 gisjoin using tract1960_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

cd "$data/temp_files"
save 1960, replace
**

cd "$data/nhgis"
import delimited nhgis0005_ds99_1970_tract.csv, clear
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1970_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/geographic"
merge m:1 gisjoin using tract1970_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

cd "$data/temp_files"
save 1970, replace

**
cd "$data/nhgis"
import delimited nhgis0005_ds107_1980_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1980_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/geographic"
merge m:1 gisjoin using tract1980_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

cd "$data/temp_files"
save 1980, replace

**
cd "$data/nhgis"
import delimited nhgis0005_ds123_1990_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/geographic"
merge m:1 gisjoin using tract1990_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

cd "$data/temp_files"
save 1990, replace

***

cd "$data/nhgis"
import delimited nhgis0005_ds151_2000_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract2000_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge

cd "$data/geographic"
merge m:1 gisjoin using tract2000_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

cd "$data/temp_files"
save 2000, replace

cd "$data/nhgis"
import delimited nhgis0005_ds184_20115_2011_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract2010_metarea
keep if _merge==3
drop _merge
drop year
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/geographic"
merge m:1 gisjoin using tract2010_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

cd "$data/temp_files"
save 2010, replace



****1960 ****
cd "$data/temp_files"
u 1960, clear
keep gisjoin year state metarea downtown  b8w001 
g income=500
drop if b8w001==0
ren b8w001 count
keep income downtown metarea gisjoin count
save 1, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w002 
g income=1500
drop if b8w002==0
ren b8w002 count
keep income downtown metarea gisjoin count
save 2, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w003 
g income=2500
drop if b8w003==0
ren b8w003 count
keep income downtown metarea gisjoin count
save 3, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w004 
g income=3500
drop if b8w004==0
ren b8w004 count
keep income downtown metarea gisjoin count
save 4, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w005 
g income=4500
drop if b8w005==0
ren b8w005 count
keep income downtown metarea gisjoin count
save 5, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w006 
g income=5500
drop if b8w006==0
ren b8w006 count
keep income downtown metarea gisjoin count
save 6, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w007 
g income=6500
drop if b8w007==0
ren b8w007 count
keep income downtown metarea gisjoin count
save 7, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w008
g income=7500
drop if b8w008==0
ren b8w008 count
keep income downtown metarea gisjoin count
save 8, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w009
g income=8500
drop if b8w009==0
ren b8w009 count
keep income downtown metarea gisjoin count
save 9, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w010
g income=9500
drop if b8w010==0
ren b8w010 count
keep income downtown metarea gisjoin count
save 10, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w011
g income=12500
drop if b8w011==0
ren b8w011 count
keep income downtown metarea gisjoin count
save 11, replace

u 1960, clear
keep gisjoin year state metarea downtown b8w012
g income=20000
drop if b8w012==0
ren b8w012 count
keep income downtown metarea gisjoin count
save 12, replace

u 1960, clear
keep gisjoin year state metarea downtown b8w013
g income=25000
drop if b8w013==0
ren b8w013 count
keep income downtown metarea gisjoin count
save 13, replace

clear
foreach num of numlist 1(1)13 {
append using `num'
*erase `num'.dta
}

g year=1960
sort metarea
save 1960_income, replace



**** 1970 ****
cd "$data/temp_files"
u 1970, clear
g income=500
drop if c3t001==0
ren c3t001 count
keep income downtown metarea gisjoin count
save 1, replace

u 1970, clear
g income=1500
drop if c3t002==0
ren c3t002 count
keep income downtown metarea gisjoin count
save 2, replace

u 1970, clear
g income=2500
drop if c3t003==0
ren c3t003 count
keep income downtown metarea gisjoin count
save 3, replace

u 1970, clear
g income=3500
drop if c3t004==0
ren c3t004 count
keep income downtown metarea gisjoin count
save 4, replace

u 1970, clear
g income=4500
drop if c3t005==0
ren c3t005 count
keep income downtown metarea gisjoin count
save 5, replace

u 1970, clear
g income=5500
drop if c3t006==0
ren c3t006 count
keep income downtown metarea gisjoin count
save 6, replace

u 1970, clear
g income=6500
drop if c3t007==0
ren c3t007 count
keep income downtown metarea gisjoin count
save 7, replace

u 1970, clear
g income=7500
drop if c3t008==0
ren c3t008 count
keep income downtown metarea gisjoin count
save 8, replace

u 1970, clear
g income=8500
drop if c3t009==0
ren c3t009 count
keep income downtown metarea gisjoin count
save 9, replace

u 1970, clear
g income=9500
drop if c3t010==0
ren c3t010 count
keep income downtown metarea gisjoin count
save 10, replace

u 1970, clear
g income=11000
drop if c3t011==0
ren c3t011 count
keep income downtown metarea gisjoin count
save 11, replace

u 1970, clear
g income=14000
drop if c3t012==0
ren c3t012 count
keep income downtown metarea gisjoin count
save 12, replace

u 1970, clear
g income=20000
drop if c3t013==0
ren c3t013 count
keep income downtown metarea gisjoin count
save 13, replace

u 1970, clear
g income=32500
drop if c3t014==0
ren c3t014 count
keep income downtown metarea gisjoin count
save 14, replace

u 1970, clear
g income=50000
drop if c3t015==0
ren c3t015 count
keep income downtown metarea gisjoin count
save 15, replace


foreach num of numlist 1(1)15 {
append using `num'
*erase `num'.dta
}

g year=1970
sort metarea
replace count=0 if count==-1
save 1970_income, replace


*** 1980 ***
cd "$data/temp_files"
u 1980, clear
g income=1250
drop if did001==0
ren did001 count
keep income downtown metarea gisjoin count
save 1, replace

u 1980, clear 
g income=3750
drop if did002==0
ren did002 count
keep income downtown metarea gisjoin count
save 2, replace

u 1980, clear 
g income=6250
drop if did003==0
ren did003 count
keep income downtown metarea gisjoin count
save 3, replace

u 1980, clear
g income=8750
drop if did004==0
ren did004 count
keep income downtown metarea gisjoin count
save 4, replace

u 1980, clear
g income=11250
drop if did005==0
ren did005 count
keep income downtown metarea gisjoin count
save 5, replace

u 1980, clear
g income=13750
drop if did006==0
ren did006 count
keep income downtown metarea gisjoin count
save 6, replace

u 1980, clear 
g income=16250
drop if did007==0
ren did007 count
keep income downtown metarea gisjoin count
save 7, replace

u 1980, clear
g income=18750
drop if did008==0
ren did008 count
keep income downtown metarea gisjoin count
save 8, replace

u 1980, clear
g income=21250
drop if did009==0
ren did009 count
keep income downtown metarea gisjoin count
save 9, replace

u 1980, clear
g income=23750
drop if did010==0
ren did010 count
keep income downtown metarea gisjoin count
save 10, replace

u 1980, clear
g income=26250
drop if did011==0
ren did011 count
keep income downtown metarea gisjoin count
save 11, replace

u 1980, clear
g income=28750
drop if did012==0
ren did012 count
keep income downtown metarea gisjoin count
save 12, replace

u 1980, clear
g income=32500
drop if did013==0
ren did013 count
keep income downtown metarea gisjoin count
save 13, replace

u 1980, clear
g income=37500
drop if did014==0
ren did014 count
keep income downtown metarea gisjoin count
save 14, replace

u 1980, clear
g income=45000
drop if did015==0
ren did015 count
keep income downtown metarea gisjoin count
save 15, replace

u 1980, clear
g income=62500
drop if did016==0
ren did016 count
keep income downtown metarea gisjoin count
save 16, replace

u 1980, clear
g income=75000
drop if did017==0
ren did017 count
keep income downtown metarea gisjoin count
save 17, replace

foreach num of numlist 1(1)17 {
append using `num'
*erase `num'.dta
}

g year=1980
sort metarea
replace count=0 if count==-1
save 1980_income, replace

*** 1990 ***
cd "$data/temp_files"
u 1990, clear
g income=2500
drop if e4t001==0
ren e4t001 count
keep income downtown metarea gisjoin count
save 1, replace

u 1990, clear
g income=7500
drop if e4t002==0
ren e4t002 count
keep income downtown metarea gisjoin count
save 2, replace

u 1990, clear
g income=11250
drop if e4t003==0
ren e4t003 count
keep income downtown metarea gisjoin count
save 3, replace

u 1990, clear
g income=13750
drop if e4t004==0
ren e4t004 count
keep income downtown metarea gisjoin count
save 4, replace

u 1990, clear
g income=16250
drop if e4t005==0
ren e4t005 count
keep income downtown metarea gisjoin count
save 5, replace

u 1990, clear
g income=18750
drop if e4t006==0
ren e4t006 count
keep income downtown metarea gisjoin count
save 6, replace

u 1990, clear
g income=21250
drop if e4t007==0
ren e4t007 count
keep income downtown metarea gisjoin count
save 7, replace

u 1990, clear
g income=23750
drop if e4t008==0
ren e4t008 count
keep income downtown metarea gisjoin count
save 8, replace

u 1990, clear
g income=26250
drop if e4t009==0
ren e4t009 count
keep income downtown metarea gisjoin count
save 9, replace

u 1990, clear
g income=28750
drop if e4t010==0
ren e4t010 count
keep income downtown metarea gisjoin count
save 10, replace

u 1990, clear
g income=31250
drop if e4t011==0
ren e4t011 count
keep income downtown metarea gisjoin count
save 11, replace

u 1990, clear
g income=33750
drop if e4t012==0
ren e4t012 count
keep income downtown metarea gisjoin count
save 12, replace

u 1990, clear
g income=37250
drop if e4t013==0
ren e4t013 count
keep income downtown metarea gisjoin count
save 13, replace

u 1990, clear
g income=38750
drop if e4t014==0
ren e4t014 count
keep income downtown metarea gisjoin count
save 14, replace

u 1990, clear
g income=41250
drop if e4t015==0
ren e4t015 count
keep income downtown metarea gisjoin count
save 15, replace

u 1990, clear
g income=43750
drop if e4t016==0
ren e4t016 count
keep income downtown metarea gisjoin count
save 16, replace

u 1990, clear
g income=46250
drop if e4t017==0
ren e4t017 count
keep income downtown metarea gisjoin count
save 17, replace

u 1990, clear
g income=48750
drop if e4t018==0
ren e4t018 count
keep income downtown metarea gisjoin count
save 18, replace

u 1990, clear
g income=52500
drop if e4t019==0
ren e4t019 count
keep income downtown metarea gisjoin count
save 19, replace

u 1990, clear
g income=57500
drop if e4t020==0
ren e4t020 count
keep income downtown metarea gisjoin count
save 20, replace

u 1990, clear
g income=62500
drop if e4t021==0
ren e4t021 count
keep income downtown metarea gisjoin count
save 21, replace

u 1990, clear
g income=87500
drop if e4t022==0
ren e4t022 count
keep income downtown metarea gisjoin count
save 22, replace

u 1990, clear
g income=112500
drop if e4t023==0
ren e4t023 count
keep income downtown metarea gisjoin count
save 23, replace

u 1990, clear
g income=137500
drop if e4t024==0
ren e4t024 count
keep income downtown metarea gisjoin count
save 24, replace


u 1990, clear
g income=150000
drop if e4t025==0
ren e4t025 count
keep income downtown metarea gisjoin count
save 25, replace

foreach num of numlist 1(1)25 {
append using `num'
*erase `num'.dta
}

g year=1990
sort metarea
replace count=0 if count==-1
save 1990_income, replace


*** 2000 ***
cd "$data/temp_files"
u 2000, clear
g income=5000
drop if gmx001==0
ren gmx001 count
keep income downtown metarea gisjoin count
save 1, replace

u 2000, clear
g income=12500
drop if gmx002==0
ren gmx002 count
keep income downtown metarea gisjoin count
save 2, replace

u 2000, clear
g income=17500
drop if gmx003==0
ren gmx003 count
keep income downtown metarea gisjoin count
save 3, replace

u 2000, clear
g income=22500
drop if gmx004==0
ren gmx004 count
keep income downtown metarea gisjoin count
save 4, replace

u 2000, clear
g income=27500
drop if gmx005==0
ren gmx005 count
keep income downtown metarea gisjoin count
save 5, replace

u 2000, clear
g income=32500
drop if gmx006==0
ren gmx006 count
keep income downtown metarea gisjoin count
save 6, replace

u 2000, clear
g income=37500
drop if gmx007==0
ren gmx007 count
keep income downtown metarea gisjoin count
save 7, replace

u 2000, clear
g income=42500
drop if gmx008==0
ren gmx008 count
keep income downtown metarea gisjoin count
save 8, replace

u 2000, clear
g income=47500
drop if gmx009==0
ren gmx009 count
keep income downtown metarea gisjoin count
save 9, replace

u 2000, clear
g income=55000
drop if gmx010==0
ren gmx010 count
keep income downtown metarea gisjoin count
save 10, replace

u 2000, clear
g income=67500
drop if gmx011==0
ren gmx011 count
keep income downtown metarea gisjoin count
save 11, replace

u 2000, clear
g income=87500
drop if gmx012==0
ren gmx012 count
keep income downtown metarea gisjoin count
save 12, replace

u 2000, clear
g income=112500
drop if gmx013==0
ren gmx013 count
keep income downtown metarea gisjoin count
save 13, replace

u 2000, clear
g income=137500
drop if gmx014==0
ren gmx014 count
keep income downtown metarea gisjoin count
save 14, replace

u 2000, clear
g income=175000
drop if gmx015==0
ren gmx015 count
keep income downtown metarea gisjoin count
save 15, replace

u 2000, clear
g income=200000
drop if gmx016==0
ren gmx016 count
keep income downtown metarea gisjoin count
save 16, replace


foreach num of numlist 1(1)16 {
append using `num'
*erase `num'.dta
}

g year=2000
sort metarea
replace count=0 if count==-1
save 2000_income, replace


*** 2010 ***
cd "$data/temp_files"
u 2010, clear
g income=5000
drop if mp0e002==0
ren mp0e002 count
keep income downtown metarea gisjoin count
save 2, replace

u 2010, clear
g income=12500
drop if mp0e003==0
ren mp0e003 count
keep income downtown metarea gisjoin count
save 3, replace

u 2010, clear
g income=17500
drop if mp0e004==0
ren mp0e004 count
keep income downtown metarea gisjoin count
save 4, replace

u 2010, clear
g income=22500
drop if mp0e005==0
ren mp0e005 count
keep income downtown metarea gisjoin count
save 5, replace

u 2010, clear
g income=27500
drop if mp0e006==0
ren mp0e006 count
keep income downtown metarea gisjoin count
save 6, replace

u 2010, clear
g income=32500
drop if mp0e007==0
ren mp0e007 count
keep income downtown metarea gisjoin count
save 7, replace

u 2010, clear
g income=37500
drop if mp0e008==0
ren mp0e008 count
keep income downtown metarea gisjoin count
save 8, replace

u 2010, clear
g income=42500
drop if mp0e009==0
ren mp0e009 count
keep income downtown metarea gisjoin count
save 9, replace

u 2010, clear
g income=47500
drop if mp0e010==0
ren mp0e010 count
keep income downtown metarea gisjoin count
save 10, replace

u 2010, clear
g income=55000
drop if mp0e011==0
ren mp0e011 count
keep income downtown metarea gisjoin count
save 11, replace

u 2010, clear
g income=67500
drop if mp0e012==0
ren mp0e012 count
keep income downtown metarea gisjoin count
save 12, replace

u 2010, clear
g income=87500
drop if mp0e013==0
ren mp0e013 count
keep income downtown metarea gisjoin count
save 13, replace

u 2010, clear
g income=112500
drop if mp0e014==0
ren mp0e014 count
keep income downtown metarea gisjoin count
save 14, replace

u 2010, clear
g income=137500
drop if mp0e015==0
ren mp0e015 count
keep income downtown metarea gisjoin count
save 15, replace

u 2010, clear
g income=175000
drop if mp0e016==0
ren mp0e016 count
keep income downtown metarea gisjoin count
save 16, replace

u 2010, clear
g income=200000
drop if mp0e017==0
ren mp0e017 count
keep income downtown metarea gisjoin count
save 17, replace


foreach num of numlist 2(1)17 {
append using `num'
}

g year=2010
sort metarea
replace count=0 if count==-1
save 2010_income, replace

*****
****1950
cd "$data/temp_files"
u 1950, clear
keep if rank<=25
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd "$data/temp_files"
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/temp_files"
keep if rank<=25
collapse income [w=count], by(downtown year)
save temp_`num', replace
}
clear
foreach num of numlist 1950(10)2010 {
append using temp_`num'
}
drop if downtown==.
reshape wide income, i(year) j(downtown)
g income_ratio=income1/income0

*** Main Figure (Figure 1a)

** income ratio (5 miles to downtown) top 25 MSAs
graph twoway connected income_ratio year, xlabel(1950(10)2010) ytitle(Central city income/suburb household income)  xtitle(Census year) graphregion(color(white)) yscale(range(0.72 0.85)) ylabel(0.7(0.05)0.9)
graph export "$data/graph/income_ratio_25.emf", replace


*** Appendix Figures
**** Ranking (1-10)
****1950
cd "$data/temp_files"
u 1950, clear
keep if rank>=1 & rank<=10
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd "$data/temp_files"
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/temp_files"
keep if rank>=1 & rank<=10
collapse income [w=count], by(downtown year)
save temp_`num', replace
}
clear
foreach num of numlist 1950(10)2010 {
append using temp_`num'
}
drop if downtown==.
reshape wide income, i(year) j(downtown)
g income_ratio=income1/income0

graph twoway connected income_ratio year, xlabel(1950(10)2010) ytitle(Central city income/suburb household income)  xtitle(Census year) graphregion(color(white)) 
graph export "$data/graph"\income_ratio_1_10_5mi.emf, replace

**** Ranking (11-25)
****1950
cd "$data/temp_files"
u 1950, clear
keep if rank>=11 & rank<=25
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd "$data/temp_files"
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/temp_files"
keep if rank>=11 & rank<=25
collapse income [w=count], by(downtown year)
save temp_`num', replace
}
clear
foreach num of numlist 1950(10)2010 {
append using temp_`num'
}
drop if downtown==.
reshape wide income, i(year) j(downtown)
g income_ratio=income1/income0

graph twoway connected income_ratio year, xlabel(1950(10)2010) ytitle(Central city income/suburb household income)  xtitle(Census year) graphregion(color(white)) 
graph export "$data/graph"\income_ratio_11_25_5mi.emf, replace



**** Ranking (25-50)
****1950
cd "$data/temp_files"
u 1950, clear
keep if rank>25 & rank<=50
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd "$data/temp_files"
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/temp_files"
keep if  rank>25 & rank<=50
collapse income [w=count], by(downtown year)
save temp_`num', replace
}
clear
foreach num of numlist 1950(10)2010 {
append using temp_`num'
}
drop if downtown==.
reshape wide income, i(year) j(downtown)
g income_ratio=income1/income0

graph twoway connected income_ratio year, xlabel(1950(10)2010) ytitle(Central city income/suburb household income)  xtitle(Census year) graphregion(color(white)) 
graph export "$data/graph"\income_ratio_25_50_5mi.emf, replace
****1950
cd "$data/temp_files"
u 1950, clear
keep if rank>50
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd "$data/temp_files"
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/temp_files"
keep if  rank>50
collapse income [w=count], by(downtown year)
save temp_`num', replace
}
clear
foreach num of numlist 1950(10)2010 {
append using temp_`num'
}
drop if downtown==.
reshape wide income, i(year) j(downtown)
g income_ratio=income1/income0

graph twoway connected income_ratio year, xlabel(1950(10)2010) ytitle(Central city income/suburb household income)  xtitle(Census year) graphregion(color(white)) 
graph export "$data/graph"\income_ratio_50+_5mi.emf, replace

*******************************************************************************
*******************************************************************************
*******************************************************************************
*******************************************************************************
***********************************
*** income ratio (3 miles)
**********************************
cd "$data/nhgis"
import delimited nhgis0038_ds82_1950_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1950_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/geographic"
merge m:1 gisjoin using tract1950_downtown3mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

cd "$data/temp_files"
save 1950, replace

**
cd "$data/nhgis"
import delimited nhgis0005_ds92_1960_tract.csv,  clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1960_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/geographic"
merge m:1 gisjoin using tract1960_downtown3mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

cd "$data/temp_files"
save 1960, replace
**

cd "$data/nhgis"
import delimited nhgis0005_ds99_1970_tract.csv, clear
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1970_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/geographic"
merge m:1 gisjoin using tract1970_downtown3mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

cd "$data/temp_files"
save 1970, replace

**
cd "$data/nhgis"
import delimited nhgis0005_ds107_1980_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1980_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/geographic"
merge m:1 gisjoin using tract1980_downtown3mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

cd "$data/temp_files"
save 1980, replace

**
cd "$data/nhgis"
import delimited nhgis0005_ds123_1990_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
*keep if rank<=25
cd "$data/geographic"
merge m:1 gisjoin using tract1990_downtown3mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

cd "$data/temp_files"
save 1990, replace

***

cd "$data/nhgis"
import delimited nhgis0005_ds151_2000_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract2000_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
*keep if rank<=25

cd "$data/geographic"
merge m:1 gisjoin using tract2000_downtown3mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

cd "$data/temp_files"
save 2000, replace

cd "$data/nhgis"
import delimited nhgis0005_ds184_20115_2011_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract2010_metarea
keep if _merge==3
drop _merge
drop year
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
*keep if rank<=25
cd "$data/geographic"
merge m:1 gisjoin using tract2010_downtown3mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

cd "$data/temp_files"
save 2010, replace



****1960 ****
cd "$data/temp_files"
u 1960, clear
keep gisjoin year state metarea downtown  b8w001 
g income=500
drop if b8w001==0
ren b8w001 count
keep income downtown metarea gisjoin count
save 1, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w002 
g income=1500
drop if b8w002==0
ren b8w002 count
keep income downtown metarea gisjoin count
save 2, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w003 
g income=2500
drop if b8w003==0
ren b8w003 count
keep income downtown metarea gisjoin count
save 3, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w004 
g income=3500
drop if b8w004==0
ren b8w004 count
keep income downtown metarea gisjoin count
save 4, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w005 
g income=4500
drop if b8w005==0
ren b8w005 count
keep income downtown metarea gisjoin count
save 5, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w006 
g income=5500
drop if b8w006==0
ren b8w006 count
keep income downtown metarea gisjoin count
save 6, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w007 
g income=6500
drop if b8w007==0
ren b8w007 count
keep income downtown metarea gisjoin count
save 7, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w008
g income=7500
drop if b8w008==0
ren b8w008 count
keep income downtown metarea gisjoin count
save 8, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w009
g income=8500
drop if b8w009==0
ren b8w009 count
keep income downtown metarea gisjoin count
save 9, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w010
g income=9500
drop if b8w010==0
ren b8w010 count
keep income downtown metarea gisjoin count
save 10, replace

u 1960, clear
keep gisjoin year state metarea downtown  b8w011
g income=12500
drop if b8w011==0
ren b8w011 count
keep income downtown metarea gisjoin count
save 11, replace

u 1960, clear
keep gisjoin year state metarea downtown b8w012
g income=20000
drop if b8w012==0
ren b8w012 count
keep income downtown metarea gisjoin count
save 12, replace

u 1960, clear
keep gisjoin year state metarea downtown b8w013
g income=25000
drop if b8w013==0
ren b8w013 count
keep income downtown metarea gisjoin count
save 13, replace

clear
foreach num of numlist 1(1)13 {
append using `num'
*erase `num'.dta
}

g year=1960
sort metarea
save 1960_income, replace



**** 1970 ****
cd "$data/temp_files"
u 1970, clear
g income=500
drop if c3t001==0
ren c3t001 count
keep income downtown metarea gisjoin count
save 1, replace

u 1970, clear
g income=1500
drop if c3t002==0
ren c3t002 count
keep income downtown metarea gisjoin count
save 2, replace

u 1970, clear
g income=2500
drop if c3t003==0
ren c3t003 count
keep income downtown metarea gisjoin count
save 3, replace

u 1970, clear
g income=3500
drop if c3t004==0
ren c3t004 count
keep income downtown metarea gisjoin count
save 4, replace

u 1970, clear
g income=4500
drop if c3t005==0
ren c3t005 count
keep income downtown metarea gisjoin count
save 5, replace

u 1970, clear
g income=5500
drop if c3t006==0
ren c3t006 count
keep income downtown metarea gisjoin count
save 6, replace

u 1970, clear
g income=6500
drop if c3t007==0
ren c3t007 count
keep income downtown metarea gisjoin count
save 7, replace

u 1970, clear
g income=7500
drop if c3t008==0
ren c3t008 count
keep income downtown metarea gisjoin count
save 8, replace

u 1970, clear
g income=8500
drop if c3t009==0
ren c3t009 count
keep income downtown metarea gisjoin count
save 9, replace

u 1970, clear
g income=9500
drop if c3t010==0
ren c3t010 count
keep income downtown metarea gisjoin count
save 10, replace

u 1970, clear
g income=11000
drop if c3t011==0
ren c3t011 count
keep income downtown metarea gisjoin count
save 11, replace

u 1970, clear
g income=14000
drop if c3t012==0
ren c3t012 count
keep income downtown metarea gisjoin count
save 12, replace

u 1970, clear
g income=20000
drop if c3t013==0
ren c3t013 count
keep income downtown metarea gisjoin count
save 13, replace

u 1970, clear
g income=32500
drop if c3t014==0
ren c3t014 count
keep income downtown metarea gisjoin count
save 14, replace

u 1970, clear
g income=50000
drop if c3t015==0
ren c3t015 count
keep income downtown metarea gisjoin count
save 15, replace


foreach num of numlist 1(1)15 {
append using `num'
*erase `num'.dta
}

g year=1970
sort metarea
replace count=0 if count==-1
save 1970_income, replace


*** 1980 ***
cd "$data/temp_files"
u 1980, clear
g income=1250
drop if did001==0
ren did001 count
keep income downtown metarea gisjoin count
save 1, replace

u 1980, clear 
g income=3750
drop if did002==0
ren did002 count
keep income downtown metarea gisjoin count
save 2, replace

u 1980, clear 
g income=6250
drop if did003==0
ren did003 count
keep income downtown metarea gisjoin count
save 3, replace

u 1980, clear
g income=8750
drop if did004==0
ren did004 count
keep income downtown metarea gisjoin count
save 4, replace

u 1980, clear
g income=11250
drop if did005==0
ren did005 count
keep income downtown metarea gisjoin count
save 5, replace

u 1980, clear
g income=13750
drop if did006==0
ren did006 count
keep income downtown metarea gisjoin count
save 6, replace

u 1980, clear 
g income=16250
drop if did007==0
ren did007 count
keep income downtown metarea gisjoin count
save 7, replace

u 1980, clear
g income=18750
drop if did008==0
ren did008 count
keep income downtown metarea gisjoin count
save 8, replace

u 1980, clear
g income=21250
drop if did009==0
ren did009 count
keep income downtown metarea gisjoin count
save 9, replace

u 1980, clear
g income=23750
drop if did010==0
ren did010 count
keep income downtown metarea gisjoin count
save 10, replace

u 1980, clear
g income=26250
drop if did011==0
ren did011 count
keep income downtown metarea gisjoin count
save 11, replace

u 1980, clear
g income=28750
drop if did012==0
ren did012 count
keep income downtown metarea gisjoin count
save 12, replace

u 1980, clear
g income=32500
drop if did013==0
ren did013 count
keep income downtown metarea gisjoin count
save 13, replace

u 1980, clear
g income=37500
drop if did014==0
ren did014 count
keep income downtown metarea gisjoin count
save 14, replace

u 1980, clear
g income=45000
drop if did015==0
ren did015 count
keep income downtown metarea gisjoin count
save 15, replace

u 1980, clear
g income=62500
drop if did016==0
ren did016 count
keep income downtown metarea gisjoin count
save 16, replace

u 1980, clear
g income=75000
drop if did017==0
ren did017 count
keep income downtown metarea gisjoin count
save 17, replace

foreach num of numlist 1(1)17 {
append using `num'
*erase `num'.dta
}

g year=1980
sort metarea
replace count=0 if count==-1
save 1980_income, replace

*** 1990 ***
cd "$data/temp_files"
u 1990, clear
g income=2500
drop if e4t001==0
ren e4t001 count
keep income downtown metarea gisjoin count
save 1, replace

u 1990, clear
g income=7500
drop if e4t002==0
ren e4t002 count
keep income downtown metarea gisjoin count
save 2, replace

u 1990, clear
g income=11250
drop if e4t003==0
ren e4t003 count
keep income downtown metarea gisjoin count
save 3, replace

u 1990, clear
g income=13750
drop if e4t004==0
ren e4t004 count
keep income downtown metarea gisjoin count
save 4, replace

u 1990, clear
g income=16250
drop if e4t005==0
ren e4t005 count
keep income downtown metarea gisjoin count
save 5, replace

u 1990, clear
g income=18750
drop if e4t006==0
ren e4t006 count
keep income downtown metarea gisjoin count
save 6, replace

u 1990, clear
g income=21250
drop if e4t007==0
ren e4t007 count
keep income downtown metarea gisjoin count
save 7, replace

u 1990, clear
g income=23750
drop if e4t008==0
ren e4t008 count
keep income downtown metarea gisjoin count
save 8, replace

u 1990, clear
g income=26250
drop if e4t009==0
ren e4t009 count
keep income downtown metarea gisjoin count
save 9, replace

u 1990, clear
g income=28750
drop if e4t010==0
ren e4t010 count
keep income downtown metarea gisjoin count
save 10, replace

u 1990, clear
g income=31250
drop if e4t011==0
ren e4t011 count
keep income downtown metarea gisjoin count
save 11, replace

u 1990, clear
g income=33750
drop if e4t012==0
ren e4t012 count
keep income downtown metarea gisjoin count
save 12, replace

u 1990, clear
g income=37250
drop if e4t013==0
ren e4t013 count
keep income downtown metarea gisjoin count
save 13, replace

u 1990, clear
g income=38750
drop if e4t014==0
ren e4t014 count
keep income downtown metarea gisjoin count
save 14, replace

u 1990, clear
g income=41250
drop if e4t015==0
ren e4t015 count
keep income downtown metarea gisjoin count
save 15, replace

u 1990, clear
g income=43750
drop if e4t016==0
ren e4t016 count
keep income downtown metarea gisjoin count
save 16, replace

u 1990, clear
g income=46250
drop if e4t017==0
ren e4t017 count
keep income downtown metarea gisjoin count
save 17, replace

u 1990, clear
g income=48750
drop if e4t018==0
ren e4t018 count
keep income downtown metarea gisjoin count
save 18, replace

u 1990, clear
g income=52500
drop if e4t019==0
ren e4t019 count
keep income downtown metarea gisjoin count
save 19, replace

u 1990, clear
g income=57500
drop if e4t020==0
ren e4t020 count
keep income downtown metarea gisjoin count
save 20, replace

u 1990, clear
g income=62500
drop if e4t021==0
ren e4t021 count
keep income downtown metarea gisjoin count
save 21, replace

u 1990, clear
g income=87500
drop if e4t022==0
ren e4t022 count
keep income downtown metarea gisjoin count
save 22, replace

u 1990, clear
g income=112500
drop if e4t023==0
ren e4t023 count
keep income downtown metarea gisjoin count
save 23, replace

u 1990, clear
g income=137500
drop if e4t024==0
ren e4t024 count
keep income downtown metarea gisjoin count
save 24, replace


u 1990, clear
g income=150000
drop if e4t025==0
ren e4t025 count
keep income downtown metarea gisjoin count
save 25, replace

foreach num of numlist 1(1)25 {
append using `num'
*erase `num'.dta
}

g year=1990
sort metarea
replace count=0 if count==-1
save 1990_income, replace


*** 2000 ***
cd "$data/temp_files"
u 2000, clear
g income=5000
drop if gmx001==0
ren gmx001 count
keep income downtown metarea gisjoin count
save 1, replace

u 2000, clear
g income=12500
drop if gmx002==0
ren gmx002 count
keep income downtown metarea gisjoin count
save 2, replace

u 2000, clear
g income=17500
drop if gmx003==0
ren gmx003 count
keep income downtown metarea gisjoin count
save 3, replace

u 2000, clear
g income=22500
drop if gmx004==0
ren gmx004 count
keep income downtown metarea gisjoin count
save 4, replace

u 2000, clear
g income=27500
drop if gmx005==0
ren gmx005 count
keep income downtown metarea gisjoin count
save 5, replace

u 2000, clear
g income=32500
drop if gmx006==0
ren gmx006 count
keep income downtown metarea gisjoin count
save 6, replace

u 2000, clear
g income=37500
drop if gmx007==0
ren gmx007 count
keep income downtown metarea gisjoin count
save 7, replace

u 2000, clear
g income=42500
drop if gmx008==0
ren gmx008 count
keep income downtown metarea gisjoin count
save 8, replace

u 2000, clear
g income=47500
drop if gmx009==0
ren gmx009 count
keep income downtown metarea gisjoin count
save 9, replace

u 2000, clear
g income=55000
drop if gmx010==0
ren gmx010 count
keep income downtown metarea gisjoin count
save 10, replace

u 2000, clear
g income=67500
drop if gmx011==0
ren gmx011 count
keep income downtown metarea gisjoin count
save 11, replace

u 2000, clear
g income=87500
drop if gmx012==0
ren gmx012 count
keep income downtown metarea gisjoin count
save 12, replace

u 2000, clear
g income=112500
drop if gmx013==0
ren gmx013 count
keep income downtown metarea gisjoin count
save 13, replace

u 2000, clear
g income=137500
drop if gmx014==0
ren gmx014 count
keep income downtown metarea gisjoin count
save 14, replace

u 2000, clear
g income=175000
drop if gmx015==0
ren gmx015 count
keep income downtown metarea gisjoin count
save 15, replace

u 2000, clear
g income=200000
drop if gmx016==0
ren gmx016 count
keep income downtown metarea gisjoin count
save 16, replace


foreach num of numlist 1(1)16 {
append using `num'
*erase `num'.dta
}

g year=2000
sort metarea
replace count=0 if count==-1
save 2000_income, replace


*** 2010 ***
cd "$data/temp_files"
u 2010, clear
g income=5000
drop if mp0e002==0
ren mp0e002 count
keep income downtown metarea gisjoin count
save 2, replace

u 2010, clear
g income=12500
drop if mp0e003==0
ren mp0e003 count
keep income downtown metarea gisjoin count
save 3, replace

u 2010, clear
g income=17500
drop if mp0e004==0
ren mp0e004 count
keep income downtown metarea gisjoin count
save 4, replace

u 2010, clear
g income=22500
drop if mp0e005==0
ren mp0e005 count
keep income downtown metarea gisjoin count
save 5, replace

u 2010, clear
g income=27500
drop if mp0e006==0
ren mp0e006 count
keep income downtown metarea gisjoin count
save 6, replace

u 2010, clear
g income=32500
drop if mp0e007==0
ren mp0e007 count
keep income downtown metarea gisjoin count
save 7, replace

u 2010, clear
g income=37500
drop if mp0e008==0
ren mp0e008 count
keep income downtown metarea gisjoin count
save 8, replace

u 2010, clear
g income=42500
drop if mp0e009==0
ren mp0e009 count
keep income downtown metarea gisjoin count
save 9, replace

u 2010, clear
g income=47500
drop if mp0e010==0
ren mp0e010 count
keep income downtown metarea gisjoin count
save 10, replace

u 2010, clear
g income=55000
drop if mp0e011==0
ren mp0e011 count
keep income downtown metarea gisjoin count
save 11, replace

u 2010, clear
g income=67500
drop if mp0e012==0
ren mp0e012 count
keep income downtown metarea gisjoin count
save 12, replace

u 2010, clear
g income=87500
drop if mp0e013==0
ren mp0e013 count
keep income downtown metarea gisjoin count
save 13, replace

u 2010, clear
g income=112500
drop if mp0e014==0
ren mp0e014 count
keep income downtown metarea gisjoin count
save 14, replace

u 2010, clear
g income=137500
drop if mp0e015==0
ren mp0e015 count
keep income downtown metarea gisjoin count
save 15, replace

u 2010, clear
g income=175000
drop if mp0e016==0
ren mp0e016 count
keep income downtown metarea gisjoin count
save 16, replace

u 2010, clear
g income=200000
drop if mp0e017==0
ren mp0e017 count
keep income downtown metarea gisjoin count
save 17, replace


foreach num of numlist 2(1)17 {
append using `num'
}

g year=2010
sort metarea
replace count=0 if count==-1
save 2010_income, replace

*****
****1950
cd "$data/temp_files"
u 1950, clear
keep if rank<=25
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd "$data/temp_files"
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/temp_files"
keep if rank<=25
collapse income [w=count], by(downtown year)
save temp_`num', replace
}
clear
foreach num of numlist 1950(10)2010 {
append using temp_`num'
}
drop if downtown==.
reshape wide income, i(year) j(downtown)
g income_ratio=income1/income0

** income ratio (3 miles to downtown) top 25 MSAs
graph twoway connected income_ratio year, xlabel(1950(10)2010) ytitle(Central city income/suburb household income)  xtitle(Census year) graphregion(color(white)) yscale(range(0.72 0.85)) ylabel(0.7(0.05)0.9)
graph export "$data/graph"\income_ratio_25_3mi.emf, replace


**** Ranking (1-10)
****1950
cd "$data/temp_files"
u 1950, clear
keep if rank>=1 & rank<=10
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd "$data/temp_files"
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/temp_files"
keep if rank>=1 & rank<=10
collapse income [w=count], by(downtown year)
save temp_`num', replace
}
clear
foreach num of numlist 1950(10)2010 {
append using temp_`num'
}
drop if downtown==.
reshape wide income, i(year) j(downtown)
g income_ratio=income1/income0

graph twoway connected income_ratio year, xlabel(1950(10)2010) ytitle(Central city income/suburb household income)  xtitle(Census year) graphregion(color(white)) 
graph export "$data/graph"\income_ratio_1_10_3mi.emf, replace

**** Ranking (11-25)
****1950
cd "$data/temp_files"
u 1950, clear
keep if rank>=11 & rank<=25
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd "$data/temp_files"
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/temp_files"
keep if rank>=11 & rank<=25
collapse income [w=count], by(downtown year)
save temp_`num', replace
}
clear
foreach num of numlist 1950(10)2010 {
append using temp_`num'
}
drop if downtown==.
reshape wide income, i(year) j(downtown)
g income_ratio=income1/income0

graph twoway connected income_ratio year, xlabel(1950(10)2010) ytitle(Central city income/suburb household income)  xtitle(Census year) graphregion(color(white)) 
graph export "$data/graph"\income_ratio_11_25_3mi.emf, replace



**** Ranking (25-50)
****1950
cd "$data/temp_files"
u 1950, clear
keep if rank>25 & rank<=50
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd "$data/temp_files"
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/temp_files"
keep if  rank>25 & rank<=50
collapse income [w=count], by(downtown year)
save temp_`num', replace
}
clear
foreach num of numlist 1950(10)2010 {
append using temp_`num'
}
drop if downtown==.
reshape wide income, i(year) j(downtown)
g income_ratio=income1/income0

graph twoway connected income_ratio year, xlabel(1950(10)2010) ytitle(Central city income/suburb household income)  xtitle(Census year) graphregion(color(white)) 
graph export "$data/graph"\income_ratio_25_50_3mi.emf, replace


****1950
cd "$data/temp_files"
u 1950, clear
keep if rank>50
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd "$data/temp_files"
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd "$data/temp_files"
keep if  rank>50
collapse income [w=count], by(downtown year)
save temp_`num', replace
}
clear
foreach num of numlist 1950(10)2010 {
append using temp_`num'
}
drop if downtown==.
reshape wide income, i(year) j(downtown)
g income_ratio=income1/income0

graph twoway connected income_ratio year, xlabel(1950(10)2010) ytitle(Central city income/suburb household income)  xtitle(Census year) graphregion(color(white)) 
graph export "$data/graph"\income_ratio_50+_3mi.emf, replace


******************************************************************************************************
******************************************************************************************************
******************************************************************************************************
******************************************************************************************************
*******************************
*** home value ratio
*********************************

*** Extract from raw data (NHGIS)

cd "$data/nhgis"

import delimited nhgis0004_ds82_1950_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1950_metarea
keep if _merge==3
drop _merge
cd "$data/temp_files"
save 1950, replace

cd "$data/nhgis"
import delimited nhgis0004_ds92_1960_tract.csv,  clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1960_metarea
keep if _merge==3
drop _merge
cd "$data/temp_files"
save 1960, replace

cd "$data/nhgis"
import delimited nhgis0004_ds95_1970_tract.csv, clear
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1970_metarea
keep if _merge==3
drop _merge
cd "$data/temp_files"
save 1970, replace

cd "$data/nhgis"
import delimited nhgis0004_ds104_1980_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1980_metarea
keep if _merge==3
drop _merge
cd "$data/temp_files"
save 1980, replace

cd "$data/nhgis"
import delimited nhgis0004_ds120_1990_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge
cd "$data/temp_files"
save 1990, replace

cd "$data/nhgis"
import delimited nhgis0004_ds151_2000_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract2000_metarea
keep if _merge==3
drop _merge
cd "$data/temp_files"
save 2000, replace

cd "$data/nhgis"
import delimited nhgis0004_ds176_20105_2010_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract2010_metarea
keep if _merge==3
drop _merge
cd "$data/temp_files"
save 2010, replace

***
cd "$data/temp_files"
u 1950, clear

cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
keep if rank<=25

cd "$data/geographic"
merge m:1 gisjoin using tract1950_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge


ren b05001 rent
ren b09001 hvalue
replace rent=. if rent==0
replace hvalue=. if hvalue==0
collapse (mean) rent (mean) hvalue, by(downtown)
drop if downtown==.
cd "$data/temp_files"
g year=1950
save temp_1950, replace


cd "$data/temp_files"
u 1960, clear

cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
keep if rank<=25

cd "$data/geographic"
merge m:1 gisjoin using tract1960_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge


# delimit
collapse (sum) b7o001 b7o002 b7o003 b7o004 b7o005 b7o006 b7o007 
b7o008 b7o009 b7o010 b7p001 b7p002 b7p003 b7p004 b7p005 b7p006 
b7p007 b7p008 b7p009 b7p010 b7p011 b7p012 b7p013, by(downtown);
# delimit cr

# delimit
g hvalue=(2500*b7o001+6200*b7o002+8700*b7o003+11200*b7o004+13700*b7o005+16200*b7o006+
18700*b7o007+22450*b7o008+29950*b7o009+35000*b7o010)/(b7o001+b7o002+b7o003+b7o004+b7o005+
b7o006+b7o007+b7o008+b7o009+b7o010);
# delimit cr

# delimit
g rent=(10*b7p001+24.5*b7p002+34.5*b7p003+44.5*b7p004+54.5*b7p005+64.5*b7p006+74.5*b7p007+
84.5*b7p008+94.5*b7p009+109.5*b7p010+129.5*b7p011+174.5*b7p012+200*b7p013)/(b7p001+b7p002+
b7p003+b7p004+b7p005+b7p006+b7p007+b7p008+b7p009+b7p010+b7p011+b7p012+b7p013);
# delimit cr
drop if downtown==.
keep downtown hvalue rent
cd "$data/temp_files"
g year=1960
save temp_1960, replace

cd "$data/temp_files"
u 1970, clear

cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
keep if rank<=25

cd "$data/geographic"
merge m:1 gisjoin using tract1970_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

# delimit
collapse (sum) cg7001 cg7002 cg7003 cg7004 cg7005 cg7006 cg7007 
cg7008 cg7009 cg7010 cg7011 cha001 cha002 cha003 cha004 cha005 
cha006 cha007 cha008 cha009 cha010 cha011 cha012 cha013 cha014, by(downtown);
# delimit cr

# delimit
g hvalue=(2500*cg7001+6250*cg7002+8750*cg7003+11250*cg7004+13750*cg7005+
16250*cg7006+18750*cg7007+22500*cg7008+30000*cg7009+42500*cg7010+50000*cg7011)/
(cg7001+cg7002+cg7003+cg7004+cg7005+
cg7006+cg7007+cg7008+cg7009+cg7010+cg7011);
# delimit cr

# delimit
g rent=(15*cha001+35*cha002+45*cha003+55*cha004+65*cha005+75*cha006+85*cha007
+95*cha008+110*cha009+130*cha010+175*cha011+225*cha012+275*cha013+300*cha014)/
(cha001+cha002+cha003+cha004+cha005+cha006+cha007
+cha008+cha009+cha010+cha011+cha012+cha013+cha014);
# delimit cr

drop if downtown==.
keep downtown hvalue rent
cd "$data/temp_files"
g year=1970
save temp_1970, replace


cd "$data/temp_files"
u 1980, clear

cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
keep if rank<=25

cd "$data/geographic"
merge m:1 gisjoin using tract1980_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

# delimit
collapse (sum) c8i001 c8i002 c8i003 c8i004 c8i005 c8i006 c8i007 
c8i008 c8i009 c8i010 c8i011 c8i012 c8i013 c8n001 c8n002 c8n003 
c8n004 c8n005 c8n006 c8n007 c8n008 c8n009 c8n010 c8n011 c8n012 c8n013,
 by(downtown);
# delimit cr

# delimit
g hvalue=(5000*c8i001+12500*c8i002+17500*c8i003+22500*c8i004+27500*c8i005+
32500*c8i006+37500*c8i007+45000*c8i008+65000*c8i009+90000*c8i010+125000*c8i011
+175000*c8i012+200000*c8i013)/
(c8i001+c8i002+c8i003+c8i004+c8i005+c8i006+c8i007+c8i008+c8i009+c8i010+c8i011
+c8i012+c8i013);
# delimit cr

# delimit
g rent=(25*c8n001+75*c8n002+110*c8n003+130*c8n004+145*c8n005+155*c8n006
+165*c8n007+180*c8n008+225*c8n009+275*c8n010+350*c8n011+450*c8n012+500*c8n013)/
(c8n001+c8n002+c8n003+c8n004+c8n005+c8n006
+c8n007+c8n008+c8n009+c8n010+c8n011+c8n012+c8n013);
# delimit cr
drop if downtown==.
keep downtown hvalue rent
cd "$data/temp_files"
g year=1980
save temp_1980, replace

cd "$data/temp_files"
u 1990, clear

cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
keep if rank<=25

cd "$data/geographic"
merge m:1 gisjoin using tract1990_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

# delimit
collapse (sum) esr001 esr002 esr003 esr004 esr005 esr006 
esr007 esr008 esr009 esr010 esr011 esr012 esr013 esr014 
esr015 esr016 esr017 esr018 esr019 esr020 
es4001 es4002 es4003 es4004 es4005 es4006 es4007 es4008 
es4009 es4010 es4011 es4012 es4013 es4014 es4015 es4016, by(downtown);
# delimit cr

# delimit
g hvalue=(7500*esr001+17500*esr002+22500*esr003+27500*esr004
+32500*esr005+37500*esr006+42500*esr007+47500*esr008
+55000*esr009+67500*esr010+87500*esr011+112500*esr012
+137500*esr013+162500*esr014+187500*esr015+225000*esr016
+275000*esr017+350000*esr018+450000*esr019+500000*esr020)/
(esr001+esr002+esr003+esr004
+esr005+esr006+esr007+esr008
+esr009+esr010+esr011+esr012
+esr013+esr014+esr015+esr016
+esr017+esr018+esr019+esr020);
# delimit cr

# delimit
g rent=(50*es4001+125*es4002+175*es4003+225*es4004+275*es4005
+325*es4006+375*es4007+425*es4008+475*es4009+525*es4010+575*es4011
+625*es4012+675*es4013+725*es4014+875*es4015+1000*es4016)/
(es4001+es4002+es4003+es4004+es4005
+es4006+es4007+es4008+es4009+es4010+es4011
+es4012+es4013+es4014+es4015+es4016);
# delimit cr
drop if downtown==.
keep downtown hvalue rent
cd "$data/temp_files"
g year=1990
save temp_1990, replace


cd "$data/temp_files"
u 2000, clear

cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
keep if rank<=25

cd "$data/geographic"
merge m:1 gisjoin using tract2000_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

# delimit
collapse (sum)
gbe001 gbe002 gbe003 gbe004 gbe005 gbe006 gbe007 gbe008 
gbe009 gbe010 gbe011 gbe012 gbe013 gbe014 gbe015 gbe016 
gbe017 gbe018 gbe019 gbe020 gbe021 gb5001 gb5002 
gb5003 gb5004 gb5005 gb5006 gb5007 gb5008 gb5009 gb5010 
gb5011 gb5012 gb5013 gb5014 gb5015 gb5016 gb5017 gb5018 
gb5019 gb5020 gb5021 gb5022 gb5023 gb5024, by(downtown);
# delimit cr

# delimit
g hvalue=(5000*gb5001+12500*gb5002 
+17500*gb5003+22500*gb5004+27500*gb5005+32500*gb5006+37500*gb5007+
45000*gb5008+55000*gb5009+65000*gb5010+75000*gb5011+85000*gb5012+
95000*gb5013+112500*gb5014+137500*gb5015+162500*gb5016+187500*gb5017+
225000*gb5018+275000*gb5019+350000*gb5020+450000*gb5021+625000*gb5022+
875000*gb5023+1000000*gb5024)/
(gb5001+gb5002+gb5003+gb5004+gb5005+gb5006+gb5007+gb5008+gb5009+gb5010+
gb5011+gb5012+gb5013+gb5014+gb5015+gb5016+gb5017+gb5018+
gb5019+gb5020+gb5021+gb5022+gb5023+gb5024);
# delimit cr

# delimit
g rent=(50*gbe001+125*gbe002+175*gbe003+225*gbe004+275*gbe005+325*gbe006+375*gbe007+425*gbe008+
475*gbe009+525*gbe010+575*gbe011+625*gbe012+675*gbe013+725*gbe014+775*gbe015+850*gbe016+
950*gbe017+1125*gbe018+1375*gbe019+1750*gbe020+2000*gbe021)/
(gbe001+gbe002+gbe003+gbe004+gbe005+gbe006+gbe007+gbe008+
gbe009+gbe010+gbe011+gbe012+gbe013+gbe014+gbe015+gbe016+
gbe017+gbe018+gbe019+gbe020+gbe021);
# delimit cr

drop if downtown==.
keep downtown hvalue rent
cd "$data/temp_files"
g year=2000
save temp_2000, replace


cd "$data/temp_files"
u 2010, clear
drop year
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
keep if rank<=25

cd "$data/geographic"
merge m:1 gisjoin using tract2010_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

# delimit
collapse (sum)
jsxe003 jsxe004 jsxe005 jsxe006 jsxe007 
jsxe008 jsxe009 jsxe010 jsxe011 jsxe012 jsxe013 jsxe014 
jsxe015 jsxe016 jsxe017 jsxe018 jsxe019 jsxe020 jsxe021 
jsxe022 jsxe023
jtge002 jtge003 jtge004 jtge005 jtge006 
jtge007 jtge008 jtge009 jtge010 jtge011 jtge012 
jtge013 jtge014 jtge015 jtge016 jtge017 jtge018 
jtge019 jtge020 jtge021 jtge022 jtge023 jtge024 
jtge025, by(downtown);
# delimit cr

# delimit
g hvalue=(5000*jtge002+12500*jtge003+17500*jtge004+22500*jtge005+27500*jtge006+
32500*jtge007+37500*jtge008+45000*jtge009+55000*jtge010+65000*jtge011+75000*jtge012+
85000*jtge013+95000*jtge014+112500*jtge015+137500*jtge016+162500*jtge017+187500*jtge018+
225000*jtge019+275000*jtge020+350000*jtge021+450000*jtge022+625000*jtge023+875000*jtge024+
1000000*jtge025)/
(jtge002+jtge003+jtge004+jtge005+jtge006+
jtge007+jtge008+jtge009+jtge010+jtge011+jtge012+
jtge013+jtge014+jtge015+jtge016+jtge017+jtge018+
jtge019+jtge020+jtge021+jtge022+jtge023+jtge024+
jtge025);
# delimit cr

# delimit
g rent=(50*jsxe003+125*jsxe004+175*jsxe005+225*jsxe006+275*jsxe007+
325*jsxe008+375*jsxe009+425*jsxe010+475*jsxe011+525*jsxe012+575*jsxe013+625*jsxe014+
675*jsxe015+725*jsxe016+775*jsxe017+850*jsxe018+950*jsxe019+1125*jsxe020+1375*jsxe021+
1750*jsxe022+2000*jsxe023)/
(jsxe003+jsxe004+jsxe005+jsxe006+jsxe007+
jsxe008+jsxe009+jsxe010+jsxe011+jsxe012+jsxe013+jsxe014+
jsxe015+jsxe016+jsxe017+jsxe018+jsxe019+jsxe020+jsxe021+
jsxe022+jsxe023);
# delimit cr
drop if downtown==.
keep downtown hvalue rent
cd "$data/temp_files"
g year=2010
save temp_2010, replace

clear
foreach num of numlist 1950(10)2010 {
append using temp_`num'

}
reshape wide rent hvalue, i(year) j(downtown)
g rent_ratio=rent1/rent0
g hvalue_ratio=hvalue1/hvalue0


*** Main Figure (Figure 1b)
cd "$data/graph"
*****Graphs - home value ratio (3 miles within downtown pin vs outside)
graph twoway connected hvalue_ratio year, xlabel(1950(10)2010) ytitle(Central city home value/suburb home value) xtitle(Census year) graphregion(color(white))
graph export hvalue_ratio_25.emf, replace


***** Population (top 25 MSA)
cd "$data/nhgis"
import delimited nhgis0039_ds82_1950_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1950_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
keep if rank<=25

cd "$data/geographic"
merge m:1 gisjoin using tract1950_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

g total=bz8001
keep gisjoin metarea downtown total
g year=1950
cd "$data/temp_files"
save 1950, replace

***** Population (top 25 MSA)
cd "$data/nhgis"
import delimited nhgis0039_ds92_1960_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1960_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
keep if rank<=25

cd "$data/geographic"
merge m:1 gisjoin using tract1960_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

g total=ca4001
keep gisjoin metarea downtown total
g year=1960
cd "$data/temp_files"
save 1960, replace

***** Population (top 25 MSA)
cd "$data/nhgis"
import delimited nhgis0039_ds97_1970_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1970_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
keep if rank<=25

cd "$data/geographic"
merge m:1 gisjoin using tract1970_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

g total=cy7001
keep gisjoin metarea downtown total
g year=1970
cd "$data/temp_files"
save 1970, replace

***** Population (top 25 MSA)
cd "$data/nhgis"
import delimited nhgis0039_ds104_1980_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1980_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
keep if rank<=25

cd "$data/geographic"
merge m:1 gisjoin using tract1980_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

g total=c7l001
keep gisjoin metarea downtown total
g year=1980
cd "$data/temp_files"
save 1980, replace

***** Population (top 25 MSA)
cd "$data/nhgis"
import delimited nhgis0039_ds120_1990_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
keep if rank<=25

cd "$data/geographic"
merge m:1 gisjoin using tract1990_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

g total=et1001
keep gisjoin metarea downtown total
g year=1990
cd "$data/temp_files"
save 1990, replace

cd "$data/nhgis"
import delimited nhgis0039_ds146_2000_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract2000_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
keep if rank<=25

cd "$data/geographic"
merge m:1 gisjoin using tract2000_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

g total=fl5001
keep gisjoin metarea downtown total
g year=2000
cd "$data/temp_files"
save 2000, replace

cd "$data/nhgis"
import delimited nhgis0039_ds184_20115_2011_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin
drop county
cd "$data/geographic"
merge 1:1 gisjoin using tract2010_metarea
keep if _merge==3
drop _merge
cd "$data/geographic"
merge m:1 metarea using 1990_rank, force
drop _merge
keep if rank<=25

cd "$data/geographic"
merge m:1 gisjoin using tract2010_downtown5mi
g downtown=0
replace downtown=1 if _merge==3
drop if _merge==2
drop _merge

g total=mnte001
keep gisjoin metarea downtown total
g year=2010
cd "$data/temp_files"
save 2010, replace


cd "$data/temp_files"
clear
append using 1950
append using 1960
append using 1970
append using 1980
append using 1990
append using 2000
append using 2010

collapse (sum) total, by(year downtown)
sort year downtown
by year: g ratio=total/(total+total[_n-1])

# delimit
graph twoway (connected ratio year if downtown==1), 
xlabel(1950(10)2010) ylabel(0(0.1)0.4) ytitle(Central city population share)  xtitle(year) graphregion(color(white)) 
xscale(range(1950 2010)) yscale(range(0 0.2));
# delimit cr
graph export "$data/graph/pop_share25.emf", replace

*************************************+*************************************+****
**# Output - Skill Ratio
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"


****skill ratio against distance
cd $data\temp_files

u skill_pop, clear
g ratio1990= impute1990_high/ impute1990_low
g ratio2000= impute2000_high/ impute2000_low
g ratio2010= impute2010_high/ impute2010_low

cd $data\geographic\
merge 1:1 gisjoin using tract1990_downtown_200mi
keep if _merge==3
drop _merge

merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

replace distance=distance/1609
g dratio=ln( ratio2010)-ln(ratio1990)
g dratio2000=ln(ratio2000) - ln(ratio1990)
g dratio2010=ln(ratio2010) - ln(ratio2000)
cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge

cd $data\graph\
# delimit 
graph twoway (lpoly dratio distance) (lpoly dratio2000 distance, lpattern(dash)) (lpoly dratio2010 distance,lpattern(shortdash)) if distance<=30 & rank<=25
, ytitle(Change in log skill ratio) xtitle(distance to downtown) legend(lab(1 "1990 - 2010") lab(2 "1990 - 2000") lab(3 "2000 - 2010"))
graphregion(color(white)) yscale(range(0 0.6)) ylabel(0(0.2)0.6);
# delimit cr
graph export dratio_distance_25.emf, replace



**** Figure 4


*** By income 1980s
cd $data\temp_files

u skill_pop, clear
g ratio1990= impute1990_high/ impute1990_low
g ratio2010= impute2010_high/ impute2010_low

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown_200mi
keep if _merge==3
drop _merge

merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

replace distance=distance/1609
g dratio=ln( ratio2010)-ln(ratio1990)

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge
drop if gisjoin==""

ren gisjoin gisjoin1
merge 1:1 gisjoin1 using $data\geographic\tract1990_tract1980_nearest.dta
keep if _merge==3
drop _merge

ren gisjoin2 gisjoin

cd $data\temp_files
merge m:1 gisjoin using 1980_income_rank

g pop1990_high=int(impute1990_high)
g pop2010_high=int(impute2010_high)
g downtown=0
replace downtown=1 if distance<=5
g dpop_high= pop2010_high- pop1990_high
keep if rank<=25
collapse (sum) dpop_high, by(rank_income downtown)

sort downtown
drop if rank_income==.
by downtown: egen total=total(dpop_high)
g dpop_high_share=dpop_high/total
sort downtown rank_income


lab define rank 1 "1st quintile" 2 "2nd quintile" 3 "3rd quintile" 4 "4th quintile" 5 "5th quintile"
lab value rank_income rank
graph bar dpop_high_share if downtown==1, over(rank_income) b1title(Income rank in 1980) ytitle(Fraction of additional high-skilled residents) graphregion(color(white)) yscale(range(0 0.7)) ylabel(0(0.2)0.6)
cd $data\graph
graph export new_skilled_by_1980_income.png, replace


*** By income 2000
cd $data\temp_files

u skill_pop, clear
g ratio1990= impute1990_high/ impute1990_low
g ratio2010= impute2010_high/ impute2010_low

cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown_200mi
keep if _merge==3
drop _merge

merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

replace distance=distance/1609
g dratio=ln( ratio2010)-ln(ratio1990)

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge
drop if gisjoin==""

ren gisjoin gisjoin1
merge 1:1 gisjoin1 using $data\geographic\tract1990_tract2000_nearest.dta
keep if _merge==3
drop _merge

ren gisjoin2 gisjoin

cd $data\temp_files
merge m:1 gisjoin using 2000_income_rank

g pop1990_high=int(impute1990_high)
g pop2010_high=int(impute2010_high)
g downtown=0
replace downtown=1 if distance<=5
g dpop_high= pop2010_high- pop1990_high
keep if rank<=25
collapse (sum) dpop_high, by(rank_income downtown)

sort downtown
drop if rank_income==.
by downtown: egen total=total(dpop_high)
g dpop_high_share=dpop_high/total
sort downtown rank_income


lab define rank 1 "1st quintile" 2 "2nd quintile" 3 "3rd quintile" 4 "4th quintile" 5 "5th quintile"
lab value rank_income rank
graph bar dpop_high_share if downtown==1, over(rank_income) b1title(Income rank in 2000) ytitle(Fraction of additional high-skilled residents) graphregion(color(white))  yscale(range(0 0.7)) ylabel(0(0.2)0.6)
cd $data\graph
graph export new_skilled_by_2000_income.png, replace


*************************************+*************************************+****
**# Output - Residential Work
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"


cd $data\temp_files

u occ_emp_1994,clear

cd $data\geographic

merge m:1 zip using zip1990_downtown
drop if _merge==2

g downtown=0
replace downtown=1 if _merge==3
drop _merge


cd $data\geographic

merge m:1 zip using zip1990_metarea
keep if _merge==3
drop _merge

cd $data\geographic

merge m:1 metarea using 1990_rank
keep if _merge==3
drop _merge

cd $data\geographic
keep if rank<=25
drop serial year

collapse (sum) est_num1990=est_num, by(occ2010 downtown)
cd $data\temp_files
save temp1990, replace

**2000
cd $data\temp_files

u occ_emp_2000,clear

cd $data\geographic

merge m:1 zip using zip2000_downtown
drop if _merge==2

g downtown=0
replace downtown=1 if _merge==3
drop _merge


cd $data\geographic

merge m:1 zip using zip2000_metarea
keep if _merge==3
drop _merge

cd $data\geographic

merge m:1 metarea using 1990_rank
keep if _merge==3
drop _merge

cd $data\geographic
keep if rank<=25
drop serial year

collapse (sum) est_num2000=est_num, by(occ2010 downtown)
cd $data\temp_files
save temp2000, replace
***
**2010
cd $data\temp_files

u occ_emp_2010,clear

cd $data\geographic

merge m:1 zip using zip2010_downtown
drop if _merge==2

g downtown=0
replace downtown=1 if _merge==3
drop _merge

cd $data\geographic

merge m:1 zip using zip2010_metarea
keep if _merge==3
drop _merge

cd $data\geographic

merge m:1 metarea using 1990_rank
keep if _merge==3
drop _merge

cd $data\geographic
keep if rank<=25
drop serial year

collapse (sum) est_num2010=est_num, by(occ2010 downtown)
cd $data\temp_files
save temp2010, replace

cd $data\temp_files
clear
u temp1990, clear
merge 1:1 occ2010 downtown using temp2000
keep if _merge==3
drop _merge

merge 1:1 occ2010 downtown using temp2010
keep if _merge==3
drop _merge 

sort occ2010 downtown

by occ2010: g ratio_emp2010=est_num2010/(est_num2010+est_num2010[_n-1])
by occ2010: g ratio_emp2000=est_num2000/(est_num2000+est_num2000[_n-1])
by occ2010: g ratio_emp1990=est_num1990/(est_num1990+est_num1990[_n-1])

keep occ2010 downtown ratio_emp*
save occ_emp_downtown, replace


**** residential share
cd $data\temp_files
 u tract_impute.dta, clear
 cd $data\geographic
 merge m:1 gisjoin using tract1990_downtown5mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge

 cd $data\geographic

merge m:1 metarea using 1990_rank
keep if _merge==3
drop _merge

keep if rank<=25
drop serial year

collapse (sum) impute1990 impute2000 impute2010, by(occ2010 downtown)
by occ2010: g ratio1990=impute1990/(impute1990+impute1990[_n-1])
by occ2010: g ratio2000=impute2000/(impute2000+impute2000[_n-1])
by occ2010: g ratio2010=impute2010/(impute2010+impute2010[_n-1])

keep occ2010 downtown ratio1990 ratio2000 ratio2010

cd $data\temp_files
merge 1:1 occ2010 downtown using occ_emp_downtown
keep if _merge==3
drop _merge
cd $data\geographic

g dratio=ln(ratio2010)-ln(ratio1990)
g dratio_emp=ln(ratio_emp2010)-ln(ratio_emp1990)

label define occ 120 "financial worker" 2100 "Lawyer"
label values occ2010 occ

g occ2010_2=occ2010 if occ2010==800 | occ2010==2100 | occ2010==4820 | occ2010==30 | occ2010==1000 | occ2010==5700 | occ2010==4030
cd $data\temp_files
merge m:1 occ2010 using college_share
keep if _merge==3
drop _merge

g high_skill=0
replace high_skill=1 if college_share1990>0.4

cd $data\temp_files
merge m:1 occ2010 using count1990_rank25
drop _merge

** binscatters
# delimit 
binscatter ratio2010 ratio1990 [w=count1990],  
by(high_skill) legend(lab(1 "Low skill") lab(2 "High skill"))  msymbols(O S)
xtitle(Share of residents in central cities in 1990) ytitle(Share of residents in central cities in 2010) text(0.25 0.1 "Slope (Low-skilled) = 0.688 (0.0713)", size(medsmall))
text(0.23 0.1008 "Slope (High-skilled) = 1.052 (0.0692)", size(medsmall)) text(0.21 0.089 "Difference = 0.364 (0.0994)", size(medsmall));
# delimit cr
graph export $data\graph\central_res_1990_2010.emf, replace
graph export $data\graph\labeled\figure_3a.pdf, replace


# delimit 
binscatter ratio_emp2010 ratio_emp1990 [w=count1990],  
by(high_skill) legend(lab(1 "Low skill") lab(2 "High skill")) msymbols(O S) 
xtitle(Share of employment in central cities in 1994) ytitle(Share of employment in central cities in 2010) text(0.36 0.2 "Slope (Low-skilled) = 0.785 (0.054)", size(medsmall))
text(0.335 0.205 "Slope (High-skilled) = 0.819 (0.0509)", size(medsmall)) text(0.31 0.185 "Difference = 0.0342 (0.0743)", size(medsmall));
# delimit cr
graph export $data\graph\central_emp_1990_2010.emf, replace
graph export $data\graph\labeled\figure_3b.pdf, replace




*** Job concentration in central cities (appendix figure)

**
# delimit 
graph twoway (scatter ratio1990 ratio_emp1990  [w=count1990], msize(small) msymbol(oh)) (line ratio1990 ratio1990)
,legend(lab(1 "Occupation")  lab(2 "45 degree line"))
xtitle(Share of employment in central cities in 1994) ytitle(Share of residents in central cities in 1990) graphregion(color(white));
# delimit cr
graph export $data\graph\central_emp_res.emf, replace
graph export $data\graph\labeled\figure_a9.pdf, replace

cd $data\temp_files
u temp1990, clear
merge 1:1 occ2010 downtown using temp2000
keep if _merge==3
drop _merge

merge 1:1 occ2010 downtown using temp2010
keep if _merge==3
drop _merge 

sort occ2010 downtown

cd $data\temp_files
merge m:1 occ2010 using high_skill
drop if _merge==2
drop _merge

cd $data\temp_files
merge m:1 occ2010 using val_40_60_total_1990_2000_2010
keep if _merge==3
drop _merge

g dval=val_2010-val_1990
g fast=0
replace fast=1 if dval>=0.005

collapse (sum) est_num1990, by(high_skill fast downtown)

by high_skill fast: g share=est_num1990/(est_num1990+est_num1990[_n-1])

lab define fast_lab 1 "{&Delta} LHP>=0.005" 0 "{&Delta} LHP<0.005"
lab define high_skill_lab 1 "High-skilled jobs" 0 "Low-skilled jobs"
lab value fast fast_lab
lab value high_skill high_skill_lab

graph bar share, over(fast, lab(labsize(small))) over(high_skill) graphregion(color(white)) ytitle(Share of jobs in central cities (1994))
cd $data\graph
graph export job_central_cities.png, replace
graph export $data\graph\labeled\figure_a11.pdf, replace


*************************************+*************************************+****
**# Appendix - Wage Decile
*************************************+*************************************+****



clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"


cd $data\ipums_micro
u 1990_2000_2010_temp , clear

keep if uhrswork>=30

keep if sex==1
keep if age>=25 & age<=65
*keep if year==1990 | year==2010


*drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork==0
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

replace inctot_real=inctot_real/52

g wage_real=inctot_real/uhrswork

xtile wage_tile1990=wage_real [w=perwt] if year==1990, nq(10)
xtile wage_tile2000=wage_real [w=perwt] if year==2000, nq(10)
xtile wage_tile2010=wage_real [w=perwt] if year==2010, nq(10)
g wage_tile=wage_tile1990 if year==1990
replace wage_tile=wage_tile2000 if year==2000
replace wage_tile=wage_tile2010 if year==2010

g greaterthan50=0
replace greaterthan50=1 if uhrswork>=50


collapse greaterthan50 [w=perwt], by(year wage_tile)

cd $data\temp_files
save tile_1990_2010, replace

****
cd $data\ipums_micro
u 1980_1990, clear

keep if uhrswork>=30

keep if sex==1
keep if age>=25 & age<=65
keep if year==1980


drop if uhrswork==0
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999
ren inctot inctot_real

replace inctot_real=inctot_real/52

g wage_real=inctot_real/uhrswork

xtile wage_tile=wage_real [w=perwt], nq(10)


g greaterthan50=0
replace greaterthan50=1 if uhrswork>=50

collapse greaterthan50 [w=perwt], by(year wage_tile)

cd $data\temp_files
append using tile_1990_2010

*keep if year==1980 | year==2010

sort wage_tile year

by wage_tile: g dg10=greaterthan50-greaterthan50[_n-1]
by wage_tile: g dg20=greaterthan50-greaterthan50[_n-2]
by wage_tile: g dg30=greaterthan50-greaterthan50[_n-3]

*** Main figure
   cd $data\graph\
 
 # delimit 
 graph twoway (bar dg30 wage_tile if year==2010, msymbol(O) ) 
 , graphregion(color(white)) xtitle(Wage decile) ytitle(Change in prob of working >=50 hrs/week)
 xscale(range(1 10)) xlabel(1(1)10) legend(lab(1 "1980") lab(2 "2010")) saving(dgreaterthan50_wage_tile, replace);
 # delimit cr
 
 graph export dgreaterthan50_wage_tile.emf, replace
 
** Appendix figure

    cd $data\graph\
 
 # delimit 
 graph twoway (bar dg20 wage_tile if year==2000, msymbol(O) ) 
 , graphregion(color(white)) xtitle(Wage decile) ytitle(Change in prob of working >=50 hrs/week)
 xscale(range(1 10)) xlabel(1(1)10);
 # delimit cr
 

 graph export dgreaterthan50_wage_tile1980_2000.emf, replace
 
 
     cd $data\graph\
 
 # delimit 
 graph twoway (bar dg10 wage_tile if year==2010, msymbol(O) ) 
 , graphregion(color(white)) xtitle(Wage decile) ytitle(Change in prob of working >=50 hrs/week)
 xscale(range(1 10)) xlabel(1(1)10) yscale(range(-0.2 0)) ylabel(-0.2(0.05)0);
 # delimit cr
 

 graph export dgreaterthan50_wage_tile2000_2010.emf, replace
 
 
 *****************************
 *** Commute
 
 
*** Generate change in commute time by group
** By wage decile
cd $data\ipums_micro
u 1990_2000_2010_temp , clear

keep if uhrswork>=30

keep if age>=25 & age<=65
*keep if year==1990 | year==2010
keep if sex==1

*drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork==0
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

replace inctot_real=inctot_real/52

g wage_real=inctot_real/uhrswork

xtile wage_tile1990=wage_real [w=perwt] if year==1990, nq(10)
xtile wage_tile2000=wage_real [w=perwt] if year==2000, nq(10)
xtile wage_tile2010=wage_real [w=perwt] if year==2010, nq(10)
g wage_tile=wage_tile1990 if year==1990
replace wage_tile=wage_tile2000 if year==2000
replace wage_tile=wage_tile2010 if year==2010

g ln_trantime=ln(trantime)
keep if tranwork<70 & tranwork>0 & trantime>0

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge
keep if rank<=25

cd $data\temp_files
collapse ln_trantime [w=perwt], by(year wage_tile)

save commute_tile_1990_2010, replace

****
cd $data\ipums_micro
u 1980_1990, clear

keep if uhrswork>=30

keep if sex==1
keep if age>=25 & age<=65
keep if year==1980


drop if uhrswork==0
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999
ren inctot inctot_real

replace inctot_real=inctot_real/52

g wage_real=inctot_real/uhrswork

xtile wage_tile=wage_real [w=perwt], nq(10)

g ln_trantime=ln(trantime)

keep if tranwork<70 & tranwork>0 & trantime>0

cd $data\geographic
merge m:1 metarea using 1990_rank
drop _merge
keep if rank<=25
collapse ln_trantime [w=perwt], by(year wage_tile)

cd $data\temp_files
append using commute_tile_1990_2010

sort wage_tile year
 
 by wage_tile: g dln_trantime_10 = ln_trantime-ln_trantime[_n-1]

 **Main Figure
 by wage_tile: g dln_trantime_30 = ln_trantime-ln_trantime[_n-3]
  # delimit 
 graph twoway (bar dln_trantime_30 wage_tile if year==2010, msymbol(O) ) 
 , graphregion(color(white)) xtitle(Wage decile) ytitle(Change in mean log commute time)
 xscale(range(1 10)) xlabel(1(1)10) yscale(range(0.00 0.15)) ylabel(0(0.04)0.16) saving(ln_trantime_rank25_1980_2010, replace);
 # delimit cr
 
 graph export ln_trantime_rank25_1980_2010.png, replace
 
 
 *** Appendix figures
   cd $data\graph\
 # delimit 
 graph twoway (bar dln_trantime_10 wage_tile if year==2010, msymbol(O) ) 
 , graphregion(color(white)) xtitle(Wage decile) ytitle(Change in mean log commute time)
 xscale(range(1 10)) xlabel(1(1)10) yscale(range(0.00 0.15)) ylabel(0(0.04)0.16) saving(ln_trantime_rank25_2000_2010, replace);
 # delimit cr
 graph export ln_trantime_rank25_2000_2010.png, replace


by wage_tile: g dln_trantime_20 = ln_trantime-ln_trantime[_n-2]
   cd $data\graph\
 # delimit 
 graph twoway (bar dln_trantime_20 wage_tile if year==2000, msymbol(O) ) 
 , graphregion(color(white)) xtitle(Wage decile) ytitle(Change in mean log commute time)
 xscale(range(1 10)) xlabel(1(1)10) yscale(range(0.00 0.15)) ylabel(0(0.04)0.16) saving(ln_trantime_rank25_1980_2000, replace);
 # delimit cr
  graph export ln_trantime_rank25_1980_2000.png, replace


*************************************+*************************************+****
**# Output -  Figure CPS
*************************************+*************************************+****


clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"

*************************
** Hours definition changes before and after 1976. 
cd $data\cps
u cps_hours_annual, clear
keep if sex==1
keep if age<=65 & age>=25
drop if uhrsworkly>=997
drop if uhrsworkly<30
keep if year>=1976
replace inctot=. if inctot>=99999998

*** generate income percentile for each year

g wage_tile=.
g wage=inctot/uhrsworkly
foreach num of numlist 1976(1)2015 {
xtile wage_tile`num'=wage if year==`num', nq(10)
replace wage_tile=wage_tile`num' if year==`num'
}
cd $data\temp_files
save temp, replace

*** 1962 to 1976
cd $data\cps
u cps_hours, clear
keep if sex==1
keep if age<=65 & age>=25
drop if ahrsworkt>=997
drop if ahrsworkt<30
replace inctot=. if inctot>=99999998

*** generate income percentile for each year

g wage_tile=.
g wage=inctot/ahrsworkt
foreach num of numlist 1962(1)1975 {
xtile wage_tile`num'=wage if year==`num', nq(10)
replace wage_tile=wage_tile`num' if year==`num'
}
cd $data\temp_files
save temp_1962_1975, replace


*** Generate three year moving average of the percentage of full-time workers working at least 50 hours a week

foreach num of numlist 1962(1)2017 {
u temp_1962_1975, clear
append using temp
g greaterthan50=0
replace greaterthan50=1 if ahrsworkt>=50 & ahrsworkt<990 & year<=1975
replace greaterthan50=1 if uhrsworkly>=50 & uhrsworkly<990 & year>=1976
keep if ahrsworkt>=30 | uhrsworkly>=30

keep if year<=`num'+1 & year>=`num'-1
g wage_quintile=1 if wage_tile>=1 & wage_tile<=2
replace wage_quintile=2 if wage_tile>=3 & wage_tile<=4
replace wage_quintile=3 if wage_tile>=5 & wage_tile<=6
replace wage_quintile=4 if wage_tile>=7 & wage_tile<=8
replace wage_quintile=5 if wage_tile>=9 & wage_tile<=10

collapse greaterthan50, by(wage_tile)
g year=`num'
save temp_year`num'_g50, replace
}

clear all
foreach num of numlist 1962(1)2015 {
append using temp_year`num'_g50
}


# delimit 
graph twoway (connected greaterthan50 year if wage_tile==10, msymbol(diamond) msize(small)) (connected greaterthan50 year if wage_tile==1, msize(small))
,yscale(range(0.1 0.6)) ylabel(0.1(0.2)0.6) xlabel(1960(10)2015) graphregion(color(white)) 
xtitle(year) ytitle(Percentage of working >=50 hrs/week) legend(lab(1 "Percent of working long-hour (Top wage decile)") lab(2 "Percent of working long-hour (Bottom wage decile)") col(1)) ;
# delimit cr

graph export $data\graph\hour_trend_1962_2016.png, replace


  
*************************************+*************************************+****
**# Appendix - Income Rank
*************************************+*************************************+****
 
global data="C:\Users\alen_\Dropbox\paper_folder\replication\data"

** 1980 1990 2000 2010 income comes from demographic do file. 
clear all

cd $data\temp_files

u 1980_income, clear

collapse income [w=count], by(metarea gisjoin)
egen rank_income=xtile(income), n(5) by(metarea)

keep gisjoin rank_income

save 1980_income_rank, replace

u 1990_income, clear

collapse income [w=count], by(metarea gisjoin)
egen rank_income=xtile(income), n(5) by(metarea)

keep gisjoin rank_income

save 1990_income_rank, replace

u 2000_income, clear

collapse income [w=count], by(metarea gisjoin)
egen rank_income=xtile(income), n(5) by(metarea)

keep gisjoin rank_income

save 2000_income_rank, replace

u 2010_income, clear

collapse income [w=count], by(metarea gisjoin)
egen rank_income=xtile(income), n(5) by(metarea)

keep gisjoin rank_income

save 2010_income_rank, replace

**** income rank vs distance to downtown

cd $data\temp_files
u 1980_income_rank, clear
cd $data\geographic
merge 1:1 gisjoin using tract1980_downtown_200mi
keep if _merge==3
drop _merge

merge 1:1 gisjoin using tract1980_metarea
keep if _merge==3
drop _merge
replace distance=distance/1609
cd $data\temp_files
g year=1980
save temp1980, replace

cd $data\temp_files
u 1990_income_rank, clear
cd $data\geographic
merge 1:1 gisjoin using tract1990_downtown_200mi
keep if _merge==3
drop _merge

merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

replace distance=distance/1609
cd $data\temp_files
g year=1990
save temp1990, replace

cd $data\temp_files
u 2000_income_rank, clear
cd $data\geographic
merge 1:1 gisjoin using tract2000_downtown_200mi
keep if _merge==3
drop _merge

merge 1:1 gisjoin using tract2000_metarea
keep if _merge==3
drop _merge

replace distance=distance/1609
cd $data\temp_files
g year=2000
save temp2000, replace

cd $data\temp_files
u 2010_income_rank, clear
cd $data\geographic
merge 1:1 gisjoin using tract2010_downtown_200mi
keep if _merge==3
drop _merge

merge 1:1 gisjoin using tract2010_metarea
keep if _merge==3
drop _merge

replace distance=distance/1609
cd $data\temp_files
g year=2010
save temp2010, replace

clear 

u temp1980, clear
append using temp1990
append using temp2000
append using temp2010

cd $data\graph
# delimit 
graph twoway (lpoly rank_income distance if distance<=30 & year==1980,lpattern(dash)) 
(lpoly rank_income distance if distance<=30  & year==1990, lpattern(shortdash) )
(lpoly rank_income distance if distance<=30 & year==2000 , lpattern(longdash_dot))
 (lpoly rank_income distance if distance<=30 & year==2010, lcolor(black)) if metarea==160,
 legend(lab(1 "1980") lab(2 "1990") lab(3 "2000") lab(4 "2010") ) yscale(range(1 5)) ylabel(1(1)5)
 xtitle(distance to downtown (mile)) ytitle(Income quintile) graphregion(color(white))
 ;
 # delimit cr
 graph export chicago_income_quitile_distance.emf, replace
 
 # delimit 
graph twoway (lpoly rank_income distance if distance<=30 & year==1980,lpattern(dash)) 
(lpoly rank_income distance if distance<=30  & year==1990, lpattern(shortdash) )
(lpoly rank_income distance if distance<=30 & year==2000 , lpattern(longdash_dot))
 (lpoly rank_income distance if distance<=30 & year==2010, lcolor(black)) if metarea==560,
 legend(lab(1 "1980") lab(2 "1990") lab(3 "2000") lab(4 "2010") )  yscale(range(1 5)) ylabel(1(1)5)
 xtitle(distance to downtown (mile)) ytitle(Income quintile) graphregion(color(white))
 ;
 # delimit cr
  graph export ny_income_quitile_distance.emf, replace

 
 ********************************************************
 ********************************************************
 ********************************************************
 
  *** In a map (do stata instead of ArcMap)

  

**** Chicago

cd $data\temp_files
u 1980_income_rank, clear

cd $data\geographic
merge 1:1 gisjoin using longitude_latitude_tract1980
drop _merge

ren gisjoin GISJOIN

merge 1:1 GISJOIN using tract1980_shape

spmap rank_income using tract1980_coord if latitude<=5180000 & latitude>=5123040 & longitude>=-9801742 & longitude<=-9743004, id(id) fcolor(Reds) legend(pos(1)) cln(5)
cd $data\graph
graph export chicago_ranking_1980.png, replace

cd $data\temp_files
u 1990_income_rank, clear

cd $data\geographic
merge 1:1 gisjoin using longitude_latitude_tract1990
drop _merge

ren gisjoin GISJOIN

merge 1:1 GISJOIN using tract1990_shape

spmap rank_income using tract1990_coord if latitude<=5180000 & latitude>=5123040 & longitude>=-9801742 & longitude<=-9743004, id(id) fcolor(Reds) legend(pos(1)) cln(5)
cd $data\graph
graph export chicago_ranking_1990.png, replace


cd $data\temp_files
u 2000_income_rank, clear

ren gisjoin GISJOIN
cd $data\geographic
merge 1:1 GISJOIN using tract2000_shape

spmap rank_income using tract2000_coord if latitude<=5180000 & latitude>=5123040 & longitude>=-9801742 & longitude<=-9743004, id(id) fcolor(Reds) legend(pos(1)) cln(5)
cd $data\graph
graph export chicago_ranking_2000.png, replace

cd $data\temp_files
u 2010_income_rank, clear

ren gisjoin GISJOIN
cd $data\geographic
merge 1:1 GISJOIN using tract2010_shape

spmap rank_income using tract2010_coord if latitude<=5180000 & latitude>=5123040 & longitude>=-9801742 & longitude<=-9743004, id(id) fcolor(Reds) legend(pos(1)) cln(5)
cd $data\graph
graph export chicago_ranking_2010.png, replace

*****************************
******************************

**** New York

cd $data\temp_files
u 1980_income_rank, clear

cd $data\geographic
merge 1:1 gisjoin using longitude_latitude_tract1980
drop _merge

ren gisjoin GISJOIN

merge 1:1 GISJOIN using tract1980_shape

spmap rank_income using tract1980_coord if latitude<=5012000 & latitude>=4949000 & longitude>=-8265000 & longitude<=-8199000, id(id) fcolor(Reds) legend(pos(5)) cln(5)
cd $data\graph
graph export nyc_ranking_1980.png, replace

cd $data\temp_files
u 1990_income_rank, clear

cd $data\geographic
merge 1:1 gisjoin using longitude_latitude_tract1990
drop _merge

ren gisjoin GISJOIN

merge 1:1 GISJOIN using tract1990_shape

spmap rank_income using tract1990_coord if latitude<=5012000 & latitude>=4949000 & longitude>=-8265000 & longitude<=-8199000, id(id) fcolor(Reds) legend(pos(5)) cln(5)
cd $data\graph
graph export nyc_ranking_1990.png, replace



cd $data\temp_files
u 2000_income_rank, clear

ren gisjoin GISJOIN

cd $data\geographic
merge 1:1 GISJOIN using tract2000_shape

spmap rank_income using tract2000_coord if latitude<=5012000 & latitude>=4949000 & longitude>=-8265000 & longitude<=-8199000, id(id) fcolor(Reds) legend(pos(5)) cln(5)
cd $data\graph
graph export nyc_ranking_2000.png, replace

cd $data\temp_files
u 2010_income_rank, clear

ren gisjoin GISJOIN
cd $data\geographic
merge 1:1 GISJOIN using tract2010_shape

spmap rank_income using tract2010_coord if latitude<=5012000 & latitude>=4949000 & longitude>=-8265000 & longitude<=-8199000, id(id) fcolor(Reds) legend(pos(5)) cln(5)
cd $data\graph
graph export nyc_ranking_2010.png, replace



*************************************+*************************************+****
**# Output - LHP
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"



*** Financial specialists
cd $data\ipums_micro

u 1990_2000_2010_temp if occ2010==120 | occ2010==800| occ2010==4820, clear

drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork<40
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

replace inctot_real=inctot_real/52

replace inctot_real=ln(inctot_real)
drop occ met2013 city puma rentgrs valueh bpl occsoc incwage puma1990 greaterthan40 datanum serial pernum rank ind ind2000 hhwt statefip marst inctot occ1990

g hours1990=.
g hours2010=.
replace hours1990=uhrswork if year==1990
replace hours2010=uhrswork if year==2010

reghdfe inctot_real [pw=perwt] , absorb(i.occ2010 i.occ2010#i.age#i.year i.occ2010#i.sex#i.year i.occ2010#i.educ#i.year i.occ2010#i.race#i.year i.occ2010#i.hispan#i.year i.occ2010#i.ind1990#i.year) res(inctot_real_res)
reghdfe hours1990 [pw=perwt] if year==1990, absorb(i.occ2010 i.occ2010#i.age#i.year i.occ2010#i.sex#i.year i.occ2010#i.educ#i.year i.occ2010#i.race#i.year i.occ2010#i.hispan#i.year i.occ2010#i.ind1990#i.year) res(hours1990_res)
reghdfe hours2010  [pw=perwt] if year==2010, absorb(i.occ2010 i.occ2010#i.age#i.year i.occ2010#i.sex#i.year i.occ2010#i.educ#i.year i.occ2010#i.race#i.year i.occ2010#i.hispan#i.year i.occ2010#i.ind1990#i.year) res(hours2010_res)

sum hours1990 [w=perwt]
replace hours1990_res=hours1990_res+r(mean)
sum hours2010 [w=perwt]
replace hours2010_res=hours2010_res+r(mean)
sum inctot_real [w=perwt]
replace inctot_real_res=inctot_real_res+r(mean)

sum inctot_real_res [w=perwt] if hours1990_res<=42 & hours1990_res>=38
replace inctot_real_res=inctot_real_res-r(mean) if year==1990

sum inctot_real_res [w=perwt] if hours2010_res<=42 & hours2010_res>=38
replace inctot_real_res=inctot_real_res-r(mean) if year==2010

cd $data\graph\
# delimit
graph twoway (lpoly inctot_real_res hours1990_res [w=perwt] if year==1990 & hours1990_res>=38 & hours1990_res<=60, lpattern(solid) bwidth(2.5)) 
(lpoly inctot_real_res hours2010_res [w=perwt] if year==2010 & hours2010_res>=38 & hours2010_res<=60, lpattern(dash) bwidth(2.5)), graphregion(color(white))
legend(lab(1 "1990") lab(2 "2010")) xtitle(Weekly hours worked) ytitle(Weekly real log earnings) xscale(range(40 60))  yscale(range(0 0.5)) ylabel(0(0.1)0.5) xlabel(40(5)60);
# delimit cr
graph export financial_log_earnings.emf, replace


***
**** lawyer
cd $data\ipums_micro

u 1990_2000_2010_temp if occ2010==2100, clear

drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork<40
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

replace inctot_real=inctot_real/52

replace inctot_real=ln(inctot_real)
drop occ met2013 city puma rentgrs valueh bpl occsoc incwage puma1990 greaterthan40 datanum serial pernum rank ind ind2000 hhwt statefip marst inctot occ1990

g hours1990=.
g hours2010=.
replace hours1990=uhrswork if year==1990
replace hours2010=uhrswork if year==2010

reghdfe inctot_real [pw=perwt] , absorb(i.occ2010 i.occ2010#i.age#i.year i.occ2010#i.sex#i.year i.occ2010#i.educ#i.year i.occ2010#i.race#i.year i.occ2010#i.hispan#i.year i.occ2010#i.ind1990#i.year) res(inctot_real_res)
reghdfe hours1990 [pw=perwt] if year==1990, absorb(i.occ2010 i.occ2010#i.age#i.year i.occ2010#i.sex#i.year i.occ2010#i.educ#i.year i.occ2010#i.race#i.year i.occ2010#i.hispan#i.year i.occ2010#i.ind1990#i.year) res(hours1990_res)
reghdfe hours2010 [pw=perwt] if year==2010, absorb(i.occ2010 i.occ2010#i.age#i.year i.occ2010#i.sex#i.year i.occ2010#i.educ#i.year i.occ2010#i.race#i.year i.occ2010#i.hispan#i.year i.occ2010#i.ind1990#i.year) res(hours2010_res)

sum hours1990
replace hours1990_res=hours1990_res+r(mean)
sum hours2010
replace hours2010_res=hours2010_res+r(mean)
sum inctot_real
replace inctot_real_res=inctot_real_res+r(mean)

sum inctot_real_res if hours1990_res<=42 & hours1990_res>=38
replace inctot_real_res=inctot_real_res-r(mean) if year==1990

sum inctot_real_res if hours2010_res<=42 & hours2010_res>=38
replace inctot_real_res=inctot_real_res-r(mean) if year==2010

cd $data\graph
# delimit
graph twoway (lpoly inctot_real_res hours1990_res [w=perwt] if year==1990 & hours1990_res>=38 & hours1990_res<=60, lpattern(solid) bwidth(2.5)) 
(lpoly inctot_real_res hours2010_res [w=perwt] if year==2010 & hours2010_res>=38 & hours2010_res<=60, lpattern(dash) bwidth(2.5)), graphregion(color(white))
legend(lab(1 "1990") lab(2 "2010")) xtitle(Weekly hours worked) ytitle(Weekly real log earnings) xscale(range(40 60)) yscale(range(0 0.5)) ylabel(0(0.1)0.5) xlabel(40(5)60);
# delimit cr
graph export lawyer_log_earnings.emf, replace

***
**** Office administrator
cd $data\ipums_micro

u 1990_2000_2010_temp if occ2010==5700, clear

drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork<40
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

replace inctot_real=inctot_real/52

replace inctot_real=ln(inctot_real)
drop occ met2013 city puma rentgrs valueh bpl occsoc incwage puma1990 greaterthan40 datanum serial pernum rank ind ind2000 hhwt statefip marst inctot occ1990

g hours1990=.
g hours2010=.
replace hours1990=uhrswork if year==1990
replace hours2010=uhrswork if year==2010

reghdfe inctot_real [pw=perwt], absorb(i.occ2010 i.occ2010#i.age#i.year i.occ2010#i.sex#i.year i.occ2010#i.educ#i.year i.occ2010#i.race#i.year i.occ2010#i.hispan#i.year i.occ2010#i.ind1990#i.year) res(inctot_real_res)
reghdfe hours1990 [pw=perwt] if year==1990, absorb(i.occ2010 i.occ2010#i.age#i.year i.occ2010#i.sex#i.year i.occ2010#i.educ#i.year i.occ2010#i.race#i.year i.occ2010#i.hispan#i.year i.occ2010#i.ind1990#i.year) res(hours1990_res)
reghdfe hours2010 [pw=perwt]if year==2010, absorb(i.occ2010 i.occ2010#i.age#i.year i.occ2010#i.sex#i.year i.occ2010#i.educ#i.year i.occ2010#i.race#i.year i.occ2010#i.hispan#i.year i.occ2010#i.ind1990#i.year) res(hours2010_res)

sum hours1990 [w=perwt]
replace hours1990_res=hours1990_res+r(mean)
sum hours2010 [w=perwt]
replace hours2010_res=hours2010_res+r(mean)
sum inctot_real [w=perwt]
replace inctot_real_res=inctot_real_res+r(mean)

sum inctot_real_res [w=perwt] if hours1990_res<=42 & hours1990_res>=38
replace inctot_real_res=inctot_real_res-r(mean) if year==1990

sum inctot_real_res  [w=perwt] if hours2010_res<=42 & hours2010_res>=38
replace inctot_real_res=inctot_real_res-r(mean) if year==2010

cd $data\graph
# delimit
graph twoway (lpoly inctot_real_res hours1990_res [w=perwt] if year==1990 & hours1990_res>=38 & hours1990_res<=60, lpattern(solid) bwidth(2.5)) 
(lpoly inctot_real_res hours2010_res [w=perwt] if year==2010 & hours2010_res>=38 & hours2010_res<=60, lpattern(dash) bwidth(2.5)), graphregion(color(white))
legend(lab(1 "1990") lab(2 "2010")) xtitle(Weekly hours worked) ytitle(Weekly real log earnings) xscale(range(40 60) ) yscale(range(0 0.5)) ylabel(0(0.1)0.5) xlabel(40(5)60);
# delimit cr
graph export office_log_earnings.emf, replace

**** Teacher
cd $data\ipums_micro

u 1990_2000_2010_temp if occ2010==2320 | occ2010==2310, clear

drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork<40
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

replace inctot_real=inctot_real/52

replace inctot_real=ln(inctot_real)
drop occ met2013 city puma rentgrs valueh bpl occsoc incwage puma1990 greaterthan40 datanum serial pernum rank ind ind2000 hhwt statefip marst inctot occ1990

g hours1990=.
g hours2010=.
replace hours1990=uhrswork if year==1990
replace hours2010=uhrswork if year==2010

reghdfe inctot_real [pw=perwt], absorb(i.occ2010 i.occ2010#i.age#i.year i.occ2010#i.sex#i.year i.occ2010#i.educ#i.year i.occ2010#i.race#i.year i.occ2010#i.hispan#i.year i.occ2010#i.ind1990#i.year) res(inctot_real_res)
reghdfe hours1990 [pw=perwt] if year==1990, absorb(i.occ2010 i.occ2010#i.age#i.year i.occ2010#i.sex#i.year i.occ2010#i.educ#i.year i.occ2010#i.race#i.year i.occ2010#i.hispan#i.year i.occ2010#i.ind1990#i.year) res(hours1990_res)
reghdfe hours2010 [pw=perwt] if year==2010, absorb(i.occ2010 i.occ2010#i.age#i.year i.occ2010#i.sex#i.year i.occ2010#i.educ#i.year i.occ2010#i.race#i.year i.occ2010#i.hispan#i.year i.occ2010#i.ind1990#i.year) res(hours2010_res)

sum hours1990 [w=perwt]
replace hours1990_res=hours1990_res+r(mean)
sum hours2010 [w=perwt]
replace hours2010_res=hours2010_res+r(mean)
sum inctot_real [w=perwt]
replace inctot_real_res=inctot_real_res+r(mean)

sum inctot_real_res [w=perwt] if hours1990_res<=42 & hours1990_res>=38
replace inctot_real_res=inctot_real_res-r(mean) if year==1990

sum inctot_real_res [w=perwt] if hours2010_res<=42 & hours2010_res>=38
replace inctot_real_res=inctot_real_res-r(mean) if year==2010

cd $data\graph
# delimit
graph twoway (lpoly inctot_real_res hours1990_res [w=perwt] if year==1990 & hours1990_res>=38 & hours1990_res<=60, lpattern(solid) bwidth(2.5)) 
(lpoly inctot_real_res hours2010_res [w=perwt] if year==2010 & hours2010_res>=38 & hours2010_res<=60, lpattern(dash) bwidth(2.5)), graphregion(color(white))
legend(lab(1 "1990") lab(2 "2010")) xtitle(Weekly hours worked) ytitle(Weekly real log earnings) xscale(range(40 60) ) yscale(range(0 0.5)) ylabel(0(0.1)0.5) xlabel(40(5)60);
# delimit cr
graph export teacher_log_earnings.emf, replace


******

*************************************+*************************************+****
**# Output - Exogenity Figure
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"


*** Plot the change in commute time by skill content

cd $data\ipums_micro
u 1990_2000_2010_temp , clear

cd $data\geographic

merge m:1 metarea using 1990_rank
keep if _merge==3
drop _merge

keep if uhrswork>=30

keep if sex==1
keep if age>=25 & age<=65
keep if year==1990 | year==2010

drop wage distance tranwork pwpuma ownershp ownershpd gq

drop if uhrswork==0
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

replace inctot_real=inctot_real/52

g greaterthan50=0
replace greaterthan50=1 if uhrswork>=50

replace trantime=ln(trantime)

keep if rank<=25

g college=0
replace college=1 if educ>=10


collapse greaterthan50 trantime, by(year college)
drop if year==.
reshape wide greaterthan50 trantime , i(college) j(year)


g ln_d=ln( greaterthan502010)-ln( greaterthan501990)

g dtrantime=trantime2010-trantime1990

drop greaterthan501990 greaterthan502010 trantime2010 trantime1990

label define college_lab 0 "No College" 1 "College"
label value college college_lab
 cd $data\graph\
  # delimit 
 graph bar dtrantime  , over(college)  graphregion(color(white))  ytitle(Change in mean log commute time);
 # delimit cr
 graph export dtrantime_college.png, replace


*** Plot the change in incidence of work long hours by skill content

cd $data\ipums_micro
u 1990_2000_2010_temp , clear

cd $data\geographic

merge m:1 metarea using 1990_rank
keep if _merge==3
drop _merge

keep if uhrswork>=30

keep if sex==1
keep if age>=25 & age<=65
keep if year==1990 | year==2010

drop wage distance tranwork pwpuma ownershp ownershpd gq

drop if uhrswork==0
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

replace inctot_real=inctot_real/52

g greaterthan50=0
replace greaterthan50=1 if uhrswork>=50

replace trantime=ln(trantime)


g college=0
replace college=1 if educ>=10


collapse greaterthan50 trantime, by(year college)
drop if year==.
reshape wide greaterthan50 trantime , i(college) j(year)


g ln_d=ln( greaterthan502010)-ln( greaterthan501990)

g dtrantime=trantime2010-trantime1990

drop greaterthan501990 greaterthan502010 trantime2010 trantime1990

label define college_lab 0 "No College" 1 "College"
label value college college_lab
 cd $data\graph
  # delimit 
 graph bar ln_d  , over(college)  graphregion(color(white))  ytitle(Change in prob of working >=50 hrs/week);
 # delimit cr
 graph export ln_d_college.png, replace
 

*** Wage decile and changing incidence of working long


*** Generate change in long hour incidence by group
** By wage decile
cd $data\ipums_micro
u 1990_2000_2010_temp , clear

keep if uhrswork>=30

keep if sex==1
keep if age>=25 & age<=65
keep if year==1990 | year==2010


*drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork==0
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

replace inctot_real=inctot_real/52

g wage_real=inctot_real/uhrswork

xtile wage_tile1990=wage_real [w=perwt] if year==1990, nq(10)
xtile wage_tile2010=wage_real [w=perwt] if year==2010, nq(10)
g wage_tile=wage_tile1990 if year==1990
replace wage_tile=wage_tile2010 if year==2010

g greaterthan50=0
replace greaterthan50=1 if uhrswork>=50

cd $data\geographic
merge m:1 statefip puma1990 using puma1990_downtown_5mi
g downtown=0
replace downtown=1 if _merge==3
drop _merge

merge m:1 statefip puma using puma_downtown_5mi
replace downtown=1 if _merge==3
drop _merge


collapse greaterthan50 [w=perwt], by(year wage_tile downtown)
cd $data\temp_files
save tile_1990_2010, replace

cd $data\temp_files
u tile_1990_2010, clear

keep if year==1990 | year==2010

sort wage_tile downtown year

by wage_tile downtown: g dg=greaterthan50-greaterthan50[_n-1]

by wage_tile downtown: g ln_dg=ln(greaterthan50)-ln(greaterthan50[_n-1])

 
   cd $data\graph
 
 # delimit 
 graph twoway (bar dg wage_tile if year==2010, msymbol(O) ) 
 if downtown==1, graphregion(color(white)) xtitle(Wage decile) ytitle(Change in prob of working >=50 hrs/week)
 xscale(range(1 10)) xlabel(1(1)10) legend(lab(1 "1980") lab(2 "2010")) ;
 # delimit cr
  graph export dgreaterthan50_wage_tile_downtown.emf, replace
 
  # delimit 
 graph twoway (bar dg wage_tile if year==2010, msymbol(O) ) 
 if downtown==0, graphregion(color(white)) xtitle(Wage decile) ytitle(Change in prob of working >=50 hrs/week)
 xscale(range(1 10)) xlabel(1(1)10) legend(lab(1 "1980") lab(2 "2010")) ;
 # delimit cr
 graph export dgreaterthan50_wage_tile_suburbs.emf, replace
