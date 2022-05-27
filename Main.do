*****************************************************
** Universidad de los Andes - Facultad de Economía **
** 			      Economía Urbana           	   **
**												   **
** 		      Lina María Gómez García              **
** 			   						               **
**   Improvements to the Code Needed to Reproduce  **
**                    Su (2022)                    **
*****************************************************

clear all
cls
global data= "/Users/linagomez/Documents/Stata/Economia_Urbana/Revision_Codigo_Lina/data"
global table= "/Users/linagomez/Documents/Stata/Economia_Urbana/Revision_Codigo_Lina/"

*******************************************************************************
**# Se generan base de datos necesarias para correr el código:
** Este proceso estaba antes en do file various measures:
*******************************************************************************

*** Medida de ingreso para generar la demanda de vivienda:

/* 
Se encontraba en do data_prep_various_measures y se movió acá para poder correr los do's en el orden en el que especifica el autor en el Readme.
*/

cd $data/ipums_micro
u 1990_2000_2010_temp , clear

* Se limpia la base:
drop wage distance tranwork trantime pwpuma ownershp ownershpd gq
drop if uhrswork==0
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

* Se genera una variable que traiga los ingresos totales de ese año a términos reales de 2010:

/*
IPC 1990 USA: 130.7
IPC 2000 USA: 172.2
IPC 2010 USA: 218.056 
*/

g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

* Se divide entre 52 el ingreso total ya que se quiere saber cual es el ingreso semanal de los individuos. Se divide por 40 ya que se quiere saber cuanto salario gana por hora la persona:
g wage_real=inctot_real/(52*40)

* Se generan variables que almacenen los ingresos reales y salarios totales de cada año en variables diferentes:
g inc_mean1990=inctot_real if year==1990
g inc_mean2000=inctot_real if year==2000
g inc_mean2010=inctot_real if year==2010

g wage_real1990=wage_real if year==1990
g wage_real2000=wage_real if year==2000
g wage_real2010=wage_real if year==2010

*Se genera una variable que sume el número de personas por ocupación para ese año y se almacena la información de cada año en variables diferentes:
bysort occ2010 year: egen count=count(perwt) 

g count1990=count if year==1990
g count2000=count if year==2000
g count2010=count if year==2010

*Se agrega la base a nivel ocupación con las variables generadas anteriormente:
collapse (mean) count1990 count2000 count2010 inc_mean1990 inc_mean2000 inc_mean2010 wage_real1990 wage_real2000 wage_real2010  [w=perwt], by(occ2010)
cd $data/temp_files
save inc_occ_1990_2000_2010, replace


*** Base número de personas en cada ocupación por área metropolitana:

* Se limpia la base:
cd $data/ipums_micro
u 1990_2000_2010_temp , clear

* Se limpia la base:
drop wage distance tranwork trantime pwpuma ownershp ownershpd gq
drop if uhrswork<30
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

* Se crea la variable count que suma el número de personas de acuerdo a la ocupación, área metropolitana y año:
bysort metarea occ2010 year: egen count=total(perwt) 

* Se almacena el conteo en diferentes variables de acuerdo con el año y se organiza la base para que quede una fila por cada ocupación dentro de un metarea. 
g count1990=count if year==1990
g count2000=count if year==2000
g count2010=count if year==2010

collapse (mean) count1990 count2000 count2010 [w=perwt], by(metarea occ2010)

cd $data/temp_files

save count_metarea, replace
******************************

cd $data/ipums_micro
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

cd $data/temp_files

save occ2010_count, replace


****************************
cd $data/ipums_micro
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

cd $data/temp_files

save occ2010_count_male, replace

*******************
*** Welfare calculate earnings level


*** compute log wage for every state
cd $data/ipums_micro
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

cd $data/temp_files
save val_time_weekly_earnings_total, replace



*******************************************************************************
**# Data Prep Long Hour Premium
*******************************************************************************

*Se utiliza la base de datos del US Census:
cd $data/ipums_micro

u 1990_2000_2010_temp, clear


**# Limpieza Base Datos:

** Se eliminan las siguientes variables:
drop wage distance tranwork trantime pwpuma ownershp ownershpd gq occ met2013 city puma rentgrs valueh bpl occsoc incwage puma1990 greaterthan40 datanum serial pernum rank ind ind2000 hhwt statefip marst occ1990

** Se elimina si una persona trabaja menos de 40 horas a la semana ya que esta es la jornada laboral y se quiere estimar cuanto se trabaja por horas extras: 
drop if uhrswork<40

** Valores que no tienen sentido lógico para el ingreso total se cambian por missing o por cero: 
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999


** Está trayendo los salarios nominales de 1990 y 2000 en términos de salarios reales del 2010:

/*
IPC 1990 USA: 130.7
IPC 2000 USA: 172.2
IPC 2010 USA: 218.056 
*/

/* Se recomienda definir el significado de los valores de las siguientes tres líneas de código a priori, ya que no se sabía que hacía referencia a los IPC para Estados Unidos */
g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010
drop inctot

** Se divide entre 52 el ingreso total ya que se quiere saber cual es el ingreso semanal de los individuos. Se hace una transformación logarítmica de esta variable para reducir la varianza. 
replace inctot_real=inctot_real/52
replace inctot_real=ln(inctot_real)


/* Algunas variables se eliminaban en este punto. Para optimizar el código se junto esta linea de código con la línea 24. */

** Se generan nuevas variables:

/* Se optimizó el proceso de generación de variables mediante loops */

global ano 1990 2000 2010
foreach x in $ano{
	local var val se
	foreach y in `var' {
		gen `y'_`x'=.
	}
}

*Se generan variables que indican el número de horas de trabajo semanales para los datos reportados para este año en particular:
foreach x in $ano{
	gen hours`x' = 0
	replace hours`x' = uhrswork if year == `x'	
}

g dval=.
g se_dval=.

**# Creación Variables Long Hour Premium:


*Los números dentro del local indican el código de las ocupaciones que el autor está teniendo en cuenta.
* Se está generando una regresión lineal con múltiples efectos fijos dados por la interacción entre el año y diferentes características sociodemográficas. Esta regresión mide la relación entre las horas extras de trabajo de 1990, 2000 y 2010 y el ingreso total real para cada ocupación. Se almacena en una variable los coeficientes para las horas semanales de un año particular. Así, se encuentra el valor que tiene una hora extra de cada año en términos de ingreso controlando por factores sociodemográficos que no varían en el tiempo.
*El autor utiliza en la regresión clusters a nivel de área metropolitana ya que puede haber autocorrelación entre lo no observable de los individuos que viven en el área metropolitana. 

#delimit ;
local num 30 120 130 150 205 230 310
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
9510 9600 9610 9620 9640 ;
# delimit cr
macro dir
foreach num in `num'{
	
display `num'
qui reghdfe inctot_real hours1990 hours2000 hours2010 if occ2010==`num' &  uhrswork<=60 [w=perwt], absorb(i.age#i.year i.sex#i.year i.educ#i.year i.race#i.year i.hispan#i.year i.ind1990#i.year) cluster(metarea)

foreach x in $ano{
		replace val_`x' = _b[hours`x' ] if occ2010 == `num'
		replace se_`x' = _se[hours`x' ] if occ2010 == `num'
		}
}

/* Se altera este proceso para que queda más claro y óptimo de realizar - se genera un local en vez de meter todos los números al comienzo del loop y se genera un loop dentro del loop anterior para optimizar el proceso. */

** Se almacena el premium por ocupación a través de un collapse. Se guarda en una nueva base de datos.
collapse (firstnm) val_1990 se_1990 val_2000 se_2000 val_2010 se_2010, by(occ2010)


cd $data/temp_files

save val_40_60_total_1990_2000_2010, replace

*******************************************************************************
**# Data Prep Job Distribution
*******************************************************************************

*******************************************************************************
**Participación de cada ocupación en la industria a la que pertenece por año
*******************************************************************************




* generate occupation share per industry by year using the IPUMS microdata
cd $data/ipums_micro
use 1990_2000_2010_temp, clear

cd $data/temp_files

**perwt representa el número de individuos en la población representados por esa observación. Se suma el número de individuos de acuerdo a la clasificación de ocupación de 2010, la industria de acuerdo con la clasificación de 1990 y el año:
collapse (sum) pop=perwt, by(year ind1990 occ2010)
save ind1990_2010, replace

**Se suma la población de acuerdo con el año y la industria:
collapse (sum) pop_ind1990=pop, by(year ind1990)

**Se junta la base de datos que almacena la población por industria y la población por ocupación. Se limpia la base:
merge 1:m year ind1990 using ind1990_2010
drop _merge
drop if ind1990==0


**Se crea una nueva variable igual a la proporción de la población en una ocupación respecto a la proporción de la población de acuerdo a la industria. Se limpia la base:
g occ_share=pop/pop_ind1990
drop pop pop_ind1990
sort year ind1990 occ2010
save occ_share_perind, replace


**Se genera una base de datos de cada proporción para cada año:

foreach num of numlist 1990(10)2010{
	u occ_share_perind, clear
	keep if year==`num'
	save occ_share_perind`num', replace
}
/* Se optimizó el proceso con un loop. */

*******************************************************************************
**# Descomposición del cruce del CIC-NAICS:

**El IPUMS utiliza el CIC (Census Industry Code). Las bases de datos de información de la industria respecto al zipcode en el que se localizan para 2000 y 2010 utiliza el NAICS (North American Industry Classification System), por lo que es necesario desagregarlo para poder utilizarlo en la limpieza de esta base de datos. 
*******************************************************************************


cd $data/zbp
import excel cic1990_naics97.xlsx, sheet("Sheet1") firstrow clear
drop C

**Limpieza de la variable NAICS:
tostring NAICS, g(naics)
unique naics
duplicates tag naics, g(tag)
drop if tag>=1
drop NAICS

**Limpieza de la variable CIC: 
destring Census, g(ind1990)
*Se renombra la variable que indica el nombre de la categoría de la industria:
ren Census2000CategoryTitle naics_descr
keep ind1990 naics  naics_descr
*Se genera una variable que represente la longitud del código NAICS:
g digit=length(naics)

*Se almacena en una nueva base de datos:
cd $data/temp_files
save cic1990_naics97, replace

**Se almacena la información para cada longitud del NAICS en una nueva base de datos:
foreach num of numlist 6/2{
	u cic1990_naics97, clear
	keep if digit== `num'
	ren naics naics`num'
	save cic1990_naics97_`num'digit, replace
}
/* Se optimizó el proceso con un loop. */


*******************************************************************************
**# Descomposición del cruce del CIC-SIC:

**El IPUMS utiliza el CIC (Census Industry Code). Las bases de datos de información de la industria respecto al zipcode en el que se localizan para 1994 utiliza el SIC (Standard Industrial Classification), por lo que es necesario desagregarlo para poder utilizarlo en la limpieza de esta base de datos. 
*******************************************************************************


cd $data/zbp
import excel cic_sic_crosswalk.xlsx, sheet("Sheet1") firstrow allstring clear

**Limpieza de la base de datos:
destring cic_code, g(ind1990)
drop cic_code
*Se genera una variable que represente la longitud del código SIC:
g digit=length(sic)

*Se almacena en una nueva base de datos:
cd $data/temp_files
save cic_sic_crosswalk, replace

**Se almacena la información para cada longitud del SIC en una nueva base de datos:
foreach num of numlist 4/2{
	u cic_sic_crosswalk, clear
	keep if digit== `num'
	ren sic sic`num'
	drop digit
	save cic_sic_crosswalk`num'digit, replace		
}

/* Se optimizó el proceso con un loop. */
	
*******************************************************************************
**# Número de Empleados para cada Ocupación de Acuerdo al Zip Code para 1990. 
*******************************************************************************

cd $data/zbp
u zip94detail, clear

/* Descripción de las variables: 
EST Total Number of Establishments

N1_4 Number of Establishments: Employment Size Class: 1-4 Employees
N5_9 Number of Establishments: Employment Size Class: 5-9 Employees
N10_19 Number of Establishments: Employment Size Class: 10-19 Employees
N20_49 Number of Establishments: Employment Size Class: 20-49 Employees
N50_99 Number of Establishments: Employment Size Class: 50-99 Employees
N100_249 Number of Establishments: Employment Size Class: 100-249 Employees      
N250_499 Number of Establishments: Employment Size Class: 250-499 Employees
N500_999 Number of Establishments: Employment Size Class: 500-999 Employees
N1000 Number of Establishments: Employment Size Class: 1,000 Or More Employees
*/

**Se genera una variable que represente el número de personas trabajando en cada tipo de establecimiento. Este procedimiento se hace multiplicando el número de establecimientos por la mediana del número de personas que trabajan en ese establecimiento. Se suma el número de personas empleadas para cada zip-sic:
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

**Se limpia la variable sic eliminando aquellos valores cuyos números no estén completos:
g lastdigit=substr(sic,4,1)
drop if lastdigit=="-"
drop if lastdigit=="\"

**Para cada longitud del sic se junta la base de datos que cruza los datos SIC-CIC con el número de la población para 1994:
cd $data/temp_files

foreach num of numlist 4/2{
	g sic`num'=substr(sic,1,`num')
	merge m:1 sic`num' using cic_sic_crosswalk`num'digit
	ren (_merge ind1990) (_merge_`num'digit ind1990_`num'digit)
	}

/* Se optimiza el proceso con un loop */.

**Se genera una nueva variable que almacene el código de industria de 2, 3 y 4 dígitos.
g ind1990=ind1990_2digit if _merge_2digit==3
replace ind1990=ind1990_3digit if _merge_3digit==3
replace ind1990=ind1990_4digit if _merge_4digit==3

**Se limpia la base de datos:
drop _merge_2digit ind1990_2digit sic2 _merge_3digit ind1990_3digit sic3 _merge_4digit ind1990_4digit sic4 lastdigit
drop if ind1990==.
drop if zip==.

**Se suma el número de empleados para cada industria ubicada en un zipcode particular:
collapse (sum) est_num, by(zip ind1990)

cd $data/temp_files
save temp, replace

**Se divide el grupo de zip codes para hacer más sencillo al programa el cálculo. Une dos bases de datos con el indicador ind1990 (la base que tiene la proporción de ocupación respecto a industria y la base que tiene el número de empleados por industria para cada zip code). Se almacena en una nueva base de datos: 
cd $data/temp_files
save temp, replace
forvalues i = 0(20000)80000{
	u temp, clear
	local nombre= `i' + 20000
	keep if zip>=`i' & zip<`nombre'
	joinby ind1990 using occ_share_perind1990
	replace est_num=est_num*occ_share
	collapse (sum) est_num, by(zip occ2010)
	save temp`i'_`nombre', replace 	
}

**Se pegan las bases generadas anteriormente para obtener una que tenga la ocupación y el número de personas que trabajan en esa ocupación para cada zip code:
clear all
forvalues i=0(20000)80000{
	local nombre= `i' + 20000
	append using temp`i'_`nombre'	
	}

**Se genera una variable de año y se guarda la base:	
g year=1990
save occ_emp_1994, replace
/* Se generan loops para optimizar el proceso */.


*******************************************************************************
**# Número de Empleados para cada Ocupación en Zip Code para 2000, 2010. 
*******************************************************************************

** El proceso es similar a lo anterior por lo que no se repetira la descripción.

**Se genera un loop para realizar todo el proceso ya que las bases del 2000 y 2010 utilizan el NAICS.

local ano 00 10
foreach x in `ano'{
	cd $data/zbp
	display `x'
	u zip`x'detail, clear
	g n1_4_num=2.5*n1_4
	g n5_9_num=7*n5_9
	g n10_19_num=14.5*n10_19
	g n20_49_num=34.5*n20_49
	g n50_99_num=74.5*n50_99
	g n100_249_num=174.5*n100_249
	g n250_499_num=374.5*n250_499
	g n500_999_num=749.5*n500_999
	g n1000_num=1500*n1000
	g est_num=n1_4_num+n5_9_num+n10_19_num+n20_49_num+n50_99_num+n100_249_num+	n250_499_num+n500_999_num+n1000_num
		
	g lastdigit=substr(naics,6,1)
	drop if lastdigit=="-"
	drop lastdigit
	
	sort naics
	
	cd "/Users/linagomez/Documents/GitHub/Revised-Reproduction-Package-for-Su-2022-/temp_files"
	foreach num of numlist 6/2{
		g naics`num'=substr(naics,1,`num')
		merge m:1 naics`num' using cic1990_naics97_`num'digit
		ren (_merge ind1990) (_merge_`num'digit ind1990_`num'digit)
		}
		drop naics`num' digit naics_descr

		
	g ind1990=ind1990_2digit if _merge_2digit==3
	replace ind1990=ind1990_3digit if _merge_3digit==3
	replace ind1990=ind1990_4digit if _merge_4digit==3
	replace ind1990=ind1990_5digit if _merge_5digit==3
	replace ind1990=ind1990_6digit if _merge_6digit==3
	
	drop if ind1990==.
	drop if zip==.
	drop ind1990_6digit _merge_6digit ind1990_5digit _merge_5digit ind1990_4digit _merge_4digit ind1990_3digit _merge_3digit ind1990_2digit _merge_2digit
	
	collapse (sum) est_num, by(zip ind1990)
	save temp, replace
	
	forvalues i = 0(20000)80000{
		u temp, clear
		local nombre= `i' + 20000
		keep if zip>=`i' & zip<`nombre'
		joinby ind1990 using occ_share_perind20`x'
		replace est_num=est_num*occ_share
		collapse (sum) est_num, by(zip occ2010)
		save temp`i'_`nombre', replace 	
	}

	clear all
	forvalues i=0(20000)80000{
		local nombre= `i' + 20000
		append using temp`i'_`nombre'	
		}

	g year = 2000
	save occ_emp_20`x', replace
}
/* Se generan loops para optimizar el proceso */.


*******************************************************************************
**# Génerar la participació de empleo de cada zip code en el metarea. 
*******************************************************************************

forvalues i=1990(10)2010{
	*Para los años 1990, 2000 y 2010, se junta la base que almacena el número 
	*de empleados para cada ocupación por cada zip code y los zip codes que 
	*hacen parte de un área metropolitana.
	cd "/Users/linagomez/Documents/GitHub/Revised-Reproduction-Package-for-Su-2022-/temp_files"
	u occ_emp_`i', clear
	
	cd $data/geographic
	
	merge m:1 zip using zip`i'_metarea
	keep if _merge==3
	drop _merge
	cd "/Users/linagomez/Documents/GitHub/Revised-Reproduction-Package-for-Su-2022-/temp_files"
	save temp, replace
	
	*Se suma el número de empleados para cada ocupación en cada área 
	*metropolitana. Se genera una variable que sea la proporción de empleados 
	*por ocupación para cada zip respecto a la proporción de empleados por 
	*ocupación para cada área metropolitana. Se almacena en una nueva variable
	*y se genera una nueva base de datos.
	
	collapse (sum) est_num_total=est_num, by(occ2010 metarea)
	merge 1:m occ2010 metarea using temp
	drop _merge
	g share=est_num/est_num_total
	keep share zip occ2010 metarea

	save occ_emp_share_`i', replace
	
}
/* Se generan loops para optimizar el proceso */


*******************************************************************************
**# Data Prep Impute Travel Time
*******************************************************************************

*******************************************************************************
** Limpieza base NHTS 1995 y el valor que tiene una unidad adicional o 
*un uno porciento adicional de cada una de las variables en el procentaje de la velocidad de viaje:
*******************************************************************************

cd $data/travel

u nhts, clear

**El autor está utilizando la variable modo de transporte para que las observaciones que queden sean aquellas tipo automóvil (automóvil, van, camioneta) o camión:
keep if TRPTRANS>=1 & TRPTRANS<=5
** Se mantienen las observaciones cuyo día de viaje fue entre el Lunes y el Viernes:
keep if TRAVDAY>=2 & TRAVDAY<=6
**Se mantienen las vobservaciones cuyo viaje era de su casa o hasta su casa (17):
keep if WHYTO==17 | WHYFROM==17
** Esta variable mide la distancia reportada en millas. Cambió por missings aquellas distancias mayores a 9000 millas:
replace TRPMILES=. if TRPMILES>=9000
**Esta variable mide el tiempo de viaje en minutos. Cambió por missings aquellos tiempos de viaje mayores a 90000:
replace TRVL_MIN=. if TRVL_MIN>=9000


**Se genera una transformación logarítmica a la distancia y al tiempo de viaje en horas:
g log_distance=ln(TRPMILES)
g log_time=ln(TRVL_MIN/60)
**Se genera el cuadrado del logaritmo de la distancia:
g log_distance2=log_distance^2
**Se genera una variable que mide la velocidad (vel=dist/tiempo) en millas por hora y se realiza una transformación logarítmica:
g speed=TRPMILES/(TRVL_MIN/60)
g log_speed=ln(speed)


**Esta variable mide la densidad poblacional a nivel census tract. Se reemplazan algunos valores por missing (ya que el máximo valor es 35,000 [25k a 999k]) y se genera una variable que represente la densidad:
replace HTPPOPDN=. if HTPPOPDN>90000
g pop_den=HTPPOPDN
**Esta variable mide la densidad residencial a nivel census tract. Se reemplazan algunos valores por missing (ya que el máximo valor es 6,000 [5k a 999k]) y se genera una variable que represente la densidad:
replace HTHRESDN=. if HTHRESDN>7000
g unit_den=HTHRESDN
**Esta variable mide el ingreso mediano del hogar a nivel census tract. Se reemplazan algunos valores por missing (ya que el máximo valor es 80,000 [70k a 999k]) y se genera una variable que represente el ingreso:
replace HTHINMED=. if HTHINMED>100000
g inc=HTHINMED
**Esta variable mide el porcentaje de población trabajadora a nivel census tract. Se reemplazan algunos valores por missing (ya que el máximo valor es 95 [95 a 100]) y se genera una variable que represente el ingreso:
replace HTINDRET=. if HTINDRET>100
g working=HTINDRET


**Se crea una dummy para área metropolitana:
g metarea_d=998


/* No se entiende porque el autor divide el número que identifica el MSA entre 10 */



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

**Se genera una variable que represente las horas al día que son pico (entre las 6:30am y las 10:30am, entre las 4:30pm y las 8:30pm) y se mantienen esas observaciones:
g rush=1 if STRTTIME>= 630 & STRTTIME <= 1030
replace rush=1 if STRTTIME>= 1630 & STRTTIME <= 2030
keep if rush==1


**Se generan dummies partiendo de las variables categóricas densidad poblacional, ingreso mediano del hogar, y proporción de población trabajando a nivel de census tract:
xi i.pop_den i.inc i.working


*Se realiza una regresión entre el logaritmo de la velocidad de viaje y el logaritmo cuadrático de la distancia, las dummies de densidad poblacional, ingreso mediano y proporción de trabajadores por census tract. Los errores estándares son robustos para evitar la heterocedasticidad.

*Los coeficientes representan el valor que tiene una unidad adicional o un  uno porciento adicional de cada una de las variables en el procentaje de la velocidad de viaje:
reg log_speed log_distance log_distance2 _Ipop_den_* _Iinc_* _Iworking_*, r
estimates store speed_results


*******************************************************************************
** Recreación de las características del barrio en el mapa de Census Tract:
*******************************************************************************

*******************************************************************************
*** Se obtiene el área de cada census tract y se almacena en una nueva base de datos:
*******************************************************************************


clear
cd $data/geographic
import delimited tract1990_area.csv, varname(1) clear 
keep gisjoin area_sm
ren area_sm area
cd $data/geographic
sort gisjoin 
save area_sqmile, replace

*******************************************************************************
*** Se obtiene el ingreso mediano para cada census tract  se almacena en una nueva base de datos:
*******************************************************************************

clear
cd $data/nhgis
import delimited nhgis0031_ds123_1990_tract.csv, clear
keep gisjoin e4u001
ren e4u001 median_income
sort gisjoin
cd $data/temp_files
save median_income1990, replace


*******************************************************************************
*** Se obtiene la proporción de personas trabajadoras para cada census tract  y se almacena en una nueva base de datos:
*******************************************************************************

clear 
cd $data/nhgis/working_pop
import delimited nhgis0016_ds123_1990_tract.csv, clear
egen working_pop=rowtotal(e4i001 e4i002 e4i005 e4i006)
keep gisjoin working_pop


/* La siguiente base no aparece en el ReadMe como un Raw Data. Tampoco aparece en ningún código como si se estuviera generando en Do previo a este. Se descarga del AER pero no se tiene conocimiento de donde sale y si se hizo un proceso de limpieza previo */

*** Se genera la proporción de de poblaciín trabajando sobre el total de la población, se limpia la base y se guarda en una base de datos:
cd $data/temp_files
merge 1:1 gisjoin using population1990
drop _merge
g share_working=working_pop/population
drop if share_working==.
replace share_working=1 if share_working>1
keep gisjoin share_working
sort gisjoin
save working_pop1990, replace


*******************************************************************************
*** Se genera la población por área metropolitana juntando la base de población para 1990 con la base que almacena el área de cada census tract. Se limpia la base y se almacena en una nueva base de datos:
*******************************************************************************

cd $data/temp_files
u population1990, clear
cd $data/geographic
merge 1:1 gisjoin using area_sqmile
keep if _merge==3
drop _merge
destring area, g(area_num) ignore(",")
drop area 
ren area_num area
g density=population/area
cd $data/geographic
keep gisjoin density
sort gisjoin
save density, replace


*******************************************************************************
*** Se almacena en una base la proporción de personas que trabajan y el ingreso mediano en cada Census tract:
*******************************************************************************

cd $data/geographic
u density, clear

cd $data/temp_files

cd $temp/temp_files
local base "working_pop1990 median_income1990"
foreach x in `base'{
merge 1:1 gisjoin using `x'
keep if _merge==3
drop _merge
}

sort gisjoin
cd $data/temp_files
save tract1990_char, replace


*******************************************************************************
*** Se crea el promedio de densidad, proporción de población trabajando e ingreso mediano alrededor de 2 millas de cada Census Tract:
*******************************************************************************

*** Se abre la base que contiene información para los tracts a 2 millas de un Tract particular:
cd $data/geographic
u tract1990_tract1990_2mi, clear
ren gisjoin2 gisjoin

*** Se junta con base que almacenó la proporción de población trabajando, densidad e ingreso mediano por cada census tract: 
cd $data/temp_files
merge m:1 gisjoin using tract1990_char
keep if _merge==3
drop _merge
ren gisjoin gisjoin2
ren gisjoin1 gisjoin
cd $data/temp_files
save temp, replace


*** Se pega a la base original las observaciones generadas para cada dos millas de distancia de un census tract:
cd $data/temp_files
u tract1990_char, clear
g gisjoin2=gisjoin
append using temp
*** Se saca el promedio de las variables de acuerdo con el census tract:
collapse density share_working median_income, by(gisjoin)
cd $data/temp_files
save tract1990_char_2mi, replace


*******************************************************************************
*** Se crean las características promedio para 2 millas a la redonda de cada zip code:
*******************************************************************************

*** Se junta base que tiene almacenado la equivalencia entre tract y zip a dos millas con la base que almacena zip:
cd $data/geographic
import delimited zip1990_tract1990_nearest.csv, varnames(1) clear
ren in_fid fid
cd $data/geographic
merge m:1 fid using zip1990
keep if _merge==3
drop _merge


*** Se limpia la base:
drop fid
ren near_fid fid

*** Se junta esta base con la base que tiene el código de Tract:
merge m:1 fid using tract1990 
keep if _merge==3
drop _merge

*** Se limpia la base:
keep gisjoin zip 

*** Se almacena el zip y el tract más cercano:
save zip1990_tract1990_nearest, replace

*** Se pega con el cruce entre el tract y el zip más cercano:
append using tract1990_zip1990_2mi
duplicates drop gisjoin zip, force

*** Se junta con la base que almacena las características por cada census tract:
cd $data/temp_files
sort zip gisjoin
merge m:1 gisjoin using tract1990_char
keep if _merge==3
drop _merge

*** Se saca el promedio de las variables respecto al zip más cercano y se almacena en nueva base:
collapse density share_working median_income, by(zip)
save zip1990_char_2mi, replace


*******************************************************************************
** Se estiman valores de tiempo de viaje de acuerdo con la distancia:
*******************************************************************************

/* La base con 51 toma los rankings mayores a 51 */

local base "tract1990_zip1990_leftover.csv tract1990_zip1990_leftover_51.csv"
local i 1
foreach x in `base'{
	cd $data/geographic
	*** Se importa la base:
	/* El autor en su readme no específica que significan estas bases de
	datos por lo que no se comprende que tipo de base se está usando*/
	import delimited `x', varnames(1) clear 
	ren input_fid fid
	merge m:1 fid using tract1990
	keep if _merge==3
	drop _merge fid
	ren near_fid fid

	*** Se pega junto con el zip code para 1990: 
	merge m:1 fid using zip1990
	keep if _merge==3
	drop _merge
	keep gisjoin zip distance
	destring distance, replace ignore(",")

	*** Se multiplica la distancia por 1.6 para cambiar de millas a kilómetros:
	replace distance=distance*1.6

	*** Se genera una variable del tiempo de viaje que divida la distancia 
	** sobre la velocidad (3600 y 1609.34 es para generar equivalencia entre
	** unidades):

	/* No se sabe de donde sale el 35. En el apéndice menciona que para 	
	encontrar el tiempo se debe multiplicar la distancia por la velocidad 
	pero esta fórmula no tiene sentido para encontrar el tiempo */
	g time=3600*distance/(35*1609.34)
	cd $temp/temp_files
	
	if `i' == 1 {
		save temp, replace
	}
	else {
		save temp_51, replace
	}
	local ++i
}

*******************************************************************************
** Se genera la base que almacena el tiempo de viaje histórico:
*******************************************************************************

*** Datos del Google Distance Matrix API: 
cd $data/travel
u travel_time, clear

*** Se junta esta base con la base que almaceno el tiempo:
cd $data/temp_files
merge 1:1 gisjoin zip using temp
drop if _merge==2
drop _merge


*** Se genera una variable que toma el valor de 1 cuando el tiempo de viaje y la distancia de viaje es -1, 0 o "."; Se reemplaza el tiempo de viaje y la distancia por los valores del tiempo de viaje generados en la base anterior:
g leftover=1 if travel_time==-1 | travel_dist==-1 | travel_time==0 | travel_dist==0 | travel_time==. | travel_dist==.
replace travel_time=time if time!=. & leftover==1
replace travel_dist=distance if  distance!=. & leftover==1

**** Se limpia base:
drop leftover time distance

*** Se sigue mismo proceso con base de tiempo 51:
merge 1:1 gisjoin zip using temp_51
drop if _merge==2
drop _merge
g leftover=1 if travel_time==-1 | travel_dist==-1 | travel_time==0 | travel_dist==0 | travel_time==. | travel_dist==.
replace travel_time=time if time!=. & leftover==1
replace travel_dist=distance if  distance!=. & leftover==1
drop if zip==93562
drop time distance leftover

*** Se junta con la base que tiene las características de las personas del barrio 2 millas a la redonda del census tract:
cd $data/temp_files
merge m:1 gisjoin using tract1990_char_2mi
drop if _merge==2
drop _merge
ren (density share_working median_income) (density1 share_working1 median_income1)

*** Se junta con la base que tiene las características de las personas del barrio 2 millas a la redonda del zip code
merge m:1 zip using zip1990_char_2mi
drop if _merge==2
drop _merge
ren (density share_working median_income) (density2 share_working2 median_income2)


sum density1, detail
*** Se llenan las observaciones missing:
replace density1=5267.096 if density1==.
replace share_working1=.4599274 if share_working1==.
replace median_income1=30438.35 if median_income1==.

replace density2=5267.096 if density2==.
replace share_working2=.4599274 if share_working2==.
replace median_income2=30438.35 if median_income2==.
/* El autor nunca especifica de donde salieron estos números */


*** Con ambas variables se saca un promedio para cada característica:
g density=(density1+density2)/2
g share_working=(share_working1+share_working2)/2
g median_income=(median_income1+median_income2)/2

*** Se limpia la base de datos:
drop *1 *2

*** Se generan variables categóricas para los efectos fijos:

** Densidad:
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

** Ingreso mediano:
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

** Proporción trabajando:
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


*** Se separan las variables categóricas en dummies:
xi i.pop_den i.inc i.working

*** Se hace una transformación logarítmica a la distancia en millas de la Google Matrix desde metros:
g log_distance=ln(travel_dist/1609.34)
** Se eleva la variable al cuadrado:
g log_distance2=log_distance^2

*** Se genera la variable que represente el logaritmo de la velocidad en millas por hora:  
g log_speed=ln((travel_dist/1609.34)/(travel_time/3600))


*** Se utiliza el Google API para estimar los efectos fijos para cada ruta:
reg log_speed log_distance log_distance2 _Ipop_den_* _Iinc_* _Iworking_*, r
predict fixed_effects, residual

*** Con los resultados de la regresión con la NHTS se predice el valor del logaritmo de la velocidad:
estimates restore speed_results
predict log_speed_hat, xb

*** A esta predicció se le suman los efectos fijos de cada ruta y se despeja para la velocidad:
replace log_speed_hat=log_speed_hat+fixed_effects
g speed_hat=exp(log_speed_hat)

*** Se genera el tiempo de viaje en horas y se almacena en base de datos:
g travel_time_hat=(travel_dist/1609.34)/speed_hat
keep gisjoin zip travel_time_hat

cd $data/travel
save travel_time_hat, replace


*************************************+*************************************+***
**# Data Prep -  Expected Commute
*************************************+*************************************+***

*******************************************************************************
** Se generan algunas variables necesarias para la estimación principal
*******************************************************************************

**Se junta la base de datos de la participación de empleo de cada zip code en el metarea:
cd $data/temp_files
u occ_emp_share_1994, clear

cd $data/geographic
merge m:1 metarea using 1990_rank
drop _merge

cd $data/temp_files
save occ_emp_share_temp, replace

cd $temp/temp_files
save occ_emp_share_temp, replace

** En el siguiente global se delimitan las ocupaciones para las cuales se quieren hacer los siguientes procesos:
# delimit ;
global num 30 120 130 150 205 230 310
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
9510 9600 9610 9620 9640;
# delimit cr
macro dir


foreach num of global num{
	
	*Se abre la base y se mantienen solo las observaciones para esas 
	*ocupaciones en específico:
	cd $data/temp_files
	u occ_emp_share_temp, clear
	keep if occ2010==`num'
	drop serial year rank
	
	*Se junta esa base de datos con la base que contiene información del tiempo
	*de desplazamiento tract a zip ajustada por las condiciones de tráfico de 
	*1995:
	cd $data/travel
	merge 1:m zip using travel_time_hat
	keep if _merge==3
	drop _merge
	ren travel_time_hat travel_time
	*Se reemplaza el tiempo de viaje por horas de viaje a la semana (10 
	*viajes - 5 ida y 5 vuelta):
	replace travel_time=10*travel_time

	*Según el modelo hay un parámetro de aversión que multiplica el tiempo de
	*de viaje con un parámetro de aversión se genera manualmente:
	/* No se tiene conocimiento de a qué hace referencia ese número */
	g discount=exp(-0.3425*travel_time)
	*Se genera variable que es el parámetro de aversión (escalar).
	*Se genera variable que representa la fracción de empleo en el MSA 
	*localizado en un census tract.
	g pi=share*discount
	sort gisjoin
	by gisjoin: egen pi_total=sum(pi)

	*Se calcula la proporción de población empleada en una ocupación respecto a
	*la población en el MSA:
	g  share_tilda=pi/pi_total

	
	*Se genera la variable que tiene el tiempo de viaje weighted por la 
	*distribución espacial de empleos para cada ocupación:
	g travel_time_share=travel_time*share_tilda

	*Se junta la weighted proportion de acuerdo al census tract:
	collapse (sum) expected_commute=travel_time_share, by(gisjoin)

	cd $data/temp_files/commute
	sort expected

	save commute_`num', replace
}


*** En cada base se adiciona una variable que almacene la ocupación para la 
*que se generó esa base: 
cd $temp/temp_files/commute
foreach num of global num{
	u commute_`num', clear
	g occ2010=`num'
	save commute_`num'_temp, replace
}


*** Se juntan las bases de datos generadas para cada ocupación en una sola y se almacena:
clear
foreach num of global num{
	append using commute_`num'_temp
	
}
cd $data/temp_files/commute
save commute, replace

*******************************************************************************
** Se generan algunas variables necesarias para la estimación principal
*******************************************************************************


local a 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 23 24 25 
foreach num of local a{
	u occ_emp_1994, clear

	*Se generan grupos de acuerdo con la ocupación:
	
	/* Número_de_la_observación Definición
	* 1: MANAGEMENT, BUSINESS, SCIENCE, AND ARTS
	* 2: BUSINESS OPERATIONS SPECIALISTS
	* 3: FINANCIAL SPECIALISTS
	* 4: COMPUTER AND MATHEMATICAL
	* 5: ARCHITECTURE AND ENGINEERING
	* 6: TECHNICIANS
	* 7: LIFE, PHYSICAL, AND SOCIAL SCIENCE
	* 8: COMMUNITY AND SOCIAL SERVICES
	* 9: LEGAL
	* 10: EDUCATION, TRAINING, AND LIBRARY
	* 11: ARTS, DESIGN, ENTERTAINMENT, SPORTS, AND MEDIA
	* 12: HEALTHCARE PRACTITIONERS AND TECHNICAL
	* 13: HEALTHCARE SUPPORT
	* 14: PROTECTIVE SERVICE
	* 15: FOOD PREPARATION AND SERVING
	* 16: BUILDING AND GROUNDS CLEANING AND MAINTENANCE
	* 17: PERSONAL CARE AND SERVICE
	* 18: SALES AND RELATED
	* 19: OFFICE AND ADMINISTRATIVE SUPPORT
	* 20: FARMING, FISHING, AND FORESTRY
	* 21: CONSTRUCTION
	* 22: EXTRACTION
	* 23: INSTALLATION, MAINTENANCE, AND REPAIR
	* 24: PRODUCTION
	* 25: TRANSPORTATION AND MATERIAL MOVING
	*/
	
	g occ_group=1 if occ2010>=10 & occ2010<=430
	replace occ_group=2 if occ2010>=500 & occ2010<=730
	replace occ_group=3 if occ2010>=800 & occ2010<=950
	replace occ_group=4 if occ2010>=1000 & occ2010<=1240
	replace occ_group=5 if occ2010>=1300 & occ2010<=1540
	replace occ_group=6 if occ2010>=1550 & occ2010<=1560
	replace occ_group=7 if occ2010>=1600 & occ2010<=1980
	replace occ_group=8 if occ2010>=2000 & occ2010<=2060
	replace occ_group=9 if occ2010>=2100 & occ2010<=2150
	replace occ_group=10 if occ2010>=2200 & occ2010<=2550
	replace occ_group=11 if occ2010>=2600 & occ2010<=2920
	replace occ_group=12 if occ2010>=3000 & occ2010<=3540
	replace occ_group=13 if occ2010>=3600 & occ2010<=3650
	replace occ_group=14 if occ2010>=3700 & occ2010<=3950
	replace occ_group=15 if occ2010>=4000 & occ2010<=4150
	replace occ_group=16 if occ2010>=4200 & occ2010<=4250
	replace occ_group=17 if occ2010>=4300 & occ2010<=4650
	replace occ_group=18 if occ2010>=4700 & occ2010<=4965
	replace occ_group=19 if occ2010>=5000 & occ2010<=5940
	replace occ_group=20 if occ2010>=6005 & occ2010<=6130
	replace occ_group=21 if occ2010>=6200 & occ2010<=6765
	replace occ_group=22 if occ2010>=6800 & occ2010<=6940
	replace occ_group=23 if occ2010>=7000 & occ2010<=7630
	replace occ_group=24 if occ2010>=7700 & occ2010<=8965
	replace occ_group=25 if occ2010>=9000 & occ2010<=9750
	
	*Se mantienen todas las observaciones menos las del grupo de ocupación para
	*el cual se está corriendo el loop:
	keep if occ_group!=`num'

	*Se suma el número de personas por zip code :
	collapse (sum) est_num, by(zip)

	*Se junta con la base que cruza el zip con el MSA:
	cd $data/geographic
	merge m:1 zip using zip1990_metarea
	keep if _merge==3
	drop _merge
	sort metarea
	
	*Se genera una variable que almacene por cada área metropolitana el número
	*de personas:
	by metarea: egen est_num_total=sum(est_num)

	*Se genera la proporción de personas que trabajan en cada zip respecto al 
	*total del área metropolitana:
	g share=est_num/est_num_total
	keep share zip metarea

	*Se junta con la base que organizó la población en orden:
	cd $data/geographic
	merge m:1 metarea using 1990_rank
	drop _merge
	drop serial year rank
	
	*Se junta con la base que tiene imputado el tiempo de viaje:
	cd $data/travel
	merge 1:m zip using travel_time_hat
	keep if _merge==3
	drop _merge
	ren travel_time_hat travel_time

	*En esta base se genera el número de horas de viaje por semana:
	replace travel_time=10*travel_time

	*Según el modelo hay un parámetro de aversión que multiplica el tiempo de
	*de viaje con un parámetro de aversión se genera manualmente:
	/* No se tiene conocimiento de a qué hace referencia ese número */
	g discount=exp(-0.3425*travel_time)
	*Se genera variable que es el parámetro de aversión (escalar).
	*Se genera variable que representa la fracción de empleo en el MSA 
	*localizado en un census tract.
	g pi=share*discount
	sort gisjoin
	by gisjoin: egen pi_total=sum(pi)

	*Se calcula la proporción de población empleada en una ocupación respecto a
	*la población en el MSA:
	g  share_tilda=pi/pi_total

	*Se genera la variable que tiene el tiempo de viaje weighted por la 
	*distribución espacial de empleos para cada ocupación:
	g travel_time_share=travel_time*share_tilda

	*Se junta la weighted proportion de acuerdo al census tract:
	collapse (sum) expected_commute=travel_time_share, by(gisjoin)

	*Se almacena en una nueva base:
	sort expected
	ren expected_commute total_commute
	cd $data/temp_files/commute
	save commute_total`num', replace
}

*** En cada base se adiciona una variable que almacene la ocupación para la que se generó esa base: 
clear
local a 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 23 24 25 
foreach num of local a{
	u commute_total`num', clear
	g occ_group=`num'
	save commute_total`num', replace
}

*** Se almacena en una nueva base:
clear
	foreach num of local a{
	append using commute_total`num'
}

*Se almacena en una nueva base:

save commute_total, replace

*************************************+*************************************+***
**# Data Prep -  Location Choice Data
*************************************+*************************************+***


*******************************************************************************
** Cruce entre el grupo de ocupación y la ocupación
*******************************************************************************

*******************************************************************************
**Se agrupan las ocupaciones del IPUMS por grupo de ocupación del NHGIS de 1990.
*******************************************************************************

*1) Se agrupan las ocupaciones en grupos y se almacenan en una base temporal:


***Para 1990:

cd $data/ipums_micro
u 1990_2000_2010_temp if year==1990, clear
replace puma = puma1990
drop puma1990

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

cd $temp/temp_files
save temp_1990, replace

***Para 2000:

/* Número: Grupo Ocupación 2000*/
/*
1: Management
2: Profesional
3: Salud
4: Protección
5: Preparación comida
6: Mantenimiento y limpieza de construcciones
7: Cuidado personal
8: Ventas
9: Oficina y administrativos
10: Farming
11: Pesca
12: Construcción y extracción
13: Instalación
14: Producción
15: Transporte
*/

cd $data/ipums_micro
u 1990_2000_2010_temp if year==2000, clear

g occ2000_group=1 if occ>=1 & occ<=95
replace occ2000_group=2 if occ>=100 & occ<=354
replace occ2000_group=3 if occ>=360 & occ<=365
replace occ2000_group=4 if occ>=370 & occ<=395
replace occ2000_group=5 if occ>=400 & occ<=413
replace occ2000_group=6 if occ>=420 & occ<=425
replace occ2000_group=7 if occ>=430 & occ<=465
replace occ2000_group=8 if occ>=470 & occ<=496
replace occ2000_group=9 if occ>=500 & occ<=593
replace occ2000_group=10 if occ>=600 & occ<=605
replace occ2000_group=11 if occ>=610 & occ<=613
replace occ2000_group=12 if occ>=620 & occ<=694
replace occ2000_group=13 if occ>=700 & occ<=762
replace occ2000_group=14 if occ>=770 & occ<=896
replace occ2000_group=15 if occ>=900 & occ<=975

cd $temp/temp_files
save temp_2000, replace

***Para 2010:

/* Número: Grupo Ocupación 2000*/
/*
5:  
6:  Negocios y finanzas
8:  Computación y matemáticas
9:  Arquitectura e ingenieria
10: Ciencias físicas, sociales o biológicas
12: Servicio social y comunitario
13: Legal
14: Educacción, entrenamiento y biblioteca
15: Arte, diseño, entretenimiento, deporte y media
16: Diagnóstico en salud, médicos tratantes y otros técnicos
20: Técnicos y tecnólogos en Salud
21: Protección: bombero, etc.
24: Preparación comida
25: Mantenimiento y limpieza de construcciones
26: Cuidado personal
28: Ventas
29: Oficina y administrativos
31: Farming, Pesca y Forestry
32: Construcción y extracción
33: Instalación, mantenimiento y reparaciones
35: Producción
36: Transporte
37: Material moviendo ocupaciones
38: Desempleado
*/

cd $data/ipums_micro
u 1990_2000_2010_temp if year==2010, clear

g occ2010_group=5 if occ2010>=10 & occ2010<=430
replace occ2010_group=6 if occ2010>=500 & occ2010<=950
replace occ2010_group=8 if occ2010>=1000 & occ2010<=1240
replace occ2010_group=9 if occ2010>=1300 & occ2010<=1560
replace occ2010_group=10 if occ2010>=1600 & occ2010<=1980
replace occ2010_group=12 if occ2010>=2000 & occ2010<=2060
replace occ2010_group=13 if occ2010>=2100 & occ2010<=2150
replace occ2010_group=14 if occ2010>=2200 & occ2010<=2550
replace occ2010_group=15 if occ2010>=2600 & occ2010<=2920
replace occ2010_group=16 if occ2010>=3000 & occ2010<=3540
replace occ2010_group=20 if occ2010>=3600 & occ2010<=3650
replace occ2010_group=21 if occ2010>=3700 & occ2010<=3950
replace occ2010_group=24 if occ2010>=4000 & occ2010<=4150
replace occ2010_group=25 if occ2010>=4200 & occ2010<=4250
replace occ2010_group=26 if occ2010>=4300 & occ2010<=4650
replace occ2010_group=28 if occ2010>=4700 & occ2010<=4965
replace occ2010_group=29 if occ2010>=5000 & occ2010<=5940
replace occ2010_group=31 if occ2010>=6005 & occ2010<=6130
replace occ2010_group=32 if occ2010>=6200 & occ2010<=6940
replace occ2010_group=33 if occ2010>=7000 & occ2010<=7630
replace occ2010_group=35 if occ2010>=7700 & occ2010<=8965
replace occ2010_group=36 if occ2010>=9000 & occ2010<=9420
replace occ2010_group=37 if occ2010>=9510 & occ2010<=9750
replace occ2010_group=38 if occ2010==9920

cd $temp/temp_files
save temp_2010, replace

/* Se generan loops para optimizar el proceso posterior para 1990, 2000 y 2010 */

forvalues x=1990(10)2010{

*2) Partiendo de esta base, se cruzan los grupos generados de ocupación de 1990 con los grupos por ocupcación de 2010. Se genera una base que tenga el grupo para 1990 y la ocupación para 2010.

*Se agrupa el número de hogares por grupo de ocupación y ocupación:
cd $temp/temp_files
u temp_`x', clear
g a=1
collapse (count) count=a, by(occ2010 occ`x'_group)
*Se ordena de acuerdo a la ocupación y se calcula el valor máximo de observaciones dentro de una ocupación y en que posición se encuentra dentro de esta observación. De esta forma si hay duplicados se está eliminando aquel que tiene un menor número de personas trabajando en esa ocupación:
sort occ2010 count
by occ2010: g max=_N
by occ2010: g rank=_n
keep if max==rank
keep occ2010 occ`x'_group
sort occ2010 occ`x'_group
save occ_occ_group`x', replace

*3) Se agrupa el número de hogares por Estado, PUMA, ocupación del 2010 y grupo de ocupación de 1990 particular:
cd $temp/temp_files
u temp_`x', clear
collapse (count) count=serial, by(statefip puma occ2010 occ`x'_group)
drop if occ2010==9920
drop if occ`x'_group==.
save temp1, replace

*4) Se agrupa el número de hogares por Estado, PUMA y grupo de ocupación de 1990 particular: 
collapse (sum) count_occ=count, by(statefip puma occ`x'_group)

*5) Se junta la base de datos que contiene el número de hogares Estado, PUMA y grupo de ocupación de 1990 particular y la base que agrupa por esto y adicionalmente por la ocupación en el 2010:
merge 1:m statefip puma occ`x'_group using temp1
drop _merge

*6) Se genera una nueva variable que calcule la proporción de la población que trabaja en cada ocupación del grupo de ocupación: 
g occ_group_share=count/ count_occ
keep statefip puma occ2010 occ`x'_group occ_group_share

*7) Se almacena esto en una nueva base de datos:
cd $temp/temp_files
save occ_group_share`x', replace
}

*******************************************************************************
** Escogencia de ubicación por ocupación:

/* Estas bases contiene la probilidad de escoger ubicación de los trabajadores para cada ocupación en cada MSA para cada año. */
*******************************************************************************

***1990:

*Significado de las variables con las que se trabajaran (grupo de ocupación):
/*
gisjoin: identificador que incluye Estado, County, Census Tract, Census Block
e4q001: Managerial and professional (000-202): Executive, administrative
e4q002: Managerial and professional (000-202): Professional specialist
e4q003: Technical, sales, administrative support (203-402): Technicians
e4q004: Technical, sales, administrative support (203-402): Sales occupation
e4q005: Technical, sales, administrative support (203-402): Administratitive
e4q006: Service occupations (403-472): Private household occupations (403-412)
e4q007: Service occupations (403-472): Protective service occupations (413-432)
e4q008: Service occupations (403-472): Service occupations, except protective and househ
e4q009: Farming, forestry, fishing occupations (473-502)
e4q010: Precision production, craft, and repair occupations (503-702)
e4q011: Operators, fabricators,laborers (703-902): Machine operators, assembler
e4q012: Operators, fabricators,laborers (703-902): Transportation, material mov
e4q013: Operators, fabricators,laborers (703-902): Handlers, equipment cleaners
*/





*1) Se junta la base de datos de ocupación para 1990 de la nhgis con la base de datos que almacena la equivalencia entre los PUMA y los tracts para ese año:
*Ocupación NHGIS:
**1990
cd $data/nhgis/occupation
import delimited nhgis0013_ds123_1990_tract.csv, clear 
duplicates tag gisjoin, g(tag)
drop if tag>0
drop tag
sort gisjoin

*Tract-Puma:
cd $data/geographic
merge 1:1 gisjoin using puma1990_tract1990
keep if _merge==3
drop _merge


*Se limpia la base de datos:
drop anrca county year res_onlya trusta aianhha res_trsta blck_grpa tracta cda c_citya countya cty_suba divisiona msa_cmsaa placea pmsaa regiona state statea urbrurala urb_areaa zipa cd103a anpsadpi


*2) Se genera una variable que almacena los datos de la variable e4q0.. que representan el número de personas en cada grupo de ocupación para el tract, dentro del county, dentro del Estado. Se almacena estas variables en una base de datos: 
foreach num of numlist 1(1)9 {
g occ1990_group`num'=e4q00`num'
}
foreach num of numlist 10(1)13 {
g occ1990_group`num'=e4q0`num'
}

*Se limpia la base:
drop e4p* e4q*
sort gisjoin
cd $data/temp_files
save occ_tract1990, replace

*3) Se genera el número de empleados para cada cada grupo de ocupación de acuerdo con el Census tract:
cd $data/temp_files
u occ_tract1990, clear
ren puma puma1990
keep gisjoin statefip puma1990 occ1990*

*Se cambia la base de datos de formato wide a formato long mediante los identificadores gisjoin, statefip y puma. Se busca que se almacene en una nueva variable group que determine el grupo de ocupación al que pertenece el número de personas:
reshape long occ1990_group, i(gisjoin statefip puma1990) j(group)
*Se limpia la base:
ren (occ1990_group group) (number_occ1990 occ1990_group)

preserve
*Se suma el número de personas en cada grupo de ocupación en cada tract dentro del puma, county y Estado. Se almacena en una base de datos
collapse (sum) number_tract=number_occ1990, by(gisjoin statefip puma)
save number_tract1990, replace
restore


*4) Se junta la base que identifica el número de personas que trabajan en cada grupo de ocupación de acuerdo con el census tract con la base que cruza la información entre el grupo de ocupación y ocupación partiendo de los identificadores statefip, grupo de ocupación para 1990 y puma:
joinby statefip puma1990 occ1990_group using occ_group_share1990

*5) Se imputa el número de empleados por ocupación para cada census tract de 1990 multiplicando el número de personas en cada grupo de ocupación por la proporción de personas que trabajan en cada ocupación dentro del grupo de ocupación al que pertenecen:
g impute=number_occ1990*occ_group_share

*6) Se suma el número de empleados por ocupación de acuerdo con la ocupación, census tract, puma y Estado.
collapse (sum) impute, by(gisjoin statefip puma1990 occ2010)
*Se junta esta base con la base que tiene el grupo de ocupación para 1990 y la ocupación para 2010:
keep gisjoin statefip puma1990 occ2010 impute
*Se limpia la base:
merge m:1 occ2010 using occ_occ_group1990
keep if _merge==3
drop _merge

*7) Para cada identificador gisjoin existen diferentes ocupaciones reportadas. Para que todos tengan los mismas ocupaciones reportadas se utiliza el comando fillin que completa estas ocupaciones y les pone missings. A las observaciones con missing en impute se les pone 0:
fillin gisjoin occ2010
replace impute=0 if impute==.

*Se limpia la base:
drop _fillin statefip puma1990 occ1990_group
replace impute=round(impute)
save tract_impute1990, replace


*** 2000:

*Significado de las variables con las que se trabajaran (grupo de ocupación):
/*
h04001: Male - Management, prof, related occupations: Management, business
h04002: Male - Management, prof, related occupations: Professional and related
h04003: Male - Service: Healthcare support occupations
h04004: Male - Service: Protective service occupations
h04005: Male - Service: Food preparation and serving related occupations
h04006: Male - Service: Building and grounds cleaning and maintenance occup
h04007: Male - Service: Personal care and service occupations
h04008: Male - Sales and office: Sales and related
h04009: Male - Sales and office: Office and administrative support
h04010: Male - Farming, fishing, forestry: Agricultural workers
h04011: Male - Farming, fishing, forestry: Fishing, hunting, and forest
h04012: Male - Construction, extraction, maintenance: Construction
h04013: Male - Construction, extraction, maintenance: Installation
h04014: Male - Production, transportation, material moving: Production 
h04015: Male - Production, transportation, material moving: Transportation
h04016: Female - Management, prof, related occupations: Management, business
h04017: Female - Management, prof, related occupations: Professional and rela
h04018: Female - Service: Healthcare support occupations
h04019  Female - Service: Protective service occupations
h04020: Female - Service: Food preparation and serving related occupations
h04021: Female - Service: Building and grounds cleaning and maintenance occup
h04022: Female - Service: Personal care and service occupations
h04023: Female - Sales and office: Sales and related
h04024: Female - Sales and office: Office and administrative support
h04025: Female - Farming, fishing, forestry: Agricultural workers
h04026: Female - Farming, fishing, forestry: Fishing, hunting, and forest
h04027: Female - Construction, extraction, maintenance: Construction
h04028: Female - Construction, extraction, maintenance: Installation
h04029: Female - Production, transportation, material moving: Production 
h04030: Female - Production, transportation, material moving: Transportation
*/




*1) Se junta la base de datos de ocupación para 2000 de la nhgis con la base de datos que almacena la equivalencia entre los tracts de 1990 y 2000:
cd $data/nhgis/occupation

import delimited nhgis0014_ds153_2000_tract.csv, clear 

*Se limpia la base de datos:
drop year regiona divisiona state statea county countya cty_suba placea tracta trbl_cta blck_grpa trbl_bga c_citya res_onlya trusta aianhha trbl_suba anrca msa_cmsaa pmsaa necmaa urb_areaa cd106a cd108a cd109a zip3a zctaa name
sort gisjoin

*Tract 1990-2000:
cd $data/geographic
merge 1:m gisjoin using tract1990_tract2000
keep if _merge==3
drop _merge


*2) Creación de base que tenga el número de personas en cada grupo de ocupación para el tract:

*Se genera una variable que almacena los datos de la variable h040.. por el porcentaje que representan el número de hombres o mujeres en cada grupo de ocupación para el tract, dentro del county, dentro del Estado: 
foreach num of numlist 1(1)9 {
replace h0400`num'=h0400`num'*percentage
}

foreach num of numlist 10(1)30 {
replace h040`num'=h040`num'*percentage
}

*Se limpia la base eliminando uno de los identificadores únicos que contenia la base:
drop gisjoin
ren gisjoin_1 gisjoin

*Al haber duplicados, se hace un collapse de todas las variables importantes de acuerdo al identificador gisjoin para que para cada census tract quede una observación:
collapse (sum) h04001 h04002 h04003 h04004 h04005 h04006 h04007 h04008 h04009 h04010 h04011 h04012 h04013 h04014 h04015 h04016 h04017 h04018 h04019 h04020 h04021 h04022 h04023 h04024 h04025 h04026 h04027 h04028 h04029 h04030 , by(gisjoin)

*Al tenerse desagregada la información para cada grupo por sexo, se suman las observaciones para tener el número total de individuos por grupo de ocupación:
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

*Para cada variable, se redondea el número de observaciones:
foreach num of numlist 1(1)15 {
replace occ2000_group`num'=round(occ2000_group`num')
}

*Se limpia la base:
drop h04* 
sort gisjoin

*Se junta base creada con base que tiene el cruce del número del Tract con el PUMA:
cd $data/geographic
merge 1:1 gisjoin using puma_tract1990
keep if _merge==3
drop _merge

*3) Se genera el número de empleados para cada cada grupo de ocupación de acuerdo con el Census tract:
cd $data/temp_files
save occ_tract2000, replace
u occ_tract2000, clear
keep gisjoin statefip puma occ2000*

*Se cambia la base de datos de formato wide a formato long mediante los identificadores gisjoin, statefip y puma. Se busca que se almacene en una nueva variable group que determine el grupo de ocupación al que pertenece el número de personas:
reshape long occ2000_group, i(gisjoin statefip puma) j(group)
*Se limpia la base:
ren (occ2000_group group) (number_occ2000 occ2000_group)

preserve
*Se suma el número de personas en cada grupo de ocupación en cada bloque dentro del tract, puma, county y Estado. Se almacena en una base de datos:
collapse (sum) number_tract=number_occ2000, by(gisjoin statefip puma)
save number_tract2000, replace
restore

*4) Se junta la base que identifica el número de personas que trabajan en cada grupo de ocupación de acuerdo con el census tract con la base que cruza la información entre el grupo de ocupación y ocupación partiendo de los identificadores statefip, grupo de ocupación para 2000:
cd $temp/temp_files
joinby statefip puma occ2000_group using occ_group_share2000

*5) Se imputa el número de empleados por ocupación para cada census tract de 2000 multiplicando el número de personas en cada grupo de ocupación por la proporción de personas que trabajan en cada ocupación dentro del grupo de ocupación al que pertenecen:
g impute=number_occ2000*occ_group_share

*6) Se suma el número de empleados por ocupación de acuerdo con la ocupación, census tract, puma y Estado.
collapse (sum) impute, by(gisjoin statefip puma occ2010)
*Se junta esta base con la base que tiene el grupo de ocupación para 2000 y la ocupación para 2010:
keep gisjoin statefip puma occ2010 impute
*Se limpia la base:
merge m:1 occ2010 using occ_occ_group2000
keep if _merge==3
drop _merge


*7) Para cada identificador gisjoin existen diferentes ocupaciones reportadas. Para que todos tengan los mismas ocupaciones reportadas se utiliza el comando fillin que completa estas ocupaciones y les pone missings. A las observaciones con missing en impute se les pone 0:
fillin gisjoin occ2010
replace impute=0 if impute==.


replace impute=round(impute)
keep gisjoin occ2010 impute 
drop _fillin
save tract_impute2000, replace


***2010


*1) Se junta la base de datos de ocupación para 2010 de la nhgis con la base de datos que almacena la equivalencia entre los tracts de 1990 y 2010:

*Ocupación NHGIS:
cd $data/nhgis/occupation
import delimited nhgis0013_ds184_20115_2011_tract.csv, clear 


*Tract 1990-2010:
cd $data/geographic
merge 1:m gisjoin using tract1990_tract2010
keep if _merge==3
drop _merge

*Se limpia la base de datos:
drop year regiona divisiona state statea county countya name_m cousuba placea tracta blkgrpa concita aianhha res_onlya trusta aitscea anrca cbsaa csaa metdiva nectaa cnectaa nectadiva uaa cdcurra sldua sldla zcta5a submcda sdelma sdseca sdunia puma5a bttra btbga name_e


*2) Creación de base que tenga el número de personas en cada grupo de ocupación para el tract:

*Se genera una variable que almacena los datos de la variable mspe0..., ms=e0.. por el porcentaje que representan el número de hombres o mujeres en cada grupo de ocupación para el tract, dentro del county, dentro del Estado: 
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

*Se limpia la base eliminando uno de los identificadores únicos que contenia la base:
drop gisjoin
ren gisjoin_1 gisjoin

*Al haber duplicados, se hace un collapse de todas las variables importantes de acuerdo al identificador gisjoin para que para cada census tract quede una observación:
collapse (sum) mspe001-mspe073, by(gisjoin)

*Al tenerse desagregada la información para cada grupo por sexo, se suman las observaciones para tener el número total de individuos por grupo de ocupación:
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


*Para cada variable se redondea el número de observaciones:
foreach num of numlist 1(1)37 {
replace occ2010_group`num'=round(occ2010_group`num')
}

*Se limpia la base:
drop mspe*
drop occ2010_group1 occ2010_group2
sort gisjoin

*Se junta base creada con base que tiene el cruce del número del Tract con el PUMA:
cd $data/geographic
merge 1:1 gisjoin using puma_tract1990
keep if _merge==3
drop _merge

*Se almacena la base:
cd $temp/temp_files
save occ_tract2010, replace


*3) Se genera el número de empleados para cada cada grupo de ocupación de acuerdo con el Census tract:
cd $temp/temp_files
u occ_tract2010, clear
keep gisjoin statefip puma occ2010*

*Se cambia la base de datos de formato wide a formato long mediante los identificadores gisjoin, statefip y puma. Se busca que se almacene en una nueva variable group que determine el grupo de ocupación al que pertenece el número de personas:
reshape long occ2010_group, i(gisjoin statefip puma) j(group)

*Se limpia la base:
ren (occ2010_group group) (number_occ2010 occ2010_group)

preserve
*Se suma el número de personas en cada grupo de ocupación en cada bloque dentro del tract, puma, county y Estado. Se almacena en una base de datos:
collapse (sum) number_tract=number_occ2010, by(gisjoin statefip puma)
save number_tract2010, replace
restore

*4) Se junta la base que identifica el número de personas que trabajan en cada grupo de ocupación de acuerdo con el census tract con la base que cruza la información entre el grupo de ocupación y ocupación partiendo de los identificadores statefip, grupo de ocupación para 1990:
cd $temp/temp_files
joinby statefip puma occ2010_group using occ_group_share2010

*5) Se imputa el número de empleados por ocupación para cada census tract de 2000 multiplicando el número de personas en cada grupo de ocupación por la proporción de personas que trabajan en cada ocupación dentro del grupo de ocupación al que pertenecen:
g impute=number_occ2010*occ_group_share

*6) Se suma el número de empleados por ocupación de acuerdo con la ocupación, census tract, puma y Estado.
collapse (sum) impute, by(gisjoin statefip puma occ2010)
*Se junta esta base con la base que tiene el grupo de ocupación para 2000 y la ocupación para 2010:
keep gisjoin statefip puma occ2010 impute
*Se limpia la base:
merge m:1 occ2010 using occ_occ_group2010
keep if _merge==3
drop _merge


*7) Para cada identificador gisjoin existen diferentes ocupaciones reportadas. Para que todos tengan los mismas ocupaciones reportadas se utiliza el comando fillin que completa estas ocupaciones y les pone missings. A las observaciones con missing en impute se les pone 0:
fillin gisjoin occ2010
replace impute=0 if impute==.

*Se limpia la base:
replace impute=round(impute)
keep gisjoin occ2010 impute 
sort gisjoin occ2010
cd $temp/temp_files
save tract_impute2010, replace

*******************************************************************************
** Combinación de todas las bases:
*******************************************************************************

/*
El proceso para generar la base occ2010_count se encontraba en /Do-File/data_prep_various_measures. Se pasa a esta base ya que aquí se utiliza por primera vez. El autor sugiere revisar los do's en un orden particular en el cual esta base estaba primero, por lo que la especificación  dada por él no es la adecuada para el paquete de replicación.
*/


*1) Se genera una base que tenga el número de personas por ocupación en 1990 y 2010:

cd $data/ipums_micro
u 1990_2000_2010_temp , clear

*Se limpia la base (eliminan variables, observaciones cuyos valores se salen de un rango deseado):
drop wage distance tranwork trantime pwpuma ownershp ownershpd gq
drop if uhrswork<30
keep if age>=25 & age<=65
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

*Se genera una variable que cuente el número de personas que representa cada una de las observaciones de la base y se suma el número de personas por cada ocupación de 2010:
g count1990=perwt if year==1990
g count2000=perwt if year==2000
g count2010=perwt if year==2010
collapse (count) count1990 count2010, by(occ2010)
replace count1990=. if count1990==0
replace count2010=. if count2010==0
*Se guarda la base
cd $temp/temp_files
save occ2010_count, replace

/* Se generan loops para optimizar el proceso */

*2) Se pegan las tres bases de datos generadas en apartado anterior:
u tract_impute1990, clear
foreach x of numlist 1990 2000{
	ren impute impute`x'
	local a = `x'+10
	merge 1:1 occ2010 gisjoin using tract_impute`a'
	drop _merge
	replace impute`x'=0 if impute`x'==.
}

*Se limpia la base:
ren impute impute2010
replace impute2010=0 if impute2010==.

*3) Se asegura que las observaciones sean consistentes en los tres periodos:
*Se junta la base con aquella que tiene el número de personas por ocupación en 1990 y 2010:
cd $temp/temp_files
merge m:1 occ2010 using occ2010_count
keep if _merge==3
drop _merge
drop count*

*Se junta con la base que tiene las equivalencias entre tract de 1990 y área metropolitana:
cd $data/geographic
merge m:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

*4) Se suma 1 a todas las variables para suavizar las observaciones cuyo valor es 0. 
cd $temp/temp_files
replace impute1990=impute1990+1
replace impute2000=impute2000+1
replace impute2010=impute2010+1
save tract_impute, replace

*5) Se genera una base que tenga el conteo de la población por ocupación para cada MSA para el año 1990, 2000 y 2010:
collapse (sum) impute_total1990=impute1990 impute_total2000=impute2000 impute_total2010=impute2010, by(occ2010 metarea)

*6) Se junta base de población por ocupación para cada MSA con base de población por ocupación para cada Tract:
merge 1:m occ2010 metarea using tract_impute
drop _merge

*7) Se genera variable de proporción de población por ocupación para cada tract respecto al MSA. Se almacena en una base de datos:
g impute_share1990=impute1990/impute_total1990
g impute_share2000=impute2000/impute_total2000
g impute_share2010=impute2010/impute_total2010
keep occ2010 metarea gisjoin impute_share1990 impute_share2000 impute_share2010
save tract_impute_share, replace






*************************************+*************************************+***
**# Data Prep -  High Skill Share
*************************************+*************************************+***

/*Se optimiza el proceso de esta base mediante un loop. Se generan diferentes bases donde se tiene si la proporción de personas con altas habilidades para cada ocupación es mayor a un valor. Este proceso se hace una proporción mayor a 0.3, 0.4 o 0.5.*/


forvalues x=0.3(0.1)0.5{
	
	display `x'
	
	** Se abre la base:
	cd $data/ipums_micro
	u 1990_2000_2010_temp, clear
	
	**Se genera una variable que indica si la persona tiene un número alto
	* de años de educación definido por más de 4 años de educación superior:
	g college=0
	replace college=1 if educ>=10 & educ<.
	
	**La variable educación es una categórica. Se saca la media de la 
	* variable universidad que representa la proporción de personas que tienen
	* universidad de acuerdo con la ocupación en la que trabajan:
	collapse college, by(occ2010)
	
	**Si la proporción de personas en esa ocupación es mayor al 40% se dice 
	* que esa ocupación representa una de altas habilidades. Se genera la 
	* variable que representa esto:
	ren college college_share
	g high_skill=0
	replace high_skill=1 if college_share>=`x'	
	** Se almacena en una nueva base de datos:
	cd $temp/temp_files
	if `x' == 0.4{
		save high_skill, replace
	}
	else{
		save high_skill_`x', replace
	}	
}

*************************************+*************************************+***
**# Data Prep -  Skill Ratio
*************************************+*************************************+***

** Se abre base de datos que almacena la proporción de población por ocupación para cada tract respecto al MSA:
cd $data/temp_files
u tract_impute_share, clear

/* No se sabe de donde sale esta base de datos que junta con la base de tract_impute_share. No aparece como raw data y en ninguno de los do-files la genera */


*** Base salario por metarea:
cd $data/temp_files
merge m:1 occ2010 metarea using wage_metarea
keep if _merge==3
drop _merge
drop count*

*** Base nivel de habilidad para cada ocupación basada en la proporción de personas que que fueron a universidad por cada ocupación en 1990:
cd $data/temp_files
merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

*** Base número de personas en cada ocupación por área metropolitana:
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

*******************************************************************************
** Generación de variables:
*******************************************************************************

*** Se genera una variable que diga el número de personas que trabajan en ocupaciones con altas habilidades para cada año:
g impute2010_high=impute_share2010*count2010*high_skill
g impute2000_high=impute_share2000*count2000*high_skill
g impute1990_high=impute_share1990*count1990*high_skill

*** Se genera una variable que diga el número de personas que trabajan en ocupaciones con bajas habilidades para cada año:
g impute2010_low=impute_share2010*count2010*(1-high_skill)
g impute2000_low=impute_share2000*count2000*(1-high_skill)
g impute1990_low=impute_share1990*count1990*(1-high_skill)

*** Se organiza la base de datos para que queden el número de personas de acuerdo con área metropolitana y census tract (se deja de lado la población por ocupación):
collapse (sum) impute2010_high impute2010_low impute2000_high impute2000_low impute1990_high impute1990_low, by(metarea gisjoin)
cd $data/temp_files
save skill_pop, replace


*** Se genera una variable que sea el cambio porcentual de la proporción de personas que trabajan en ocupaciones que requieren alta habilidad respecto a baja habilidad entre el 2010 y 1990::
cd $data/temp_files
u skill_pop, clear

g dratio=ln( impute2010_high/ impute2010_low)-ln( impute1990_high/ impute1990_low)
keep gisjoin dratio
save skill_ratio_occupation, replace


*************************************+*************************************+***
**# Data Prep -  Rent
*************************************+*************************************+***


*** 1990:

** Se abre base:
cd $data/nhgis
import delimited nhgis0018_ds120_1990_tract.csv, clear

******************************************************************************
** Se almacena en diferentes bases la renta traída a precios reales de 2010:
******************************************************************************


**Se renombran las variables para que se entienda que significa y se mantienen solo esas variables. Se organiza la base por el identificador único: 

**Se renombran las variables para que se entienda que significa y se mantienen solo esas variables. Se organiza la base por el identificador único: 
ren (est001 es6001) (hp rent)
keep gisjoin hp rent
sort gisjoin

**Está trayendo el precio de la vivienda y el valor de la renta de 1990 en términos de precios reales del 2010:
/*
IPC 1990 USA: 130.7
IPC 2000 USA: 172.2
IPC 2010 USA: 218.056 
*/
replace hp=hp*218.056/130.7
replace rent=rent*218.056/130.7

** Se almacena en una nueva base:
cd $data/temp_files
save rent1990, replace

/** Se realiza el mismo para proceso para la base del 2000 y 2010. No se optimiza el proceso mediante un loop porque el nombre de las variables en cada base son diferentes. No se describirá el proceso al ser el mismo. */

*** 2000:
cd $data/nhgis
import delimited nhgis0018_ds151_2000_tract.csv, clear
ren (gb7001 gbg001) (hp rent)
keep gisjoin hp rent
sort gisjoin
replace hp=hp*218.056/172.2
replace rent=rent*218.056/172.2
cd $data/temp_files
save rent2000, replace

*** 2010:
cd $data/nhgis
import delimited nhgis0018_ds184_20115_2011_tract.csv, clear 
ren (muje001 mu2e001) (rent hp)
keep gisjoin hp rent
sort gisjoin
cd $data/temp_files
save rent2010, replace

******************************************************************************
** Se genera base de datos que tenga la renta:
******************************************************************************

** Se abre base de datos que cruza la información de tract de 1990 y 2010:
cd $data/geographic
u tract1990_tract2010_nearest, clear
*Se limpia: 
ren gisjoin1 gisjoin

** Se junta esta base con las bases que tienen información de la renta para 1990 y 2010:

foreach num of numlist 1990 2010{
	cd $temp/temp_files
	merge m:1 gisjoin using rent`num'
	keep if _merge==3
	drop _merge
	ren rent rent`num'
	
	if `num' == 1990{
		ren gisjoin gisjoin1
		ren gisjoin2 gisjoin
	}
	else{
		drop gisjoin
	}
}

** Se junta la base generada con las bases que tienen información de tract de 1990 y 2000:
cd $data/geographic
merge 1:1 gisjoin1 using tract1990_tract2000_nearest
keep if _merge==3
drop _merge
ren gisjoin2 gisjoin

** Se junta la base generada con la base que tiene información de la renta para 2000:
cd $temp/temp_files
merge m:1 gisjoin using rent2000
keep if _merge==3
drop _merge 
ren rent rent2000
drop gisjoin
ren gisjoin1 gisjoin
keep gisjoin rent*
save rent, replace

******************************************************************************
** Reemplazar valores de renta missing con la renta promedio a nivel MSA:
******************************************************************************

** Se abre base:
cd $temp/temp_files
u rent, clear

**Se junta con base que cruza información del tract de 1990 con el área metropolitana:
cd $data/geographic
merge 1:1 gisjoin using tract1990_metarea
cd $data/temp_files
keep if _merge==3
drop _merge
save temp, replace

** Se genera el promedio de la renta para cada uno de los años de acuerdo con área metropolitana y se almacena en una nueva base de datos:
collapse mean_rent1990=rent1990 mean_rent2000=rent2000 mean_rent2010=rent2010, by(metarea)
save rent_metarea, replace

** Se junta este promedio de renta por área metropolitana con la renta para cada tract:
merge 1:m metarea using temp
drop _merge

** Se limpia la base:
*Para valores de renta que no tiene información, reemplace su valor con el promedio de la renta en esa área metropolitana:
forvalues x=1990(10)2010{
replace rent`x'=mean_rent`x' if rent`x'==0 | rent`x'==.
}
keep gisjoin rent2010 rent2000 rent1990
sort gisjoin


** Se almacena la base de datos:
save rent, replace

*************************************+*************************************+***
**# Data Prep -  IV 1990-2010 main
*************************************+*************************************+***

*************************************+*************************************+***
*** Merge de varias bases de datos: 
*************************************+*************************************+***

** Se usa los datos de tiempo de viaje:
cd $data/temp_files/commute

u commute, clear

** Se junta con la base que cruza la definición de tract1990 con la metarea:
cd $data/geographic
merge m:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

*** Se junta con la base que almacena el long hour premium para cada ocupación:
cd $data/temp_files
merge m:1 occ2010 using val_40_60_total_1990_2000_2010
keep if _merge==3
drop _merge

drop se_1990 se_2010

*** Se generan grupos de acuerdo con la ocupación:
	
	/* Número_de_la_observación Definición
	* 1: MANAGEMENT, BUSINESS, SCIENCE, AND ARTS
	* 2: BUSINESS OPERATIONS SPECIALISTS
	* 3: FINANCIAL SPECIALISTS
	* 4: COMPUTER AND MATHEMATICAL
	* 5: ARCHITECTURE AND ENGINEERING
	* 6: TECHNICIANS
	* 7: LIFE, PHYSICAL, AND SOCIAL SCIENCE
	* 8: COMMUNITY AND SOCIAL SERVICES
	* 9: LEGAL
	* 10: EDUCATION, TRAINING, AND LIBRARY
	* 11: ARTS, DESIGN, ENTERTAINMENT, SPORTS, AND MEDIA
	* 12: HEALTHCARE PRACTITIONERS AND TECHNICAL
	* 13: HEALTHCARE SUPPORT
	* 14: PROTECTIVE SERVICE
	* 15: FOOD PREPARATION AND SERVING
	* 16: BUILDING AND GROUNDS CLEANING AND MAINTENANCE
	* 17: PERSONAL CARE AND SERVICE
	* 18: SALES AND RELATED
	* 19: OFFICE AND ADMINISTRATIVE SUPPORT
	* 20: FARMING, FISHING, AND FORESTRY
	* 21: CONSTRUCTION
	* 22: EXTRACTION
	* 23: INSTALLATION, MAINTENANCE, AND REPAIR
	* 24: PRODUCTION
	* 25: TRANSPORTATION AND MATERIAL MOVING
	*/
	
	g occ_group=1 if occ2010>=10 & occ2010<=430
	replace occ_group=2 if occ2010>=500 & occ2010<=730
	replace occ_group=3 if occ2010>=800 & occ2010<=950
	replace occ_group=4 if occ2010>=1000 & occ2010<=1240
	replace occ_group=5 if occ2010>=1300 & occ2010<=1540
	replace occ_group=6 if occ2010>=1550 & occ2010<=1560
	replace occ_group=7 if occ2010>=1600 & occ2010<=1980
	replace occ_group=8 if occ2010>=2000 & occ2010<=2060
	replace occ_group=9 if occ2010>=2100 & occ2010<=2150
	replace occ_group=10 if occ2010>=2200 & occ2010<=2550
	replace occ_group=11 if occ2010>=2600 & occ2010<=2920
	replace occ_group=12 if occ2010>=3000 & occ2010<=3540
	replace occ_group=13 if occ2010>=3600 & occ2010<=3650
	replace occ_group=14 if occ2010>=3700 & occ2010<=3950
	replace occ_group=15 if occ2010>=4000 & occ2010<=4150
	replace occ_group=16 if occ2010>=4200 & occ2010<=4250
	replace occ_group=17 if occ2010>=4300 & occ2010<=4650
	replace occ_group=18 if occ2010>=4700 & occ2010<=4965
	replace occ_group=19 if occ2010>=5000 & occ2010<=5940
	replace occ_group=20 if occ2010>=6005 & occ2010<=6130
	replace occ_group=21 if occ2010>=6200 & occ2010<=6765
	replace occ_group=22 if occ2010>=6800 & occ2010<=6940
	replace occ_group=23 if occ2010>=7000 & occ2010<=7630
	replace occ_group=24 if occ2010>=7700 & occ2010<=8965
	replace occ_group=25 if occ2010>=9000 & occ2010<=9750

*** Se junta con la base que contiene el número de personas en cada ocupación por área metropolitana:
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge
drop if count1990==.

*** Se junta con la base que contiene la designación de si la ocupación es de alta o baja habilidad: 
cd $data/temp_files
merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

*** Se junta con la probabilidad de ocupación de los trabajadores de la ocupación para cada MSA:
cd $data/temp_files
merge m:1 occ2010 gisjoin using tract_impute_share
keep if _merge==3
drop _merge
drop count2000 
cd $data/temp_files
save temp, replace

*************************************+*************************************+***
*** Instrumento para el cambio del ratio de habilidad: 
*************************************+*************************************+***

/* La variable instrumental es el valor predicho de cambios en el ratio de población de altas habilidades respecto a bajas habilidades por el tiempo de viaje esperado para cada ocupación y el valor de una hora extra de trabajo. Esto lo hace para evaluar cual es el efecto de que las personas migren al tract por cambios en el valor del tiempo y ubicación de sus trabajos, y no por otras razones. */


local x 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 23 24 25
foreach num of local x{
	cd $data/temp_files
	u temp if occ_group!=`num', clear
	
*Se genera una variable que sea la proporción de población por 		
*ocupación para cada tract respecto al MSA para cada año:


*Para el año 1990 el autor utiliza el valor imputado de la proporción de población por ocupación para cada tract que tienen altas o bajas habilidades respecto al valor para cada MSA. Este valor se imputó multiplicando el número de personas en cada grupo de ocupación por la proporción de personas que trabajan en cada ocupación dentro del grupo de ocupación al que pertenecen (ver data prep location choice).
	g a1990=exp( log(impute_share1990))
	
*Para el año 2010 lo generó sumando el valor imputado de la proporción de población que tienen altas o bajas habilidades por ocupación para cada tract respecto al valor para cada MSA, y la diferencia entre la multiplicación del valor de una hora extra de 1990 por el tiempo de viaje esperado por un escalar y la misma multiplicación pero con el valor de una hora extra de 1990.

/* No se tiene certeza de por qué el escalar toma este valor ya que en ninguna de las regresiones del data prep aparece este valor. Se sugiere al autor complementar el do-file explicando porque toma este valor. */

	g a2010=exp( log(impute_share1990)+7.204779*val_1990*expected_commute-7.204779*val_2010*expected_commute)

	sort occ2010 metarea

*Se suman los valores simulados para ambos años de acuerdo con el área metropolitana y la ocupación. Esto para encontrar la proporción de población por ocupación para cada MSA:
	by occ2010 metarea: egen sim1990=sum(a1990)
	by occ2010 metarea: egen sim2010=sum(a2010)

	
*Se saca la proporción de población por ocupación para cada tract respecto a la proporción de MSA. Se multiplica por el número de personas que trabajan en cada ocupación para evaluar cual es el número de personas que trabajan en una ocupación para cada tract. Esto lo hace para el total de población del tract, altas habilidades y bajas habilidades:
	replace sim1990=a1990/sim1990
	replace sim2010=a2010/sim2010

	replace sim1990=sim1990*count1990
	replace sim2010=sim2010*count1990

	g sim1990_high=sim1990 if high_skill==1
	g sim1990_low=sim1990 if high_skill==0

	g sim2010_high=sim2010 if high_skill==1
	g sim2010_low=sim2010 if high_skill==0

	collapse (sum) sim1990_high  (sum) sim1990_low (sum) sim2010_high (sum) sim2010_low (sum) count=count1990,by(gisjoin metarea)

*Se genera el cambio entre ambos periodos de tiempo para altas habilidades, bajas habilidades o la población total del tract:
	g dln_sim_low=ln(sim2010_low)-ln(sim1990_low)
	g dln_sim_high=ln(sim2010_high)-ln(sim1990_high)
	g dln_sim=ln(sim2010_high+sim2010_low)-ln(sim1990_high+sim1990_low)

	keep gisjoin dln_sim_low dln_sim_high dln_sim
	g occ_group=`num'
	cd $data/temp_files/iv
	save sim_iv`num', replace
}

*Se almacena en una nueva base de datos:
clear all
local x 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 23 24 25
foreach num of local x{
append using sim_iv`num'
}
save sim_iv, replace



*************************************+*************************************+***
*** Base para el Instrumento para el housing rent y amenity shock: 
*************************************+*************************************+***

/* La variable instrumental en este caso es el valor predicho de cambios en el ratio de población de altas habilidades respecto a bajas habilidades por el tiempo de viaje esperado para la población en total del tract y el valor de una hora extra de trabajo. Esto lo hace para evaluar cual es el efecto de que las personas migren al tract por cambios en el valor del tiempo y ubicación de sus trabajos, y no por otras razones. */

/* La diferencia entre el instrumento para housing rent y amenity shock es que en la base de housing rent generan el cambio en el número de personas con altas o bajas habilidades o el total de población para el tract entre 1990 y 2010 mientras que en la base para amenity shock no lo hacen. Esto lo hace más adelante en el do*/

cd $data/temp_files
u temp, clear
g a1990=exp( log(impute_share1990))

*Para el año 2010 lo generó sumando el valor imputado de la proporción de población que tienen altas o bajas habilidades  para cada tract respecto al valor para cada MSA, y la diferencia entre la multiplicación del valor de una hora extra de 1990 por el tiempo de viaje esperado por un escalar y la misma multiplicación pero con el valor de una hora extra de 1990.

/* El autor explica que el valor de este escalar no importa en el tamaño de los estimadores de los parámetros de interés, así afecte la primera etapa de variables instrumentales.*/

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

preserve
cd $data/temp_files/iv
save ingredient_for_iv_amenity, replace
restore


g dln_sim_low=ln(sim2010_low)-ln(sim1990_low)
g dln_sim_high=ln(sim2010_high)-ln(sim1990_high)
g dln_sim=ln(sim2010_high+sim2010_low)-ln(sim1990_high+sim1990_low)

keep gisjoin dln_sim_low dln_sim_high dln_sim
ren dln_sim_low dln_sim_low_total
ren dln_sim_high dln_sim_high_total
ren dln_sim dln_sim_total
cd $data/temp_files/iv
save sim_iv_total, replace


*************************************+*************************************+***
**# Data Prep -  Housing Demand
*************************************+*************************************+***


*******************************************************************************
** Se juntan distintas bases:
*******************************************************************************

cd $data/temp_files
u tract_impute_share, clear

***Se junta con otras bases de datos:

* Base de ingreso a nivel ocupación para los años 1990, 2000 y 2010:
cd $data/temp_files
merge m:1 occ2010 using inc_occ_1990_2000_2010
keep if _merge==3
drop _merge
drop count* wage_real1990 wage_real2000 wage_real2010

* Base de salario por área metropolitana:
cd $data/temp_files
merge m:1 occ2010 metarea using wage_metarea
keep if _merge==3
drop _merge

***Se genera una variable que sea igual al ingreso promedio de la gente que trabaja en esa ocupación por MSA:
g inc1990=impute_share1990*inc_mean1990*count1990
g inc2010=impute_share2010*inc_mean2010*count2010

***Se agrega la base de datos a nivel área metropolitana:
collapse (sum) inc1990 inc2010, by(gisjoin metarea)

***Se genera una variable que exprese el cambio porcentual de los ingresos del área metropolitana de 2010 respecto a 1990. Se almacena en nueva base de datos:
g ddemand=ln(inc2010)-ln(inc1990)
keep gisjoin ddemand
cd $data/temp_files
save ddemand, replace


*************************************+*************************************+***
**# Data Prep -  Housing Density
*************************************+*************************************+***


*******************************************************************************
** Se genera una base que almacene el área del tract para 1980:
*******************************************************************************

*** import area (1980 census tract)
cd $data/geographic
import delimited UStract1980.csv, varnames(1) clear 

** Se limpia la base:
keep gisjoin area_sm
destring area_sm, g(area) ignore(",")
keep gisjoin area

** Se almacena la base:
cd $data/geographic
save area1980, replace


*******************************************************************************
** Número de vivienda en 1980:
*******************************************************************************

cd $data/nhgis
import delimited nhgis0034_ds107_1980_tract.csv, clear
ren def001 room

** Se limpia la base:
keep gisjoin room
sort gisjoin
cd $data/temp_files
save room1980, replace

*******************************************************************************
** Densidad habitacional usando datos de 1980:
*******************************************************************************

cd $data/geographic
u tract1990_tract1980_1mi, clear

** Se limpia base:
ren gisjoin2 gisjoin

** Se junta con base que almacena el área del tract para 1980:
cd $data/geographic
merge m:1 gisjoin using area1980
drop _merge

** Se junta con base que almacena la vivienda en 1980:
cd $data/temp_files
merge m:1 gisjoin using room1980
drop _merge

** Se hace un collapse de la base sumando el área y vivienda por identificador de census tract:
collapse (sum) area room, by(gisjoin1)

** Se genera una variable que sea igual al número de vivienda  de cada tract sobre el área del tract para ver:
g room_density_1mi_3mi=(room)/(area)
replace room_density_1mi_3mi=0 if room_density_1mi_3mi==.
ren gisjoin1 gisjoin

** Se almacena en nueva base:
save room_density1980_1mi, replace

*************************************+*************************************+***
**# Data Prep -  Counterfactual Value
*************************************+*************************************+***

****************************************************************
**** Create value for employment proximity term in 1990
****************************************************************


*************************************+*************************************+***
** Cruce base de datos
*************************************+*************************************+***

***Proporción de emplados por ocupación respecto al tract para 1994:
cd $data/temp_files
u occ_emp_share_1994, clear

*** Valor de las horas extraspara los tres años:
cd $data/temp_files
merge m:1 occ2010 using val_40_60_total_1990_2000_2010
keep if _merge==3
drop _merge

*** Dummy ocupación es altamente calificada: 
cd $data/temp_files

preserve
merge m:1 occ2010 using high_skill
drop if _merge==2
drop _merge
drop se_1990 se_2010
save occ_emp_share_temp, replace
restore

preserve 
merge m:1 occ2010 using high_skill_30
drop if _merge==2
drop _merge
drop se_1990 se_2010
save occ_emp_share_temp_30, replace
restore

merge m:1 occ2010 using high_skill_50
drop if _merge==2
drop _merge
drop se_1990 se_2010
save occ_emp_share_temp_50, replace

*************************************+*************************************+***
** Crear un valor para el término de proximidad de 1990, 2000 y 2010:
*************************************+*************************************+***
/*El proceso de generación de bases se tenía en loops separados, lo cual hacía que no fuera óptimo el proceso. Se fusionó todo en un loop para que fuera más sencillo comprender todo el proceso.*/


**Cada número representa una ocupación: 
# delimit
global x 30 120 130 150 205 230 310
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
9510 9600 9610 9620 9640 ;
# delimit cr

** Para cada tipo de definición de ocupaciones que requieren altas habilidades:
local b "occ_emp_share_temp occ_emp_share_temp_30 occ_emp_share_temp_50"
foreach a of local b{
	local i = 1
** Para cada año para el que se requiere el análisis:
foreach y of numlist 1990 2000 2010{
	**Para cada ocupación:
	foreach num of global x{
	
	**Se mantienen las observaciones para ese periodo de tiempo:
	cd $data/temp_files
	u `a', clear
	keep if occ2010==`num'
	
	** Se junta con la base de datos que estima el tiempo de recorrido:
	cd $data/temp_files
	drop if zip==.
	merge 1:m zip using travel_time_hat
	keep if _merge==3
	drop _merge
	
	ren travel_time_hat travel_time

	** Horas de viaje por semana: 
	replace travel_time=travel_time*10

*** Se estima el valor del tiempo de ese año utilizando el valor 
**verdadero, el tiempo de viaje y si se es de alta o baja calificación.
/* El autor plantea unos números para estimar el valor para cada 
definición; sin embargo no se sabe de donde salieron. Se sugiere que 
después revise esto y haga explícito de donde están sacando las variables 
*/
if `i' == 1{
	
	g value`y'=exp(-1.408819*val_`y'*travel_time*(1-high_skill) -6.002858*high_skill*val_`y'*travel_time)
	sort zip
	*** Se estima el valor del tiempo de cada año utilizando el valor estimado por la proporción de personas que tiene esa ocupación que viven en el tract:
	replace value`y'=value`y'*share
	collapse (sum) counterfactual_share=value`y', by(gisjoin)
	g occ2010=`num'
	cd $data/temp_files/counterfactual
	save value_term`y'_`num', replace
	
	}
	
else if `i' == 2{
	g value`y'=exp(-2.128*val_1990*travel_time*(1-high_skill) -6.184*high_skill*val_1990*travel_time)
	sort zip
	replace value`y'=value`y'*share
	collapse (sum) counterfactual_share=value`y', by(gisjoin)
	g occ2010=`num'
	cd $data/temp_files/counterfactual
	save value_term`y'_30_`num', replace
	}
	
else if `i'== 3{
	g value`y'=exp(-3.431*val_`y'*travel_time*(1-high_skill) -9.494*high_skill*val_`y'*travel_time)
	sort zip
	replace value`y'=value`y'*share
	collapse (sum) counterfactual_share=value`y', by(gisjoin)
	g occ2010=`num'
	cd $data/temp_files/counterfactual
	save value_term`y'_50_`num', replace	
	}
	}
*** Se juntan todas la base de datos y se almacenan en una sola:
cd $data/temp_files/counterfactual
clear
foreach num of global x{
	if `i' == 1{
		append using value_term`y'_`num'
	}
	else if `i' == 2{
		append using value_term`y'_30_`num'
	}
	else if `i'== 3{
		append using value_term`y'_50_`num'	
		}
}	

if `i' == 1{
		save value_term`y', replace
	}
else if `i' == 2{
		save value_term`y'_high30, replace
	}
else if `i'== 3{
		save value_term`y'_high50, replace
}	
}

local ++1

}


*************************************+*************************************+**
*************************************+*************************************+**
**# Output -  Amenities
*************************************+*************************************+**
*************************************+*************************************+**

/* Esta base de datos genera la tabla 1 y 6. */


*************************************+*************************************+**
/* Data Cleaning */
*************************************+*************************************+**


/*Para cada zip se está sumando el número de establecimientos que tienen un cierto rango de empleados para cada tipo de amenidad descrito posteriormente y se está almacenando en una nueva base de datos. Esto se hace para el año 1994, 2000 y 2010 */
*************************************+*************************************+**


***** pick out establishments of interest and generate zip code statistics to plot. 
**1. Restaurant 2. grocery store 3. gym  4. personal care

cd $data/zbp

/* Descripción de las variables: 
EST Total Number of Establishments

N1_4 Number of Establishments: Employment Size Class: 1-4 Employees
N5_9 Number of Establishments: Employment Size Class: 5-9 Employees
N10_19 Number of Establishments: Employment Size Class: 10-19 Employees
N20_49 Number of Establishments: Employment Size Class: 20-49 Employees
N50_99 Number of Establishments: Employment Size Class: 50-99 Employees
N100_249 Number of Establishments: Employment Size Class: 100-249 Employees      
N250_499 Number of Establishments: Employment Size Class: 250-499 Employees
N500_999 Number of Establishments: Employment Size Class: 500-999 Employees
N1000 Number of Establishments: Employment Size Class: 1,000 Or More Employees
*/

************************
*** Restaurante:
************************
/*
SIC 5812 - Restaurantes
SIC 5813 - Bares y Cafeterias
SIC 54 - Detallistas de alimentación
SIC 7991 - Physical fitness activities
SIC 7230 - Beauty Shops
SIC 7240 - Barber Shops
SIC 7299 - Servicios personales diversos
NAICS 722 - Food Services and Drinking Places
NAICS 445 - Food and Beverage store
NAICS 71394 - Fitness and recreational sport centers
NAICS 8121 - Personal care services
 */
 

** 1994: 
u zip94detail, clear
keep if sic=="5812" | sic=="5813"
collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
cd $data/temp_files
save restaurant94,replace

/* Se genera un loop para optimizar el proceso que se estaba haciendo anteriormente */
local x 00 10
foreach num of local x{
	cd $data/zbp
	u zip`num'detail, clear
	g lastthreedigit=substr(naics,4,3)
	g lasttwodigit=substr(naics,5,2)
	g lastdigit=substr(naics,6,1)
	drop if lastthreedigit=="---"
	drop if lasttwodigit=="--"
	drop if lastdigit=="-"
	g naics_3=substr(naics,1,3)
	keep if naics_3=="722"
	collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
	cd $data/temp_files
	save restaurant`num',replace		
}
************************
*** Grocery Store:
************************

cd $data/zbp
u zip94detail, clear
g lasttwodigit=substr(sic,3,2)
g lastdigit=substr(sic,4,1)
drop if lasttwodigit=="--"
drop if lastdigit=="-"
g sic_2=substr(sic,1,2)
keep if sic_2=="54"
collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
cd $data/temp_files
save grocery94, replace

/* Se genera un loop para optimizar el proceso que se estaba haciendo anteriormente */
local x 00 10
foreach num of local x{
	cd $data/zbp
	u zip`num'detail, clear
	g lastthreedigit=substr(naics,4,3)
	g lasttwodigit=substr(naics,5,2)
	g lastdigit=substr(naics,6,1)
	drop if lastthreedigit=="---"
	drop if lasttwodigit=="--"
	drop if lastdigit=="-"
	g naics_3=substr(naics,1,3)
	keep if naics_3=="445"
	collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
	cd $data/temp_files
	save grocery`num',replace		
}

************************
*** Gym:
************************

*** gym
cd $data/zbp
u zip94detail, clear
keep if sic=="7991"
collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
cd $data/temp_files
save gym94, replace


/* Se genera un loop para optimizar el proceso que se estaba haciendo anteriormente */
local x 00 10
foreach num of local x{
	cd $data/zbp
	u zip`num'detail, clear
	g lastdigit=substr(naics,6,1)
	drop if lastdigit=="-"
	g naics_5=substr(naics,1,5)
	keep if naics_5=="71394"
	collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
	cd $data/temp_files
	save gym`num',replace		
}


***************************
*** Personal Care Services:
***************************


cd $data/zbp
u zip94detail, clear
keep if sic=="7230" | sic=="7240" | sic=="7299"
collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
cd $data/temp_files
save personal94, replace


/* Se genera un loop para optimizar el proceso que se estaba haciendo anteriormente */
local x 00 10
foreach num of local x{
		cd $data/zbp
	u zip`num'detail, clear
	g lasttwodigit=substr(naics,5,2)
	g lastdigit=substr(naics,6,1)
	drop if lasttwodigit=="--"
	drop if lastdigit=="-"
	g naics_4=substr(naics,1,4)
	keep if naics_4=="8121"
	collapse (sum) est n1_4 n5_9 n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000,by(zip)
	cd $data/temp_files
	save personal`num',replace		
}


/* Se está pasando la información de cada base de datos de zip code a census tract considerando establecimientos con alto número de empleados (más de 10) o bajo número de empleados (menos de 10). Se está realizando cogiendo la información del tract que queda 1 milla a la redonda y cogiendo el zip code más cercano al tract */
*************************************+*************************************+**

/* Se genera un loop para optimizar el proceso que se estaba haciendo anteriormente */
local i "restaurant grocery personal"
local j 94 00 10
foreach x of local i{
	foreach y of local j{
		cd $data/temp_files
		u `x'`y', clear
		egen est_small= rowtotal(n1_4 n5_9)
		egen est_large= rowtotal(n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000)
		keep zip est_small est_large
		cd $data/geographic
		if `y' == 94{
			merge 1:m zip using tract1990_zip1990_1mi
		}
		else if `y' == 00{
			merge 1:m zip using tract1990_zip2000_1mi	
		}
		else if `y' == 10{
			merge 1:m zip using tract1990_zip2010_1mi
		}
		keep if _merge==3
		drop _merge
		capture collapse (sum) est_small est_large, by(gisjoin)
		cd $data/temp_files
		save tract_`x'`y', replace

		cd $data/geographic
		if `y' == 94{
			u tract1990_zip1990_nearest, clear
		}
		else if `y' == 00{
			u tract1990_zip2000_nearest, clear	
		}
		else if `y' == 10{
			u tract1990_zip2010_nearest, clear
		}
		cd $data/temp_files
		merge m:1 zip using `x'`y'
		egen est_small= rowtotal(n1_4 n5_9)
		egen est_large= rowtotal(n10_19 n20_49 n50_99 n100_249 n250_499 n500_999 n1000)
		keep gisjoin est_small est_large
		capture collapse (sum) est_small_nearest=est_small est_large_nearest=est_large, by(gisjoin)
		merge 1:1 gisjoin using tract_`x'`y'
		drop _merge
		replace est_small=est_small_nearest if est_small==.
		replace est_large=est_large_nearest if est_large==.
		keep gisjoin est_small est_large
		drop if gisjoin==""
		save tract_`x'`y', replace		
	}	
}

/* Se genera un loop para optimizar el proceso que se estaba haciendo anteriormente */
local y 94 00 10
foreach j of local y{
	cd $data/temp_files
	display "gym"
	u gym`j', clear
	keep zip est
	cd $data/geographic
	if `j' == 94{
		merge 1:m zip using tract1990_zip1990_1mi
		}
	else if `j' == 00{
		merge 1:m zip using tract1990_zip2000_1mi	
		}
	else if `j' == 10{
		merge 1:m zip using tract1990_zip2010_1mi
		}
	keep if _merge==3
	drop _merge
	capture collapse (sum) est, by(gisjoin)
	cd $data/temp_files
	save tract_gym`j', replace

	cd $data/geographic
	if `j' == 94{
		u tract1990_zip1990_nearest, clear
	}
	else if `j' == 00{
		u tract1990_zip2000_nearest, clear	
		}
	else if `j' == 10{
		u tract1990_zip2010_nearest, clear
		}
	cd $data/temp_files
	merge m:1 zip using gym`j'

	keep gisjoin est
	capture collapse (sum) est_nearest=est, by(gisjoin)
	merge 1:1 gisjoin using tract_gym`j'
	drop _merge
	replace est=est_nearest if est==.
	keep gisjoin est
	drop if gisjoin==""
	save tract_gym`j', replace
}	


/* Se están juntando todas las bases que se crearon en una base para cada tipo de servicio: */
*************************************+*************************************+**

/* Se genera un loop para optimizar el proceso que se estaba haciendo anteriormente */
local i "restaurant grocery personal"
foreach x of local i{
	display "`x'"
	cd $data/temp_files
	u tract_`x'94, clear
	ren est_small est_small_`x'1990
	ren est_large est_large_`x'1990

	merge 1:1 gisjoin using tract_`x'00
	drop _merge
	ren est_small est_small_`x'2000
	ren est_large est_large_`x'2000

	merge 1:1 gisjoin using tract_`x'10
	drop _merge
	ren est_small est_small_`x'2010
	ren est_large est_large_`x'2010

	save tract_`x', replace	
}

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


/* Se están juntando todas las bases que se crearon en una base: */
*************************************+*************************************+**

u tract_restaurant, clear

merge 1:1 gisjoin using tract_grocery
drop _merge
merge 1:1 gisjoin using tract_gym
drop _merge
merge 1:1 gisjoin using tract_personal
drop _merge


sort gisjoin
save tract_amenities, replace


/* Se juntan las bases que contienen información de la población en 1990 y 2010 para cada tract, la población de altas habilidades a una milla a la redonde del tract */
*************************************+*************************************+**

cd $data/geographic
u tract1990_tract1990_2mi, clear

keep if dist<=1610
cd $data/temp_files
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


cd $data/temp_files
merge m:1 gisjoin using skill_pop_1mi
keep if _merge==3
drop _merge

/* Se juntan con la base que computa la variable instrumental para el ratio de habilidad, con la base creada anteriormente de las amenidades y la que combina información del tract con la del área metropolitana*/
*************************************+*************************************+**

cd $data/temp_files/iv
merge m:1 gisjoin using ingredient_for_iv_amenity
keep if _merge==3
drop _merge


collapse (sum) population1990 population2010 impute2010_high impute2010_low impute1990_high impute1990_low sim1990_high sim1990_low sim2010_high sim2010_low, by(gisjoin)

cd $data/temp_files

merge 1:1 gisjoin using tract_amenities
keep if _merge==3
drop _merge

cd $data/geographic

merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

/*Se generan las variables que representan la transformación logarítmica de las variables de amenidades (solo con altas habilidades, con bajas amenidades o en general) con alto número o bajo número de empleados por cada 1000 residentes. Esto hace para evaluar como fue el cambio en el tiempo del número de establecimientos: */ 
*************************************+*************************************+**

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


/*Se generan las variables que representan el cambio del número de habitantes en ocupaciones de altas habilidades respecto a bajas habilidades sumado a nivel tract que se encuentran a una milla del tract : */
*************************************+*************************************+**

g dratio=ln((impute2010_high+1)/(impute2010_low+1))-ln((impute1990_high+1)/(impute1990_low+1))

g dratio_sim=ln(sim2010_high/sim2010_low)- ln(sim1990_high/sim1990_low)
g dln_sim_high=ln(sim2010_high)- ln(sim1990_high)
g dln_sim_low=ln(sim2010_low)- ln(sim1990_low)

duplicates drop gisjoin, force
cd $data/temp_files
egen tract_id=group(gisjoin)

save data_matlab, replace

*************************************+*************************************+**
/* Tabla 1 */
*************************************+*************************************+**

*****************************
* Column (1-4) of Table 1
*****************************

/*Se hace una regresión entre las amenidades del barrio y el cambio del número de habitantes en ocupaciones de altas habilidades respecto a bajas habilidades sumado a nivel tract. Se están utilizando efectos fijos de área metropolitana para controlar por todas las características no observables invariantes en el tiempo del área. Estas indican que manteniendo constante las características del área invariantes, la relación de aumentar la proporción de personas calificadas en el tract en el crecimiento de las amenidades es positivo. Se utilizan errores estándares robustos por posible heterocedasticidad de los errores estándares. El autor utiliza para el crecimiento de la habilidad el valor imputado de la proporción de población por ocupación para cada tract que tienen altas o bajas habilidades respecto al valor para cada MSA. Este valor se imputó multiplicando el número de personas en cada grupo de ocupación por la proporción de personas que trabajan en cada ocupación dentro del grupo de ocupación al que pertenecen (ver data prep location choice). */
*************************************+*************************************+**

cd $data/temp_files

u data_matlab, clear

*Se etiquetan a las variables:
label variable d_restaurant "Restaurants per 1,000 residents"
label variable d_grocery "Grocery Store per 1,000 residents"
label variable d_gym "Gyms per 1,000 residents"
label variable d_personal "Personal serv. estab. per 1,000 residents"
label variable dratio "$\Delta$ ln(skill ratio)"

est clear

*Se estiman los resultados y se adicionan a la tabla en formato .tex:
cd $table/table
eststo: reghdfe d_restaurant dratio, absorb(metarea) vce(robust)
estadd local OBS "19291"
estadd local FE "Yes" 

eststo: reghdfe d_grocery dratio, absorb(metarea) vce(robust)
estadd local OBS "19291"
estadd local FE "Yes"

eststo: reghdfe d_gym dratio, absorb(metarea) vce(robust)
estadd local OBS "19291"
estadd local FE "Yes"

eststo: reghdfe d_personal dratio, absorb(metarea) vce(robust)
estadd local OBS "19291"
estadd local FE "Yes"

/* esttab using "table1.tex", replace b(3) se(3) nocon nostar scalars("FE MSA Fixed Effects") r2 obslast nogaps label alignment(D{.}{.}{-1}) mgroups("Dependent variable: ∆ln(measurement of the selected amenity)", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cline{@span})) title("Relationship Between Local Skill Ratio and Supply of Local Amenities") nonotes addnotes("Notes: Results shown above are OLS regressions, with sample from all MSAs. Each observation for columns 1–4" "is at the census tract level. For each census tract, I sum up all the relevant business establishments located within" "a one-mile radius of zip code centroids. Then, I sum up the population in census tracts located within 1 mile and" "compute the count of establishments per 1,000 residents. The skill ratio is computed as the ratio of the number of" "workers in high-skilled occupations and the number of workers in low-skilled occupations summed over all" "census tracts within one mile of each census tract. Each observation for columns 5–6 is a municipality. To compute log" "crime rate, I add 0.1 to avoid taking log over zero crime rate. To compute skill ratio for 5–6, I match census tracts" "to municipalities and compute the overall skill ratio using variables summed over across census tracts matched to" "municipalities. Robust standard errors are reported in parentheses.") */

*************************************+*************************************+**
/* Data Cleaning Crime Amenity*/
*************************************+*************************************+**

cd $data/crime
import delimited crime_place2013_tract1990.csv , varnames(1) clear

keep gisjoin crime_violent_rate1990 crime_property_rate1990 crime_violent_rate2010 crime_property_rate2010 gisjoin_1

ren gisjoin gisjoin_muni
ren gisjoin_1 gisjoin

cd $data/temp_files

merge 1:1 gisjoin using population1990
keep if _merge==3
drop _merge

merge 1:1 gisjoin using population2010
keep if _merge==3
drop _merge

cd $data/temp_files

merge 1:1 gisjoin using skill_pop
keep if _merge==3
drop _merge

cd $data/temp_files/iv
merge m:1 gisjoin using ingredient_for_iv_amenity
drop if _merge==2
drop _merge

cd $data/geographic

merge m:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge


collapse (sum) impute2010_high impute2010_low impute1990_high impute1990_low population population2010 sim1990_high sim1990_low sim2010_high sim2010_low (mean) crime_violent_rate* crime_property_rate* , by(gisjoin_muni metarea)


*************************************+*************************************+**
/* Tabla 1 */
*************************************+*************************************+**


/* Se generan los ratios para la variable independiente y el instrumento del cambio del ratio de los altamente calificados respecto a los no calificados  */
*************************************+*************************************+**


g dratio=ln((impute2010_high+1)/(impute2010_low+1))-ln((impute1990_high+1)/(impute1990_low+1))
g dratio_sim=ln(sim2010_high/sim2010_low)- ln(sim1990_high/sim1990_low)
g dviolent=ln( crime_violent_rate2010+0.1)-ln( crime_violent_rate1990+0.1)
g dproperty=ln( crime_property_rate2010+0.1)-ln( crime_property_rate1990+0.1)


g dln_sim_high=ln(sim2010_high)- ln(sim1990_high)
g dln_sim_low=ln(sim2010_low)- ln(sim1990_low)

*****************************
* Column (5-6) of Table 1
*****************************

/* El autor está realizando una regresión entre el cambio en la tasa de crimen y el cambio en la tasa de crimen de propiedad entre 2010 y 1990 respecto al cambio en el ratio de la población con calificación alta o baja ponderando por la población de 1990 si la variable instrumental es diferente a missing. Se utiliza efectos fijos de área metropolitana y errores estándares robustos.  */
*************************************+*************************************+**

*Se etiquetan a las variables:
label variable dproperty "Property Crime per 1,000 residents"
label variable dviolent "Violent Crime per 1,000 residents"
label variable dratio " $\Delta$ ln(skill ratio)"

cd $table/table
eststo:reghdfe dproperty dratio [w=population] if dln_sim_high!=., absorb(metarea) vce(robust)
estadd local OBS "1870"
estadd local FE "Yes"

eststo: reghdfe dviolent dratio [w=population] if dln_sim_high!=., absorb(metarea)  vce(robust)
estadd local OBS "1870"
estadd local FE "Yes"


esttab using "table1.tex", replace b(3) se(3) nocon nostar scalars("FE MSA Fixed Effects" "OBS Observations") r2 noobs label mgroups("Dependent variable: $\Delta$ ln(measurement of the selected amenity)", pattern(0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cline{@span}))  nonotes title("Relationship Between Local Skill Ratio and Supply of Local Amenities") mtitles("\shortstack{Restaurants\\per 1,000\\residents}" "\shortstack{Grocery Store\\per 1,000\\residents}""\shortstack{Gyms\\per 1,000\\residents}" "\shortstack{Personal serv.\\estab. per 1,000\\residents}" "\shortstack{Property crime\\per 1,000\\residents}" "\shortstack{Violent crime\\per 1,000\\residents}") addnotes("Notes: Results shown above are OLS regressions, with sample from all MSAs. Each observation for columns 1–4 is at the census tract level. For each census" "tract, I sum up all the relevant business establishments located within a one-mile radius of zip code centroids. Then, I sum up the population in census" "tracts located within 1 mile and compute the count of establishments per 1,000 residents. The skill ratio is computed as the ratio of the number of workers in high-" "skilled occupations and the number of workers in low-skilled occupations summed over all census tracts within one mile of each census tract. Each observa-" "tion for columns 5–6 is a municipality. To compute log crime rate, I add 0.1 to avoid taking log over zero crime rate. To compute skill ratio for 5–6, I match" "census tracts to municipalities and compute the overall skill ratio using variables summed over across census tracts matched to municipalities. Robust stand-" "ard errors are reported in parentheses.")

*************************************+*************************************+**
/* Tabla 6 */
*************************************+*************************************+**


cd $data/temp_files

u data_matlab, clear

*Se etiquetan a las variables:
label variable d_restaurant "Restaurants per 1,000 residents"
label variable d_grocery "Grocery Store per 1,000 residents"
label variable d_gym "Gyms per 1,000 residents"
label variable d_personal "Personal serv. estab. per 1,000 residents"
label variable dratio "$\Delta$ ln(skill ratio)"

est clear

*Se estiman los resultados y se adicionan a la tabla en formato .tex:
cd $table/table
*****************************
* Column (1-4) of Table 6
*****************************
/*Se hace una regresión entre las amenidades del barrio y el cambio del número de habitantes en ocupaciones de altas habilidades respecto a bajas habilidades sumado a nivel tract. Se están utilizando efectos fijos de área metropolitana y se utilizan errores estándares robustos por posible heterocedasticidad de los errores estándares. El autor instrumenta la variable independiente con su variable instrumental ya que quiere evaluar cual es el efecto de que las personas migren al tract por cambios en el valor del tiempo y ubicación de sus trabajos, y no por otras razones. Se observa que en este caso instrumenta con el crecimiento de altas habilidades y el crecimiento de bajas habilidades por separado. No se comprende muy bien porque tomo esta decisión en vez de instrumentar con el valor simulado que calcula el cambio en la proporción en el tiempo (drtio). Tampoco se comprende muy bien si el comando ivreghdfe ya está teniendo en cuenta que la estimación se pretende hacer por GMM o si se está corriendo con una regresión lineal. Se sugiere que el autor aclare esto ya que haciendo una busqueda de internet no aparece como sería el comando si se quisiera utilizar otro modelo diferente. Al no tenerse mucho conocimiento del método GMM, no se sabe si el estimador puede seguir siendo endógeno porque asentarse cerca a su trabajo y mayores amenidades pueden estar relacionadas con el valor de la renta por ejemplo. */
*************************************+*************************************+**

eststo: ivreghdfe d_restaurant (dratio=dln_sim_high dln_sim_low), absorb(metarea) robust
estadd local OBS "19291"
estadd local FE "Yes"

eststo: ivreghdfe d_grocery (dratio=dln_sim_high dln_sim_low), absorb(metarea) robust
estadd local OBS "19291"
estadd local FE "Yes"

eststo: ivreghdfe d_gym (dratio= dln_sim_high dln_sim_low), absorb(metarea) robust
estadd local OBS "19291"
estadd local FE "Yes"

eststo: ivreghdfe d_personal (dratio= dln_sim_high dln_sim_low), absorb(metarea) robust
estadd local OBS "19291"
estadd local FE "Yes"



*************************************+*************************************+**
/* Data Cleaning Crime Amenity*/
*************************************+*************************************+**

cd $data/crime
import delimited crime_place2013_tract1990.csv , varnames(1) clear

keep gisjoin crime_violent_rate1990 crime_property_rate1990 crime_violent_rate2010 crime_property_rate2010 gisjoin_1

ren gisjoin gisjoin_muni
ren gisjoin_1 gisjoin

cd $data/temp_files

merge 1:1 gisjoin using population1990
keep if _merge==3
drop _merge

merge 1:1 gisjoin using population2010
keep if _merge==3
drop _merge

cd $data/temp_files

merge 1:1 gisjoin using skill_pop
keep if _merge==3
drop _merge

cd $data/temp_files/iv
merge m:1 gisjoin using ingredient_for_iv_amenity
drop if _merge==2
drop _merge

cd $data/geographic

merge m:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge


collapse (sum) impute2010_high impute2010_low impute1990_high impute1990_low population population2010 sim1990_high sim1990_low sim2010_high sim2010_low (mean) crime_violent_rate* crime_property_rate* , by(gisjoin_muni metarea)


*************************************+*************************************+**
/* Tabla 6 */
*************************************+*************************************+**


/* Se generan los ratios para la variable independiente y el instrumento del cambio del ratio de los altamente calificados respecto a los no calificados  */
*************************************+*************************************+**


g dratio=ln((impute2010_high+1)/(impute2010_low+1))-ln((impute1990_high+1)/(impute1990_low+1))
g dratio_sim=ln(sim2010_high/sim2010_low)- ln(sim1990_high/sim1990_low)
g dviolent=ln( crime_violent_rate2010+0.1)-ln( crime_violent_rate1990+0.1)
g dproperty=ln( crime_property_rate2010+0.1)-ln( crime_property_rate1990+0.1)


g dln_sim_high=ln(sim2010_high)- ln(sim1990_high)
g dln_sim_low=ln(sim2010_low)- ln(sim1990_low)

*****************************
* Column (5-6) of Table 6
*****************************

/*En este caso el autor está realizando la misma estimación pero instrumentando la variable independiente por el cambio en el tiempo de la población con altas habilidades y el cambio en el tiempo de la población con bajas habilidades. Pondera, utiliza los mismos efectos fijos y errores estándares robustos por si hay heterocedasticidad de los errores. */

*Se etiquetan a las variables:
label variable dproperty "Property Crime per 1,000 residents"
label variable dviolent "Violent Crime per 1,000 residents"
label variable dratio " $\Delta$ ln(skill ratio)"

cd $table/table
eststo: ivreghdfe dproperty (dratio=dln_sim_high dln_sim_low) [w=population] , absorb(metarea) robust
estadd local OBS "1870"
estadd local FE "Yes"

eststo: ivreghdfe dviolent (dratio=dln_sim_high dln_sim_low) [w=population], absorb(metarea) robust
estadd local OBS "1870"
estadd local FE "Yes"


esttab using "table6.tex", replace b(3) se(3) nocon nostar scalars("FE MSA Fixed Effects" "OBS Observations") noobs label mgroups("Dependent variable: $\Delta$ ln(measurement of the selected amenity)", pattern(1 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cline{@span}))  nonotes title("Estimates for Amenity Supply Equations") mtitles("\shortstack{Restaurants\\per 1,000\\residents}" "\shortstack{Grocery Store\\per 1,000\\residents}""\shortstack{Gyms\\per 1,000\\residents}" "\shortstack{Personal serv.\\estab. per 1,000\\residents}" "\shortstack{Property crime\\per 1,000\\residents}" "\shortstack{Violent crime\\per 1,000\\residents}") addnotes("Notes: Results shown above are GMM/IV regressions, with sample from all MSAs. I use the change in log number of high-skilled workers and" "change in log number of low-skilled workers predicted by expected commute time and change of value of time as instrumental variables for the" "change in skill ratio. Each observation for columns 1–4 is at census tract level. For each census tract, I sum up all the relevant business establish-" "ments located within a one-mile radius. Then, I sum up the population in census tracts located within 1 mile and compute the count of establishments per 1,000 residents. The skill ratio is computed as the ratio of the number of workers in high-skilled occupations and the number of work-" "ers in low-skilled occupations summed over all census tracts within one mile of each census tract. Each observation for columns 5–6 is a muni-" "cipality. To compute log crime rate, I add 0.1 to avoid taking log over zero crime rate. To compute skill ratio for 5–6, I match census tracts to" "municipalities and compute the skill ratio using variables summed over across census tracts matched to municipalities. Robust standard errors" "are reported.")

  
/* Se adiciona el código para exportar las tablas. Se observa que el autor hace las estimaciones con los comandos reghdfe y ivreghdfe. Con este comando no es posible hacer estimaciones por el método generalizado de momentos que es 
el método que el afirma utilizar en su paper. Esto puede ser porque el método de momentos en algunos casos es similar a una estimación por mínimos cuadrados ordinarios. Sin embargo, es importante que el autor aclare esto en su apéndice. La documentación del comando ivreghdfe no es lo suficientemente completa. */

*************************************+*************************************+** 
*************************************+*************************************+***
**# Output -  Motivation
*************************************+*************************************+***
*************************************+*************************************+***

/* Se comenta solo para la tabla 3 del paper.*/

*************************************+*************************************+***
** Generación de variables necesarias para la estimación
*************************************+*************************************+***


cd $data/ipums_micro
u 1990_2000_2010_temp , clear

** Se mantienen horas de trabajo mayores a 30, hombres, entre 25 y 60, y solo se mantienen las observaciones para los años 1990 y 2010. 
keep if uhrswork>=30

keep if sex==1
keep if age>=25 & age<=65
keep if year==1990 | year==2010

** Se limpia la base:
drop wage distance tranwork trantime pwpuma ownershp ownershpd gq
drop if uhrswork==0
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999



** Está trayendo los salarios nominales de 1990 y 2000 en términos de salarios reales del 2010:

/*
IPC 1990 USA: 130.7
IPC 2000 USA: 172.2
IPC 2010 USA: 218.056 
*/

/* Se recomienda definir el significado de los valores de las siguientes tres líneas de código a priori, ya que no se sabía que hacía referencia a los IPC para Estados Unidos */
g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010

** Se divide entre 52 el ingreso total ya que se quiere saber cual es el ingreso semanal de los individuos. 
replace inctot_real=inctot_real/52

** Se genera una dummy que represente si la persona trabaja más de 50 horas a la semana. Para cada ocupación se define cual es el promedio de personas que trabajan más de 50 horas a la semana. 
g greaterthan50=0
replace greaterthan50=1 if uhrswork>=50
collapse greaterthan50, by(year occ2010)

** Se almacena ese promedio para cada año dependiendo de las deficiones de la ocupación para 2010:
reshape wide greaterthan50, i(occ2010) j(year)

** Se genera variable que indique cual fue el cambio en el promedio de personas que trabajaron en el 2010 respecto a 1990 más de 50 horas a la semana.
g ln_d=ln( greaterthan502010)-ln( greaterthan501990)

** Se junta con base que identifica ingresos por ocupación:
cd $data/temp_files
merge 1:1 occ2010 using inc_occ_1990_2000_2010
drop _merge

** Se limpia la base:
drop inc_mean1990 inc_mean2000 inc_mean2010 wage_real1990 wage_real2000 wage_real2010

cd $data/temp_files

** Se junta con la base que almacena el valor de una hora extra para cada ocupación: 
merge 1:1 occ2010 using val_40_60_total_1990_2000_2010
drop _merge

**Variable que representa el cambio del valor del tiempo entre 2010 y 1990.
g dval=val_2010-val_1990

cd $data/temp_files
save reduced_form, replace

*************************************+*************************************+***
** Generación de variables necesarias para la estimación
*************************************+*************************************+***

** Skill ratio para cada tract: 
cd $data/temp_files
u tract_impute.dta, clear

** Identificación de tracts a menos de 5 millas del centro:
cd $data/geographic
merge m:1 gisjoin using tract1990_downtown5mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge

** Ranking de población de área metropolitana:
cd $data/geographic
merge m:1 metarea using 1990_rank
keep if _merge==3
drop _merge

drop serial year

** Se suman los valores de acuerdo con ocupación, área metropolitana, si se está cerca o lejos del centro y el rank de la población del área metropolitana a comparación de las otras áreas metropolitanas: 
collapse (sum) impute1990 impute2000 impute2010, by(occ2010 metarea rank downtown)

** Proporción del ratio de esa área en el centro por ocupación respecto al ratio de esa área en los suburbios por ocupación para cada año: 
by occ2010 metarea: g ratio1990=impute1990/(impute1990+impute1990[_n-1])
by occ2010 metarea: g ratio2000=impute2000/(impute2000+impute2000[_n-1])
by occ2010 metarea: g ratio2010=impute2010/(impute2010+impute2010[_n-1])

keep occ2010 metarea downtown ratio1990 ratio2000 ratio2010 rank

** Se genera el cambio en la proporción encontrada antes:
g dratio=ln(ratio2010)-ln(ratio1990)

** Se pega con base que se generó anteriormente: 
cd $data/temp_files
merge m:1 occ2010 using reduced_form
keep if _merge==3
drop _merge
drop count*

** Se pega con base tiene la población para cada área metropolitana
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge 

save table_2_3.dta, replace

**** Change in central city share on change in long hours

*************************************+*************************************+***
** Generación de variables necesarias para la estimación
*************************************+*************************************+***

**** Commute time on change in long hours

cd $data/ipums_micro
u 1990_2000_2010_temp , clear

** Se mantienen horas de trabajo mayores a 30, hombres, entre 25 y 60, y solo se mantienen las observaciones para los años 1990 y 2010. 
keep if uhrswork>=30

keep if sex==1
keep if age>=25 & age<=65
keep if year==1990 | year==2010

** Se hace la transformación logaritmica del tiempo de transporte y se agrupa a nivel ocupación, área metropolitana, tamaño del área metropolitana por la cantidad de población y año.
replace trantime=ln(trantime)
collapse trantime, by(year occ2010 metarea rank)
reshape wide trantime, i(occ2010 metarea) j(year)

** Se genera la diferencia de tiempo de transporte entre ambos periodos de tiempo.
g dtran= trantime2010-trantime1990

** Se pega con base generada anteriormente:
cd $data/temp_files
merge m:1 occ2010 using reduced_form
drop _merge

** Se pega con base que tiene número de población para cada área metropolitana: 
drop count*
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

save table_2_3_2.dta, replace

*************************************+*************************************+***
** Tabla 2
*************************************+*************************************+***
clear all
use table_2_3.dta, clear

label variable ln_d " $\Delta$ ln(pct long-hour)"


* Column 1 - 3 

/* 
*Regresión entre el cambio en el tiempo de la proporción relativa del ratio de altas vs bajas habilidades entre el centro y los suburbios con el cambio en el valor del tiempo: 
*Utiliza efectos fijos de área metropolitana
*Pondera por la población del área metropolitana de 1990.
*Lo hace solo para aquellas observaciones que se ubican a menos de 5 millas del centro.
*Lo hace para las 10 ciudades más grandes o las 25 ciudades más grandes.
*Agrupa los errores estándar a nivel área metropolitana ya que cree que los errores dentro del área metropolitana para las observaciones podrían estar correlacionados. 
*/

eststo: ivreghdfe dratio ln_d [ w=count1990] if dval!=. & rank<=10 & downtown==1, absorb(metarea, savefe) vce(cl metarea)
estadd local FE "\multicolumn{3}{c}{MSA}"
estadd local Tab "\multicolumn{3}{c}{MSA/occupation}"
estadd local SE "\multicolumn{3}{c}{Cluster at MSA}"

eststo: ivreghdfe dratio ln_d [ w=count1990] if dval!=. & rank<=25 & downtown==1, vce(cl metarea) absorb(metarea, savefe) 


eststo: ivreghdfe dratio ln_d [ w=count1990] if dval!=. & downtown==1, vce(cl metarea) absorb(metarea, savefe) 

use table_2_3_2.dta, clear

label variable ln_d " $\Delta$ ln(pct long-hour)"

/* 
*Se está haciendo una regresión entre el cambio en el tiempo de transporte y el cambio en el valor del tiempo ponderado por la cantidad de población de 1990.
*Se utiiliza efectos fijos de área metropolitana.
*Se hace para las 10 ciudades con mayor población o para las 25 ciudades con mayor población.
*Se agrupan los errores estándares a nivel área metropolitana porque asume que los errores se autocorrelacionan entre ocupaciones (puede que algo que explique el tiempo de transporte de una ocupación no observable también explique el tiempo de otra. Ejemplo: el trancón afecta el tiempo de transporte de ambas ocupaciones).
*/

* Column 4-6 
eststo: ivreghdfe dtran ln_d [w=count1990] if dval!=. & rank<=10, vce(cl metarea) absorb(metarea, savefe) 
estadd local FE "&\multicolumn{3}{c}{MSA}"
estadd local Tab "\multicolumn{3}{c}{MSA/occupation}"
estadd local SE "\multicolumn{3}{c}{Cluster at MSA}"

eststo: ivreghdfe dtran ln_d [w=count1990] if dval!=. & rank<=25, vce(cl metarea) absorb(metarea, savefe) 


eststo: ivreghdfe dtran ln_d [w=count1990] if dval!=., vce(cl metarea) absorb(metarea, savefe) 



esttab using "table2.tex", replace b(3) se(3)  nocon nostar label mgroups("$\Delta$ ln(share in central city)" "$\Delta$ ln(reported commuting time)", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) nonotes title("Workers in Increasingly Long-Hour Occupations Increasingly Live in the Central Cities" "and Have Slower Growth in Commuting Time") scalars("FE Fixed Effects" "Tab Tabulation" "SE SE") mtitles("\shortstack{Largest 10\\ MSAs}" "\shortstack{Largest 25\\ MSAs}""\shortstack{All MSAs}" "\shortstack{Largest 10\\ MSAs}" "\shortstack{Largest 25\\ MSAs}" "\shortstack{All MSAs}") keep(ln_d) addnotes("Notes: Results shown above are OLS regressions, with tabulated cells by MSA and occupation. I compute the share in central city" "by computing the percentage of workers in each occupation in each MSA who live within five-mile radius of downtown pin (Holian" "and Kahn 2015). The percentage of long hour is defined as the share of workers within each occupation who work at least 50 hours a week." "The regressions are conducted by taking the first differ- ence between data in 2010 and 1990. MSA fixed effects are included. Standard" "errors are clustered at MSA level.")


*************************************+*************************************+***
** Tabla 3
*************************************+*************************************+***
clear all
cd $data/temp_files
u reduced_form, clear
label variable ln_d " $\Delta$ ln(pct long-hour)"
label variable dval " $\Delta$ LHP"

* Column 1: cambio del valor del tiempo respecto al cambio en el promedio de personas que trabajaron en el 2010 respecto a 1990 más de 50 horas a la semana.
*Errores estándares robustos, ponderado por la población en cada ocupación
eststo: ivreghdfe ln_d dval [w=count1990] if dval!=., vce(robust)
estadd local FE "NA"
estadd local Tab "Occupation"
estadd local SE "Robust"

* Column 2-4

use table_2_3.dta, clear
label variable ln_d " $\Delta$ ln(pct long-hour)"
label variable dval " $\Delta$ LHP"

/* 
*Regresión entre el cambio en el tiempo de la proporción relativa del ratio de altas vs bajas habilidades entre el centro y los suburbios con el cambio en el valor del tiempo: 
*Utiliza efectos fijos de área metropolitana
*Pondera por la población del área metropolitana de 1990.
*Lo hace solo para aquellas observaciones que se ubican a menos de 5 millas del centro.
*Lo hace para las 10 ciudades más grandes o las 25 ciudades más grandes.
*Agrupa los errores estándar a nivel área metropolitana ya que cree que los errores dentro del área metropolitana para las observaciones podrían estar correlacionados. 
*/


eststo: ivreghdfe dratio dval [ w=count1990] if dval!=. & downtown==1 & rank<=10, vce(cl metarea) absorb(metarea) 
estadd local FE "\multicolumn{3}{c}{MSA}"
estadd local Tab "\multicolumn{3}{c}{MSA/occupation}"
estadd local SE "\multicolumn{3}{c}{Cluster at MSA}"

eststo: ivreghdfe dratio dval [ w=count1990] if dval!=. & downtown==1 & rank<=25, vce(cl metarea)  absorb(metarea) 
eststo: ivreghdfe dratio dval [ w=count1990] if dval!=. & downtown==1, vce(cl metarea)  absorb(metarea) 

* Column 5-7 

/* 
*Se está haciendo una regresión entre el cambio en el tiempo de transporte y el cambio en el valor del tiempo ponderado por la cantidad de población de 1990.
*Se utiiliza efectos fijos de área metropolitana.
*Se hace para las 10 ciudades con mayor población o para las 25 ciudades con mayor población.
*Se agrupan los errores estándares a nivel área metropolitana porque asume que los errores se autocorrelacionan entre ocupaciones (puede que algo que explique el tiempo de transporte de una ocupación no observable también explique el tiempo de otra. Ejemplo: el trancón afecta el tiempo de transporte de ambas ocupaciones).
*/
use table_2_3_2.dta, clear
label variable ln_d "$\Delta$ ln(pct long-hour)"
label variable dval "$\Delta$ LHP"

eststo: ivreghdfe dtran dval [w=count1990] if dval!=. & rank<=10, absorb(metarea)  vce(cl metarea) 
estadd local FE "\multicolumn{3}{c}{MSA}"
estadd local Tab "\multicolumn{3}{c}{MSA/occupation}"
estadd local SE "\multicolumn{3}{c}{Cluster at MSA}"

eststo: ivreghdfe dtran  dval [w=count1990] if dval!=. & rank<=25, absorb(metarea)  vce(cl metarea) 
eststo: ivreghdfe dtran dval [w=count1990] if dval!=., absorb(metarea) vce(cl metarea) 


esttab using "table3.tex", replace b(3) se(3)  nocon nostar label mgroups("" "$\Delta$ ln(share in central city)" "$\Delta$ ln(reported commuting time)", pattern(0 1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) nonotes title("Reduced-Form Relationship between Long-Hour Premium and Long-Hour Worked, Central City Sorting, and Commuting Time") scalars("FE Fixed Effects" "Tab Tabulation" "SE SE") mtitles("\shortstack{$\Delta$ ln(pct \\ long-hour)}" "\shortstack{Largest 10\\ MSAs}" "\shortstack{Largest 25\\ MSAs}""\shortstack{All MSAs}" "\shortstack{Largest 10\\ MSAs}" "\shortstack{Largest 25\\ MSAs}" "\shortstack{All MSAs}") keep(dval) addnotes("Notes: Results shown above are OLS regressions, with tabulated cells. In column 1, I regress the change in the percentage of working long hours" "on the change in long-hour premium (LHP) across occupations, with each obser- vation a tabulation of occupation. From columns 2 to 7, I compute" "the share in central city by computing the percentage of workers in each occupation in each MSA who live within five-mile radius of downtown pin" "(Holian and Kahn, 2015). The percentage of long hour is defined as the share of workers within each occupation who work at least 50 hours a week." "The regressions in columns 2–7 are conducted by taking the first difference between data in 2010 and 1990, with each observation an MSA/occupa-" "tion tabulation. LHP denotes long-hour premium. MSA fixed effects are included. Standard errors are clustered at MSA level.")



*************************************+*************************************+****
**# Output -  Summary Statistics
*************************************+*************************************+****


clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"

**** Summary statistics

*** Rent

cd $data/temp_files
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



*************************************+*************************************+***
*************************************+*************************************+***
**# Output - Main Regression
*************************************+*************************************+***
*************************************+*************************************+***

*************************************+*************************************+***
** Cruce de bases de datos:
*************************************+*************************************+***

** residential data
cd $data/temp_files
u tract_impute_share, clear

** Commute time data
cd $data/temp_files/commute

merge 1:m gisjoin occ2010 using commute
keep if _merge==3
drop _merge

ren expected_commute expected_commute_1990

merge 1:m gisjoin occ2010 using commute2010
keep if _merge==3
drop _merge

ren expected_commute expected_commute_2010
ren expected_commute_1990 expected_commute

/*Se genera una variable que calcule la diferencia en el tiempo de viaje esperado ente 2010 y 1990. */
g dexpected=expected_commute_2010-expected_commute

*** value of time data
cd $data/temp_files
merge m:1 occ2010 using val_40_60_total_1990_2000_2010
keep if _merge==3
drop _merge

drop se_1990 se_2000

*** rent
cd $data/temp_files
merge m:1 gisjoin using rent
drop if _merge==2
drop _merge

*** instrument for location demand

	/* Número_de_la_observación Definición
	* 1: MANAGEMENT, BUSINESS, SCIENCE, AND ARTS
	* 2: BUSINESS OPERATIONS SPECIALISTS
	* 3: FINANCIAL SPECIALISTS
	* 4: COMPUTER AND MATHEMATICAL
	* 5: ARCHITECTURE AND ENGINEERING
	* 6: TECHNICIANS
	* 7: LIFE, PHYSICAL, AND SOCIAL SCIENCE
	* 8: COMMUNITY AND SOCIAL SERVICES
	* 9: LEGAL
	* 10: EDUCATION, TRAINING, AND LIBRARY
	* 11: ARTS, DESIGN, ENTERTAINMENT, SPORTS, AND MEDIA
	* 12: HEALTHCARE PRACTITIONERS AND TECHNICAL
	* 13: HEALTHCARE SUPPORT
	* 14: PROTECTIVE SERVICE
	* 15: FOOD PREPARATION AND SERVING
	* 16: BUILDING AND GROUNDS CLEANING AND MAINTENANCE
	* 17: PERSONAL CARE AND SERVICE
	* 18: SALES AND RELATED
	* 19: OFFICE AND ADMINISTRATIVE SUPPORT
	* 20: FARMING, FISHING, AND FORESTRY
	* 21: CONSTRUCTION
	* 22: EXTRACTION
	* 23: INSTALLATION, MAINTENANCE, AND REPAIR
	* 24: PRODUCTION
	* 25: TRANSPORTATION AND MATERIAL MOVING
	*/
	
	g occ_group=1 if occ2010>=10 & occ2010<=430
	replace occ_group=2 if occ2010>=500 & occ2010<=730
	replace occ_group=3 if occ2010>=800 & occ2010<=950
	replace occ_group=4 if occ2010>=1000 & occ2010<=1240
	replace occ_group=5 if occ2010>=1300 & occ2010<=1540
	replace occ_group=6 if occ2010>=1550 & occ2010<=1560
	replace occ_group=7 if occ2010>=1600 & occ2010<=1980
	replace occ_group=8 if occ2010>=2000 & occ2010<=2060
	replace occ_group=9 if occ2010>=2100 & occ2010<=2150
	replace occ_group=10 if occ2010>=2200 & occ2010<=2550
	replace occ_group=11 if occ2010>=2600 & occ2010<=2920
	replace occ_group=12 if occ2010>=3000 & occ2010<=3540
	replace occ_group=13 if occ2010>=3600 & occ2010<=3650
	replace occ_group=14 if occ2010>=3700 & occ2010<=3950
	replace occ_group=15 if occ2010>=4000 & occ2010<=4150
	replace occ_group=16 if occ2010>=4200 & occ2010<=4250
	replace occ_group=17 if occ2010>=4300 & occ2010<=4650
	replace occ_group=18 if occ2010>=4700 & occ2010<=4965
	replace occ_group=19 if occ2010>=5000 & occ2010<=5940
	replace occ_group=20 if occ2010>=6005 & occ2010<=6130
	replace occ_group=21 if occ2010>=6200 & occ2010<=6765
	replace occ_group=22 if occ2010>=6800 & occ2010<=6940
	replace occ_group=23 if occ2010>=7000 & occ2010<=7630
	replace occ_group=24 if occ2010>=7700 & occ2010<=8965
	replace occ_group=25 if occ2010>=9000 & occ2010<=9750


*** Tiempo total de viaje:
cd $data/temp_files/commute
merge m:1 gisjoin occ_group using commute_total
drop _merge

*** Variable instrumental ratio calificación población: 
cd "$data/temp_files/iv"
merge m:1 gisjoin occ_group using sim_iv
keep if _merge==3
drop _merge

*** Variable instrumental renta de vivienda: 
merge m:1 gisjoin using sim_iv_total
keep if _merge==3
drop _merge

*** Cambio porcentual de la proporción de personas que trabajan en ocupaciones que requieren alta habilidad respecto a baja habilidad entre el 2010 y 1990:
cd $data/temp_files
merge m:1 gisjoin using skill_ratio_occupation
keep if _merge==3
drop _merge

*** ranking de la población de área metropolitana basada en el census decenial de 1990:
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge

*** número de trabajadores por ocupación y área metropolitana:
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

drop if count1990==.


*** Cambio en la proporción de población por ocupación para cada tract respecto al MSA entre 2010 y 1990: 
g dimpute=ln(impute_share2010)-ln(impute_share1990)

*** Se generan tracts:
egen tract_id=group(gisjoin)

*** Se generan grupos que identifiquen cruce entre área metropolitana y ocupación y se nombra: 
egen metarea_occ=group(metarea occ2010)
drop year serial
drop  count2000 count2010

*** Cambio en el valor del long hour premium de 2010 respecto a 1990: 
g dval=val_2010-val_1990

*** Se multiplica la diferencia entre el valor del tiempo y el tiempo de viaje esperado: 
g dval_expected_commute=dval*expected_commute

*** Cambio en el valor de la renta entre 2010 y 1990:
g drent=ln(rent2010+1)-ln(rent1990+1)

ren count1990 count

*** Designación de nivel de habilidad para cada ocupación basado en que el 40% o más de la población empleada tenga título universitario: 
cd $data/temp_files
merge m:1 occ2010 using high_skill
drop if _merge==2
drop _merge

*** Unidad de densidad de vivienda en el census tract: número de viviendas /área del tract: 

/* Lo hace para mirar la oferta de vivienda: si un barrio tiene una alta densidad de estructuras existentes, el costo marginal de construir una nueva vivienda sería mayor por lo que habría una oferta más inelástica*/

cd $data/temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge


*************************************+*************************************+***
** Generación de variables:
*************************************+*************************************+***

/* El autor estandariza la variable restándole la media muestral y diviendo sobre su desviación estándar. Lo tenía con números, pero una persona que no conoce bien del tema puede no intuir el proceso. Por esto se modifica el comando para que queden claro de donde salen los números. */
sum room_density_1mi_3mi
return list
scalar mean = r(mean)
scalar sd = r(sd)
display mean, sd
replace room_density_1mi_3mi=(room_density_1mi_3mi-mean)/sd


*** Se genera variable que múltiplique por dummy que indica si la ocupación requiere altas habilidades con el cambio en el ratio entre población con alta vs baja calificación entre 2010 y 1990: 
g high_skill_dratio=high_skill*dratio

*** Se hace mismo proceso pero multiplicando con los valores simulados (aquellos que tienen en cuenta solo el valor del tiempo extra y el tiempo de viaje esperado) para altas y bajas habilidades y el total de la población en el tract:
g high_skill_dln_sim_high=high_skill* dln_sim_high
g high_skill_dln_sim_low=high_skill* dln_sim_low
g high_skill_dln_sim=high_skill*dln_sim

*** Se genera variable que multiplique la estandarización de la densidad habitacional por los valores simulados (aquellos que tienen en cuenta solo el valor del tiempo extra y el tiempo de viaje esperado) para altas y bajas habilidades y el total de la población en el tract:

/* En los últimos tres aparentemente se hizo lo mismo que en los primeros tres. Parece ser que un un punto de la codificación cambio el nombre de las variables pero al ser tantos do files en donde se generan las mismas variables múltiples veces es difícil seguir el proceso que está teniendo el autor. Se sugiere que revise la organización del paquete de replicación para que sea mucho más claro para quien quiere revisarlo saber el proceso que está siguiendo.*/
g dln_sim_density=dln_sim*room_density_1mi_3mi
g dln_sim_high_density=dln_sim_high*room_density_1mi_3mi
g dln_sim_low_density=dln_sim_low*room_density_1mi_3mi
g dln_sim_total_density=dln_sim_total*room_density_1mi_3mi
g dln_sim_high_total_density=dln_sim_high_total*room_density_1mi_3mi
g dln_sim_low_total_density=dln_sim_low_total*room_density_1mi_3mi


*** Se genera variable que multiplique el cambio del valor de la renta entre 2010 y 1990 por la dummy que indica si la ocupación requiere altas habilidades:
g high_skill_drent= high_skill*drent

*** Se hace el mismo proceso pero multiplicando con los valores simulados (aquellos que tienen en cuenta solo el valor del tiempo extra y el tiempo de viaje esperado) para altas y bajas habilidades y el total de la población en el tract:
g high_skill_dln_sim_density = high_skill*dln_sim_density
g high_skill_dln_sim_high_density= high_skill*dln_sim_high_density 
g high_skill_dln_sim_low_density =high_skill*dln_sim_low_density

*** Se genera variable que multiplique la densidad habitacional del census tract por la dummy que indica si la ocupación requiere altas habilidades:
g high_skill_room_density_1mi_3mi= high_skill*room_density_1mi_3mi

*** Se genera una variable que multiplica la dummy de ocupación por el tiempo esperado de viaje o por la diferencia entre el valor del tiempo y el tiempo de viaje esperado:
g high_skill_expected_commute=high_skill*expected_commute
g high_dval_expected_commute=high_skill*dval_expected_commute


*************************************+*************************************+***
** Variable para ecuación de la renta:
*************************************+*************************************+***


***Demanda de vivienda para cada census tract:
cd $data/temp_files
merge m:1 gisjoin using ddemand
keep if _merge==3
drop _merge

/* No se sabe de donde se genera esta base de datos ni la siguiente. Se sugiere al autor que sea explícito de donde surgió porque puede que haya sido una base generada por él en otro do-file que no aparece en el paquete de replicación */

cd $data/temp_files
merge m:1 metarea occ2010 using trantime_metarea_occ2010
drop _merge

** Se genera una variable que sea la interacción entre el tiempo de viaje esperado y la diferencia en el tiempo de transporte entre 2010 y 1990. Luego se genera una variable que multiplique esto por las ocupaciones que requieren altas habilidades: 
g dtran_expected_commute=dtran*expected_commute
g high_dtran_expected_commute= high_skill*dtran_expected_commute

** 
merge m:1 occ2010 using val_time_sd_earning_total_standard
drop _merge

merge m:1 occ2010 using val_greaterthan50
drop _merge

*** Se reemplaza una variable que sea la diferencia entre el número de personas que trabajan más de 50 horas entre 2010 y 1990 para cada ocupación:
replace ln_d=ln(greaterthan502010)-ln(greaterthan501990)

*** Se genera una variable que sea la diferencia de la desviación estándar de ingresos para cada ocupación dentro de cada tract y se multiplica con el tiempo esperado de viaje:
g dsd_expected_commute=(sd_inctot2010-sd_inctot1990)*expected_commute

*** Se multiplica la variable generada por si la ocupación requiere trabajadores con altas calificaciones:
g high_dsd_expected_commute=high_skill*dsd_expected_commute

*** Se multiplica el tiempo de viaje esperado por el cambio en el número de personas que trabajan más de 50h entre 2010y 1990.
g ln_d_expected_commute=ln_d*expected_commute

*** Se multiplica variable generada por si la ocupación requiere trabajadores con altas calificaciones: 
g high_ln_d_expected_commute=high_skill*ln_d_expected_commute

*** Se multiplica la densidad por la demanda de housing:
g ddemand_density=room_density_1mi_3mi*ddemand

cd $data/temp_files
save data, replace
 
*******************************************************************************
 *** Main specification (Table 5)
*******************************************************************************

**** Regress 
cd $data/temp_files
u data, clear 
 
***********************
 ** Panel A
*********************** 

/* El autor estima el el impacto que tiene en el cambio de la proporción de población por ocupación para cada tract respecto al MSA entre 2010 y 1990:
* El valor del tiempo por el tiempo esperado de desplazamiento (el tiempo de desplazamiento en una semana) ponderado por la distribución espacial de los trabajos de cada ocupación y esto mismo para ocupaciones con altas habilidades.
*El cambio del arriendo en el tiempo solo e interactuado con ocupaciones que requieren de altas habilidades.
*La oferta de servicios que tenga el barrio cuya proxy es el cambio en el tiempo de la proporción de trabajadores calificados respecto a poco calificados solo e interactuado con ocupaciones que requieren de altas habilidades. */


/*Utiliza como controles:
*El tiempo esperado de desplazamiento y el tiempo esperado de desplazamiento para ocupaciones con altas habilidades.
*/

/*Utiliza variables instrumentales para el cambio en el arriendo y en la proporción de trabajadores calificados respecto a poco calificados:

* Cambio en la proporción de trabajadores calificados respecto a poco calificados estimado por el valor de horas extras y el tiempo de viaje esperado para población con altas y bajas cualificaciones. 
* Lo mismo pero teniendo en cuenta la información para ocupaciones que requieren altas y bajas cualificaciones.
* Cambio en la proporción de trabajadores calificados respecto a poco calificados estimado para población con altas y bajas cualificaciones interactuado con la estandarización de la densidad de vivienda total, para altas densidades o bajas densidades para todas las ocupaciones, y ocupaciones con altas y bajas cualificaciones.
* Cambio en la estandarización de la demanda habitacional solo o interctuado con ocupaciones calificadas como que requieren altas cualificaciones
  */
  
/*  Se pondera por el número de trabajadores en cada ocupación para cada área metropolitana en 1990. 
	Se utiliza efectos fijos de área metropolitana interactuada con la ocupación (para ver el cambio en el ratio dentro de una ocupación dentro de un área metropolitana), ocupación interactuada con el cambio en el tiempo esperado de desplazamiento, ocupación interactuada con el tiempo total de viaje (para ver el cambio en el ratio dentro de una ocupación para personas cuyo cambio en el tiempo de desplazamiento y tiempo de desplazamiento fue el mismo).
	Se utiliza el método generalizado de momentos.
	Se agrupan los errores estándares a nivel census tract.
  */

*ivreghdfe es una regresión variable instrumental con múltiples niveles de efectos fijos.

  # delimit
ivreghdfe dimpute expected_commute high_skill_expected_commute dval_expected_commute high_dval_expected_commute 
(dratio high_skill_dratio drent high_skill_drent=  dln_sim_high dln_sim_low high_skill_dln_sim_high high_skill_dln_sim_low dln_sim_density dln_sim_high_density dln_sim_low_density high_skill_dln_sim_density high_skill_dln_sim_high_density high_skill_dln_sim_low_density high_skill_room_density_1mi_3mi room_density_1mi_3mi)
[w=count] , absorb(i.metarea_occ i.occ2010#c.dexpected i.occ2010#c.total_commute) cluster(tract_id) gmm2s;
 # delimit cr

 /* Se observa una congruencia con lo explicado en el paper. Se sugiere organizar de mejor forma la carpeta de replicación para que le quede más claro a la persona que está intentando hacer. De igual forma, se sugiere que el autor en el do haga una explicación más detallada de lo que está estimando en esta ecuación ya que fue difícil identificar que es lo que estaba haciendo. */

/* Realizando la estimación se observa que los coeficientes encontrados con este comando dan diferentes aquellos reportados en la tabla 5. Esto se cree puede ser porque el do está desordenado, lo que hace que la generación de variables pueda ser diferente dando diferentes resultados. Otra posibilidad es que no se sepa interpretar bien el output que muestra el comando, aunque esta es menos probable. Esta mayor diferencia entre los resultados encontrados y los resultados estimados se da en mayor medida con el coeficiente del costo de desplazamiento. Se observa que dan valores parecidos en las amenidades y la renta. */
 

/* Los siguientes comandos los utiliza para encontrar el valor de los coeficientes para el promedio de las ocupaciones que requieren empleados con bajas cualificaciones o con altas cualificaciones. */
 
/* El comando lincom hace la combinación líneal de parámetros tras obtener una estimación. */

 * Commute cost
 *********************** 
 
* High-skilled
lincom dval_expected_commute + high_dval_expected_commute
* Low-skilled
lincom dval_expected_commute


* Amenities
*********************** 

* High-skilled
lincom dratio + high_skill_dratio
* low-skilled
lincom dratio

* Rent
*********************** 

* High_skilled
lincom drent + high_skill_drent
* Low-skilled
lincom drent



*******************************************
 * Panel B:  Housing supply equation
*******************************************

/* El autor estima el el impacto que tiene en el cambio del valor de la renta entre 2010 y 1990:
* La densidad habitacional respecto al área del census tract 
* La densidad habitacional multiplicada por la diferencia en el ingreso
*/


/*Utiliza variables instrumentales para la densidad habitacional multiplicada por la diferencia en el ingreso:

*Utiliza la interacción entre la estandarización de la densidad habitacional por los valores simulados de trabajadores altamente y bajamente calificados y el total de la población en el tract (aquellos que tienen en cuenta solo el valor del tiempo extra y el tiempo de viaje esperado):
  */
  
/*  
Se pondera por el número de trabajadores en cada ocupación para cada área metropolitana en 1990. 
Se utiliza efectos fijos de área metropolitana.
Se utiliza el método generalizado de momentos.
Se agrupan los errores estándares a nivel census tract.
  */

*ivreghdfe es una regresión variable instrumental con múltiples niveles de efectos fijos.

  ivreghdfe drent room_density_1mi_3mi (ddemand_density =dln_sim_total_density dln_sim_low_total_density dln_sim_high_total_density)[w=count], absorb(i.metarea) cluster(tract_id) gmm2s

  
/* Si bien los coeficientes no son iguales, tienen valores relativamente cercanos a los presentados en el paper. Esta diferencia puede ser por diferencias en las estimaciones del método o por un problema de organización del paquete de replicación que hace que se repitan los mismos procesos en múltiples bases de datos diferentes. Si bien se sale del scope del presente trabajo de replicación, se sugiere a futuras personas que quieran replicarlo que organicen cada uno de los do-files de forma que se optimice el número de líneas de código". */  
  
 
 
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
cd $data/temp_files
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

cd $data/temp_files
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

cd $data/temp_files
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
cd $data/temp_files

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

cd $data/temp_files

merge m:1 gisjoin using skill_pop_1mi
keep if _merge==3
drop _merge

*** Merge the ingredient to compute the instrumental variable for local skill ratio
cd $data/temp_files/iv
merge m:1 gisjoin using ingredient_for_iv_amenity
keep if _merge==3
drop _merge


collapse (sum) population1990 population2010 impute2010_high impute2010_low impute1990_high impute1990_low sim1990_high sim1990_low sim2010_high sim2010_low, by(gisjoin)

cd $data/temp_files

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

cd $data/temp_files

merge 1:1 gisjoin using population1990
keep if _merge==3
drop _merge

merge 1:1 gisjoin using population2010
keep if _merge==3
drop _merge

merge 1:1 gisjoin using skill_pop
keep if _merge==3
drop _merge

cd $data/temp_files/iv
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
cd $data/temp_files
u tract_impute_share, clear

** Commute time data
cd $data/temp_files/commute

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
cd $data/temp_files
merge m:1 occ2010 using val_40_60_total_1990_2000_2010
keep if _merge==3
drop _merge

drop se_1990 se_2000

*** rent
cd $data/temp_files
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

cd $data/temp_files/commute
merge m:1 gisjoin occ_group using commute_total
drop _merge


cd $data/temp_files/iv
merge m:1 gisjoin occ_group using sim_iv
keep if _merge==3
drop _merge

merge m:1 gisjoin using sim_iv_total
keep if _merge==3
drop _merge

cd $data/temp_files
merge m:1 gisjoin using skill_ratio_occupation
keep if _merge==3
drop _merge

cd $data/geographic
merge m:1 metarea using 1990_rank
drop _merge

cd $data/temp_files
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

cd $data/temp_files
merge m:1 occ2010 using high_skill_30
drop if _merge==2
drop _merge


cd $data/temp_files
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
cd $data/temp_files
merge m:1 gisjoin using ddemand
keep if _merge==3
drop _merge

cd $temp_files
save data_30, replace

**** Regress 
cd $data/temp_files
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
cd $data/temp_files
u tract_impute_share, clear

** Commute time data
cd $data/temp_files/commute

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
cd $data/temp_files
merge m:1 occ2010 using val_40_60_total_1990_2000_2010
keep if _merge==3
drop _merge

drop se_1990 se_2000

*** rent
cd $data/temp_files
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

cd $data/temp_files/commute
merge m:1 gisjoin occ_group using commute_total
drop _merge


cd $data/temp_files/iv
merge m:1 gisjoin occ_group using sim_iv
keep if _merge==3
drop _merge

merge m:1 gisjoin using sim_iv_total
keep if _merge==3
drop _merge

cd $data/temp_files
merge m:1 gisjoin using skill_ratio_occupation
keep if _merge==3
drop _merge

cd $data/geographic
merge m:1 metarea using 1990_rank
drop _merge

cd $data/temp_files
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

cd $data/temp_files
merge m:1 occ2010 using high_skill_50
drop if _merge==2
drop _merge


cd $data/temp_files
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
cd $data/temp_files
merge m:1 gisjoin using ddemand
keep if _merge==3
drop _merge

cd $temp_files
save data_50, replace

**** Regress 
cd $data/temp_files
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


*************************************+*************************************+***
**# Output - Counterfactual Main
*************************************+*************************************+***

*************************************+*************************************+***
** Se generan variables necesarias para el análisis:
*************************************+*************************************+***

*** create counterfatual location share in 2010

** Base de probabilidad de ocupación de los trabajadores de la ocupación para cada MSA:
cd $data/temp_files
u tract_impute_share, clear

** Se junta con la base del valor del tiempo de 1990 utilizando el valor estimado por la proporción de personas que tiene esa ocupación que viven en el tract:
cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge
ren counterfactual_share value_term1990

** Se junta con la misma base pero para el 2010: 
cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term2010
keep if _merge==3
drop _merge
ren counterfactual_share value_term2010


** Se hace una transformación logarítmica a las variables: 
replace value_term1990=ln(value_term1990)
replace value_term2010=ln(value_term2010)

** Se genera una variable que sea proporción de población por ocupación para cada tract respecto al MSA en 1990 más el cambio en el valor del tiempo entre 2010 y 1990:
g sim2010=exp(ln(impute_share1990)-value_term1990+value_term2010)
sort occ2010 metarea gisjoin

** Se genera una variable por ocupación para cada área metropolitana que sea la suma de sim2010:
by occ2010 metarea: egen total_sim2010=sum(sim2010)

** Proporción por la ocupación en el tract sobre la proporción por ocupación en el área metropolitana:
g counterfactual_share=sim2010/total_sim2010

** Se junta con base que tiene número de trabajadores por ocupación y área metropolitana:
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

** Se junta con base que tiene que ocupaciones tienen alta habilidad:
cd $data/temp_files
merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

** Base ingreso por ocupación para los tres años: 
cd $data/temp_files
merge m:1 occ2010 using inc_occ_1990_2000_2010
keep if _merge==3
drop _merge
drop count1990 count2000 count2010 wage_real1990 wage_real2000 wage_real2010

ren count1990_2 count1990
ren count2000_2 count2000
ren count2010_2 count2010

*** Se genera variables que indiquen como es la proporción observada y como sería el contrafactual del ratio de habilidad relativo (ratio entre el ratio de habilidades de las ciudades y de los suburbios). Esto se hace multiplicando si la ocupación es de alta o baja habilidad, el número de trabajadores por ocupación y área metropolitana para 1990 y 2010 por la proporción de población por ocupación para cada tract respecto al MSA en 1990 (valores observados) ola proporción de población por ocupación para cada tract respecto al MSA dado si se estimara la diferencia en el valor del tiempo (se estima el valor del tiempo de ese año utilizando el valor verdadero, el tiempo de viaje y si se es de alta o baja calificación):
g impute2010_high_cf=counterfactual_share*count1990*high_skill
g impute2010_low_cf=counterfactual_share*count1990*(1-high_skill)

g impute2010_high=impute_share2010*count2010*high_skill
g impute2010_low=impute_share2010*count2010*(1-high_skill)

g impute1990_high=impute_share1990*count1990*high_skill
g impute1990_low=impute_share1990*count1990*(1-high_skill)

*** Se genera una variable que indique como es el cambio del ingreso promedio relativo:
g inc1990=impute_share1990*inc_mean1990*count1990
g inc2010_cf=counterfactual_share*inc_mean1990*count1990

** En vez de tenerse por ocupación se busca que esté a nivel census tract:
collapse (sum) impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low inc1990 inc2010_cf, by(metarea gisjoin)

** Base de densidad habitacional:
cd $data/temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

** Estandarización de la variable densidad habitacional: 
sum room_density_1mi_3mi
return list
scalar mean = r(mean)
scalar sd = r(sd)
display mean, sd
replace room_density_1mi_3mi=(room_density_1mi_3mi-mean)/sd

save impute, replace

cd $data/temp_files
u impute, clear

** Se renombran las variables del contrafactual:
g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace

/* Se observa que el autor genera varias veces las mismas variables en cada proceso de generación de la tabla. Se cree que esto es porque quiere que el código sea autocontenido, pero que este organizado de esta forma dificulta la comprensión. Se sugiere reorganizar el código para que sea más fácil de comprender.*/


*****************************************************************************
** Evaluación a una distancia de tres millas del centro: 
*****************************************************************************

cd $data/temp_files
u temp, clear

** Información de cuales tracts se encuentran a 3 millas de distancia del centro:
cd $data/geographic
merge 1:1 gisjoin using tract1990_downtown3mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge

** Se junta la información para tracts que tienen una distancia menor a 3 millas de distancia del centro:
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

*** Se genera una variable que calcula el ratio de trabajadores con altas cualificaciones respecto a bajas cualificaciones con los valores observados o los generados por el contrafactual (si mantuviera todo constante menos el valor del tiempo de los trabajadores comparando las ciudades con los suburbios):
g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

** Se genera variable que sea el cambio en el tiempo para ambas variables generadas anteriormente:
g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)

** Población para cada metarea para el año 1990:
cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

**  Ranking de MSA de acuerdo con cuales tienen más o menos población:
cd $data/geographic
merge m:1 metarea using 1990_rank
drop _merge
sort metarea downtown

** Para cada área metropolitana se genera el ratio entre esa observación y la anterior (cercana al centro y no cercana al centro):
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]




** Table 8
***************

/* Se observa que el autor en la tabla expone las medias para todos los MSA del ratio del ratio de la población con altas y bajas habilidades cercana al centro y no cercana al centro. Esto lo hace teniendo ponderando cada una de las observaciones por el tamaño de la población para darle más importancia a aquellas que tienen más población. Realiza el proceso para las 25 ciudades más grandes y para las 50 ciudades más grandes.

Con este proceso el autor está intentando mostrar que solo cambiando el valor del tiempo de los trabajadores, habría un cambio en la proporción de personas con diferentes calificaciones en el centro respecto al suburbio de entre 6% y 7%. Así, resalta que el valor del tiempo si hace que las personas quieran vivir más cerca al centro, lo cual se da en mayor medida en personas con altas cualificaciones que el supone valoran más su tiempo de desplazamiento y luego logra demostrar esto empíricamente.
 */

 /* Estos resultados son interesantes no solo por lo que le aportan a su paper, sino también porque demuestra que las personas cuando empiezan a valorar más su tiempo deciden vivir a distancias cercanas al lugar de trabajo. Esto implica la importancia del diseño de ciudades que tengan en cuenta las necesidades de las personas para que tenga un mayor impacto en su bienestar. Estas ciudades deberían estar pensadas en términos de las personas que tienen menores ingresos (cuya proxy en este caso es si están altamente calificados o no), ya que se observa que hay un desplazamiento relativo de personas de mayores ingresos al centro respecto a de bajos ingresos (más adelante el autor probará si hubo gentrificación lo cual implicaría una pérdida de bienestar de las personas de bajos ingresos) (no entendido como bienestar económico). */
 
 
* column 1 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* column 4 (3 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50


/* Al igual que con todas las otras tablas se observa que los valores dan muy similares pero no son exactamente los mismos que los reportados en el paper. Esto se debería revisar más a profundidad en futuros intentos de replicación reorganizando los do's para que sea más claro el proceso y ver donde hay posibles errores*/


*****************************************************************************
** Evaluación a una distancia de cinco millas del centro: 
*****************************************************************************

cd $data/temp_files
u temp, clear

** Información de cuales tracts se encuentran a 5 millas de distancia del centro:
cd $data/geographic
merge 1:1 gisjoin using tract1990_downtown5mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge

** Se junta la información para tracts que tienen una distancia menor a 5 millas de distancia del centro o mayor a 5 millas:
collapse (sum) predict2010_high_cf predict2010_low_cf impute2010_high_cf impute2010_low_cf impute2010_high impute2010_low impute1990_high impute1990_low , by( metarea downtown)

*** Se genera una variable que calcula el ratio de trabajadores con altas cualificaciones respecto a bajas cualificaciones con los valores observados o los generados por el contrafactual (si mantuviera todo constante menos el valor del tiempo de los trabajadores comparando las ciudades con los suburbios):
g ratio2010_cf=predict2010_high_cf/(predict2010_low_cf)
g ratio2010=impute2010_high/(impute2010_low)
g ratio1990=impute1990_high/(impute1990_low)

** Se genera variable que sea el cambio en el tiempo para ambas variables generadas anteriormente:
g dln_ratio_cf=ln( ratio2010_cf)-ln(ratio1990)
g dln_ratio=ln( ratio2010)-ln(ratio1990)

** Población para cada metarea para el año 1990:
cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

**  Ranking de MSA de acuerdo con cuales tienen más o menos población:
cd $data/geographic
merge m:1 metarea using 1990_rank
drop _merge

** Para cada área metropolitana se genera el ratio entre esa observación y la anterior (cercana al centro y no cercana al centro):
sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]


/* Se observa que el autor en la tabla expone las medias para todos los MSA del ratio del ratio de la población con altas y bajas habilidades cercana al centro y no cercana al centro. Esto lo hace teniendo ponderando cada una de las observaciones por el tamaño de la población para darle más importancia a aquellas que tienen más población. Realiza el proceso para las 25 ciudades más grandes y para las 50 ciudades más grandes.

Con este proceso el autor está intentando mostrar que solo cambiando el valor del tiempo de los trabajadores, habría un cambio en la proporción de personas con diferentes calificaciones en el centro respecto al suburbio de entre 7% y 8%. Así, resalta que el valor del tiempo si hace que las personas quieran vivir más cerca al centro, lo cual se da en mayor medida en personas con altas cualificaciones que el supone valoran más su tiempo de desplazamiento y luego logra demostrar esto empíricamente.
 */


** Table 8
* column 1 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=25

* column 4 (5 miles) Actual: mean of dln_ratio_ratio; Model-predicted: mean of dln_ratio_ratio_cf; %: mean of dln_ratio_ratio_cf/mean of dln_ratio_ratio
sum dln_ratio_ratio* [w=population] if downtown==1 & rank<=50



 
cd $data/temp_files
u impute, clear

g dln_sim_high_total  = ln(impute2010_high_cf)- ln(impute1990_high)
g dln_sim_low_total =ln(impute2010_low_cf)-ln(impute1990_low)

g drent_predict=0.099514*(ln(inc2010_cf)-ln(inc1990)) + 0.01814*room_density_1mi_3mi

g ratio1990=impute1990_high/impute1990_low
g ratio2010=impute2010_high/impute2010_low
g dratio=ln(ratio2010)-ln(ratio1990)


keep gisjoin dln_sim_high_total dln_sim_low_total ratio1990 ratio2010 dratio drent_predict

cd $data/geographic
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

*** rent
cd $data/temp_files
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
cd $data/temp_files
save counterfactual_I_pre_merge, replace

cd $data/temp_files
u data, clear

cd $data/temp_files
merge m:1 gisjoin using counterfactual_I_pre_merge
keep if _merge==3
drop _merge

cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data/temp_files/counterfactual
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
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge


g counterfactual=count1990*counterfactual_share

cd $data/temp_files

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
cd $data/temp_files

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace



*****************************************
**** Three mile evaluation
cd $data/temp_files
u temp, clear

cd $data/geographic
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


cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/temp_files
u temp, clear

cd $data/geographic
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


cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/temp_files
u impute, clear

g dln_sim_high_total  = ln(impute2010_high_cf)- ln(impute1990_high)
g dln_sim_low_total =ln(impute2010_low_cf)-ln(impute1990_low)

g drent_predict=0.099514*(ln(inc2010_cf)-ln(inc1990)) + 0.01814*room_density_1mi_3mi


g ratio1990=impute1990_high/impute1990_low
g ratio2010=impute2010_high/impute2010_low
g dratio=ln(ratio2010)-ln(ratio1990)


keep gisjoin dln_sim_high_total dln_sim_low_total ratio1990 ratio2010 dratio drent_predict

cd $data/geographic
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

*** rent
cd $data/temp_files
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
cd $data/temp_files
save counterfactual_I_pre_merge, replace

cd $data/temp_files
u data, clear

cd $data/temp_files
merge m:1 gisjoin using counterfactual_I_pre_merge
keep if _merge==3
drop _merge

cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data/temp_files/counterfactual
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
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge


g counterfactual=count1990*counterfactual_share

cd $data/temp_files

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
cd $data/temp_files

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

** counterfactual ratio and actual ratio (by changing value of time and amenity predicted by the value of time shock and rent)
save temp, replace


*****************

*****************************************************
*** Three miles evaluation
cd $data/temp_files
u temp, clear

cd $data/geographic
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


cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/temp_files
u temp, clear

cd $data/geographic
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


cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/ipums_micro

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


cd $data/temp_files

save val_40_60_total_noeduc, replace

*** show that selection only occurs at level estimate but not change
cd $data/temp_files

u val_40_60_total_noeduc, clear

keep occ2010 dval val_1990 val_2010
ren dval dval_noeduc
ren val_1990 val_1990_noeduc
ren val_2010 val_2010_noeduc

merge m:1 occ2010 using val_40_60_total_1990_2000_2010
drop _merge

cd $data/temp_files
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

cd $data/temp_files
u tract_impute_share, clear


cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data/temp_files/counterfactual
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
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data/temp_files

merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data/temp_files
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


cd $data/temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data/temp_files
u impute, clear

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace


**************************************
**** Three Mile evaluation
cd $data/temp_files
u temp, clear

cd $data/geographic
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

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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


cd $data/temp_files
u tract_impute_share, clear


cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data/temp_files/counterfactual
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
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data/temp_files

merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data/temp_files
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


cd $data/temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data/temp_files
u impute, clear

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace


**************************************
**** Three Mile evaluation
cd $data/temp_files
u temp, clear

cd $data/geographic
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

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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

cd $data/temp_files
u tract_impute_share, clear


cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data/temp_files/counterfactual
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
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data/temp_files

merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data/temp_files
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


cd $data/temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data/temp_files
u impute, clear

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace


**************************************
**** Three Mile evaluation
cd $data/temp_files
u temp, clear

cd $data/geographic
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

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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


cd $data/temp_files
u tract_impute_share, clear


cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data/temp_files/counterfactual
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
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data/temp_files

merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data/temp_files
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


cd $data/temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data/temp_files
u impute, clear

g predict2000_high_cf=impute2000_high_cf
g predict2000_low_cf=impute2000_low_cf

save temp, replace


**************************************
**** Three Mile evaluation
cd $data/temp_files
u temp, clear

cd $data/geographic
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

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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


cd $data/temp_files
u tract_impute_share, clear


cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term2000
keep if _merge==3
drop _merge

ren counterfactual_share value_term2000
cd $data/temp_files/counterfactual
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
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data/temp_files

merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data/temp_files
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


cd $data/temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data/temp_files
u impute, clear

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace


**************************************
**** Three Mile evaluation
cd $data/temp_files
u temp, clear

cd $data/geographic
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

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

* Table A2

* Column 5

reg dln_ratio_ratio dln_ratio_ratio_cf  [w=population] if downtown==1, r



*************************************+*************************************+***
**# Appendix - Exogeneity
*************************************+*************************************+***


*** Regressing change in incidence of working long hours in the suburbs and central cities
cd $data/ipums_micro
u 1990_2000_2010_temp , clear

** Se elimina si una persona trabaja menos de 30 horas a la semana: 
keep if uhrswork>=30

** Valores que no tienen sentido lógico para el ingreso total se cambian por missing o por cero: 
replace inctot=0 if inctot<0
replace inctot=. if inctot==9999999

** Está trayendo los salarios nominales de 1990 y 2000 en términos de salarios reales del 2010:

/*
IPC 1990 USA: 130.7
IPC 2000 USA: 172.2
IPC 2010 USA: 218.056 
*/

/* Se recomienda definir el significado de los valores de las siguientes tres líneas de código a priori, ya que no se sabía que hacía referencia a los IPC para Estados Unidos */
g inctot_real=inctot*218.056/130.7 if year==1990
replace inctot_real=inctot*218.056/172.2 if year==2000
replace inctot_real=inctot if year==2010
drop inctot

** Se divide entre 52 el ingreso total ya que se quiere saber cual es el ingreso semanal de los individuos. Se hace una transformación logarítmica de esta variable para reducir la varianza. 
replace inctot_real=inctot_real/52
replace inctot_real=ln(inctot_real)

** Se genera una dummy que indique si la persona trabaja más o menos de 50 horas a la semana:
g greaterthan50=0
replace greaterthan50=1 if uhrswork>=50


** Se pega con base que tiene pumas a menos de 5 millas del centro. 
cd $data/geographic
merge m:1 statefip puma1990 using puma1990_downtown_5mi
g downtown=0
replace downtown=1 if _merge==3
drop _merge

merge m:1 statefip puma using puma_downtown_5mi
replace downtown=1 if _merge==3
drop _merge

** Población que trabaja más de 50 horas por ocupación, centro y año: 
collapse greaterthan50, by(year occ2010 downtown)
drop if year==.
reshape wide greaterthan50, i(occ2010 downtown) j(year)

** Se genera el cambio de esta población entre 2010 y 1990:
g ln_d=ln( greaterthan502010)-ln( greaterthan501990)

** Se agrupa respecto a ocupación y si se está cerca al centro o no: 
drop greaterthan501990 greaterthan502010
reshape wide ln_d, i(occ2010) j(downtown)


reg ln_d1 ln_d0

** Número de personas por ocupación en 2010: 
cd $data/temp_files
merge 1:1 occ2010 using occ2010_count
drop _merge

** Valor del tiempo:
cd $data/temp_files
merge 1:1 occ2010 using val_40_60_total_1990_2000_2010
drop _merge

g dval=val_2010-val_1990 

**************
** Table A3
**************

/* 
*Regresión entre la proporción de personas en la ocupación que están cerca al centro (no cerca al centro) respecto al valor del tiempo. Regresión entre la proporción de personas en la ocupación que están cerca al centro respecto a la proporción de personas que no están cerca al centro. Esto lo pondera por la población en 1990. 
* Se utilizan errores estándares robustos por si hay heterocedasticidad de los errores.

*/


** Column 1
reg ln_d1 dval [w=count1990] if dval!=., r

** Column 2
reg ln_d0 dval [w=count1990] if dval!=., r

** Column 3
reg ln_d1 ln_d0 [w=count1990] if dval!=., r


*************************************+*************************************+***
**# Appendix - First Stage Regression
*************************************+*************************************+***

cd $data/temp_files
u skill_pop, clear

 cd $data/temp_files/iv
merge m:1 gisjoin using sim_iv_total
keep if _merge==3
drop _merge

** Se genera una variable que sea el cambio del ratio de alta respecto a bajas cualificaciones entre el 2010 y 1990 utilizando los datos observables o la simulación teniendo en cuenta solo el valor del tiempo y el tiempo esperado de desplazamiento (tiempo destinado a desplazamiento durante la semana).
g dratio=ln(impute2010_high/impute2010_low)-ln(impute1990_high/impute1990_low)
g dratio_sim=dln_sim_high_total - dln_sim_low_total 

**************************************
** Tabla A4 - Primera Etapa
**************************************

/* Para evaluar la relevancia de los intrumentos que está utilizando para la tabla 5 - Panel A el autor está haciendo una regresión entre el crecimiento del ratio de habildades y el valor predicho de este crecimiento. Utiliza efectos fijos de área metropolitana (al interior de un área metropolitana se observa la relación ya que está controlando por todas las características invariables en el tiempo de esta área). Utiliza errores estándares robustos. */


* Column 1
reghdfe dratio dratio_sim, absorb(metarea) cluster(gisjoin)
* Column 2
reghdfe dratio dln_sim_low_total dln_sim_high_total, absorb(metarea) vce(robust)

/*En este caso ocurre lo mismo que en otras estimaciones.Se observan diferencias en las magnitudes. De igual forma, se observa que en la descripción de la tabla plantea que para tener en cuenta la posible autocorrelación agrupa los errores a nivel census tract. Esto no se observa en el código arriba descrito. */ 


*************************************+*************************************+****
**# Output - Counterfactual Adjusted MSA
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"


*** create counterfatual location share in 2010

cd $data/temp_files
u tract_impute_share, clear


cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data/temp_files/counterfactual
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
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data/temp_files

merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data/temp_files
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


cd $data/temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data/temp_files
u impute, clear

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace


**************************************
**** Three Mile evaluation
cd $data/temp_files
u temp, clear

cd $data/geographic
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

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/temp_files
u temp, clear

cd $data/geographic
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

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/temp_files
u impute, clear

g dln_sim_high_total  = ln(impute2010_high_cf)- ln(impute1990_high)
g dln_sim_low_total =ln(impute2010_low_cf)-ln(impute1990_low)

g drent_predict=0.099514*(ln(inc2010_cf)-ln(inc1990)) + 0.01814*room_density_1mi_3mi


g ratio1990=impute1990_high/impute1990_low
g ratio2010=impute2010_high/impute2010_low
g dratio=ln(ratio2010)-ln(ratio1990)


keep gisjoin dln_sim_high_total dln_sim_low_total ratio1990 ratio2010 dratio drent_predict

cd $data/geographic
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

*** rent
cd $data/temp_files
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
cd $data/temp_files
save counterfactual_I_pre_merge, replace

cd $data/temp_files
u data, clear

cd $data/temp_files
merge m:1 gisjoin using counterfactual_I_pre_merge
keep if _merge==3
drop _merge

cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data/temp_files/counterfactual
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
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge


g counterfactual=count2010*counterfactual_share

cd $data/temp_files

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
cd $data/temp_files

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace



*****************************************
**** Three mile evaluation
cd $data/temp_files
u temp, clear

cd $data/geographic
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


cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/temp_files
u temp, clear

cd $data/geographic
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


cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/temp_files
u impute, clear

g dln_sim_high_total  = ln(impute2010_high_cf)- ln(impute1990_high)
g dln_sim_low_total =ln(impute2010_low_cf)-ln(impute1990_low)

g drent_predict=0.099514*(ln(inc2010_cf)-ln(inc1990)) + 0.01814*room_density_1mi_3mi


g ratio1990=impute1990_high/impute1990_low
g ratio2010=impute2010_high/impute2010_low
g dratio=ln(ratio2010)-ln(ratio1990)


keep gisjoin dln_sim_high_total dln_sim_low_total ratio1990 ratio2010 dratio drent_predict

cd $data/geographic
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

*** rent
cd $data/temp_files
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
cd $data/temp_files
save counterfactual_I_pre_merge, replace

cd $data/temp_files
u data, clear

cd $data/temp_files
merge m:1 gisjoin using counterfactual_I_pre_merge
keep if _merge==3
drop _merge

cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data/temp_files/counterfactual
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
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge


g counterfactual=count2010*counterfactual_share

cd $data/temp_files

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
cd $data/temp_files

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

** counterfactual ratio and actual ratio (by changing value of time and amenity predicted by the value of time shock and rent)
save temp, replace


*****************************************************
*** Three miles evaluation
cd $data/temp_files
u temp, clear

cd $data/geographic
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


cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/temp_files
u temp, clear

cd $data/geographic
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


cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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

cd $data/temp_files
u tract_impute_share, clear


cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term1990_high30
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data/temp_files/counterfactual
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
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data/temp_files

merge m:1 occ2010 using high_skill_30
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data/temp_files
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


cd $data/temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data/temp_files
u impute, clear

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace


**************************************
**** Three Mile evaluation
cd $data/temp_files
u temp, clear

cd $data/geographic
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

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/temp_files
u temp, clear

cd $data/geographic
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

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/temp_files
u impute, clear

g dln_sim_high_total  = ln(impute2010_high_cf)- ln(impute1990_high)
g dln_sim_low_total =ln(impute2010_low_cf)-ln(impute1990_low)

g drent_predict=0.099514*(ln(inc2010_cf)-ln(inc1990)) + 0.01814*room_density_1mi_3mi

g ratio1990=impute1990_high/impute1990_low
g ratio2010=impute2010_high/impute2010_low
g dratio=ln(ratio2010)-ln(ratio1990)


keep gisjoin dln_sim_high_total dln_sim_low_total ratio1990 ratio2010 dratio drent_predict

cd $data/geographic
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

*** rent
cd $data/temp_files
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
cd $data/temp_files
save counterfactual_I_pre_merge, replace

cd $data/temp_files
u data, clear

cd $data/temp_files
merge m:1 gisjoin using counterfactual_I_pre_merge
keep if _merge==3
drop _merge

cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term1990_high30
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data/temp_files/counterfactual
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
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge


g counterfactual=count1990*counterfactual_share

cd $data/temp_files

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
cd $data/temp_files

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace



*****************************************
**** Three mile evaluation
cd $data/temp_files
u temp, clear

cd $data/geographic
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


cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/temp_files
u temp, clear

cd $data/geographic
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


cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/temp_files
u impute, clear

g dln_sim_high_total  = ln(impute2010_high_cf)- ln(impute1990_high)
g dln_sim_low_total =ln(impute2010_low_cf)-ln(impute1990_low)

g drent_predict=0.099514*(ln(inc2010_cf)-ln(inc1990)) + 0.01814*room_density_1mi_3mi


g ratio1990=impute1990_high/impute1990_low
g ratio2010=impute2010_high/impute2010_low
g dratio=ln(ratio2010)-ln(ratio1990)


keep gisjoin dln_sim_high_total dln_sim_low_total ratio1990 ratio2010 dratio drent_predict

cd $data/geographic
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

*** rent
cd $data/temp_files
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
cd $data/temp_files
save counterfactual_I_pre_merge, replace

cd $data/temp_files
u data, clear

cd $data/temp_files
merge m:1 gisjoin using counterfactual_I_pre_merge
keep if _merge==3
drop _merge

cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term1990_high30
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data/temp_files/counterfactual
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
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge


g counterfactual=count1990*counterfactual_share

cd $data/temp_files

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
cd $data/temp_files

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

** counterfactual ratio and actual ratio (by changing value of time and amenity predicted by the value of time shock and rent)
save temp, replace


*****************

*****************************************************
*** Three miles evaluation
cd $data/temp_files
u temp, clear

cd $data/geographic
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


cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/temp_files
u temp, clear

cd $data/geographic
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


cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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

cd $data/temp_files
u tract_impute_share, clear


cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term1990_high50
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data/temp_files/counterfactual
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
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data/temp_files

merge m:1 occ2010 using high_skill_50
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data/temp_files
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


cd $data/temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data/temp_files
u impute, clear

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace


**************************************
**** Three Mile evaluation
cd $data/temp_files
u temp, clear

cd $data/geographic
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

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/temp_files
u temp, clear

cd $data/geographic
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

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/temp_files
u impute, clear

g dln_sim_high_total  = ln(impute2010_high_cf)- ln(impute1990_high)
g dln_sim_low_total =ln(impute2010_low_cf)-ln(impute1990_low)

g drent_predict=0.099514*(ln(inc2010_cf)-ln(inc1990)) + 0.01814*room_density_1mi_3mi

g ratio1990=impute1990_high/impute1990_low
g ratio2010=impute2010_high/impute2010_low
g dratio=ln(ratio2010)-ln(ratio1990)


keep gisjoin dln_sim_high_total dln_sim_low_total ratio1990 ratio2010 dratio drent_predict

cd $data/geographic
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

*** rent
cd $data/temp_files
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
cd $data/temp_files
save counterfactual_I_pre_merge, replace

cd $data/temp_files
u data, clear

cd $data/temp_files
merge m:1 gisjoin using counterfactual_I_pre_merge
keep if _merge==3
drop _merge

cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term1990_high50
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data/temp_files/counterfactual
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
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge


g counterfactual=count1990*counterfactual_share

cd $data/temp_files

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
cd $data/temp_files

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

save temp, replace



*****************************************
**** Three mile evaluation
cd $data/temp_files
u temp, clear

cd $data/geographic
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


cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/temp_files
u temp, clear

cd $data/geographic
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


cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/temp_files
u impute, clear

g dln_sim_high_total  = ln(impute2010_high_cf)- ln(impute1990_high)
g dln_sim_low_total =ln(impute2010_low_cf)-ln(impute1990_low)

g drent_predict=0.099514*(ln(inc2010_cf)-ln(inc1990)) + 0.01814*room_density_1mi_3mi


g ratio1990=impute1990_high/impute1990_low
g ratio2010=impute2010_high/impute2010_low
g dratio=ln(ratio2010)-ln(ratio1990)


keep gisjoin dln_sim_high_total dln_sim_low_total ratio1990 ratio2010 dratio drent_predict

cd $data/geographic
merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

*** rent
cd $data/temp_files
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
cd $data/temp_files
save counterfactual_I_pre_merge, replace

cd $data/temp_files
u data, clear

cd $data/temp_files
merge m:1 gisjoin using counterfactual_I_pre_merge
keep if _merge==3
drop _merge

cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term1990_high50
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data/temp_files/counterfactual
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
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge


g counterfactual=count1990*counterfactual_share

cd $data/temp_files

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
cd $data/temp_files

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf

** counterfactual ratio and actual ratio (by changing value of time and amenity predicted by the value of time shock and rent)
save temp, replace


*****************

*****************************************************
*** Three miles evaluation
cd $data/temp_files
u temp, clear

cd $data/geographic
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


cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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
cd $data/temp_files
u temp, clear

cd $data/geographic
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


cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
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

cd $data/ipums_micro

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

cd $data/temp_files

save occ2010_dg, replace


****************************

cd $data/ipums_micro

u 1990_2000_2010_temp, clear

keep if uhrswork>=30

keep if sex==1
keep if age>=25 & age<=65
*keep if year==1990 | year==2010


*drop wage distance tranwork trantime pwpuma ownershp ownershpd gq

drop if uhrswork==0

g greaterthan50=0
replace greaterthan50=1 if uhrswork>=50

cd $data/temp_files
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

cd $data/temp_files

save appendix_eval_reduced_form, replace


************************************************

*** create counterfatual location share in 2010

cd $data/temp_files
u tract_impute_share, clear


cd $data/temp_files/counterfactual
merge 1:1 occ2010 gisjoin using value_term1990
keep if _merge==3
drop _merge

ren counterfactual_share value_term1990
cd $data/temp_files/counterfactual
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
cd $data/temp_files
merge m:1 occ2010 metarea using count_metarea
keep if _merge==3
drop _merge

cd $data/temp_files

merge m:1 occ2010 using high_skill
keep if _merge==3
drop _merge

ren count1990 count1990_2
ren count2000 count2000_2
ren count2010 count2010_2

cd $data/temp_files
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


cd $data/temp_files
merge m:1 gisjoin using room_density1980_1mi
drop if _merge==2
drop _merge

replace room_density_1mi_3mi=(room_density_1mi_3mi-8127.921)/14493.66

save impute, replace

cd $data/temp_files
u impute, clear

g predict2010_high_cf=impute2010_high_cf
g predict2010_low_cf=impute2010_low_cf


cd $data/geographic
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

cd $data/temp_files
merge m:1 metarea using population1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic
merge m:1 metarea using 1990_rank
drop _merge

sort metarea downtown
by metarea: g dln_ratio_ratio_cf=dln_ratio_cf-dln_ratio_cf[_n-1]
by metarea: g dln_ratio_ratio=dln_ratio-dln_ratio[_n-1]

cd $data/temp_files
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

cd $data/temp_files

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

cd $data/temp_files
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

cd $data/temp_files
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

cd $data/temp_files
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

cd $data/temp_files
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

cd $data/temp_files
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

cd $data/temp_files
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

cd $data/temp_files
save 2010, replace



****1960 ****
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
u 1950, clear
keep if rank<=25
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd $data/temp_files
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd $data/temp_files
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
cd $data/temp_files
u 1950, clear
keep if rank>=1 & rank<=10
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd $data/temp_files
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd $data/temp_files
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
cd $data/temp_files
u 1950, clear
keep if rank>=11 & rank<=25
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd $data/temp_files
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd $data/temp_files
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
cd $data/temp_files
u 1950, clear
keep if rank>25 & rank<=50
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd $data/temp_files
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd $data/temp_files
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
cd $data/temp_files
u 1950, clear
keep if rank>50
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd $data/temp_files
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd $data/temp_files
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

cd $data/temp_files
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

cd $data/temp_files
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

cd $data/temp_files
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

cd $data/temp_files
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

cd $data/temp_files
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

cd $data/temp_files
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

cd $data/temp_files
save 2010, replace



****1960 ****
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
u 1950, clear
keep if rank<=25
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd $data/temp_files
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd $data/temp_files
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
cd $data/temp_files
u 1950, clear
keep if rank>=1 & rank<=10
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd $data/temp_files
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd $data/temp_files
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
cd $data/temp_files
u 1950, clear
keep if rank>=11 & rank<=25
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd $data/temp_files
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd $data/temp_files
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
cd $data/temp_files
u 1950, clear
keep if rank>25 & rank<=50
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd $data/temp_files
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd $data/temp_files
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
cd $data/temp_files
u 1950, clear
keep if rank>50
collapse income=b0f001 [w=b0u001], by(downtown)
g year=1950
save temp_1950, replace

cd $data/temp_files
foreach num of numlist 1960(10)2010 {
u `num'_income, clear
cd "$data/geographic"
merge m:1 metarea using 1990_rank
drop _merge
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
save 2010, replace

***
cd $data/temp_files
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
cd $data/temp_files
g year=1950
save temp_1950, replace


cd $data/temp_files
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
cd $data/temp_files
g year=1960
save temp_1960, replace

cd $data/temp_files
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
cd $data/temp_files
g year=1970
save temp_1970, replace


cd $data/temp_files
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
cd $data/temp_files
g year=1980
save temp_1980, replace

cd $data/temp_files
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
cd $data/temp_files
g year=1990
save temp_1990, replace


cd $data/temp_files
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
cd $data/temp_files
g year=2000
save temp_2000, replace


cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
save 2010, replace


cd $data/temp_files
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
cd $data/temp_files

u skill_pop, clear
g ratio1990= impute1990_high/ impute1990_low
g ratio2000= impute2000_high/ impute2000_low
g ratio2010= impute2010_high/ impute2010_low

cd $data/geographic\
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
cd $data/geographic
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
cd $data/temp_files

u skill_pop, clear
g ratio1990= impute1990_high/ impute1990_low
g ratio2010= impute2010_high/ impute2010_low

cd $data/geographic
merge 1:1 gisjoin using tract1990_downtown_200mi
keep if _merge==3
drop _merge

merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

replace distance=distance/1609
g dratio=ln( ratio2010)-ln(ratio1990)

cd $data/geographic
merge m:1 metarea using 1990_rank
drop _merge
drop if gisjoin==""

ren gisjoin gisjoin1
merge 1:1 gisjoin1 using $data/geographic\tract1990_tract1980_nearest.dta
keep if _merge==3
drop _merge

ren gisjoin2 gisjoin

cd $data/temp_files
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
cd $data/temp_files

u skill_pop, clear
g ratio1990= impute1990_high/ impute1990_low
g ratio2010= impute2010_high/ impute2010_low

cd $data/geographic
merge 1:1 gisjoin using tract1990_downtown_200mi
keep if _merge==3
drop _merge

merge 1:1 gisjoin using tract1990_metarea
keep if _merge==3
drop _merge

replace distance=distance/1609
g dratio=ln( ratio2010)-ln(ratio1990)

cd $data/geographic
merge m:1 metarea using 1990_rank
drop _merge
drop if gisjoin==""

ren gisjoin gisjoin1
merge 1:1 gisjoin1 using $data/geographic\tract1990_tract2000_nearest.dta
keep if _merge==3
drop _merge

ren gisjoin2 gisjoin

cd $data/temp_files
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


cd $data/temp_files

u occ_emp_1994,clear

cd $data/geographic

merge m:1 zip using zip1990_downtown
drop if _merge==2

g downtown=0
replace downtown=1 if _merge==3
drop _merge


cd $data/geographic

merge m:1 zip using zip1990_metarea
keep if _merge==3
drop _merge

cd $data/geographic

merge m:1 metarea using 1990_rank
keep if _merge==3
drop _merge

cd $data/geographic
keep if rank<=25
drop serial year

collapse (sum) est_num1990=est_num, by(occ2010 downtown)
cd $data/temp_files
save temp1990, replace

**2000
cd $data/temp_files

u occ_emp_2000,clear

cd $data/geographic

merge m:1 zip using zip2000_downtown
drop if _merge==2

g downtown=0
replace downtown=1 if _merge==3
drop _merge


cd $data/geographic

merge m:1 zip using zip2000_metarea
keep if _merge==3
drop _merge

cd $data/geographic

merge m:1 metarea using 1990_rank
keep if _merge==3
drop _merge

cd $data/geographic
keep if rank<=25
drop serial year

collapse (sum) est_num2000=est_num, by(occ2010 downtown)
cd $data/temp_files
save temp2000, replace
***
**2010
cd $data/temp_files

u occ_emp_2010,clear

cd $data/geographic

merge m:1 zip using zip2010_downtown
drop if _merge==2

g downtown=0
replace downtown=1 if _merge==3
drop _merge

cd $data/geographic

merge m:1 zip using zip2010_metarea
keep if _merge==3
drop _merge

cd $data/geographic

merge m:1 metarea using 1990_rank
keep if _merge==3
drop _merge

cd $data/geographic
keep if rank<=25
drop serial year

collapse (sum) est_num2010=est_num, by(occ2010 downtown)
cd $data/temp_files
save temp2010, replace

cd $data/temp_files
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
cd $data/temp_files
 u tract_impute.dta, clear
 cd $data/geographic
 merge m:1 gisjoin using tract1990_downtown5mi
drop if _merge==2
g downtown=0
replace downtown=1 if _merge==3
drop _merge

 cd $data/geographic

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

cd $data/temp_files
merge 1:1 occ2010 downtown using occ_emp_downtown
keep if _merge==3
drop _merge
cd $data/geographic

g dratio=ln(ratio2010)-ln(ratio1990)
g dratio_emp=ln(ratio_emp2010)-ln(ratio_emp1990)

label define occ 120 "financial worker" 2100 "Lawyer"
label values occ2010 occ

g occ2010_2=occ2010 if occ2010==800 | occ2010==2100 | occ2010==4820 | occ2010==30 | occ2010==1000 | occ2010==5700 | occ2010==4030
cd $data/temp_files
merge m:1 occ2010 using college_share
keep if _merge==3
drop _merge

g high_skill=0
replace high_skill=1 if college_share1990>0.4

cd $data/temp_files
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

cd $data/temp_files
u temp1990, clear
merge 1:1 occ2010 downtown using temp2000
keep if _merge==3
drop _merge

merge 1:1 occ2010 downtown using temp2010
keep if _merge==3
drop _merge 

sort occ2010 downtown

cd $data/temp_files
merge m:1 occ2010 using high_skill
drop if _merge==2
drop _merge

cd $data/temp_files
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


cd $data/ipums_micro
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

cd $data/temp_files
save tile_1990_2010, replace

****
cd $data/ipums_micro
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

cd $data/temp_files
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
cd $data/ipums_micro
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

cd $data/geographic
merge m:1 metarea using 1990_rank
drop _merge
keep if rank<=25

cd $data/temp_files
collapse ln_trantime [w=perwt], by(year wage_tile)

save commute_tile_1990_2010, replace

****
cd $data/ipums_micro
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

cd $data/geographic
merge m:1 metarea using 1990_rank
drop _merge
keep if rank<=25
collapse ln_trantime [w=perwt], by(year wage_tile)

cd $data/temp_files
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
cd $data/temp_files
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
cd $data/temp_files
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


  
*************************************+*************************************+***
**# Appendix - Income Rank
*************************************+*************************************+***

*************************************+*************************************+***
** Generación de variables necesarias para hacer el mapa:
*************************************+*************************************+***

/* Se optimiza el proceso realizando un loop para que sea más eficiente las líneas de código*/

clear all

** Ingreso para 1980, 1990, 2000 y 2010:
cd $data/temp_files


** Para cada base de ingreso de cada año, calcule el promedio ponderado por
	*población del ingreso para cada census tract de cada área metropolitana. 
	*Cree una variable que diga en que quintil está ese promedio dentro del
	*área metropolitana:
local x 1980 1990 2000 2010
foreach i of local x{
	u `i'_income, clear
	collapse income [w=count], by(metarea gisjoin)
	egen rank_income=xtile(income), n(5) by(metarea)
	keep gisjoin rank_income
	save `i'_income_rank, replace	
}


** Para cada base de cada año que ordena el promedio de ingreso de cada tract en quintiles de acuerdo con su posición respecto al área metropolitana, pegue la base que identifica cuales tracts están a una distancia menor a 200 millas del centro y la base que identifica el tract a que área metropolitana pertenece:
local x 1980 1990 2000 2010
foreach i of local x{
	
	cd $data/temp_files
	u `i'_income_rank, clear
	cd $data/geographic
	merge 1:1 gisjoin using tract`i'_downtown_200mi
	keep if _merge==3
	drop _merge

	merge 1:1 gisjoin using tract`i'_metarea
	keep if _merge==3
	drop _merge
	replace distance=distance/1609
	cd $data/temp_files
	g year=`i'
	save temp`i', replace
	
}

** Junte las bases de datos creadas anteriormente:
clear 
u temp1980, clear
append using temp1990
append using temp2000
append using temp2010


*************************************+*************************************+***
** Gráfica A7:
*************************************+*************************************+***

/* En este caso se realiza una suavización tipo kernel con polinomios locales utilizando un kernel tipo Epanechnikov. Se observa que este es un método también visto en la clase para poder observar de mejor forma la distribución de los datos.

En este caso en el eje vertical utiliza el ranking del ingreso por quintil y en el eje horizontal la distancia al centro cuando es menor a 30 millas. Esto lo hace para cada uno de los años. Así, se podría observar como está la concentración de ingresos dependiendo de la distancia al MSA (Chicago o Nueva York). Esta gráfica al comienzo parece contraintuitiva porque al comienzo no se sabe como interpretarla. Se podría hacer una gráfica más amigable con el lector que no conoce mucho del tema como hacer gráficas de concentración de ingreso del tract respecto a la distancia para cada quintil. Con esta sugerencia se harían gráficas separadas para los 4 años, Sin embargo, lo interesante de esta gráfica que el autor realiza es que permite ver como cambia esta distribución en el tiempo. Se observa que hay una mayor concentración de ingreso promedio en tracts que se encuentran más cerca al centro y disminuye el ingreso promedio hasta una distancia de 10 para luego aumentar hasta tracts cuyo ingreso promedio está en el cuarto quintil cuando la distancia al centro del tract es mayor a 10. Se observa que en 1980 no había el patrón descrito previamente (en el centro vivían personas de ingresos bajos). Esto cambió en el 90 y se fue pronunciando cada vez más cada década. Este patrón es más pronunciado para Chicago que para Nueva York. Se observa un crecimiento más rápido respecto a la distancia en Chicago que en Nueva York donde el cambio es más paulatino.
 */

cd $data/graph
# delimit 
graph twoway (lpoly rank_income distance if distance<=30 & year==1980,lpattern(dash)) 
(lpoly rank_income distance if distance<=30  & year==1990, lpattern(shortdash) )
(lpoly rank_income distance if distance<=30 & year==2000 , lpattern(longdash_dot))
 (lpoly rank_income distance if distance<=30 & year==2010, lcolor(black)) if metarea==160,
 legend(lab(1 "1980") lab(2 "1990") lab(3 "2000") lab(4 "2010") ) yscale(range(1 5)) ylabel(1(1)5)
 xtitle(distancia al centro (milla)) ytitle(Quintil de Ingreso) scheme(s1color)
 ;
 # delimit cr
 graph export chicago_income_quitile_distance.emf, replace
 
 
 # delimit 
graph twoway (lpoly rank_income distance if distance<=30 & year==1980,lpattern(dash)) 
(lpoly rank_income distance if distance<=30  & year==1990, lpattern(shortdash) )
(lpoly rank_income distance if distance<=30 & year==2000 , lpattern(longdash_dot))
 (lpoly rank_income distance if distance<=30 & year==2010, lcolor(black)) if metarea==560,
 legend(lab(1 "1980") lab(2 "1990") lab(3 "2000") lab(4 "2010") )  yscale(range(1 5)) ylabel(1(1)5)
 xtitle(distancia al centro (milla)) ytitle(Quintil de Ingreso) scheme(s1color)
 ;
 # delimit cr
  graph export ny_income_quitile_distance.emf, replace


 *************************************+*************************************+***
** Figura A6:
*************************************+*************************************+***

**** Chicago

**Para definir la forma de la figura en cuanto a en que posición se encuentran los tracts y cuál es su forma. Se hace un loop para cada uno de los años:
local x 1980 1990 2000 2010
foreach i of local x{
	
	cd $data/temp_files
	u `i'_income_rank, clear
	if `i' == 1980 {
		cd $data/geographic
		merge 1:1 gisjoin using longitude_latitude_tract`i'
		drop _merge
	}
	if `i' == 1990 {
		cd $data/geographic
		merge 1:1 gisjoin using longitude_latitude_tract`i'
		drop _merge
	}
	
	ren gisjoin GISJOIN

	merge 1:1 GISJOIN using tract`i'_shape

	spmap rank_income using tract`i'_coord if latitude<=5180000 & latitude>=5123040 & longitude>=-9801742 & longitude<=-9743004, id(id) fcolor(Greens) legend(pos(1)) cln(5)
	cd $data/graph
	graph export chicago_ranking_`i'.png, replace
	
}


*****************************
******************************

**** New York

local x 1980 1990 2000 2010
foreach i of local x{
	
	cd $data/temp_files
	u `i'_income_rank, clear
	if `i' == 1980 {
		cd $data/geographic
		merge 1:1 gisjoin using longitude_latitude_tract`i'
		drop _merge
	}
	if `i' == 1990 {
		cd $data/geographic
		merge 1:1 gisjoin using longitude_latitude_tract`i'
		drop _merge
	}
	
	ren gisjoin GISJOIN

	merge 1:1 GISJOIN using tract`i'_shape

	sspmap rank_income using tract1980_coord if latitude<=5012000 & latitude>=4949000 & longitude>=-8265000 & longitude<=-8199000, id(id) fcolor(Greens) legend(pos(5)) cln(5)
	cd $data/graph
	graph export nyc_ranking_`i'.png, replace
	
}

/* Se genera loop para optimizar el proceso y se describe que se hace. En estas es posible ver para cada tract como se ve el cambio en el ranking de ingresos en ambas ciudades. Como sugerencia se podría pintar el centro de un color para que así se sepa cuales son las mayores distancia y menores distancias. Esto podría ayudar al lector a comprender mejor la motivación. */


*************************************+*************************************+****
**# Output - LHP
*************************************+*************************************+****

clear all
global data="C:\Users\alen_su\Dropbox\paper_folder\replication\data"



*** Financial specialists
cd $data/ipums_micro

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
cd $data/ipums_micro

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
cd $data/ipums_micro

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
cd $data/ipums_micro

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

cd $data/ipums_micro
u 1990_2000_2010_temp , clear

cd $data/geographic

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

cd $data/ipums_micro
u 1990_2000_2010_temp , clear

cd $data/geographic

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
cd $data/ipums_micro
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

cd $data/geographic
merge m:1 statefip puma1990 using puma1990_downtown_5mi
g downtown=0
replace downtown=1 if _merge==3
drop _merge

merge m:1 statefip puma using puma_downtown_5mi
replace downtown=1 if _merge==3
drop _merge


collapse greaterthan50 [w=perwt], by(year wage_tile downtown)
cd $data/temp_files
save tile_1990_2010, replace

cd $data/temp_files
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
