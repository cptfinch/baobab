require 'paper_mastercard_entry'

class PaperMastercard

  attr_accessor :arv_number, :first_name, :last_name, :age, :sex, :initial_weight, :initial_height, :transfer_in, :location, :address, :occupation, :guardian_name, :hiv_test_date, :hiv_test_place, :followup, :date_of_starting_1st_line, :date_of_starting_1st_line_alternative, :date_of_starting_2nd_line, :reason_for_starting, :ptb, :eptb, :aptb, :ks, :pmtct, :third_visit_date, :height3, :weight3 , :last_outcome,:third_outcome, :third_reg, :third_amb, :third_wrk_sch, :third_side_effects, :third_pill_count, :third_receiver_guardian_patient, :third_cpt, :scd_visit_date, :scd_outcome, :height2 , :weight2, :scd_outcome, :scd_reg, :scd_amb, :scd_wrk_sch, :scd_side_effects, :scd_pill_count, :scd_receiver_guardian_patient, :scd_cpt, :first_visit_date, :weight1 , :height1, :first_outcome, :first_reg, :first_amb, :first_wrk_sch, :first_side_effects, :first_pill_count, :first_receiver_guardian_patient,:first_pill_count, :first_cpt,:year1,:year2,:year3,:month1,:month2,:month3 ,:day1,:day2,:day3,:starter

# TODO need to get the date for events like transfer in
#
  def self.to_patients(patient_obj)
    patient = Patient.new
    patient.save

    [:arv_number, :first_name, :last_name, :age, :sex, :initial_weight, :initial_height, :transfer_in, :location, :address, :occupation, :guardian_name, :hiv_test_date, :hiv_test_place, :followup, :date_of_starting_1st_line, :date_of_starting_1st_line_alternative, :date_of_starting_2nd_line, :reason_for_starting, :ptb, :eptb, :aptb, :ks, :pmtct, :last_visit_date, :last_wt, :last_ht, :last_outcome, :last_reg, :last_amb, :last_wrk_sch, :last_side_effects, :last_pill_count, :last_receiver_guardian_patient, :last_cpt].each{ |field| 
      case field
        when :location
          patient.current_place_of_residence = patient_obj.location  unless patient_obj.location.nil?
        when :first_name           
          #patient.send("set_#{field}", patient_obj.send(field)) unless patient_obj.send(field).nil?
          patient.set_first_name(patient_obj.first_name)
        when :last_name
          patient.set_last_name(patient_obj.last_name)
        when :arv_number,:age, :sex, :location, :address, :occupation, :guardian_name
         # patient.send("#{field}=", patient_obj.send(field)) unless patient_obj.send(field).nil?
        else
          #patient.send("set_#{field}", patient_obj.send(field), patient_obj.date_of_starting_1st_line) unless  patient_obj.send(field).nil?
      end
    }
    #puts patient.to_yaml
  end
  
  def self.location_name(location_name)
    lacation_id=Location.find_by_sql("select location_id from location where name like \"%#{location_name.strip[0..8]}%\"  limit 1")
    location_id = location_id.id unless location_id.nil?
    if location_id.nil? 
      self.add_new_location(location_name) 
      location_id= Location.find_by_name(location_name).id
    end 
    return Location.find_by_location_id(location_id).name
  end
  
  def self.add_new_location(location_name)
    location = Location.new
    location.name = location_name
    location.date_created = Date.today
    location.save 
  end

  def self.set_guardian_name_sex(guardian)
     
     guardian_data = Array.new()
     if guardian.match(/sister|mother|niece|wife|Daughter|aunt|mrs/i)
        sex ="Female"
        guardian = guardian.gsub(/\(|\)|sister|mother|niece|wife|Daughter|aunt|mrs/i,"").strip
     elsif guardian.match(/brother|father|nephew|husband|mr|son/i)
        sex="Male"
        guardian = guardian.gsub(/\(|\)|brother|father|nephew|husband|mr|son/i,"").strip
     else
        sex="Female"
     end
   
    if guardian.match(/(.*)([,|\(|\s].*)/) 
      first_name =  guardian.match(/(.*)([,|\(|\s].*)/)[1].to_s
      last_name =  guardian.match(/(.*)([,|\(|\s].*)/)[2].to_s
      if first_name.match(/(.*)([,|\(|\s].*)/)
        l_name = first_name.match(/(.*)([,|\(|\s].*)/)[2].to_s
        f_name = first_name.match(/(.*)([,|\(|\s].*)/)[1].to_s
        first_name =f_name 
        last_name = l_name 
      end
    else 
      first_name = guardian.to_s      
      last_name = ""
    end 
    
    if first_name.match(/(.*)([,|\(|\s].*)/)
      f_name = first_name.match(/(.*)([,|\(|\s].*)/)[1].to_s
      l_name = first_name.match(/(.*)([,|\(|\s].*)/)[2].to_s
      first_name =f_name 
      last_name = l_name 
    end
    
    if last_name.match(/(.*)([,|\(|\s].*)/)
      chk_data =last_name.match(/(.*)([,|\(|\s].*)/)[2]
      last_name = last_name.match(/(.*)([,|\(|\s].*)/)[2].to_s unless chk_data.match(/brother|father|nephew|husband|son|sister|mother|niece|wife|Daughter|aunt/i)
    end
     
    return guardian_data = first_name.strip, last_name.strip,sex 
  end

  def self.to_patient(patient_obj,count)
    puts "writing patient data:       Patient number #{count}"
    patient = Patient.new
    patient.save
    patient.gender = patient_obj.sex
    patient.set_national_id
    patient.set_name(patient_obj.first_name,patient_obj.last_name)
    init_date = patient_obj.first_visit_date.to_date unless patient_obj.first_visit_date.nil?
    init_date = Date.today if init_date.nil?
    patient.add_program_by_name("HIV")
    test_date = patient_obj.hiv_test_date
    #test_date = init_date if test_date.nil?
    patient.set_hiv_test_date(test_date) unless test_date.nil?
    location_name = self.location_name(patient_obj.hiv_test_place) unless patient_obj.hiv_test_place.nil?
    patient.set_hiv_test_location(location_name,test_date) unless location_name.nil? and test_date.nil?

    [:arv_number,:initial_weight, :initial_height,:age,:transfer_in, :location, :address, :occupation, :guardian_name,:followup, :date_of_starting_1st_line, :date_of_starting_1st_line_alternative, :date_of_starting_2nd_line,:ptb, :eptb, :aptb, :ks, :pmtct, :last_visit_date, :last_wt, :last_ht, :last_outcome, :last_reg, :last_amb, :last_wrk_sch, :last_side_effects, :last_pill_count, :last_receiver_guardian_patient, :last_cpt,:reason_for_starting].each{ |field| 
      case field
        when :location
          patient.current_place_of_residence = (patient_obj.location)  unless patient_obj.location.nil?
        when :occupation,:arv_number,:age
          patient.send("#{field}=", patient_obj.send(field)) unless patient_obj.send(field).nil?
        when :address
          patient.current_place_of_residence=(patient_obj.address) unless patient_obj.address.nil?
        when :guardian_name
          next if patient_obj.send(field).nil?
          guardian_data =Array.new()
          guardian_data = self.set_guardian_name_sex(patient_obj.guardian_name)
          patient.create_guardian(guardian_data.first,guardian_data[1],guardian_data.last) unless guardian_data.nil?
        when :transfer_in
          patient.set_transfer_in(patient_obj.send(field),init_date)
        when :ptb,:eptb,:aptb,:ks,:followup
          next if patient_obj.send(field).nil?
          if patient_obj.send(field).match(/on|yes/i)
            value = "Yes"
          elsif  patient_obj.send(field).match(/No/i)
            value = "No"
          end 
          
          concept_name="PTB within the past 2 years" if field.to_s == "ptb"
          concept_name="Extrapulmonary tuberculosis (EPTB)" if field.to_s == "eptb"
          concept_name="Active Pulmonary Tuberculosis" if field.to_s == "aptb"
          concept_name="Kaposi's sarcoma" if field.to_s == "ks"
          concept_name="Referred by PMTCT" if field.to_s == "pmtct"
          concept_name="Agrees to followup" if field.to_s == "followup"
          patient.set_art_staging_encounter(concept_name,value,init_date) 
        when :reason_for_starting
          next if patient_obj.reason_for_starting.blank?
          reasons=Array.new()
          reasons = patient_obj.reason_for_starting.split(/,/)
#          reasons = self.starting_reasons(patient_obj.reason_for_starting) if  patient_obj.reason_for_starting.match(/,/)
          
#          if reasons.empty? || reasons.nil?
#            stage_defining_condition = Concept.find_by_sql("select name from concept where name like '%#{patient_obj.reason_for_starting}%' limit 1")
#            value = stage_defining_condition.to_s unless stage_defining_condition.nil? || stage_defining_condition.empty?
#            value = self.validate_reason_for_starting(patient_obj.reason_for_starting) if value.nil?
#            patient.set_art_staging_encounter(value.to_s,"Yes",init_date) unless value.nil? or value=="CD4 Count < 250" 
#            patient.set_art_staging_int_cd4(0,"",init_date) if value=="CD4 Count < 250"
#          else
            reasons.each{|reason|
              reason = self.validate_reason_for_starting(reason)
              next if reason.nil? || reason.empty?
              patient.set_art_staging_encounter(reason.to_s,"Yes",init_date) unless reason.to_s =="CD4 Count < 250"
              patient.set_art_staging_int_cd4(0,"",init_date) if reason.to_s=="CD4 Count < 250"
            }
#          end    
           
        when :initial_weight
          next if patient_obj.send(field).nil?
          patient.set_initial_weight(patient_obj.send(field),init_date)
        when :initial_height 
          next if patient_obj.send(field).nil?
          patient.set_initial_height(patient_obj.send(field),init_date)
      end
    }
    #self.enter_visit_data(patient,patient_obj)
    self.infer_and_create_first_visit(patient)
  end
  
  def self.starting_reasons(value)
     reasons=Array.new()
     
     while value.match(/(.*)([,].*)/)
       valid_reason = value.match(/(.*)([,].*)/)[2].gsub(/\,/,"")
       reason = Concept.find_by_sql("select name from concept where name like \"%#{valid_reason}%\" limit 1")
       reasons << reason.to_s unless reason.nil? || reason.empty?
       reasons << self.validate_reason_for_starting(valid_reason) if reason.nil? || reason.empty?
       value = value.match(/(.*)([,].*)/)[1]
     end   
     reason = Concept.find_by_sql("select name from concept where name like \"%#{value}%\" limit 1")
     reason = self.validate_reason_for_starting(value) if reason.nil? || reason.empty?
     reasons << reason.to_s unless reason.nil? || reason.empty?
     return reasons.uniq 
  end

  def self.validate_reason_for_starting(value)
    
    stage_defining_conditions_map = {"active ptb" => "Active Pulmonary Tuberculosis ",
    "candidiasis of oesophagus" => "Candidiasis of oesophagus /trachea / bronchus",
    "chronic diarrhoea" => "Chronic diarrhoea for more than 1 month",
    "cryptococcosis extrapulmonary" => "Cryptococcosis, extrapulmonary",
    "disseminated endemic mycosis" => "Any disseminated endemic mycosis",
    "eptb" => "Extrapulmonary tuberculosis (EPTB) ",
    "herpes simplex inf" => "Herpes simplex infection, mucocutaneous for longer than  1 month or visceral",
    "hiv encephalopathy" => "HIV encephalopathy",
    "hiv wasting syndrome" => "HIV wasting syndrome (weight loss more than 10% of body weight and either chronic fever or diarrhoea in the absence of concurrent illness)",
    "kaposis sarcoma" => "Kaposi's sarcoma",
    "lymphoma" => "Lymphoma (cerebral or B-cell Non Hodgkin)",
    "minor muco manifest" => "Minor mucocutaneous manifestations (seborrheic dermatitis, prurigo, fungal nail infections, recurrent oral ulcerations, angular cheilitis)",
    "asymptomatic" => "Asymptomatic",
    "herpes zoster" => "Herpes zoster",
    "prolonged fever" => "Prolonged fever (intermittent or constant) for more than 1 month",
    "ptb within past 2 years" => "PTB within the past 2 years",
    "severe bacterial inf" => "Severe bacterial infections (eg pneumonia, pyomyositis, sepsis)",
    "severe recurrent bacterial pneumonia" => "Severe recurrent bacterial pneumonia",
    "tb lymphodenopathy" => "TB lymphadenopathy",
    "unexp severe wasting stunting or malnutrition" => "Unintentional weight loss: more than 10% of body weight in the absence of concurrent illness",
    "uwl gt 10 percent" => "Unintentional weight loss: more than 10% of body weight in the absence of concurrent illness",
    "stage 1 condition" => "Unspecified stage 1 condition",
    "stage 2 condition" => "Unspecified stage 2 condition",
    "stage 3 condition" => "Unspecified stage 3 condition",
    "stage 4 condition" => "Unspecified stage 4 condition",
    "unspecified stage 1 condition" => "Unspecified stage 1 condition",
    "unspecified stage 2 condition" => "Unspecified stage 2 condition",
    "unspecified stage 3 condition" => "Unspecified stage 3 condition",
    "unspecified stage 4 condition" => "Unspecified stage 4 condition",
    "oral candidiasis" => "Oral candidiasis",
    "oral hairy leukoplakia" => "Oral hairy leukoplakia",
    "pneumocystis carinii pneumonia" => "Pneumocystis carinii pneumonia",
    "prolonged fever" => "Prolonged fever (intermittent or constant) for more than 1 month",
    "ptb within past year" => "PTB within the past 2 years",
    "severe bacterial inf" => "Severe bacterial infections (eg pneumonia, pyomyositis, sepsis)",
    "toxoplasmosis of brain" => "Toxoplasmosis of the brain",
    "uwl gt 10 percent" => "Unintentional weight loss: more than 10% of body weight in the absence of concurrent illness",
    "uwl lt 10 percent" => "Unintentional weight loss in the absence of concurrent illness",
    "vulvo vaginal candidiasis" => "Oral candidiasis"}

    value.downcase!
    value.gsub!(/new /, "")

    return "CD4 Count < 250" if value.match(/cd/i)
    return stage_defining_conditions_map[value]

#     return "PTB within the past 2 years" if value.match(/Ptb/i) and  value.match(/past/i)
#     return "Unintentional weight loss: more than 10% of body weight in the absence of concurrent illness" if value.match(/Uwl gt 10 percent/i) 
#     return "Kaposi's sarcoma" if value.match(/ks|Kaposis/i)
#     return "Oral candidiasis" if value.match(/candidiasis/i)
#     return "Chronic diarrhoea for more than 1 month" if value.match(/diarrhoea/i)
#     return "Cryptococcosis, extrapulmonary" if value.match(/Cryptococcosis/i)
#     return "Unspecified stage 4 condition" if value.match(/4|IV/i) and !value.match(/cd/i) and !value.match(/active/i)
#     return "Unspecified stage 3 condition" if value.match(/3|III|lll/i)
#     return "Unspecified stage 2 condition" if value.match(/2|II|ll/i) and !value.match(/past/i)
#     return "CD4 Count < 250" if value.match(/cd/i)
#     return "Active Pulmonary Tuberculosis" if value.match(/aptb/) || value.match(/eptb/) || value.match(/tb/i) || value.match(/ptb/i)
#     return value
  end

  def self.get_all
    entry="C"
    #all_arv_numbers = PaperMastercardEntry.find_by_sql("SELECT DISTINCT arvnumber FROM paper_mastercards where entry='#{entry}'").collect{|e|e.arvnumber}
    all_arv_numbers = PaperMastercardEntry.find_by_sql("SELECT DISTINCT arvnumber FROM mastercards where entry='#{entry}'").collect{|e|e.arvnumber}
    return all_arv_numbers
  end

  def self.process_all
    count = 0
    paper_mastercard = Array.new()
    self.get_all.each{|arv_number|
      puts "Processing #{arv_number}...patient number #{count+= 1}"
      paper_mastercard << self.get_required_data(arv_number) 
    }
    return paper_mastercard
  end
  
  def self.create_patients
    count = 0
    User.current_user = User.find_by_username("administrator")
    return "Current user not set..!! set Current User" if User.current_user.blank?
    patients=self.process_all
    patients.each{|pat|
     #puts "Processing #{pat.arv_number}..."
     count+= 1
     self.to_patient(pat,count) 
    }
  end

  # This is an example for how to get input from the console
  def self.get_input_from_console
    puts "Select an option: 1: Yo, 2: Bee, 3: Ciao "
    # This reads data from the console and removes the newline
    selection = $stdin.gets.chomp
    case selection
      when "1"
        puts "You select 1"
      when "2"
        puts "You select 2"
      when "3"
        puts "You select 3"
    end
  end

  def self.get_required_data(arv_number)    
    paper_mastercard = PaperMastercard.new
    # EASY ONES
    paper_mastercard.arv_number = arv_number
    ["first_name","last_name","age","sex","initial_weight","initial_height","transfer_in","address","guardian_name", "hiv_test_place", "reason_for_starting", "ptb", "eptb", "ks", "pmtct","follow_up","alive1","year1","month1","day1","weight1","height1","amb1","alive1","wrk_sch_yes1","side_effects1","arv_given_patient1","dead1","alive2","year2","month2","day2","weight2","height2","amb2","alive2","wrk_sch_yes2","side_effects2","arv_given_patient2","dead2","cpt1","cpt2","formulation","pills_remaining2","pills_remaining1","default1","default2","wrk_sch_no2","wrk_sch_no1","arv_given_guardian1","arv_given_guardian2"].each{|field|
      value = PaperMastercardEntry.find_first_value_by_arv_number_and_field_id(arv_number, field)
      case field
        when "month2","day2","year2","year1","month1","day1"
          next if value.nil?
        when "pills_remaining2","pills_remaining1"
          value = 0 if field == "pills_remaining2" and value.nil? 
          next if value.nil?
          field = "first_pill_count" if field == "pills_remaining1" 
          field = "scd_pill_count" if field == "pills_remaining2" 
        when "formulation" #"start2","start1","start3"
          next if value.nil?
          field = "scd_reg" if field == "formulation"
          paper_mastercard.starter = value
          #field = "starter" if field == "formulation" 
          #field = "first_reg" if field == "start1" 
          #field = "scd_reg" if field == "start2" 
          #field = "third_reg" if field == "start3" 
        when "arv_given_patient2","arv_given_patient1","arv_given_guardian1","arv_given_guardian2"
          next if value.nil?
          value ="Yes" if value.match(/on/i)
          field="first_receiver_guardian_patient" and value="P" if field=="arv_given_patient1"
          field="scd_receiver_guardian_patient" and value="P" if field=="arv_given_patient2"
          field="first_receiver_guardian_patient" and value="G" if field=="arv_given_guardian1"
          field="scd_receiver_guardian_patient" and value= "G" if field=="arv_given_guardian2"

        when "dead2","dead1","alive1","alive2","default2","default1"
          value = "on" if field.match(/alive/i) and value.nil?
          next if value.nil?
          field = "first_outcome" and value = "Alive" if field=="alive1" 
          field = "scd_outcome" and value = "Alive" if field=="alive2" 
          field = "first_outcome" and value = "Died" if field=="dead1" 
          field = "scd_outcome" and value = "Died" if field=="dead2" 
          field = "defaulter" and value = "Defaulter" if field=="default1" 
          field = "scd_outcome" and value = "Defaulter"  if field=="default2"

        when "wrk_sch_yes1","wrk_sch_yes2","amb1","amb2","wrk_sch_no2","wrk_sch_no1"
          next if value.nil?
          value ="Yes" if value.match(/on/i)
          field="scd_wrk_sch" if field=="wrk_sch_yes2"
          field="first_wrk_sch" if field=="wrk_sch_yes1"
          field="scd_amb" if field=="amb2"
          field="first_amb" if field=="amb1"
          field="scd_wrk_sch" and value="No"  if field=="wrk_sch_no2"
          field="first_wrk_sch" and value="No" if field=="wrk_sch_no1"
          
        when "side_effects1","side_effects2"
          next if value.nil?
          field="first_side_effects" if field == "side_effects1"
          field="scd_side_effects" if field == "side_effects2"

        when "height2","weight2","height1","weight1"
          next if value.nil?
          value = value.to_f
        when "cpt1","cpt2"
          next if value.nil?
          field="first_cpt" if field == "cpt1"
          field="scd_cpt" if field == "cpt2"
        when "age"
          value = 20 if value.nil?
          value = value.to_i
        when "follow_up"
          value = "Yes" if value.nil?
          if value.match(/Yes/i)
            value = "Yes"
          elsif value.match(/no/i)
            value = "No"
          end
          value = value.to_s unless value.nil?
          field = "followup" 
        when "sex"
          value ="f" if value.nil?
          if value.match(/f|female/i)
            value = "Female"
          elsif value.match(/m|male/i)
            value = "Male"
          end
        when "initial_height", "initial_weight"
          value = value.to_f unless value.nil?
        when "transfer_in"
          value = "No" if value.nil?
          if value.match(/true|yes|x/i)
            value = true
          else
            value = false
          end
        when "reason_for_starting"
          value = PaperMastercard.parse_reason_for_starting(value) unless value.nil?
      end
      # Send is just like calling the method - but you can use strings
      # So this is like doing paper_master.first_name=value
      paper_mastercard.send(field+"=", value)

    }
    # handle everything else

     defining_conditions = PaperMastercardEntry.find(:all, :conditions => ["arvnumber = ? AND fieldid LIKE 'sdc_%' AND entry = 'C'", arv_number]).collect{|e|e.fieldid.sub(/sdc_/,"").sub(/\//,"").humanize}
      stage_defining_conditions = defining_conditions unless defining_conditions.to_s.match(/1|2/) rescue nil
    unless stage_defining_conditions.blank?
     if stage_defining_conditions.length > 1
       stage_defining_conditions.delete_if{|sdc|
         sdc.match(/unspecified/i)
       }
     end
    end
    paper_mastercard.reason_for_starting = stage_defining_conditions.join(",") if stage_defining_conditions.length > 0 rescue nil

    outcomes = PaperMastercardEntry.find(:all, :conditions => ["arvnumber = ? AND (fieldid LIKE 'alive%' OR fieldid LIKE 'dead%' OR fieldid LIKE 'default%' OR fieldid LIKE 'default' OR fieldid LIKE 'transfer_out') AND entry = 'C'", arv_number]).collect{|e|e.fieldid}
    last_outcome = outcomes.sort{|a,b|a.match(/\d+/)[0] <=> b.match(/\d+/)[0]}.last.gsub(/\d/,"").humanize unless outcomes.blank?

    paper_mastercard.last_outcome = last_outcome

    
    paper_mastercard.hiv_test_date = paper_mastercard.assemble_date("hiv_test")
    paper_mastercard.date_of_starting_1st_line = paper_mastercard.assemble_date("first_line")
   
    first_date = Array.new(),second_date=Array.new(),third_date=Array.new() 

    first_date = paper_mastercard.year1,paper_mastercard.month1,paper_mastercard.day1
    second_date = paper_mastercard.year2,paper_mastercard.month2,paper_mastercard.day2
    third_date = paper_mastercard.year3,paper_mastercard.month3,paper_mastercard.day3

    paper_mastercard.third_visit_date = PaperMastercard.make_date(*third_date) if third_date.length == 3
    paper_mastercard.scd_visit_date = PaperMastercard.make_date(*second_date) if second_date.length == 3
    paper_mastercard.first_visit_date = PaperMastercard.make_date(*first_date) if first_date.length == 3

    return paper_mastercard
  end

  def self.parse_reason_for_starting(string)
    return nil if string.nil?
    reason_for_starting = Array.new
    if string.match(/cd4/i)
      string.sub!(/cells|count/,"")
      if string.match(/cd4 *(\d+) *%/i) or string.match(/cd4% *(\d+)/i) or string.match(/cd4 *percent *(\d+)/i) or string.match(/cd4 *(\d+) *percent/i)
        reason_for_starting << "CD4% #{$1}"
      elsif string.match(/cd4 *(\d+)/i)
        reason_for_starting << "CD4 #{$1}"
      elsif string.match(/cd4 *< *(\d+)/i)
        reason_for_starting << "CD4 < #{$1}"
      else
        reason_for_starting << "CD4 Count < 250"
      end
    end
    reason_for_starting << self.validate_reason_for_starting(string) 

    if reason_for_starting.blank? || reason_for_starting.to_s == ""
      return "Unspecified stage 4 condition" if string.match(/4|IV/i)
      return "Unspecified stage 3 condition" if string.match(/3|III|lll/i)
      return "Unspecified stage 2 condition" if string.match(/2|II|ll/i)
      return "Unspecified stage 1 condition" if string.match(/1|I|l/i)
    end
    return reason_for_starting.join(",")
  end

  def assemble_date(prefix)
    # Create an array of date components
    date_array = ["year","month","day"].collect{|i| 
      PaperMastercardEntry.find_first_value_by_arv_number_and_field_id(self.arv_number, "#{prefix}_#{i}")
    }
    # The *date_array passes the array elements to the method as if they were 3 separate arguments
    return PaperMastercard.make_date(*date_array)

  end

  def self.make_date(year,month,day)
    year = year.to_i
    month = "Jul" if month.nil?
    return if year.nil? || year == 0
    if month.match(/[A-Za-z]/)
      month = Date::ABBR_MONTHNAMES.index(month.humanize)
    else
      month = month.to_i
    end
    day = day.to_i
    month = 7 if month == 0 || month.nil? 
    if month > 12 or month < 1
      month = 7
      day = 1
    end
    day = 15 if day < 0 or day > 31 or day.nil? or day==0
    return self.create_date(year,month,day) 
  end
  
  def self.create_date(year,month,day) 
     return if year.nil? || month.nil? || day.nil?
     date = nil
     while(date.nil?)
       begin
         date = Date.new(year.to_i, month.to_i, day.to_i).strftime("%Y-%m-%d")
       rescue Exception => e 
         day = day.to_i - 1
         raise "Invalid Date" if day < 1
       end 
     end
     return date
  end
  
  def self.enter_visit_data(patient,patient_obj)
    #puts "writing visits................."

    ["first_outcome","scd_outcome","third_visit_date","height3","weight3","third_outcome","third_reg","third_amb","third_wrk_sch","third_side_effects","third_pill_count","third_receiver_guardian_patient","third_cpt","scd_visit_date","scd_outcome","height2","weight2","scd_reg","scd_amb","scd_wrk_sch","scd_side_effects","scd_pill_count","scd_receiver_guardian_patient","scd_cpt","first_visit_date","weight1","height1","first_reg","first_amb","first_wrk_sch","first_side_effects","first_pill_count","first_receiver_guardian_patient","first_pill_count","first_cpt","starter"].each{|field|
    date = patient_obj.third_visit_date if field.match(/third/i)
    date = patient_obj.scd_visit_date if field.match(/scd|height2|weight2/i)
    date = patient_obj.first_visit_date if field.match(/starter|first|height1|weight1/i)

    next if date.blank? 
    case field
      when "height1","height2"
        next if patient_obj.send(field).nil?
        patient.set_last_height(patient_obj.send(field), date)
      when "weight1","weight2"
        next if patient_obj.send(field).nil?
        patient.set_last_weight(patient_obj.send(field), date)
      when "starter"
        patient.set_last_arv_reg("Stavudine 30 Lamivudine 150",15,date) unless patient.transfer_in?
        patient.set_last_arv_reg("Stavudine 30 Lamivudine 150 Nevirapine 200",15,date) unless patient.transfer_in?
        if patient_obj.send(field).blank? 
          patient.set_last_arv_reg("Stavudine 30 Lamivudine 150 Nevirapine 200",60,date) if patient.transfer_in? 
        elsif patient_obj.send(field).match(/T30/i)
          patient.set_last_arv_reg("Stavudine 30 Lamivudine 150 Nevirapine 200",60,date) if patient.transfer_in? 
        elsif patient_obj.send(field).match(/T40/i)
          patient.set_last_arv_reg("Stavudine 40 Lamivudine 150 Nevirapine 200",60,date) if patient.transfer_in?
        end
        unless patient_obj.first_receiver_guardian_patient.nil?
           visit_by = "Guardian present" if patient_obj.first_receiver_guardian_patient.match(/G/i)
           visit_by = "Guardian present" if patient_obj.first_receiver_guardian_patient.match(/P/i)
           patient.set_type_of_visit(visit_by,date) unless visit_by.nil?
        end 
        patient.set_art_visit_pill_count("Stavudine 30 Lamivudine 150 Nevirapine 200",patient_obj.first_pill_count,date) if patient.transfer_in? and !patient_obj.first_pill_count.nil?
      when "first_amb","scd_amb"
        next if patient_obj.send(field).nil?
        patient.set_art_visit_encounter("Is able to walk unaided",patient_obj.send(field),date)
      when "scd_wrk_sch","first_wrk_sch"
        next if patient_obj.send(field).nil?
        patient.set_art_visit_encounter("Is at work/school",patient_obj.send(field),date)
      when "first_side_effects","scd_side_effects"
        next if patient_obj.send(field).nil?
        concept_name="Hepatitis" if patient_obj.send(field).match(/hp/i)
        concept_name="Skin rash" if patient_obj.send(field).match(/sk/i)
        concept_name="Peripheral neuropathy" if patient_obj.send(field).match(/pn/i)
        concept_name="Other side effect" if patient_obj.send(field).match(/yes/i)
        patient.set_art_visit_encounter(concept_name,"Yes",date)

      when "scd_receiver_guardian_patient"
        unless patient_obj.send(field).nil?
           visit_by = "Guardian present" if patient_obj.send(field).match(/G/i)
           visit_by = "Guardian present" if patient_obj.send(field).match(/P/i)
           patient.set_type_of_visit(visit_by,date) unless visit_by.nil?
        end 
      when "scd_reg"
        next unless patient.outcome.name.match(/On ART/i)
        patient_obj.scd_reg="T30" if patient_obj.send(field).nil?
        reg = "Stavudine 30 Lamivudine 150 Nevirapine 200" if patient_obj.send(field).match(/30/i)
        reg = "Stavudine 40 Lamivudine 150 Nevirapine 200" if patient_obj.send(field).match(/40/i)
        patient.set_last_arv_reg(reg,60,date) unless reg.nil?
        remaining_pill_count = patient_obj.scd_pill_count 
        patient.set_art_visit_pill_count("Stavudine 30 Lamivudine 150",remaining_pill_count,date) 
        patient.set_art_visit_pill_count("Stavudine 30 Lamivudine 150 Nevirapine 200",0,date)
      when "first_cpt","scd_cpt"
        next if patient_obj.send(field).nil?
        pill_count= 60 if patient_obj.send(field).match(/12|2/i)
        pill_count= 30 if patient_obj.send(field).match(/52/i)
        patient.set_last_arv_reg("Cotrimoxazole 480",pill_count,date) unless pill_count.nil?
      when "first_outcome","scd_outcome"
        next if patient_obj.send(field).nil?
        outcome = patient_obj.send(field)
        patient.set_outcome(outcome,date) 
    end
    
    }
  end

  def self.infer_and_create_first_visit(patient)
# skip guardians
    return if patient.arv_number.nil?
    if patient.encounters.length > 2
      puts "First visit exists"
      return
    end

    User.current_user = User.find_by_username("mikmck") if User.current_user.nil?
    if patient.transfer_in?
      puts "transfer in"
      yell "Transfer in: #{patient.arv_number}"
      return
    end

    print patient.arv_number

    begin

    date_of_first_visit = ["first_line_year", "first_line_month", "first_line_day"].collect{|field_id| 
      arv_number = patient.arv_number
      (site,num) = arv_number.split(/ /)
      arv_number = site + num.rjust(4,'0')
      PaperMastercardEntry.find_first_value_by_arv_number_and_field_id(arv_number, field_id)
    }.join("-").to_date

    rescue
      puts "Skipping, no start date for #{patient.arv_number}"
      yell "Skipping, no start date for #{patient.arv_number}"
      return
    end

    PaperMastercard.fix_salima_dates(patient, date_of_first_visit)

    puts " #{date_of_first_visit}"

    begin
    height_weight = Encounter.new
    height_weight.provider = User.current_user
    height_weight.type = EncounterType.find_by_name("Height/Weight")
    height_weight.encounter_datetime = date_of_first_visit
    height_weight.patient = patient
    height_weight.save
    weight = patient.observations.find_by_concept_name("Weight").first
    weight.encounter = height_weight
    weight.obs_datetime = date_of_first_visit
    weight.save!
    rescue
      puts "Skipping, no weight for #{patient.arv_number}"
      yell "Skipping, no weight for #{patient.arv_number}"
      return
    end

    art_visit = Encounter.new
    art_visit.provider = User.current_user
    art_visit.type = EncounterType.find_by_name("ART Visit")
    art_visit.encounter_datetime = date_of_first_visit
    art_visit.patient = patient
    art_visit.save!

    [["Prescribe recommended dosage","Yes"],["Is able to walk unaided","Yes"],["Prescribe Cotrimoxazole (CPT)","Yes"],["Is at work/school","Yes"],["Peripheral neuropathy","No"],["Hepatitis","No"],["Continue treatment at current clinic","Yes"],["Skin rash","No"],["Prescription time period","2 weeks"],["Lactic acidosis","No"],["Lipodystrophy","No"],["ARV regimen","Stavudine Lamivudine + Stavudine Lamivudine Nevirapine"],["Anaemia","No"],["Refer patient to clinician","No"],["Other side effect","No"]].each{|obs_concept_and_answer|

      obs_concept, obs_answer_concept = obs_concept_and_answer
      observation = Observation.new
      observation.patient = patient
      observation.encounter = art_visit
      observation.obs_datetime = date_of_first_visit
      observation.concept = Concept.find_by_name(obs_concept)
      observation.answer_concept = Concept.find_by_name(obs_answer_concept)
      observation.save!
    }

    # Need two prescribed dose observations - mornign and evening
    drug_orders = DrugOrder.recommended_art_prescription(patient.current_weight)["Stavudine Lamivudine + Stavudine Lamivudine Nevirapine"]
    drug_orders.each{|drug_order|
      observation = Observation.new
      observation.patient = patient
      observation.encounter = art_visit
      observation.obs_datetime = date_of_first_visit
      observation.concept = Concept.find_by_name("Prescribed dose")
      # do logic to determine dose from weight
      observation.value_drug = drug_order.drug.id
      observation.value_text = drug_order.frequency
      observation.value_numeric = drug_order.units
      observation.save!
    }

    give_drugs = Encounter.new
    give_drugs.provider = User.current_user
    give_drugs.type = EncounterType.find_by_name("Give drugs")
    give_drugs.encounter_datetime = date_of_first_visit
    give_drugs.patient = patient
    give_drugs.save!

    order_type = OrderType.find_by_name("Give drugs")

    drug_orders.each{|drug_order|
      order = Order.new
      order.order_type = order_type
      order.orderer = User.current_user.id
      order.encounter = give_drugs
      order.save!
      drug_order.order = order
      drug_order.quantity = 15
      drug_order.save!
    }
    return nil
  end

  def self.fix_salima_dates(patient, date)
    ["HIV First visit", "HIV Staging"].each{|encounter_type_name|
      encounter = patient.encounters.find_by_type_name(encounter_type_name).first
      encounter.encounter_datetime = date
      encounter.save
      encounter.observations{|observation|
        observation.obs_datetime = date
        observation.save
      }
    }
  end

#   :third_visit_date, :height3, :weight3 , :last_outcome,:third_outcome, :third_reg, :third_amb, :third_wrk_sch, :third_side_effects, :third_pill_count, :third_receiver_guardian_patient, :third_cpt, :scd_visit_date, :scd_outcome, :height2 , :weight2, :scd_outcome, :scd_reg, :scd_amb, :scd_wrk_sch, :scd_side_effects, :scd_pill_count, :scd_receiver_guardian_patient, :scd_cpt, :first_visit_date, :weight1 , :height1, :first_outcome, :first_reg, :first_amb, :first_wrk_sch, :first_side_effects, :first_pill_count, :first_receiver_guardian_patient,:first_pill_count, :first_cpt,:year1,:year2,:year3,:month1,:month2,:month3 ,:day1,:day2,:day3,:starter 
end
