
// Purpose: Generate summary descriptive tables
// Author: Leo
// Created on: March 2019


// Stata
	clear all
	set more off
	cap log close
	set linesize 250
	
	use "$dtafile_complete", clear
	
	//log using "12_Data\4_Attrition_management\4_Reporting\Att_report_`=subinstr(c(current_date), " ", "_", .)'..smcl", replace

	
/*--------  BENEFICIARY PRODUCTIVE TIME --------*/

	gen bn_livestock_hrs=t7_livestockhrs
	replace bn_livestock_hrs=. if t7_livestockhrs<0
	replace bn_livestock_hrs=0 if t7_livestock==0
	replace bn_livestock_hrs=90 if (bn_livestock_hrs>90 & bn_livestock_hrs!=.)

	gen bn_farm_hrs=t7_agrichrs
	replace bn_farm_hrs=. if t7_agrichrs<0
	replace bn_farm_hrs=0 if t7_agric==0
	replace bn_farm_hrs=90 if (bn_farm_hrs>90 & bn_farm_hrs!=.)

	gen bn_agroprocess_hrs=t7_agroprocesshrs
	replace bn_agroprocess_hrs=. if t7_agroprocesshrs<0
	replace bn_agroprocess_hrs=0 if t7_agroprocess==0
	replace bn_agroprocess_hrs=90 if (bn_agroprocess_hrs>90 & bn_agroprocess_hrs!=.)
	
	gen bn_offfarm_hrs=t7_farmhours
	replace bn_offfarm_hrs=. if t7_farmhours<0
	replace bn_offfarm_hrs=0 if t7_farm==0
	replace bn_offfarm_hrs=90 if (bn_offfarm_hrs>90 & bn_offfarm_hrs!=.)

	gen bn_noagr_hrs=t7_noagrichrs
	replace bn_noagr_hrs=. if t7_noagrichrs<0
	replace bn_noagr_hrs=0 if t7_noagric==0
	replace bn_noagr_hrs=90 if (bn_noagr_hrs>90 & bn_noagr_hrs!=.)

	gen bn_self1_hrs=t7_enterphrs
	replace bn_self1_hrs=. if t7_enterphrs<0
	replace bn_self1_hrs=0 if t7_enterp==0
	replace bn_self1_hrs=90 if ( bn_self1_hrs>90 &  bn_self1_hrs!=.)

	gen bn_self2_hrs=t7_semployhrs
	replace bn_self2_hrs=. if t7_semployhrs<0
	replace bn_self2_hrs=0 if t7_semploy==0
	replace bn_self2_hrs=90 if ( bn_self2_hrs>90 &  bn_self2_hrs!=.)
	
	gen bn_apprentice_hrs=t7_apprenticehrs
	replace bn_apprentice_hrs=. if t7_apprenticehrs<0
	replace bn_apprentice_hrs=0 if t7_apprentice==0
	replace bn_apprentice_hrs=90 if ( bn_apprentice_hrs>90 &  bn_apprentice_hrs!=.)
	
	egen bn_productive_hrs=rowtotal(bn_*_hrs), mis
	replace bn_productive_hrs=168 if (bn_productive_hrs>168 & bn_productive_hrs!=.)
	label var bn_productive_hrs "Beneficiary productive time"

*****************************************************************************
	
	
	/*-------  BENEFICIARY EMPLOYMENT STATUS -----------*/
	
	/*TIME USE DEFINITION*/
	
	gen bn_emp_ownfarm=(t7_agric==1 & t7_agrichrs>0 & t7_agrichrs!=.)
	replace bn_emp_ownfarm=. if t7_agric==.
	gen bn_emp_offfarm=(t7_farm==1 & t7_farmhours>0 & t7_farmhours!=.)
	replace bn_emp_offfarm=. if t7_farm==.
	gen bn_emp_noag=(t7_noagric==1 & t7_noagrichrs>0 & t7_noagrichrs!=.)
	replace bn_emp_noag=. if t7_noagric==.
	gen bn_emp_self1=(t7_enterp==1 & t7_enterphrs>0 & t7_enterphrs!=.)
	replace bn_emp_self1=. if t7_enterp==.
	gen bn_emp_self2=(t7_semploy==1 & t7_semployhrs>0 & t7_semployhrs!=.)
	replace bn_emp_self2=. if t7_semploy==.
	
	*Including agricultural with no wage
	
	gen bn_employed_time=(bn_emp_ownfarm==1|bn_emp_offfarm==1|bn_emp_noag==1|bn_emp_self1==1| bn_emp_self2==1)
	replace bn_employed_time=. if (bn_emp_ownfarm==. & bn_emp_offfarm==. & bn_emp_noag==. & bn_emp_self1==. & bn_emp_self2==.) 
	label var bn_employed_time "Has a job or self-employed (time use)"
	label value bn_employed_time yesno
	
	*Excluding agricultural with no wage 
	
	gen bn_employed_timewag=(bn_emp_offfarm==1|bn_emp_noag==1|bn_emp_self1==1| bn_emp_self2==1)
	replace bn_employed_timewag=. if (bn_emp_offfarm==. & bn_emp_noag==. & bn_emp_self1==. & bn_emp_self2==.) 
	label var bn_employed_timewag "Has a wage job or self-employed (time use)"
	label value bn_employed_timewag yesno
	
	****Using number of working hours***
	*Including agricultural non-wage
	
	egen bn_work_hrs=rowtotal(bn_farm_hrs bn_offfarm_hrs bn_noagr_hrs bn_self1_hrs bn_self2_hrs), mis
	gen bn_employed_hrs=(bn_work_hrs>20 & bn_work_hrs!=.)
	label var bn_employed_hrs "Has a job or self-employed (hrs worked)"
	label value bn_employed_hrs yesno
	
	*Not including agricultural non-wage
	egen bn_work_hrswag=rowtotal(bn_offfarm_hrs bn_noagr_hrs bn_self1_hrs bn_self2_hrs), mis
	gen bn_employed_hrswag=(bn_work_hrswag>20 & bn_work_hrs!=.)
	label var  bn_employed_hrswag "Has a wage job or self-employed (hrs worked)"
	label value  bn_employed_hrswag yesno
	
		
	/*--------  BENEFICIARY MONTHLY INCOME ----------------*/
	
	/*INCOME BASED ON TIME USE SECTION*/
	gen bn_wage_offfarm=(t7_farmwage*4)
	replace bn_wage_offfarm=0 if bn_emp_offfarm==0
	gen bn_wage_noag=(t7_noagricwage*4)
	replace bn_wage_noag=0 if bn_emp_noag==0
	gen bn_wage_self1=t7_enterpwage*4
	replace bn_wage_self1=0 if bn_emp_self1==0
	gen bn_wage_self2=(t7_semploywage*4)
	replace bn_wage_self2=0 if bn_emp_self2==0
	
	egen bn_wage_time=rowtotal(bn_wage_*), mis
	label var bn_wage_time "Beneficiary monthly labor income RWF (attrition time use section)"
	
	// Distribution of working hours 
	graph hbox bn_work_hrs, scheme(s2color)   ///
	ytitle (Working hours)  note("N=1,797") ///
	title(Distribution of working hours) 
	graph export "$report/ben_workinghrs.png", replace
	


	///Income 
	winsor bn_wage_time,p(0.01) gen(bn_wage_time_win)	
	label var bn_wage_time_win "Beneficiary monthly labor income (time use/winsor)"
	
	
	*Beneficiary's income

	graph box bn_wage_time_win, scheme(s2color) ///
	ytitle (Beneficiary's monthly income) ///
	title(Distribution of beneficiary's monthly income-(Time_use_section)) 
	graph export "$report/bn_income_percentile.png", replace

	

	twoway (hist bn_wage_time, bcolor(navy)) (kdensity bn_wage_time), ///
	title("Distribution of beneficary's income (time use section)") ytitle (Density) ///
	xtitle (Monthly income)  ylabel(,format(%-12.0gc)) xlabel(,format(%-12.0gc)) ///
	legend(label(1 "Density") label(2 "Kernel estimate density")) 
	graph export "$report/bn_wage_time.png", replace
	
	twoway (hist bn_wage_time_win, bcolor(navy)) (kdensity bn_wage_time_win), ///
	title("Distribution of beneficary's income (winsor/time use section)", size (medium))  ///
	xtitle (Monthly income)  ylabel(,format(%-12.0gc)) xlabel(,format(%-12.0gc)) ///
	legend(label(1 "Density") label(2 "Kernel estimate density")) ytitle (Density) 
	graph export "$report/bn_wage_time_win.png", replace
	
	
	tabstat bn_wage_offfarm bn_wage_noag bn_wage_self1 bn_wage_self2 bn_wage_time, s(p25 median p75 max mean) c(s) f(%13.8gc)
	
	* Who is currently enrolled 
	
	tab2 t8_01 treatment if (treatment=="HD" | treatment=="COMBINED"), col m
	
	gen bn_hd_activity=(t8_01==1 & (treatment=="HD" | treatment=="COMBINED"))
	
	tab2 t8_02 treatment if bn_hd_activity==1 , col m
	
	
	
	
	// Cleaning tasks
	* People who have been called before we add the main number variable- incorporate the main number using the one they have talked to
	*
	
	
	//cap log close
	
	
