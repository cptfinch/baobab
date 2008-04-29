require "composite_primary_keys"
require "ajax_scaffold"
class ConceptSet < OpenMRS
  set_table_name "concept_set"
  belongs_to :concept, :class_name => "Concept", :foreign_key => :concept_id
  belongs_to :set_concept, :class_name => "Concept", :foreign_key => :concept_set
  belongs_to :user, :foreign_key => :user_id
  set_primary_keys :concept_id, :concept_set
  validates_uniqueness_of:concept_id, :scope => "concept_set"

  # TODO - remove this!! Only need it until our data is synced 
 # self.fix_regimens
 #
 
  def to_s
    return "#{name}: #{self.set_concept.concepts.collect{|c|c.name}}"
  end

  def before_save
    super
    raise "Concept '#{self.set_concept.name}' is not a set - set the is_set property if you want it to be" unless self.set_concept.is_set
  end

  # inefficient code
  def self.find_by_name(name)
    ConceptSet.find_all.collect{|cs|cs if cs.name == name}.compact
  end

  def name
    self.set_concept.name
  end

  def self.find_concepts_in_set_named(concept_set_name)
    Concept.find_by_name(concept_set_name).concept_sets_controlled
  end

  def self.create(set_concept, concepts)
    concepts.each{|concept|
      concept_set = ConceptSet.new
      concept_set.set_concept = set_concept
      concept_set.concept_id = concept.concept_id
      concept_set.save
    }
  end

end

# Code does not work due to a bug in CPK
def self.add_weights_for_stages
  ConceptSet.find_all.each{|cs| 
    if cs.set_concept.name =~ /(\d)/ 
      puts "Setting sort weight for #{cs.set_concept.name} to #{$1.to_i*10}"
      cs.sort_weight = $1.to_i*10
    end
  }
end


def ConceptSet.assign_who_stage
  
  stage1_adults_and_children = <<EOF
Asymptomatic
Persistent Generalised lymphadenopathy
EOF

  stage2_adults = <<EOF
Unintentional weight loss< 10% of body weight in the absence of concurrent illness
Minor mucocutaneous manifestations (seborrheic dermatitis, prurigo, fungal nail infections, recurrent oral ulcerations, angular cheilitis)
Herpes zoster 
Recurrent upper respiratory tract infections (ie, bacterial sinusitis)
EOF

  stage2_children = <<EOF
Unexplained persistent hepatomegaly and splenomegaly
Papular itchy skin eruptions
Extensive wart virus infection
Extensive molluscum contagiosum
Recurrent oral ulcerations
Unexplained persistent parotid gland enlargement
Lineal gingival erythema
Herpes zoster
Recurrent or chronic respiratory tract infections (sinusitis, otorrhoea, tonsillitis, otitis media)
Fungal nail infections
EOF

  stage3_adults_and_children =<<EOF
Oral candidiasis
Oral hairy leukoplakia 
Unintentional weight loss > 10% of body weight in the absence of concurrent illness
Chronic diarrhoea > 1 month
Prolonged fever (intermittent or constant) > 1 month 
Active Pulmonary Tuberculosis 
PTB within the past 2 years
Severe bacterial infections (eg pneumonia, pyomyositis, sepsis)
Acute ulcerative mouth infections
Unexplained anaemia, neutropenia or thrombocytopenia
EOF

  stage3_additional_for_children =<<EOF
Moderate unexplained malnutrition
TB lymphadenopathy
Severe recurrent bacterial pneumonia
Symptomatic lymphoid interstitial pneumonia
Chronic HIV lung disease, including bronchiectasis
HIV-associated cardiomyopathy
HIV-associated nephropathy
EOF

  stage4_adults_and_children =<<EOF
HIV wasting syndrome (weight loss > 10% of body weight and either chronic fever or diarrhoea in the absence of concurrent illness)
Pneumocystis carinii pneumonia
Toxoplasmosis of the brain
Cryptosporidiosis or Isosporiasis 
Recurrent severe presumed pneumonia 
Cryptococcosis, extrapulmonary
Cytomegalovirus of an organ other than liver, spleen or lymph node
Herpes simplex infection, mucocutaneous for > 1 month or visceral
Progressive multifocal leucoencephalopathy
Any disseminated endemic mycosis
Candidiasis of oesophagus /trachea / bronchus
Atypical mycobacteriosis, disseminated or lung
Recurrent bacteraemia or sepsis with NTS
Extrapulmonary tuberculosis (EPTB) 
Lymphoma (cerebral or B-cell Non Hodgkin)
Kaposi's sarcoma
HIV encephalopathy
Other (Cancer cervix, visceral leishmaniasis)
EOF

  stage4_additional_for_children = <<EOF
Unexplained severe wasting, stunting or malnutrition not responding to treatment
Recurrent severe presumed bacterial infections (eg empyema, sepsis, meningitis, bone or joint)
EOF

  stage_concepts = Hash.new 
  stage_concepts["WHO stage 1 adult"] = stage1_adults_and_children.split("\n")
  stage_concepts["WHO stage 1 peds"] = stage1_adults_and_children.split("\n")
  stage_concepts["WHO stage 2 adult"] = stage2_adults.split("\n")
  stage_concepts["WHO stage 2 peds"] = stage2_children.split("\n")
  stage_concepts["WHO stage 3 adult"] = stage3_adults_and_children.split("\n")
  stage_concepts["WHO stage 3 peds"] = stage3_adults_and_children.split("\n") + stage3_additional_for_children.split("\n")
  stage_concepts["WHO stage 4 adult"] = stage4_adults_and_children.split("\n")
  stage_concepts["WHO stage 4 peds"] = stage4_adults_and_children.split("\n") + stage4_additional_for_children.split("\n")

  stages_concept_sets = Hash.new
  1.upto(4){|index|
    stages_concept_sets["WHO stage #{index} adult"] = Concept.find_by_name "WHO Stage #{index} adult"
    stages_concept_sets["WHO stage #{index} peds"] = Concept.find_by_name "WHO Stage #{index} peds"
  }

  User.current_user = User.find_by_username "mikeymckay"
  concept_class = ConceptClass.find_by_name "Question"
  concept_datatype = ConceptDatatype.find_by_name "Coded"
  field_type = FieldType.find_by_name "select"
  concept_answers = [Concept.find_by_name("YES"), Concept.find_by_name("NO"), Concept.find_by_name("UNKNOWN")]
  stage_concepts.each{|stage_category, diagnosis_array|
    puts "Creating form: **" + stage_category + "**"
    form = Form.new
    form.name = stage_category
    form.uri = stage_category.downcase.gsub(/ /,"_")
    form.creator = User.current_user.id
    form.save
    field_index = 1

    diagnosis_array.each{|diagnosis|
      puts "Creating concept: " + diagnosis
      concept = Concept.new
      concept.class_id = concept_class.concept_class_id
      concept.datatype_id = concept_datatype.concept_datatype_id
      concept.name = diagnosis
      concept.creator = User.current_user.id
      concept.save
      concept = Concept.find_by_name(diagnosis) if concept.concept_id.nil?
      
      puts "Adding to concept_set: " + stages_concept_sets[stage_category].name
      concept_set = ConceptSet.new
      concept_set.concept_set = stages_concept_sets[stage_category].concept_id
      concept_set.concept_id = concept.concept_id
      concept_set.creator = User.current_user.id
      concept_set.save
      
      puts "Creating concept_answers"
      concept_answers.each{|answer|
        concept_answer = ConceptAnswer.new
        concept_answer.answer_concept= answer.id
        concept_answer.concept_id = concept.concept_id
        concept_answer.creator = User.current_user.id
        concept_answer.save
      }
      puts "Creating field: " + concept.name
      field = Field.find_or_create_by_name(concept.name)
      field.field_type = field_type.id
      field.concept = concept
      field.name = concept.name
      field.select_multiple = false
      field.creator = User.current_user.id
      field.save
      
      puts "Linking field to form: " + field_index.to_s
      form_field = FormField.new
      form_field.form_id = form.id
      form_field.field_id = field.id
      form_field.field_number = field_index+=1
      form_field.creator = User.current_user.id
      form_field.save
    }
    puts "Finished with: " + stage_category
  }
end

def ConceptSet.destroyme
  # This removed bad data created by above
  return;
  ActiveRecord::Base.connection.update "SET FOREIGN_KEY_CHECKS = 0"
  Concept.find(:all, :conditions => "date_created > '2006-11-16 16:00:00'").each{|f|f.destroy}
  ConceptSet.find(:all, :conditions => "date_created > '2006-11-16 16:00:00'").each{|f|f.destroy}
  ConceptAnswer.find(:all, :conditions => "date_created > '2006-11-16 16:00:00'").each{|f|f.destroy}
  Form.find(:all, :conditions => "date_created > '2006-11-16 16:00:00'").each{|f|f.destroy}
  Field.find(:all, :conditions => "date_created > '2006-11-16 16:00:00'").each{|f|f.destroy}
  FormField.find(:all, :conditions => "date_created > '2006-11-16 16:00:00'").each{|f|f.destroy}
  ActiveRecord::Base.connection.update "SET FOREIGN_KEY_CHECKS = 1"
end

### Original SQL Definition for concept_set #### 
#   `concept_id` int(11) NOT NULL default '0',
#   `concept_set` int(11) NOT NULL default '0',
#   `sort_weight` double default NULL,
#   `creator` int(11) NOT NULL default '0',
#   `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
#   PRIMARY KEY  (`concept_id`,`concept_set`),
#   KEY `has_a` (`concept_set`),
#   KEY `user_who_created` (`creator`),
#   CONSTRAINT `has_a` FOREIGN KEY (`concept_set`) REFERENCES `concept` (`concept_id`),
#   CONSTRAINT `is_a` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
#   CONSTRAINT `user_who_created` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
