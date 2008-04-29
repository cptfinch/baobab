class PihDatas < ActiveRecord::Base

  #attr_accessor :arv_number, :first_name, :last_name, :age, :sex,:reason_for_starting,:outcome_status,:side_effects,:cd4_started_with

  
  def self.get_all
    all_pih_patients = self.find(:all).collect{|pih|pih}
    return all_pih_patients
  end
 

    def self.create_openmrs_patients
     count = 0
     User.current_user = User.find_by_username("administrator")
     return "Current user not set..!! set Current User" if User.current_user.blank?
     patients=self.get_all
     patients.each{|pat|
     #puts "Processing #{pat.arv_number}..."
      count+= 1
      self.to_patients(pat,count) 
     }
   end
 
   def self.to_patients(patient_obj,count) 
      puts "writing patient data:       Patient number #{count}"
      #puts patient_obj
      patient = Patient.new
      patient.save
      
      patient.gender = "Male"
      patient.gender = "Female" if patient_obj.sex.match(/F/i)
      patient.set_national_id
      name_length  = patient_obj.name.length
      patient_name = patient_obj.name.strip[1..(name_length - 2)]
      patient.set_name(patient_name.split[0],patient_name.split[1])
      init_date = patient_obj.date_registered.to_date unless patient_obj.date_started.nil?
      init_date = Date.today if patient_obj.date_registered.nil?
      patient.add_program_by_name("HIV")
      test_date = patient_obj.date_started
    #test_date = init_date if test_date.nil?
      patient.set_hiv_test_date(test_date) unless test_date.nil?
     # location_name = self.location_name(patient_obj.hiv_test_place) unless patient_obj.hiv_test_place.nil?
      #patient.set_hiv_test_location(location_name,test_date) unless location_name.nil? and test_date.nil?
     
     pih_table_object = self.new  
     field_names = pih_table_object.attribute_names
     field_names.each{|field|
       case field
         when "age"
            patient.age = (patient_obj.age)

	 when "reason_for_starting"
		   next if patient_obj.reason_for_starting.blank?
		  # reasons=Array.new()
		   reason = patient_obj.reason_for_starting
		 #  reasons.each{|reason|
		   reason = self.set_reason_for_starting(reason)
		   unless reason.blank?
	             puts reason		   
		     patient.set_art_staging_encounter(reason.to_s,"Yes",init_date) unless reason.to_s =="CD4 Count < 250"
		     patient.set_art_staging_int_cd4(patient_obj.cd_4,"",init_date) unless patient_obj.cd_4.blank?
		   end
		# }
	 when "regimen"
        ## 

		 patient.set_last_arv_reg("Stavudine 30 Lamivudine 150",15,init_date) unless patient.transfer_in?
		 patient.set_last_arv_reg("Stavudine 30 Lamivudine 150 Nevirapine 200",15,init_date) unless patient.transfer_in?
		if patient_obj.send(field).blank? 
		  patient.set_last_arv_reg("Stavudine 30 Lamivudine 150 Nevirapine 200",60,init_date) if patient.transfer_in? 
		elsif patient_obj.send(field).gsub(/"/,"").match(/T30/i)
		  patient.set_last_arv_reg("Stavudine 30 Lamivudine 150 Nevirapine 200",60,init_date) if patient.transfer_in? 
		elsif patient_obj.send(field).gsub(/"/,"").match(/T40/i)
		  patient.set_last_arv_reg("Stavudine 40 Lamivudine 150 Nevirapine 200",60,init_date) if patient.transfer_in?
		end

	 when "side_effects"
		 next if patient_obj.send(field).nil?
		  concept_name="Other side effect" if patient_obj.send(field).gsub(/"/,"").match(/X/i)
		  patient.set_art_visit_encounter(concept_name,"Yes",init_date)
	 when "transfer_in"
		 status = false
                 status = true if patient_obj.transfer_in == "T"
		 patient.set_transfer_in(status,init_date) 
	 when "transfer_out"
		    unless patient_obj.transfer_out.blank?
		     patient.set_outcome("Transfer Out(With Transfer Note)",Date.today)
		    end
	 when "death"
		   unless patient_obj.death.blank?
		     patient.set_outcome("Died",Date.today)
		   end

	 when "unique_id"     
		# puts patient_obj.unique_id 
	         pih_arv_number     = "PIH-D: " + patient_obj.unique_id
		 patient.arv_number = (pih_arv_number) unless patient_obj.send(field).blank?

     end
     }    
   end


   
   def self.setup_reason_for_starting_map
      @@reason_for_starting_map = Hash.new
      #open file
      last_openmrs = ""
      File.open(File.join(RAILS_ROOT, "app/models/reasons_for_starting.csv"), File::RDONLY).readlines.each{|line|
       (pih, openmrs) = line.gsub(/"/,"").chomp.split(",")
      
       if openmrs.blank?
         @@reason_for_starting_map[pih] = last_openmrs
       else
         @@reason_for_starting_map[pih] = openmrs
       end
       last_openmrs = @@reason_for_starting_map[pih]
      }	      
      #find corresponding reason
      #assign vocabulary specific reason for starting
      #
   end	   

   setup_reason_for_starting_map
   
   def self.set_reason_for_starting(value)
    openmrs_reason =  @@reason_for_starting_map[value.gsub(/"/,"")]
    return openmrs_reason
   end
end
