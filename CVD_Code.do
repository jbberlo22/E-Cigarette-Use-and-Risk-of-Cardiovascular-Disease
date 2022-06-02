
*****************************************************************************
* Clean data							 						*
*****************************************************************************
 clear
set maxvar 30000

*use "36498-1001-Data-file", clear
 
** Exposure

********************************************************************************
	** Cigarette smoking **//
	gen smq_a1=0 											 
		replace smq_a1=1 if R01_AC1005==6 & (R01_AC1003==3 | R01_AC1003==-1)
		replace smq_a1=2 if R01_AC1005==6 & (R01_AC1003==1 | R01_AC1003==2)
		replace smq_a1=. if R01_AC1003<-5 | R01_AC1005<-5
		
		
			label var smq_a1 "smoking status (3 categories)"
			label define smq_a 0 "never" 1 "former" 2 "current", replace 
					label values smq_a1 smq_a

	gen smq_b1=0 											 
	* never established smoker
		replace smq_b1=1 if R01_AC1005==6 & R01_AC1003==3
		replace smq_b1=2 if R01_AC1005==6 & R01_AC1003==2 
		replace smq_b1=3 if R01_AC1005==6 & R01_AC1003==1
		replace smq_b1=. if R01_AC1003<-5 | R01_AC1005<-5
		
	gen cig_perday1=.
		replace cig_perday1=R01R_A_PERDAY_EDY_CIGS 	if smq_b1==3 & R01R_A_PERDAY_EDY_CIGS>=0
		replace cig_perday1=R01R_A_PERDAY_P30D_CIGS if smq_b1==2 & R01R_A_PERDAY_P30D_CIGS>=0
		replace cig_perday1=R01R_A_PERDAY_FMR_CIGS 	if smq_b1==1 & R01R_A_PERDAY_FMR_CIGS>=0
		replace cig_perday1=0 if smq_b1==0
	gen cig_perday_pack1=cig_perday/20
	
	gen cig_year1=R01_AC9002_YR+R01_AC9002_MO/12 if 	R01_AC9002_YR>=0 & R01_AC9002_MO>=0
	gen cig_mon1 =R01_AC9002_YR*12+R01_AC9002_MO if 	R01_AC9002_YR>=0 & R01_AC9002_MO>=0

	gen packyear=(cig_perday_pack1*cig_year1)
		replace packyear=0  if smq_b1==0
	gen packyearsquared = packyear*packyear
	
	
	gen smq1 = .
	replace smq1 =1 if R01R_A_CUR_ESTD_CIGS==1
	replace smq1 =0 if R01R_A_CUR_ESTD_CIGS==2
		
		
********************************************************************************
	** E-cigarette use **//

	
	gen ecig_use1 = .
	replace ecig_use1 = 2 if R01_AE1003  == 1
	replace ecig_use1 = 1 if R01_AE1003 ==2
	replace ecig_use1 = 0 if R01_AE1003  == -1 | R01_AE1003 ==3


	gen atleastsomedayecig1 = .
	replace atleastsomedayecig1 = 1 if R01_AE1003  == 1 | R01_AE1003 ==2
	replace atleastsomedayecig1 = 0 if R01_AE1003  == -1 | R01_AE1003 ==3
	
********************************************************************************
	** Covariates **//
	

* 2. Age 
	gen age=R01R_A_AGECAT7
		replace age=. if R01R_A_AGECAT7<0
		
	
* 3. Sex 
	gen male1=(R01R_A_SEX_IMP==1)
		replace male1=. if R01R_A_SEX_IMP<0
	
* 4. Race/ethnicity 
gen raceth1=.
		replace raceth1=1 if  R01R_A_RACECAT3==1 &  R01R_A_HISP==2
		replace raceth1=2 if  R01R_A_RACECAT3==2 &  R01R_A_HISP==2
		replace raceth1=3 if  R01R_A_HISP==1
		replace raceth1=4 if  R01R_A_RACECAT3==3 &  R01R_A_HISP==2
		
		label define raceth 1 "non-Hispanic white" 2 "non-Hispanic black" 3 "Hispanic" 4 "non-Hispanic other"
			label values raceth1 raceth
* 5. Education 
  recode R01R_A_AM0018 (1=1)(2 3=2)(4=3)(5 6=4)(else=.), gen(educ1)
		label define educ 1 "Less than High sch" 2 "High school/GED" 3 "Some college" 4 "Bachelor or above"
			label values educ1 educ

*7. BMI
gen bmi1=R01R_A_BMI
		replace bmi1=. if R01R_A_BMI<0
		
			
			
*** CVD & Risk factors ***
				
*8. History of hypertension
	gen everhypertension=	(R01_AX0111_01==1)
		replace everhypertension=. 		if R01_AX0111_01<0
			
*9. History of cholestrol
	gen everhcholestrol=	(R01_AX0111_02==1)
		replace everhcholestrol=. 		if R01_AX0111_02<0
		
*10. Congistive heart failure
	gen everheartfail=		(R01_AX0111_03==1)
		replace everheartfail=. 		if R01_AX0111_03<0
		
*11. Stroke
	gen everstroke=			(R01_AX0111_04==1)
		replace everstroke=. 			if R01_AX0111_04<0
		
*12. Heart attack
	gen everheartattack=	(R01_AX0111_05==1)
		replace everheartattack=. 		if R01_AX0111_05<0
	
			
*13. Other heart conditions
	gen everotheheart=		(R01_AX0111_06==1)
		replace everotheheart=. 		if R01_AX0111_06<0
		
	* CVD disease 
gen ever_baseline_CVD = .
replace ever_baseline_CVD = 1 if (everheartfail ==1 | everstroke==1 | everheartattack==1 | everotheheart==1)
replace ever_baseline_CVD = 0 if (everheartfail ==0 & everstroke==0 & everheartattack==0 & everotheheart==0)


*14. Diabetes
	gen everdiabetes=		(R01_AX0281==1)
		replace everdiabetes=. 		if R01_AX0281<0
	

** Additional controls				 

*16. Marijuana use
	gen ever_weed=.
		replace ever_weed=1 if R01_AX0085==1 | R01_AG9105 == 1
		replace ever_weed=0 if R01_AX0085==2
*Family Cardiac History
gen ever_fam_history = .
replace ever_fam_history =1 if R01_AX0153 ==1
replace ever_fam_history =0 if R01_AX0153 ==2


********************************************************************************
	**Merge**

*merge 1:1 PERSONID using "36498-2001-Data-file", keepusing(R02_AX0119_NB_* R02_AX0119_12M_* R02_AX0111_12M_* R02R_A_CUR_ESTD_CIGS R02_A_PWGT* R02_AC* R02_AO* R02_AM* R02_AC* R02_AT* R02_AO* R02_AE* R02_AG* R02_AP* R02_AH* R02_AU* R02_AS* R02_AD* R02R_A_* R02_AX0065* R02_AX0066* R02_AX0085* R02_AX0675* R02_AX0220* R02_AX0676* R02_AX0119* R02_AX0111* R02_AX0281* R02_AX0090* R02_AR1045* R02_AR0144* R02_NEW_BASELINE_ADULT_LD R02_A_PWGT) gen(_mer_w2_resp)
	drop if _mer_w2_resp==2
*merge 1:1 PERSONID using "36498-3001-Data-file", keepusing(R03_AX0119_NB_* R03_AX0119_12M_* R03_AX0111_12M_* R03R_A_CUR_ESTD_CIGS R03_AC* R03_AV* R03_AM* R03_AC*  R03_AE* R03_AG* R03_AP* R03_AH* R03_AU* R03_AS* R03_AD* R03_AV* R03R_A_* R03_AX0065* R03_AX0066* R03_AX0085* R03_AX0675* R03_AX0220* R03_AX0676* R03_AX0119* R03_AX0111* R03_AX0281* R03_AX0090* R03_AR1045* R03_AR0144*) gen(_mer_w3_resp)
	drop if _mer_w3_resp==2
*merge 1:1 PERSONID using "36498-4001-Data-file", keepusing(R04_AX0119_NB_* R04_AX0119_12M_* R04_AX0111_12M_* R04_AC* R04_AV* R04_AM* R04_AC* R04_AE* R04_AG* R04_AP* R04_AH* R04_AU* R04_AS* R04_AD* R04_AV* R04R_A_* R04_AX0065* R04R_A_AX0066* R04_AX0085* R04_AX0675* R04_AX0220* R04_AX0676* R04_AX0119* R04_AX0111* R04_AX0281* R04_AX0090* R04_AR1045* R04_AR0144* R04_AX0001) gen(_mer_w4_resp)
	drop if _mer_w4_resp==2
*merge 1:1 PERSONID using "36498-5001-Data-file", keepusing(R05_AX0053 * R05_AX0047_12M)  gen(_mer_w5_resp)
	drop if _mer_w5_resp==2	
	
*merge 1:1 PERSONID using "36498-3102-Data-file", gen (_mer21_w3_wgts)   
drop if _mer21_w3_wgts==2
*merge 1:1 PERSONID using "36498-4321-Data-file", gen (_mer31_w4_cowgts)  
drop if _mer31_w4_cowgts==2
*merge 1:1 PERSONID using "36498-5111-Data-file", gen (_mer41_w5_cowgts)  
drop if _mer41_w5_cowgts==2


* Complex survey design parameters
	rename VARPSU VARPSU1
	rename VARSTRAT VARSTRAT1

*********************************************************************************
	


*Time varying covariates
gen hookah1 = .
	replace hookah1 = 1 if R01_AH1003 == 1 | R01_AH1003==2
	replace hookah1 = 0 if R01_AH1002== 2 | R01_AH1003==3 | R01_AH1001 ==2
gen hookah2 = .
	replace hookah2 = 1 if R02_AH1003 == 1 | R02_AH1003==2
	replace hookah2 = 0 if R02_AH1004== 0 | R02_AH1003==3 | R02_AH1002_12M ==2 
gen hookah3 = .
	replace hookah3 = 1 if R03_AH1003 == 1 | R03_AH1003==2
	replace hookah3 = 0 if R03_AH1004== 0 | R03_AH1003==3 | R03_AH1002_12M ==2
gen hookah4 = .
	replace hookah4 = 1 if R04_AH1003 == 1 | R04_AH1003==2
	replace hookah4 = 0 if R04_AH1004== 0 | R04_AH1003==3 | R04_AH1002_12M ==2
	
gen pipe1 = .
	replace pipe1 = 1 if R01_AP1003 == 1 | R01_AP1003==2
	replace pipe1 = 0 if R01_AP1002== 2 | R01_AP1003==3 | R01_AP1001 ==2 
gen pipe2 = .
	replace pipe2 = 1 if R02_AP1003 == 1 | R02_AP1003==2
	replace pipe2 = 0 if R02_AP1002_12M== 2 | R02_AP1003==3 | R02_AP1004 ==2 	
	replace pipe2 = 0 if R02_AP1002_12M== 2 | R02_AP1003==3 | R02_AP1004 ==2 	
gen pipe3 = .
	replace pipe3 = 1 if R03_AP1003 == 1 | R03_AP1003==2
	replace pipe3 = 0 if R03_AP1002_12M== 2 | R03_AP1003==3 | R03_AP1004 ==2 	
gen pipe4= .
	replace pipe4 = 1 if R04_AP1003 == 1 | R04_AP1003==2
	replace pipe4 = 0 if R04_AP1002_12M== 2 | R04_AP1003==3 | R04_AP1004 ==2 
	
gen cigar1 = .
	replace cigar1 = 1 if R01_AG1003TC == 1 | R01_AG1003TC==2
	replace cigar1 = 0 if R01_AG9003== 2 | R01_AG1003TC==3 | R01_AG1001 ==2 | R01_AG9002_01 ==2
gen cigar2 = .
	replace cigar2 = 1 if R02_AG1003TC == 1 | R02_AG1003TC==2
	replace cigar2 = 0 if R02_AG9030== 2 | R02_AG1003TC==3 | R02_AG9003_12M ==2
gen cigar3 = .
	replace cigar3= 1 if R03_AG1003TC == 1 | R03_AG1003TC==2
	replace cigar3 = 0 if R03_AG9030== 2 | R03_AG1003TC==3 | R03_AG9003_12M ==2
gen cigar4 = .
	replace cigar4 = 1 if R04_AG1003TC == 1 | R04_AG1003TC==2
	replace cigar4 = 0 if R04_AG9030== 2 | R04_AG1003TC==3 | R04_AG9003_12M ==2
	
gen rillo1 = .
	replace rillo1 = 1 if R01_AG1003CG == 1 | R01_AG1003CG==2
	replace rillo1 = 0 if R01_AG9004== 2 | R01_AG1003CG==3 | R01_AG1001 ==2 | R01_AG9002_02 ==2
gen rillo2 = .
	replace rillo2 = 1 if R02_AG1003CG == 1 | R02_AG1003CG==2
	replace rillo2 = 0 if R02_AG9031== 2 | R02_AG1003CG==3 |R02_AG9051==2 
gen rillo3 = .
	replace rillo3 = 1 if R03_AG1003CG == 1 | R03_AG1003CG==2
	replace rillo3 = 0 if R03_AG9031== 2 | R03_AG1003CG==3 |R03_AG9051==2
gen rillo4 = .
	replace rillo4 = 1 if R04_AG1003CG == 1 | R04_AG1003CG==2
	replace rillo4 = 0 if R04_AG9031== 2 | R04_AG1003CG==3 |R04_AG9051==2 

gen snus1 = .
	replace snus1 = 1 if R01_AS1003SU == 1 | R01_AS1003SU==2
	replace snus1 = 0 if R01_AS1002_01== 2 | R01_AS1003SU==3  | R01_AS1001 ==2 | R01_AU1003==1
gen snus2 = .
	replace snus2 = 1 if R02_AS1003SU == 1 | R02_AS1003SU==2
	replace snus2 = 0 if R02_AS1003SU==3 | R02_AU1002_12M ==2
gen snus3 = .
	replace snus3 = 1 if R03_AU1003 == 1 | R03_AU1003==2
	replace snus3 = 0 if R03_AU1003==3 | R03_AU1004 ==2 |R03_AU1002_12M ==2 
gen snus4 = .
	replace snus4 = 1 if R04_AU1003 == 1 | R04_AU1003==2
	replace snus4 = 0 if R04_AU1003==3 | R04_AU1004 ==2 |R04_AU1002_12M ==2 
	
gen smokeless1 = .
	replace smokeless1 = 1 if R01_AS1003SM == 1 | R01_AS1003SM==2
	replace smokeless1 = 0 if R01_AS1002_02== 2 | R01_AS1003SM==3  | R01_AS1001 ==2
gen smokeless2 = .
	replace smokeless2 = 1 if R02_AS1003SM == 1 | R02_AS1003SM==2
	replace smokeless2 = 0 if R02_AS1002_12M== 2 | R02_AS1003SM==3
gen smokeless3 = .
	replace smokeless3 = 1 if R03_AS1003 == 1 | R03_AS1003==2
	replace smokeless3 = 0 if R03_AS1003==3 |  R03_AU1004 ==2 |R03_AU1002_12M ==2 
gen smokeless4 = .
	replace smokeless4 = 1 if R04_AS1003 == 1 | R04_AS1003==2
	replace smokeless4 = 0 if R04_AS1003==3 | R04_AU1004 ==2 |R04_AU1002_12M ==2 

	
	
gen combtob1=(cigar1==1 | rillo1==1 | pipe1==1 | hookah1==1)
	replace combtob1=. if cigar1==. | rillo1==. | pipe1==. | hookah1==.
	
	gen combtob2=(cigar2==1 | rillo2==1 | pipe2==1 | hookah2==1)
	replace combtob2=. if cigar2==. | rillo2==. | pipe2==. | hookah2==.
	
	gen combtob3=(cigar3==1 | rillo3==1 | pipe3==1 | hookah3==1)
	replace combtob3=. if cigar3==. | rillo3==. | pipe3==. | hookah3==.
	
	gen combtob4=(cigar4==1 | rillo4==1 | pipe4==1 | hookah4==1)
	replace combtob4=. if cigar4==. | rillo4==. | pipe4==. | hookah4==.

gen noncombtob1=(smokeless1==1 | snus1==1)
	replace noncombtob1=. if smokeless1==. | snus1== .
	
	gen noncombtob2=(smokeless2==1 | snus2==1)
	replace noncombtob2=. if smokeless2==. | snus2==.
	
	gen noncombtob3=(smokeless3==1 | snus3==1)
	replace noncombtob3=. if smokeless3==. | snus3==. 
	
	gen noncombtob4=(smokeless4==1 | snus4==1)
	replace noncombtob4=. if smokeless4==. | snus4==.

*Time varying exposures

gen smq2 = .
replace smq2 =1 if (R02R_A_CUR_ESTD_CIGS ==1) 
replace smq2 =0 if (R02R_A_CUR_ESTD_CIGS==2)
gen smq3 = .
replace smq3 =1 if (R03R_A_CUR_ESTD_CIGS ==1) 
replace smq3 =0 if (R03R_A_CUR_ESTD_CIGS==2)
gen smq4 = .
replace smq4 =1 if (R04R_A_CUR_ESTD_CIGS ==1) 
replace smq4 =0 if (R04R_A_CUR_ESTD_CIGS==2)

gen ecig_use2 = .
replace ecig_use2 = 2 if R02_AO1003C  == 1
replace ecig_use2 = 1 if R02_AO1003C ==2
replace ecig_use2 = 0 if R02_AO1003C  == -1 | R02_AO1003C ==3

gen ecig_use3 = .
replace ecig_use3 = 2 if R03_AV1003EC  == 1
replace ecig_use3 = 1 if R03_AV1003EC ==2
replace ecig_use3 = 0 if R03_AV1003EC  == -1 | R03_AV1003EC ==3

gen ecig_use4 = .
replace ecig_use4 = 2 if R04_AV1003 == 1
replace ecig_use4 = 1 if R04_AV1003 ==2
replace ecig_use4 = 0 if R04_AV1003  == -1 | R04_AV1003 ==3

gen atleastsomedayecig2 = ecig_use2
	replace atleastsomedayecig2 = 1 if ecig_use2==2
gen atleastsomedayecig3 = ecig_use3
	replace atleastsomedayecig3 = 1 if ecig_use3==2
gen atleastsomedayecig4 = ecig_use4
	replace atleastsomedayecig4 = 1 if ecig_use4==2
	
gen cig_ecig_composite1 = .
replace cig_ecig_composite1 =1 if atleastsomedayecig1==0 & smq1==0
replace cig_ecig_composite1 =2 if atleastsomedayecig1==1 & smq1==0
replace cig_ecig_composite1 =3 if atleastsomedayecig1==0 & smq1==1
replace cig_ecig_composite1 =4 if atleastsomedayecig1==1 & smq1==1

gen cig_ecig_composite2 = .
replace cig_ecig_composite2 =1 if atleastsomedayecig2==0 & smq2==0
replace cig_ecig_composite2 =2 if atleastsomedayecig2==1 & smq2==0
replace cig_ecig_composite2 =3 if atleastsomedayecig2==0 & smq2==1
replace cig_ecig_composite2 =4 if atleastsomedayecig2==1 & smq2==1

gen cig_ecig_composite3 = .
replace cig_ecig_composite3 =1 if atleastsomedayecig3==0 & smq3==0
replace cig_ecig_composite3 =2 if atleastsomedayecig3==1 & smq3==0
replace cig_ecig_composite3 =3 if atleastsomedayecig3==0 & smq3==1
replace cig_ecig_composite3 =4 if atleastsomedayecig3==1 & smq3==1

gen cig_ecig_composite4 = .
replace cig_ecig_composite4 =1 if atleastsomedayecig4==0 & smq4==0
replace cig_ecig_composite4 =2 if atleastsomedayecig4==1 & smq4==0
replace cig_ecig_composite4 =3 if atleastsomedayecig4==0 & smq4==1
replace cig_ecig_composite4 =4 if atleastsomedayecig4==1 & smq4==1
	
	
*Outcomes	
	
forvalues i = 2(1)5 {
	
* CVD conditions		
	gen hypertension`i'=(R0`i'_AX0111_12M_01==1)
		replace hypertension`i'=. 	if R0`i'_AX0119_12M_01<-5 | R0`i'_AX0119_12M_01==.
	gen hcholestrol`i'=	(R0`i'_AX0111_12M_02==1)
		replace hcholestrol`i'=. 	if R0`i'_AX0119_12M_02<-5 | R0`i'_AX0119_12M_02==.
	gen heartfail`i'=	(R0`i'_AX0111_12M_03==1)
		replace heartfail`i'=. 		if R0`i'_AX0119_12M_03<-5 | R0`i'_AX0119_12M_03==.
	gen stroke`i'=		(R0`i'_AX0111_12M_04==1)
		replace stroke`i'=. 		if R0`i'_AX0119_12M_04<-5 | R0`i'_AX0119_12M_04==.
	gen heartattack`i'=	(R0`i'_AX0111_12M_05==1)
		replace heartattack`i'=. 	if R0`i'_AX0119_12M_05<-5 | R0`i'_AX0119_12M_05==.
	gen otheheart`i'=	(R0`i'_AX0111_12M_06==1)
		replace otheheart`i'=. 		if R0`i'_AX0119_12M_06<-5 | R0`i'_AX0119_12M_06==.
}


*Drop if have or baseline CVD diagnosis or missing time 2 sample weights

drop if ever_baseline_CVD == 1
drop if ever_baseline_CVD ==.
drop if R02_A_PWGT==.

*******************************************************************************
*Multiple Imputation and Reshape
*To calculate total n and number of incident cases skip this section. Just do following commands...
*reshape long noncombtob combtob cig_ecig_composite, i(PERSONID) j(time)   
*drop if cig_ecig_composite==.


	set seed 2021	
	mi set mlong

mi register imputed ever_fam_history age everdiabetes packyear  packyearsquared educ bmi  ever_weed raceth1 noncombtob1 combtob1 noncombtob2 combtob2 noncombtob3 combtob3 noncombtob4 combtob4 
mi impute chained (logit, augment) noncombtob1 combtob1 noncombtob2 combtob2 noncombtob3 combtob3 noncombtob4 combtob4 everdiabetes ever_weed ever_fam_history (ologit, augment) educ age (mlogit, augment) raceth1 (regress) bmi packyear packyearsquared  =  male1 R02_A_PWGT everhypertension everhcholestrol, add(5) force

mi reshape long noncombtob combtob cig_ecig_composite, i(PERSONID) j(time)   

*Drop if missing exposure
drop if cig_ecig_composite==.


*******************************************************************************
*Create outcome variables

gen heartattack = .
replace heartattack = 0 if (heartattack2==0 & time==1) | (heartattack3==0 & time==2) | (heartattack4==0 & time==3) | (heartattack5==0 & time==4)
replace heartattack = 1 if (heartattack2==1 & time==1) | (heartattack3==1 & time==2) | (heartattack4==1 & time==3) | (heartattack5==1 & time==4)

gen heartfail = .
replace heartfail = 0 if (heartfail2==0 & time==1) | (heartfail3==0 & time==2) | (heartfail4==0 & time==3) | (heartfail5==0 & time==4)
replace heartfail = 1 if (heartfail2==1 & time==1) | (heartfail3==1 & time==2) | (heartfail4==1 & time==3) | (heartfail5==1 & time==4)

gen stroke = .
replace stroke = 0 if (stroke2==0 & time==1) | (stroke3==0 & time==2) | (stroke4==0 & time==3) | (stroke5==0 & time==4)
replace stroke = 1 if (stroke2==1 & time==1) | (stroke3==1 & time==2) | (stroke4==1 & time==3) | (stroke5==1 & time==4)

gen otheheart = .
replace otheheart = 0 if (otheheart2==0 & time==1) | (otheheart3==0 & time==2) | (otheheart4==0 & time==3) | (otheheart5==0 & time==4)
replace otheheart = 1 if (otheheart2==1 & time==1) | (otheheart3==1 & time==2) | (otheheart4==1 & time==3) | (otheheart5==1 & time==4)


*Composite outcome
gen CV_Disease = .
replace CV_Disease = 0 if (stroke ==0 & heartfail == 0 & heartattack ==0 & otheheart==0)
replace CV_Disease = 1 if (stroke ==1 | heartfail == 1 | heartattack ==1 | otheheart==1)

*Outcome without other heart conditions
gen CV_Disease_3x = .
replace CV_Disease_3x = 0 if (stroke ==0 & heartfail == 0 & heartattack ==0)
replace CV_Disease_3x = 1 if (stroke ==1 | heartfail == 1 | heartattack ==1)

*Composite outcomes at each wave
gen CV_Disease2 = .
replace CV_Disease2 = 0 if (stroke2 ==0 & heartfail2 == 0 & heartattack2 ==0 & otheheart2==0)
replace CV_Disease2 = 1 if (stroke2 ==1 | heartfail2 == 1 | heartattack2 ==1 | otheheart2==1)

gen CV_Disease3 = .
replace CV_Disease3 = 0 if (stroke3 ==0 & heartfail3 == 0 & heartattack3 ==0 & otheheart3==0)
replace CV_Disease3 = 1 if (stroke3 ==1 | heartfail3 == 1 | heartattack3 ==1 | otheheart3==1)

gen CV_Disease4 = .
replace CV_Disease4 = 0 if (stroke4 ==0 & heartfail4 == 0 & heartattack4 ==0 & otheheart4==0)
replace CV_Disease4 = 1 if (stroke4 ==1 | heartfail4 == 1 | heartattack4 ==1 | otheheart4==1)

gen CV_Disease5 = .
replace CV_Disease5 = 0 if (stroke5 ==0 & heartfail5 == 0 & heartattack5 ==0 & otheheart5==0)
replace CV_Disease5 = 1 if (stroke5 ==1 | heartfail5 == 1 | heartattack5 ==1 | otheheart5==1)

*Drop if lost to followup
drop if R03_A_SWGT==. & time==2
drop if (R03_A_SWGT==. | R04_A_C04WGT==.) & time==3
drop if (R03_A_SWGT==. | R04_A_C04WGT==. | R05_A_A01WGT==.) & time==4

*Drop if CVD occurs before outcome or is missing before outcome
drop if (time == 2 & CV_Disease2==1) | (time == 3 & (CV_Disease2==1 | CV_Disease3==1)) | (time == 4 & (CV_Disease2==1 | CV_Disease3==1 |CV_Disease4==1))
drop if (time == 2 & CV_Disease2==.) | (time == 3 & (CV_Disease2==. | CV_Disease3==.)) | (time == 4 & (CV_Disease2==. | CV_Disease3==. |CV_Disease4==.))

*Drop if missing outcome
drop if CV_Disease == .

*To get cases and exposure counts after using reshape not mi reshape above:
*tab CV_Disease cig_ecig_composite
*tab CV_Disease_3x cig_ecig_composite
*keep if time == 1
*tab cig_ecig_composite

save "MI2", replace



*******************************************************************************
*Analysis

* Compared to nonuse
foreach y in CV_Disease  CV_Disease_3x  {

use MI2, clear

mi stset time [pweight=R02_A_PWGT], failure(`y') id(CASEID)
mi estimate, hr: stcox i.cig_ecig_composite i.age male1 i.raceth1
mi estimate, hr: stcox i.cig_ecig_composite i.age male1 i.raceth1  i.educ  packyear packyearsquared noncombtob combtob everhypertension everhcholestrol everdiabetes ever_weed ever_fam_history bmi

}

*Compared to exclusive smoking
use MI2, clear

foreach y in CV_Disease  CV_Disease_3x  {

use MI2, clear
recode cig_ecig_composite (1=3)(3=1)(2=2)(4=4)(else=.), gen(cig_ref)

mi stset time [pweight=R02_A_PWGT], failure(`y') id(CASEID)
mi estimate, hr: stcox i.cig_ref i.age male1 i.raceth1 
mi estimate, hr: stcox i.cig_ref i.age male1 i.raceth1  i.educ  packyear packyearsquared noncombtob combtob everhypertension everhcholestrol everdiabetes ever_weed ever_fam_history bmi
}

*IRs
foreach y in CV_Disease CV_Disease_3x  {
use MI2, clear
mi svyset [pweight=R02_A_PWGT]
mi estimate, irr: svy: poisson `y' i.cig_ecig_composite i.age, exposure(time) 
mimrgns cig_ecig_composite , predict(ir)
}



