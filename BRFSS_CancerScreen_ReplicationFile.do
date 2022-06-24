clear all

****Working Directory must have all BRFSS datafiles from 2000-2020 (.dta format)*****

local satafiles: dir . files "*.dta"
foreach file of local satafiles { 

preserve
use `file', clear
gen filename =  regexr("`file'", "_.20", "")

#delimit;
isvar
_ageg5yr
chld04
chld0512
chld1317
children
educa
employ
employ1
income2
marital
numadult
sex
_racegr
_state idate imonth iday iyear dispcode seqno _psu
_finalwt
mscode
_llcpwt
hadmam*
howlong*
hadpap*
lastpap*
hadsigm*
lastsigm*
lastsig*
hadsgcol*
colnscpy
colntest
sigmscpy
sigmtest
csrvc*
csrvdoc*
csrvt*
chcs*
chco*
cncrt*
cncra*
cncrh*


;


#delimit cr

keep `r(varlist)' filename

save temp, replace
restore
append using temp, force
}
erase temp.dta

save data.dta, replace

*****clean data****



destring imonth iday iyear, replace

gen svywave=substr(filename,6,4)
destring svywave, replace


gen perwt=.
replace perwt=_finalwt if svywave<=2010
replace perwt=_llcpwt  if svywave>=2011
drop _finalwt _llcpwt

replace _racegr3=_racegr2 if svywave<=2012
drop _racegr2
rename _racegr3 race

rename _ageg5yr age

drop filename

rename _state statefips


rename iyear year
rename imonth month
rename iday day
rename idate date

label define STATEFIP 1 `"alabama"', modify
label define STATEFIP 2 `"alaska"', modify
label define STATEFIP 4 `"arizona"', modify
label define STATEFIP 5 `"arkansas"', modify
label define STATEFIP 6 `"california"', modify
label define STATEFIP 8 `"colorado"', modify
label define STATEFIP 9 `"connecticut"', modify
label define STATEFIP 10 `"delaware"', modify
label define STATEFIP 11 `"district of columbia"', modify
label define STATEFIP 12 `"florida"', modify
label define STATEFIP 13 `"georgia"', modify
label define STATEFIP 15 `"hawaii"', modify
label define STATEFIP 16 `"idaho"', modify
label define STATEFIP 17 `"illinois"', modify
label define STATEFIP 18 `"indiana"', modify
label define STATEFIP 19 `"iowa"', modify
label define STATEFIP 20 `"kansas"', modify
label define STATEFIP 21 `"kentucky"', modify
label define STATEFIP 22 `"louisiana"', modify
label define STATEFIP 23 `"maine"', modify
label define STATEFIP 24 `"maryland"', modify
label define STATEFIP 25 `"massachusetts"', modify
label define STATEFIP 26 `"michigan"', modify
label define STATEFIP 27 `"minnesota"', modify
label define STATEFIP 28 `"mississippi"', modify
label define STATEFIP 29 `"missouri"', modify
label define STATEFIP 30 `"montana"', modify
label define STATEFIP 31 `"nebraska"', modify
label define STATEFIP 32 `"nevada"', modify
label define STATEFIP 33 `"new hampshire"', modify
label define STATEFIP 34 `"new jersey"', modify
label define STATEFIP 35 `"new mexico"', modify
label define STATEFIP 36 `"new york"', modify
label define STATEFIP 37 `"north carolina"', modify
label define STATEFIP 38 `"north dakota"', modify
label define STATEFIP 39 `"ohio"', modify
label define STATEFIP 40 `"oklahoma"', modify
label define STATEFIP 41 `"oregon"', modify
label define STATEFIP 42 `"pennsylvania"', modify
label define STATEFIP 44 `"rhode island"', modify
label define STATEFIP 45 `"south carolina"', modify
label define STATEFIP 46 `"south dakota"', modify
label define STATEFIP 47 `"tennessee"', modify
label define STATEFIP 48 `"texas"', modify
label define STATEFIP 49 `"utah"', modify
label define STATEFIP 50 `"vermont"', modify
label define STATEFIP 51 `"virginia"', modify
label define STATEFIP 53 `"washington"', modify
label define STATEFIP 54 `"west virginia"', modify
label define STATEFIP 55 `"wisconsin"', modify
label define STATEFIP 56 `"wyoming"', modify
label define STATEFIP 61 `"maine-new hampshire-vermont"', modify
label define STATEFIP 62 `"massachusetts-rhode island"', modify
label define STATEFIP 63 `"minnesota-iowa-missouri-kansas-nebraska-s.dakota-n.dakota"', modify
label define STATEFIP 64 `"maryland-delaware"', modify
label define STATEFIP 65 `"montana-idaho-wyoming"', modify
label define STATEFIP 66 `"utah-nevada"', modify
label define STATEFIP 67 `"arizona-new mexico"', modify
label define STATEFIP 68 `"alaska-hawaii"', modify
label define STATEFIP 72 `"puerto rico"', modify
label define STATEFIP 97 `"military/mil. reservation"', modify
label define STATEFIP 99 `"state not identified"', modify

label values statefips STATEFIP


****create analyti variables***

tab hadmam howlong, missing
*mammogram*
gen mam_ever=.
replace mam_ever=0 if hadmam==2
replace mam_ever=1 if hadmam==1

gen mam_yr=.
replace mam_yr=0 if mam_ever==0 | (howlong>=2 & howlong<7)
replace mam_yr=1 if howlong==1

gen mamcat=.
replace mamcat=0 if mam_ever==0
replace mamcat=1 if howlong==1
replace mamcat=2 if howlong==2 
replace mamcat=3 if howlong==3
replace mamcat=4 if howlong==4
replace mamcat=5 if howlong==5

*pap smear*

gen pap_ever=.
replace pap_ever=0 if (hadpap==2 & svywave<2004) | (hadpap2==2 & svywave>=2004)
replace pap_ever=1 if (hadpap==1 & svywave<2004) | (hadpap2==1 & svywave>=2004)

gen pap_yr=.
replace pap_yr=0 if pap_ever==0 | (svywave<2004 & lastpap>=2 & lastpap<7) |  (svywave>=2004 & lastpap2>=2 & lastpap2<7)
replace pap_yr=1 if (svywave<2004 & lastpap==1) |  (svywave>=2004 & lastpap2==1)

gen papcat=.
replace papcat=0 if pap_ever==0
foreach n of numlist 1/5{
replace papcat=`n' if lastpap==`n' 
replace papcat=`n' if lastpap2==`n'
}

tab papcat lastpap, missing
tab papcat lastpap2, missing
*bloodstool, colonoscopy, sigmodoscopy*

gen bloodst_ever=.
replace bloodst_ever=0 if bldstool==2 & svywave<2020
replace bloodst_ever=0 if bldstol1==2 & svywave==2020
replace bloodst_ever=1 if bldstool==1 & svywave<2020
replace bloodst_ever=1 if bldstol1==1 & svywave==2020 

gen bloodst_yr=.
replace bloodst_yr=0 if bloodst_ever==0 | (lstbldst>=2 & lstbldst<7 & svywave==2000) | (lstblds2>=2 & lstblds2<7 & svywave>2000 & svywave<=2007) | (lstblds3>=2 & lstblds3<7 & svywave>2007 & svywave<=2019) | (lstblds4>=2 & lstblds4<7 & svywave==2020) 
replace bloodst_yr=1 if bloodst_ever==0 | (lstbldst==1 & svywave==2000) | (lstblds2==1 & svywave>2000 & svywave<=2007) | (lstblds3==1 &  svywave>2007 & svywave<=2019) | (lstblds4==1 &  svywave==2020) 


gen bscat=.
replace bscat=0 if bloodst_ever==0
foreach n of numlist 1/4{
replace bscat=`n' if lstbldst==`n'
replace bscat=`n' if lstblds2==`n'
replace bscat=`n' if lstblds3==`n'
replace bscat=`n' if lstblds4==`n'

}

replace bscat=4 if lstblds3==5
replace bscat=4 if lstblds4==5


tab lstbldst bscat, missing
tab lstblds2 bscat, missing
tab lstblds3 bscat, nolab missing
tab lstblds4 bscat, nolab missing


gen colsig_ever=.
replace colsig_ever=0 if (hadsigm==2 & svywave==2000) | (hadsigm2==2 & svywave>2000 & svywave<=2003) | (hadsigm3==2 &  svywave>2003 & svywave<=2019) 
replace colsig_ever=0 if svywave==2020 & (colnscpy==2 & sigmscpy==2)


replace colsig_ever=1 if (hadsigm==1 & svywave==2000) | (hadsigm2==1 & svywave>2000 & svywave<=2003) | (hadsigm3==1 &  svywave>2003 & svywave<=2019) 
replace colsig_ever=1 if svywave==2020 & (colnscpy==1 | sigmscpy==1)

gen colsig_yr=.
replace colsig_yr=0 if colsig_ever==0
replace colsig_yr=0 if (lastsigm>=2 & lastsigm<7 & svywave==2000) | (lastsig2>=2 & lastsig2<7 & svywave>2000 & svywave<=2008) | (lastsig3>=2 & lastsig3<7 & svywave>2008 & svywave<=2019)
replace colsig_yr=0 if svywave==2020 & (colntest>=2 & colntest<7 & sigmtest>=2 & sigmtest<7)

replace colsig_yr=1 if (lastsigm==1 &  svywave==2000) | (lastsig2==1 & svywave>2000 & svywave<=2008) | (lastsig3==1 & svywave>2008 & svywave<=2019)
replace colsig_yr=1 if svywave==2020 & (colntest==1 | sigmtest==1)

tab lastsigm svywave, missing nolab
tab lastsig2 svywave, missing nolab 
tab lastsig3  svywave, missing nolab
tab colntest svywave, missing nolab

gen colsigcat=.
replace colsigcat=0 if colsig_ever==0
foreach n of numlist 1/3{
	replace colsigcat=`n' if lastsigm==`n'
	replace colsigcat=`n' if lastsig2==`n'
	replace colsigcat=`n' if lastsig3==`n'
	replace colsigcat=`n' if colntest==`n'
}

	replace colsigcat=4 if lastsigm>=4 & lastsigm<=6
	replace colsigcat=4 if lastsig2>=4 & lastsig2<=6
	replace colsigcat=4 if lastsig3>=4 & lastsig3<=6
	replace colsigcat=4 if colntest>=4 & colntest<=6
	
tab lastsigm colsigcat, missing nolab
tab lastsig2 colsigcat, missing nolab 
tab lastsig3  colsigcat, missing nolab
tab colntest colsigcat, missing nolab

	

gen metro=.
replace metro=0 if _metstat==2
replace metro=1 if _metstat==1

gen rural=.
replace rural=0 if _urbstat==1
replace rural=1 if _urbstat==2

gen urban=.
replace urban=0 if metro==1 | rural==1
replace urban=1 if rural==0 & metro==0



gen edate = mdy(month, day, year)

format edate %d

gen male=.
replace male=1 if sex==1 | sex1==1 | sexvar==1
replace male=0 if sex==2 | sex1==2 | sexvar==2

gen rucca=.
replace rucca=1 if metro==1
replace rucca=2 if urban==1
replace rucca=3 if rural==1



foreach i in race age _metstat hlthplan hlthcvrg hlthcvr1 male rucca{
	
	tab  `i' svywave, missing
}

tab age if age<14 , gen(agedum)

tab race, gen(race1dum)

sum race1dum*

rename race1dum1 nhw
rename race1dum2 nhb
gen nho=0 if race1dum3==0 & race1dum4==0
replace nho=1 if race1dum3==1 | race1dum4==1
rename race1dum5 hisp

tab nhw race, missing
tab nhb race, missing
tab nho race, missing
tab hisp race, missing

foreach i in  hlthcvrg hlthcvr1{
	
	tab `i' svywave, missing
}

tab mscode , gen(msadum)


rename msadum1 metro2
rename msadum2 urban2
rename msadum3 suburban2
rename msadum4 rural2
rename msadum5 cell2

tab edu svywave, missing

tab edu if edu>=1 & edu<9, gen(edustat)

drop if statefips>56

tab marital svywave, missing

tab marital if marital>=1 & marital<9, gen(marstat)

*****Years with cancer screening data****
***3: Mammogram (mamcat, 0-5) - 2000-2020 even eyars***
gen keep_mamcat=.
foreach n of numlist 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018 2020 {
replace keep_mamcat=1 if svywave==`n'
}

***2: Pap Smear (papcat, 0-5) - 2000-2020 even eyars***
gen keep_papcat=.
foreach n of numlist 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018 2020 {
replace keep_papcat=1 if svywave==`n'
}


***3: Colonoscopy/Sigmoidoscopy (colsigcat, 0-4) - 2010, 2012, 2014, 2016, 2018, 2020***
gen keep_colsigcat=.
foreach n of numlist 2002 2004 2006 2008 2010 2012 2014 2016 2018 2020 {
replace keep_colsigcat=1 if svywave==`n'
}

***keep 2010-2020 for primary analysis***
gen keep10=1 if svywave>=2010

*****create exposure and cohort variables****
gen late=0
	
	replace late=1 if year!=svywave 

gen covid=0
replace covid=1 if svywave==2020

***drop observations apr-dec***
foreach n of numlist 2000/2020{
	
	drop if edate>=d(01apr`n') & edate<=d(31dec`n')
}

****create sample selection variables (eligible age/gender)*****
****females, age 40-74***
gen elig_mamcat=.

foreach n of numlist 5/11{
replace elig_mamcat=1 if male==0 & (agedum`n'==1)
}

***females, age 25-64****
gen elig_papcat=.
foreach n of numlist 2/9{
replace elig_papcat=1 if male==0 & agedum`n'==1
}

***f/m, age 45-84****
gen elig_colsigcat=.
foreach n of numlist 6/12{
replace elig_colsigcat=1 if agedum`n'==1
}

tab late covid if elig_mamcat==1 & keep10==1 & keep_mamcat==1
tab late covid if elig_papcat==1 & keep10==1 & keep_papcat==1
tab late covid if elig_colsigcat==1 & keep10==1 & keep_colsigcat==1

*****prep analysis****

global outcomes mamcat papcat bscat colsigcat 

keep if keep10==1

global controls i.(agedum* nhw nhb nho hisp  male marstat*  edustat1 edustat2 edustat3 edustat4 edustat5 edustat6)

***Research Plan***
**0-Graph each category year-by-year**
tab mamcat, gen(y_mam)

gen f4catmam=.
replace f4catmam=0 if y_mam1==1
replace f4catmam=1 if y_mam2==1
replace f4catmam=2 if y_mam3==1
replace f4catmam=3 if y_mam4==1 | y_mam5==1 | y_mam6==1

tab f4catmam, gen(y2_mam)

foreach n of numlist 1/4{
reg y2_mam`n' i.svywave##i.late if  keep_mamcat==1 & elig_mamcat==1 [pw=perwt]
margins svywave#late
marginsplot, scheme(white_ptol)
graph save g1a_mam`n'.gph, replace
graph export g1a_mam`n'.tif, replace

}

graph combine g1a_mam1.gph g1a_mam2.gph g1a_mam3.gph g1a_mam4.gph, ycommon
graph save gmam_comb.gph, replace
graph export gmam_comb.tif, replace

tab papcat, gen(y_pap)

gen f4catpap=.
replace f4catpap=0 if y_pap1==1
replace f4catpap=1 if y_pap2==1
replace f4catpap=2 if y_pap3==1
replace f4catpap=3 if y_pap4==1 | y_pap5==1 | y_pap6==1

tab f4catpap, gen(y2_pap)

foreach n of numlist 1/4{
reg y2_pap`n' i.svywave##i.late if keep_papcat==1 & elig_papcat==1 [pw=perwt]
margins svywave#late
marginsplot, scheme(white_ptol)
graph save g1a_pap`n'.gph, replace
graph export g1a_pap`n'.tif, replace
}

graph combine g1a_pap1.gph g1a_pap2.gph g1a_pap3.gph g1a_pap4.gph, ycommon
graph save gpap_comb.gph, replace
graph export gpap_comb.tif, replace

tab colsigcat, gen(y_colsig)

gen f4catcolsig=.
replace f4catcolsig=0 if y_colsig1==1
replace f4catcolsig=1 if y_colsig2==1
replace f4catcolsig=2 if y_colsig3==1
replace f4catcolsig=3 if y_pap4==1 | y_pap5==1 

tab f4catcolsig, gen(y2_colsig)

foreach n of numlist 1/4{
reg y2_colsig`n' i.svywave##i.late if keep_colsigcat==1 & elig_colsig==1 [pw=perwt]
margins svywave#late
marginsplot, scheme(white_ptol)
graph save g1a_colsig`n'.gph, replace
}

graph combine g1a_colsig1.gph g1a_colsig2.gph g1a_colsig3.gph g1a_colsig4.gph, ycommon
graph save gcolsig_comb.gph, replace
graph export gcolsig_comb.tif, replace

estimates clear
**1-LPM & Logit for each category (test prediction bounds)***
	foreach n of numlist 1/4{
		
		eststo: areg y2_mam`n' ib2018.svywave##i.late $controls if keep_mamcat==1 & elig_mamcat==1 [pw=perwt] , vce(cluster statefips) absorb(statefips)
		
		predict y_hat_mam_`n', xb
		sum y_hat_mam_`n'
		estadd scalar yhat_min=r(min)
		estadd scalar yhat_max=r(max)
		
		logit y2_mam`n' ib2018.svywave##i.late $controls i.statefips if keep_mamcat==1 & elig_mamcat==1 [pw=perwt] , vce(cluster statefips)
		eststo: margins svywave , dydx(late) 
		marginsplot , scheme(white_ptol) yline(0)
		graph save g2a_mam_`n'.gph, replace
		
		drop y_hat_mam_`n'
		logit y2_mam`n' ib2018.svywave##i.late $controls i.statefips if keep_mamcat==1 & elig_mamcat==1 [pw=perwt] , vce(cluster statefips)

		predict y_hat_mam_`n', xb
		sum y_hat_mam_`n'
		estadd scalar yhat_min=r(min)
		estadd scalar yhat_max=r(max)
		
		
}

esttab using t1a_mam.csv, replace b(3) se(3) sca(yhat_min yhat_max) keep(*svywave *svywave#1.late)
esttab using t1a_mam2.csv, replace b(3) ci(3) sca(yhat_min yhat_max) keep(*svywave *svywave#1.late)
esttab using t1a_mam3.csv, replace b(3) p(3) sca(yhat_min yhat_max) keep(*svywave *svywave#1.late)



estimates clear

****pap****

	foreach n of numlist 1/4{
		
		eststo: areg y2_pap`n' ib2018.svywave##i.late $controls if keep_papcat==1 & elig_papcat==1 [pw=perwt] , vce(cluster statefips) absorb(statefips)
		
		predict y_hat_pap_`n', xb
		sum y_hat_pap_`n'
		estadd scalar yhat_min=r(min)
		estadd scalar yhat_max=r(max)
		
		logit y2_pap`n' ib2018.svywave##i.late $controls i.statefips if keep_papcat==1 & elig_papcat==1 [pw=perwt] , vce(cluster statefips)
		eststo: margins svywave , dydx(late) 
		marginsplot , scheme(white_ptol) yline(0)
		graph save g2a_pap_`n'.gph, replace
		
		drop y_hat_pap_`n'
		logit y2_pap`n' ib2018.svywave##i.late $controls i.statefips if keep_papcat==1 & elig_papcat==1 [pw=perwt] , vce(cluster statefips)

		predict y_hat_pap_`n', xb
		sum y_hat_pap_`n'
		estadd scalar yhat_min=r(min)
		estadd scalar yhat_max=r(max)
		
}

esttab using t1a_pap.csv, replace b(3) se(3) sca(yhat_min yhat_max) keep(*svywave *svywave#1.late)
esttab using t1a_pap2.csv, replace b(3) ci(3) sca(yhat_min yhat_max) keep(*svywave *svywave#1.late)
esttab using t1a_pap3.csv, replace b(3) p(3) sca(yhat_min yhat_max) keep(*svywave *svywave#1.late)

****colsig****

estimates clear


	foreach n of numlist 1/4{
		
		eststo: areg y2_colsig`n' ib2018.svywave##i.late $controls if keep_colsigcat==1 & elig_colsigcat==1 [pw=perwt] , vce(cluster statefips) absorb(statefips)
		
		predict y_hat_colsig_`n', xb
		sum y_hat_colsig_`n'
		estadd scalar yhat_min=r(min)
		estadd scalar yhat_max=r(max)
		
		logit y2_colsig`n' ib2018.svywave##i.late $controls i.statefips if keep_colsigcat==1 & elig_colsigcat==1 [pw=perwt] , vce(cluster statefips)
		eststo: margins svywave , dydx(late) 
		marginsplot , scheme(white_ptol) yline(0)
		graph save g2a_colsig_`n'.gph , replace
		
		drop y_hat_colsig_`n'
		logit y2_colsig`n' ib2018.svywave##i.late $controls i.statefips if keep_colsigcat==1 & elig_colsigcat==1 [pw=perwt] , vce(cluster statefips)

		predict y_hat_colsig_`n', xb
		sum y_hat_colsig_`n'
		estadd scalar yhat_min=r(min)
		estadd scalar yhat_max=r(max)
				
}

esttab using t1a_colsig.csv, replace b(3) se(3) sca(yhat_min yhat_max) keep(*svywave *svywave#1.late)
esttab using t1a_colsig2.csv, replace b(3) ci(3) sca(yhat_min yhat_max) keep(*svywave *svywave#1.late)
esttab using t1a_colsig3.csv, replace b(3) p(3) sca(yhat_min yhat_max) keep(*svywave *svywave#1.late)


estimates clear

******pretrend tests*****

estimates clear
**1-LPM & Logit for each category (test pretrends)***
	foreach n of numlist 1/4{
		
		eststo: areg y2_mam`n' ib2018.svywave##i.late $controls if svywave<2020 & keep_mamcat==1 & elig_mamcat==1 [pw=perwt] , vce(cluster statefips) absorb(statefips)
		
test 2010.svywave#1.late = 2012.svywave#1.late = 2014.svywave#1.late = 2016.svywave#1.late = 0, mtest(b)
estadd scalar p1=r(p)
		

		
}

esttab using t2a_mam.csv, replace b(3) se(3) sca(p1) keep(*svywave *svywave#1.late)
esttab using t2a_mam2.csv, replace b(3) p(3) sca(p1) keep(*svywave *svywave#1.late)



estimates clear

****pap****

	foreach n of numlist 1/4{
		
		eststo: areg y2_pap`n' ib2018.svywave##i.late $controls if svywave<2020 & keep_papcat==1 & elig_papcat==1 [pw=perwt] , vce(cluster statefips) absorb(statefips)
		
test 2010.svywave#1.late = 2012.svywave#1.late = 2014.svywave#1.late = 2016.svywave#1.late = 0, mtest(b)
estadd scalar p1=r(p)
		
}

esttab using t2a_pap.csv, replace b(3) se(3) sca(p1) keep(*svywave *svywave#1.late)
esttab using t2a_pap2.csv, replace b(3) p(3) sca(p1) keep(*svywave *svywave#1.late)

****colsig****

estimates clear


	foreach n of numlist 1/4{
		
		eststo: areg y_colsig`n' ib2018.svywave##i.late $controls if svywave<2020 & keep_colsigcat==1 & elig_colsigcat==1 [pw=perwt] , vce(cluster statefips) absorb(statefips)
		
test 2010.svywave#1.late = 2012.svywave#1.late = 2014.svywave#1.late = 2016.svywave#1.late = 0, mtest(b)
estadd scalar p1=r(p)
				
}

esttab using t2a_colsig.csv, replace b(3) se(3) sca(p1) keep(*svywave *svywave#1.late)
esttab using t2a_colsig2.csv, replace b(3) p(3) sca(p1) keep(*svywave *svywave#1.late)




estimates clear
**MNL for cat variables (compute and plot margins)***
		

		mlogit f4catmam ib2018.svywave##i.late $controls i.statefips if keep_mamcat==1 & elig_mamcat==1 [pw=perwt] , vce(cluster statefips)
		eststo: margins svywave , dydx(late)  predict(outcome(0)) predict(outcome(1)) predict(outcome(2))  predict(outcome(3)) post
		marginsplot , scheme(white_ptol) yline(0)
		graph save `g'g3a_mam_.gph, replace
		

		

esttab using `g't3a_mam.csv, replace b(3) se(3) 
esttab using `g't3a_mam2.csv, replace b(3) ci(3) 
esttab using `g't3a_mam.csv, replace b(3) p(3) 



estimates clear

		
		mlogit f4catpap ib2018.svywave##i.late $controls i.statefips if keep_papcat==1 & elig_papcat==1 [pw=perwt] , vce(cluster statefips)
		eststo: margins svywave , dydx(late)  predict(outcome(0)) predict(outcome(1)) predict(outcome(2))  predict(outcome(3))  post
		marginsplot , scheme(white_ptol) yline(0)
		graph save `g'g3a_pap_.gph, replace
		
		


esttab using `g't3a_pap.csv, replace b(3) se(3)  
esttab using `g't3a_pap2.csv, replace b(3) ci(3) 
esttab using `g't3a_pap.csv, replace b(3) p(3)  

****colsig****

estimates clear


		
		mlogit f4catcolsig ib2018.svywave##i.late $controls i.statefips if keep_colsigcat==1 & elig_colsigcat==1 [pw=perwt] , vce(cluster statefips)
		eststo: margins svywave , dydx(late)  predict(outcome(0)) predict(outcome(1)) predict(outcome(2))  predict(outcome(3))   post
		marginsplot , scheme(white_ptol) yline(0)
		graph save g3a_colsig_.gph, replace
		
				


esttab using t3a_colsig.csv, replace b(3) se(3)  
esttab using t3a_colsig2.csv, replace b(3) ci(3) 
esttab using t3a_colsig.csv, replace b(3) p(3)  












