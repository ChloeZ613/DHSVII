**************************
*** Child illness ********
**************************
/*Note:
The structure of generatin disease-treatment variables (c_treatARI, c_treatARI2, c_diarrhea_pro, c_fevertreat,  )
is cited from Haozheyi's Github: https://github.com/hzyguan888/Git-DHS-Recode-VII/blob/master/8_child_illness.do
*/
******** ARI* c_ari	Children under 5 with cough and rapid breathing in the two weeks preceding the survey which originated from the chest.
	recode h31b h31c h31 (8 9 =.)
	gen ccough=(h31  ==1|h31  ==2)  if h31 !=.
	gen rbchest = (h31b == 1 & inlist(h31c,1,3)) if h31b !=.
	g c_ari = (rbchest==1 & ccough==1) if ccough+rbchest!=.
		
	*c_ari2: Children under 5 with cough and rapid breathing in the two weeks preceding the survey.
	gen c_ari2=(h31b == 1 & ccough == 1) if  h31b+ccough !=.

	* c_treatARI/c_treatARI2: Child with acute respiratory infection (ARI) /ARI2 symptoms seen by formal provider
	* Cited from Haozheyi's code
	order h32a-h32x,sequential
	if ~inlist(name,"Benin2017") {
		foreach var of varlist h32a-h32x {
			local lab: variable label `var'
			replace `var' = . if regexm("`lab'","( other|shop|pharmacy|market|kiosk|relative|friend|church|drug|addo|rescuer|trad|unqualified|stand|cabinet|ayush|^na)") ///
		& !regexm("`lab'","(ngo|hospital|medical center|worker)")
		replace `var' = . if !inlist(`var',0,1)
		}
		/* do not consider formal if contain words in the first group but don't contain any words in the second group */
	
		egen pro_ari = rowtotal(h32a-h32x),mi
		gen c_treatARI= pro_ari >= 1 if c_ari == 1 & pro_ari != .
		gen c_treatARI2= pro_ari >= 1 if c_ari2 == 1 & pro_ari != .
	 }

	/*
	if inlist(name,"Uganda2016") {
	  global h32 "h32a h32b h32c h32d h32j h32l h32m h32n"

	}
	foreach var in $h32 {
	  replace c_treatARI = 1 if c_treatARI == 0 & `var' == 1
	  replace c_treatARI = . if `var' == 8
	  replace c_treatARI2 = 1 if c_treatARI2 == 0 & `var' == 1
	  replace c_treatARI2 = . if `var' == 8
	}
	*/

* Diarrhea
	* c_diarrhea: Child with diarrhea in last 2 weeks
	g c_diarrhea = inlist(h11,1,2) if !inlist(h11,.,8,9)

	* c_diarrhea_hmf: Child with diarrhea received recommended home-made fluids
	g c_diarrhea_hmf = inlist(h14,1,2) if !inlist(h14,.,8,9) & c_diarrhea == 1

	* c_treatdiarrhea: Child with diarrhea receive oral rehydration salts (ORS)
	recode h13 (8=.)
	cap gen h13b  =.
	g c_treatdiarrhea = (inlist(h13,1,2) | h13b ==1) if c_diarrhea ==1 & (h13!=. | h13b!=.)

	* c_diarrhea_pro: The treatment was provided by a formal provider (all public provider except other public, pharmacy, and private sector)
	* Cited from Haozheyi's Code
	if ~inlist(name,"Philippines2017") {
		order h12a-h12x,sequential
		foreach var of varlist h12a-h12x {
			local lab: variable label `var'
			replace `var' = . if regexm("`lab'","( other|shop|pharmacy|market|kiosk|relative|friend|church|drug|addo|rescuer|trad|unqualified|stand|cabinet|ayush|^na)") ///
			& !regexm("`lab'","(ngo|hospital|medical center|worker)")
			replace `var' = . if !inlist(`var',0,1)
	  }
		egen pro_dia = rowtotal(h12a-h12x),mi

		gen c_diarrhea_pro = pro_dia >= 1 if c_diarrhea == 1 & pro_dia != .
	}
	
	*c_diarrhea_med: Child with diarrhea received any medicine other than ORS or hmf
	recode h12z h15 h15a h15b h15c h15d h15e h15f h15g h15h h15i (8=.)
	egen med =rowtotal(h12z h15 h15a h15b h15c h15d h15e h15f h15g h15h h15i),mi
	gen c_diarrhea_med = ( med !=0) if c_diarrhea == 1   // formal medicine don't include "home remedy, herbal medicine and other"
	replace c_diarrhea_med = . if h12z+h15+h15a+h15b+h15c+h15d+h15e+h15f+h15g+h15h+h15i==.

	*c_diarrhea_medfor: Get formal medicine except (ors hmf home other_med).
	recode h12z h15 h15a h15b h15c h15e h15g h15h h15i (8=.)
	egen medfor =rowtotal(h12z h15 h15a h15b h15c h15e h15g h15h h15i),mi
	gen c_diarrhea_medfor = ( medfor !=0) if c_diarrhea == 1   // formal medicine don't include "home remedy, herbal medicine and other"
	replace c_diarrhea_medfor = . if h12z+h15+h15a+h15b+h15c+h15e+h15g+h15h+h15i == .

	*c_diarrhea_mof: Child with diarrhea received more fluids
	gen c_diarrhea_mof = (h38 == 5) if !inlist(h38,.,8) & c_diarrhea == 1

	* c_diarrheaact: Child with diarrhea seen by provider OR given any form of formal treatment
	gen c_diarrheaact = (c_diarrhea_pro==1 | c_diarrhea_medfor==1 | c_diarrhea_hmf==1 | c_treatdiarrhea==1) if c_diarrhea == 1
	replace c_diarrheaact = . if (c_diarrhea_pro == . | c_diarrhea_medfor == . | c_diarrhea_hmf == . | c_treatdiarrhea == .) & c_diarrhea == 1

	* c_diarrheaact_q: Child under 5 with diarrhea in last 2 weeks seen by formal healthcare provider or given any form of treatment who received ORS
	gen c_diarrheaact_q = c_treatdiarrhea  if c_diarrheaact == 1

* Fever
	* c_fever: Child with a fever in last two weeks
	g c_fever = h22 == 1  if !inlist(h22,.,8,9)
	
	* c_fevertreat: Child with fever symptoms seen by formal provider
	* Cited from Haozheyi's Code
	if ~inlist(name,"Benin2017") {
		gen c_fevertreat = pro_ari >= 1 if c_fever == 1 & pro_ari != .
	}	
/*
  foreach var in h32a h32b h32c h32d h32j h32l h32m h32n  {
    replace c_fevertreat = 1 if c_fevertreat == 0 & `var' == 1
    replace c_fevertreat = . if `var' == . | `var' == 8
  }
*/

* Severe Diarrhea
	* c_sevdiarrhea: Child with severe diarrhea
	gen eat = (inlist(h39,0,1,2)) if !inlist(h39,.,8,9) & c_diarrhea == 1
	g c_sevdiarrhea = c_diarrhea ==1 & (eat ==1 | c_diarrhea_mof == 1 | c_fever ==1 )	 
	replace c_sevdiarrhea = . if c_diarrhea == . | c_fever == . | (c_diarrhea == 1 & (c_diarrhea_mof ==.| eat==.))

	* c_sevdiarrheatreat: Child with severe diarrhea seen by formal healthcare provider
        gen c_sevdiarrheatreat = (c_sevdiarrhea == 1 & c_diarrhea_pro == 1) if c_diarrhea == 1
	replace c_sevdiarrheatreat = . if c_sevdiarrhea == . | c_diarrhea_pro == .

	* c_sevdiarrheatreat_q: IV (intravenous) treatment of severe diarrhea among children with any formal provider visits
	gen iv = (h15c == 1) if !inlist(h15,.,8) & c_diarrhea == 1
	gen c_sevdiarrheatreat_q = (iv ==1 ) if c_sevdiarrheatreat == 1

* Illness (may need change)
	*c_illness: Child with any illness symptoms in last two weeks
	g c_illness = (c_ari==1 | c_diarrhea==1 | c_fever==1) if (c_ari+c_diarrhea+c_fever!=.)
	g c_illness2 = (c_diarrhea == 1 | c_ari2 == 1 | c_fever == 1) if (c_ari2+c_diarrhea+c_fever!=.)

	*c_illtreat: Child with any illness symptoms taken to formal provider
	gen c_illtreat = (c_fevertreat == 1 | c_diarrhea_pro == 1 | c_treatARI == 1) 
	replace c_illtreat = . if (c_fevertreat == 1 & c_fever == .) | (c_diarrhea == 1 & c_diarrhea_pro == .) | (c_ari == 1 & c_treatARI == .)
	
	gen c_illtreat2 = (c_fevertreat == 1 | c_diarrhea_pro == 1 | c_treatARI == 1) if c_illness2 == 1 & (c_fevertreat+c_diarrhea_pro+c_treatARI !=.)
	replace c_illtreat2 = . if (c_fevertreat == 1 & c_fever == .) | (c_diarrhea == 1 & c_diarrhea_pro == .) | (c_ari2 == 1 & c_treatARI2 == .)
