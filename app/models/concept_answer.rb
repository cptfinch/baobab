class ConceptAnswer < OpenMRS
  set_table_name "concept_answer"
  belongs_to :concept, :foreign_key => :concept_id
  belongs_to :answer_option, :class_name => "Concept", :foreign_key => :answer_concept
  belongs_to :user, :foreign_key => :user_id
#concept_answer_id
  set_primary_key "concept_answer_id"

  validates_uniqueness_of:answer_concept, :scope =>"concept_id"  

  def self.setup_reason_antiretrovirals_started
    reason_antiretrovirals_started = Concept.find_by_name("Reason antiretrovirals started")
    reason_antiretrovirals_started.concept_answers.each{|ca| ca.destroy}
    
    ["WHO stage 4 adult", "Lymphocyte count below threshold with WHO stage 2", "CD4 count", "CD4 percentage", "WHO stage 4 peds", "WHO stage 3 adult", "WHO stage 3 peds"].each{|reason|
      concept_answer = ConceptAnswer.new
      concept_answer.concept_id = reason_antiretrovirals_started.id
      concept_answer.answer_concept = Concept.find_by_name(reason).id
      puts "Created concept answer: #{reason} " if concept_answer.save!
    }
    

  end

  def setup_regimen_answers
    arv_regimen = Concept.find_by_name("ARV regimen")
    ["start","stop","switch"].each{|regimen|
      concept_answer = ConceptAnswer.new
      concept_answer.concept_id = arv_regimen.id
      concept_answer.answer_concept = Concept.find_by_name("ARV " + regimen).id
      concept_answer.save
    }
  end
  
  def setup_arv_formulation_answers
    arv_regimen = Concept.find_by_name("ARV formulation")
     ["C30", "C40", "AZT/3TC/NFP", "d4T/ETC/EFV", "AZT/3TC/LOPr/TDF"]
    ["start","stop","switch"].each{|regimen|
      concept_answer = ConceptAnswer.new
      concept_answer.concept_id = arv_regimen.id
      concept_answer.answer_concept = Concept.find_by_name("ARV " + regimen).id
      concept_answer.save
    }
  end
  
  def self.setup_extra_stage_defining_conditions
 
    puts "Reading in SDCs"
    
    unasked_stage_defining_condition_peds = <<EOF
Asymptomatic
Extensive wart virus infection
Extensive molluscum contagiosum
Recurrent oral ulcerations
Unexplained persistent parotid gland enlargement
Lineal gingival erythema
Oral hairy leukoplakia
Acute ulcerative mouth infections
Unexplained anaemia, neutropenia or thrombocytopenia
Symptomatic lymphoid interstitial pneumonia
Chronic HIV lung disease, including bronchiectasis
HIV-associated cardiomyopathy
HIV-associated nephropathy
Pneumocystis carinii pneumonia
Toxoplasmosis of the brain
Cryptosporidiosis or Isosporiasis
Cryptococcosis, extrapulmonary
Cytomegalovirus of an organ other than liver, spleen or lymph node
Progressive multifocal leucoencephalopathy
Any disseminated endemic mycosis
Atypical mycobacteriosis, disseminated or lung
Recurrent bacteraemia or sepsis with NTS
Lymphoma (cerebral or B-cell Non Hodgkin)
HIV encephalopathy
Other (Cancer cervix, visceral leishmaniasis)
EOF

    unasked_stage_defining_condition_adult = <<EOF
Asymptomatic
Oral hairy leukoplakia
Acute ulcerative mouth infections
Unexplained anaemia, neutropenia or thrombocytopenia
Pneumocystis carinii pneumonia
Toxoplasmosis of the brain
Cryptosporidiosis or Isosporiasis
Cryptococcosis, extrapulmonary
Cytomegalovirus of an organ other than liver, spleen or lymph node
Progressive multifocal leucoencephalopathy
Any disseminated endemic mycosis
Atypical mycobacteriosis, disseminated or lung
Recurrent bacteraemia or sepsis with NTS
Lymphoma (cerebral or B-cell Non Hodgkin)
HIV encephalopathy
Other (Cancer cervix, visceral leishmaniasis)
EOF

    puts "Reading in finding peds concepts"
    peds = Concept.find_by_name("WHO Stage defining conditions not explicitly asked peds")
    puts "Reading in finding adult concepts"
    adult = Concept.find_by_name("WHO Stage defining conditions not explicitly asked adult")
    puts "***************Creating concept answers PEDS"
    unasked_stage_defining_condition_peds.split("\n").each{|sdc|
      puts "#{sdc}"
      concept_answer = ConceptAnswer.new
      concept_answer.answer_concept= Concept.find_by_name(sdc).id
      concept_answer.concept_id = peds.id
      concept_answer.creator = User.current_user.id
      concept_answer.save or raise "Couldn't save"
    }
    puts "**************Creating concept answers adult"
    unasked_stage_defining_condition_adult.split("\n").each{|sdc|
      puts "#{sdc}"
      concept_answer = ConceptAnswer.new
      concept_answer.answer_concept= Concept.find_by_name(sdc).id
      concept_answer.concept_id = adult.id
      concept_answer.creator = User.current_user.id
      concept_answer.save or raise "Couldn't save"
    }
  
  end
end


### Original SQL Definition for concept_answer #### 
#   `concept_answer_id` int(11) NOT NULL auto_increment,
#   `concept_id` int(11) NOT NULL default '0',
#   `answer_concept` int(11) default NULL,
#   `answer_drug` int(11) default NULL,
#   `creator` int(11) NOT NULL default '0',
#   `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
#   PRIMARY KEY  (`concept_answer_id`),
#   KEY `answer_creator` (`creator`),
#   KEY `answer` (`answer_concept`),
#   KEY `answers_for_concept` (`concept_id`),
#   CONSTRAINT `answer` FOREIGN KEY (`answer_concept`) REFERENCES `concept` (`concept_id`),
#   CONSTRAINT `answers_for_concept` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
#   CONSTRAINT `answer_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
