******************************
*** Antenatal care ***********
******************************
* ANC visit
	*c_anc: 4+ antenatal care visits of births in last 2 years
	gen c_anc = (inrange(m14,4,20)) if m14<=20                         
	
	*c_anc_any: any antenatal care visits of births in last 2 years
	gen c_anc_any = (inrange(m14,1,20)) if m14<=20                         //the non-number label for byte value hard to specify.
// replace c_anc_any =1 if m2n == 0 // adjusted by m2n, turn m14 = 98 into 1


	*c_anc_bp: Blood pressure measured during pregnancy of births in last 2 years
	g c_anc_bp = 0 if m2n !=.   //  m2n covered more
	replace c_anc_bp = 1 if m42c == 1

	*c_anc_bp_q: Blood pressure measured during pregnancy among ANC users of births in last 2 years
	g c_anc_bp_q = c_anc_bp if c_anc_any==1 

	*c_anc_bs: Blood sample taken during pregnancy of births in last 2 years
	g c_anc_bs = 0 if m2n !=.  
	replace c_anc_bs = 1 if m42e == 1

	*c_anc_bs_q: Blood sample taken during pregnancy among ANC users of births in last 2 years
	g c_anc_bs_q = c_anc_bs if c_anc_any==1 

	*c_anc_ur: Urine sample taken during pregnancy of births in last 2 years
	g c_anc_ur = 0 if m2n !=.  
	replace c_anc_ur = 1 if m42d == 1

	*c_anc_ur_q: Urine sample taken during pregnancy among ANC users of births in last 2 years
	g c_anc_ur_q = c_anc_ur if c_anc_any==1

	*c_anc_ir: iron supplements taken during pregnancy of births in last 2 years
	g c_anc_ir =m45==1 if !inlist(m45,8,.)  // not a subquestion for anc visit

	*c_anc_ir_q: iron supplements taken during pregnancy among ANC users of births in last 2 years
	gen c_anc_ir_q = c_anc_ir if c_anc_any==1

	*c_anc_ear: First antenatal care visit in first trimester of pregnancy of births in last 2 years
	gen c_anc_ear = .
	
	replace c_anc_ear = 0 if m2n != .    // m13 based on Women who had seen someone for antenatal care for their last born child
	replace c_anc_ear = 1 if inrange(m13,0,3)
	replace c_anc_ear = . if m13 == 98 
	
	*c_anc_ear_q: First antenatal care visit in first trimester of pregnancy among ANC users of births in last 2 years
	g c_anc_ear_q = c_anc_ear if c_anc_any==1

	*c_anc_tet: pregnant women vaccinated against tetanus for last birth in last 2 years
	* cited from https://github.com/DHSProgram/DHS-Indicators-Stata/blob/master/Chap09_RH/RH_ANC.do
	gen tet2lastp = 0                                        				   //follow the definition by report.
	replace tet2lastp = 1 if m1 >1 & m1<8

	* temporary vars needed to compute the indicator
	gen totet = 0
	gen ttprotect = 0
	replace totet = m1 if (m1>0 & m1<8)
	replace totet = m1a + totet if (m1a > 0 & m1a < 8)

	*now generating variable for date of last injection - will be 0 for women with at least 1 injection at last pregnancy
	g lastinj = 9999
	replace lastinj = 0 if (m1 >0 & m1 <8)
	replace lastinj = (m1d  - b8) if m1d  <20 & (m1 ==0 | (m1 >7 & m1 <9996))                           // years ago of last shot - (age at of child), yields some negatives

	*now generate summary variable for protection against neonatal tetanus
	replace ttprotect = 1 if tet2lastp ==1
	replace ttprotect = 1 if totet>=2 &  lastinj<=2                                                     //at least 2 shots in last 3 years
	replace ttprotect = 1 if totet>=3 &  lastinj<=4                                                     //at least 3 shots in last 5 years
	replace ttprotect = 1 if totet>=4 &  lastinj<=9                                                     //at least 4 shots in last 10 years
	replace ttprotect = 1 if totet>=5                                                                   //at least 5 shots in lifetime
	lab var ttprotect "Full neonatal tetanus Protection"

	gen rh_anc_neotet = ttprotect
	label var rh_anc_neotet "Protected against neonatal tetanus"

	gen c_anc_tet = (rh_anc_neotet == 1) if  !mi(rh_anc_neotet)

	*c_anc_tet_q: pregnant women vaccinated against tetanus among ANC users for last birth in last 2 years
	gen c_anc_tet_q = (rh_anc_neotet == 1) if c_anc_any == 1 & !mi(rh_anc_neotet)

* c_anc_ski, c_anc_ski_q: cited from Aline: https://github.com/wengxyu1030/DHS-Recode-VII/blob/master/1_antenatal_care.do
	*anc_skill: Categories as skilled: doctor, nurse, midwife, auxiliary nurse/midwife...
	foreach var of varlist m2a-m2m {
		local lab: variable label `var'
		replace `var' = . if !regexm("`lab'","trained") & (!regexm("`lab'","doctor|nurse|midwife|mifwife|aide soignante|assistante accoucheuse|clinical officer|mch aide|auxiliary birth attendant|physician assistant|professional|ferdsher|feldshare|skilled|community health care provider|birth attendant|hospital/health center worker|hew|auxiliary|icds|feldsher|mch|vhw|village health team|health personnel|gynecolog(ist|y)|obstetrician|internist|pediatrician|family welfare visitor|medical assistant|health assistant|matron|general practitioner") ///
		|regexm("`lab'","na -|na^|-na|traditional birth attendant|untrained|unquallified|empirical midwife|box") )
		replace `var' = . if !inlist(`var',0,1)
		if regexm("`lab'","trained") | !(!regexm("`lab'","doctor|nurse|midwife|mifwife|aide soignante|assistante accoucheuse|clinical officer|mch aide|auxiliary birth attendant|physician assistant|professional|ferdsher|feldshare|skilled|community health care provider|birth attendant|hospital/health center worker|hew|auxiliary|icds|feldsher|mch|vhw|village health team|health personnel|gynecolog(ist|y)|obstetrician|internist|pediatrician|family welfare visitor|medical assistant|health assistant|matron|general practitioner") ///
		|regexm("`lab'","na -|na^|-na|traditional birth attendant|untrained|unquallified|empirical midwife|box") ){
			ren `var' `var'gskill
		}
	 }
	/* do consider as skilled if contain words in the first group but don't contain any words in the second group */
	egen anc_skill = rowtotal(m2a-m2m),mi
	
	*c_anc_ski: antenatal care visit with skilled provider for pregnancy of births in last 2 years
	gen c_anc_ski = 1 if anc_skill >= 1 & anc_skill!=.
	replace c_anc_ski = 0 if anc_skill == 0
	foreach var of varlist *gskill{
		replace c_anc_ski = . if anc_skill == 0 & mi(`var')
	}
	
	*c_anc_ski_q: antenatal care visit with skilled provider among ANC users for pregnancy of births in last 2 years
	gen c_anc_ski_q = c_anc_ski if c_anc_any == 1 

	*c_anc_eff: Effective ANC (4+ antenatal care visits, any skilled provider, blood pressure, blood and urine samples) of births in last 2 years
	egen anc_blood = rowtotal(m42c m42d m42e) if m2n != .
	gen c_anc_eff = (c_anc == 1 & anc_skill>0 & anc_blood == 3) 
	replace c_anc_eff = . if c_anc ==. |  anc_skill==. | anc_blood == .

	*c_anc_eff_q: Effective ANC (4+ antenatal care visits, any skilled provider, blood pressure, blood and urine samples) among ANC users of births in last 2 years
	gen c_anc_eff_q = c_anc_eff if c_anc_any == 1

	*c_anc_eff2: Effective ANC (4+ antenatal care visits, any skilled provider, blood pressure, blood and urine samples, tetanus vaccination) of births in last 2 years
	gen c_anc_eff2 = c_anc_eff ==1 & rh_anc_neotet == 1
	replace c_anc_eff2 = . if c_anc_eff ==. | rh_anc_neotet == .
	
	*c_anc_eff2_q: Effective ANC (4+ antenatal care visits, any skilled provider, blood pressure, blood and urine samples, tetanus vaccination) among ANC users of births in last 2 years
	gen c_anc_eff2_q = c_anc_eff2 if c_anc_any == 1

	*c_anc_eff3: Effective ANC (4+ antenatal care visits, any skilled provider, blood pressure, blood and urine samples, tetanus vaccination, start in first trimester) of births in last 2 years
	gen c_anc_eff3 = c_anc_eff2 ==1 & inrange(m13,0,3)
	replace c_anc_eff3 = . if c_anc_eff2 ==. | m13 == 98 

	*c_anc_eff3_q: Effective ANC (4+ antenatal care visits, any skilled provider, blood pressure, blood and urine samples, tetanus vaccination, start in first trimester) among ANC users of births in last 2 years
	gen c_anc_eff3_q = c_anc_eff3 if c_anc_any == 1

	*w_sampleweight.
	gen w_sampleweight = v005/10e6