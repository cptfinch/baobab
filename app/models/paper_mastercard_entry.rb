class PaperMastercardEntry < ActiveRecord::Base
  #set_table_name "paper_mastercards"
  set_table_name "mastercards"
 
  @@cached_result = nil

#  def self.find_by_arv_number_and_field_id(arv_number, field_id)
    #result = self.find(:all,:conditions => ["mastercard_number=1 AND arvnumber = ? AND fieldid = ? AND entry = ?", arv_number, field_id, "C"],:order =>'mastercard_number')
    #result = @@cached_result[arv_number + "," + field_id]
    #return result
#  end
#
  def self.dump_cache
    puts self.cache.to_yaml
  end

  def self.cache
    unless @@cached_result
      counter = 0
      @@cached_result = Hash.new()
      self.find(:all, :select => "arvnumber,fieldid,fieldvalue", :conditions => ["mastercard_number = 1 AND entry = ?", "C"], :order => 'mastercard_number').each{|result|
        print "." if counter % 100 == 0
        print "#{counter} " if ((counter+=1) % 10000) == 0
        @@cached_result[result.arvnumber + "," + result.fieldid] = result.fieldvalue
      }
    end
    return @@cached_result
  end

  def self.find_first_value_by_arv_number_and_field_id(arv_number, field_id)
#    result = self.find_by_arv_number_and_field_id(arv_number, field_id)
    #puts "Warning: #{result.length} results were found for #{field_id}" if result.length != 1
#    result = result.first
#    return result.fieldvalue unless result.nil?
#    puts "looking up:"
#    puts "arv" + arv_number
    return self.cache[arv_number + "," + field_id]
#    return result unless result.nil?
  end

end

#DROP TABLE IF EXISTS `mastercards`;
#CREATE TABLE `mastercards` (
#  `id` int(11) NOT NULL auto_increment,
#  `arvnumber` varchar(50) NOT NULL,
#  `fieldid` varchar(100) NOT NULL,
#  `fieldvalue` varchar(100) NOT NULL,
#  `entry` char(1) NOT NULL,
#  `mastercard_number` int(2) default NULL,
#  `username` varchar(20) default NULL,
#  PRIMARY KEY  (`id`)
#) ENGINE=MyISAM DEFAULT CHARSET=latin1;

#address
#age
#alive
#alt_first_line_day
#alt_first_line_month
#alt_first_line_regimen
#alt_first_line_year
#amb
#arv_given_guardian
#arv_given_patient
#arv_not_given
#bed
#card_year
#CD4
#cpt
#day
#dead
#default
#eptb
#first_line_day
#first_line_month
#first_line_year
#first_name
#follow_up
#formulation
#free_text
#guardian_name
#height
#hiv_test_day
#hiv_test_month
#hiv_test_place
#hiv_test_year
#initial_height
#initial_weight
#ks
#last_name
#mastercard_id
#mastercard_number
#month
#other
#phone
#pills_given
#pills_remaining
#pmtct
#ptb
#reason_for_starting
#sdc_active_ptb/
#sdc_candidiasis_of_oesophagus/
#sdc_chronic_diarrhoea/
#sdc_cryptococcosis_extrapulmonary/
#sdc_cryptosporidiosis_with_diarrhoea/
#sdc_disseminated_endemic_mycosis/
#sdc_eptb/
#sdc_herpes_simplex_inf/
#sdc_hiv_encephalopathy/
#sdc_hiv_wasting_syndrome/
#sdc_kaposis_sarcoma/
#sdc_lymphoma/
#sdc_minor_muco_manifest/
#sdc_new_active_ptb/
#sdc_new_asymptomatic/
#sdc_new_candidiasis_of_oesophagus/
#sdc_new_chronic_diarrhoea/
#sdc_new_cryptococcosis_extrapulmonary/
#sdc_new_disseminated_endemic_mycosis/
#sdc_new_eptb/
#sdc_new_herpes_simplex_inf/
#sdc_new_herpes_zoster/
#sdc_new_hiv_wasting_syndrome/
#sdc_new_kaposis_sarcoma/
#sdc_new_minor_muco_manifest/
#sdc_new_oral_candidiasis/
#sdc_new_prolonged_fever/
#sdc_new_ptb_within_past_2_years/
#sdc_new_recent_severe_presumed_bacterial_infection/
#sdc_new_severe_bacterial_inf/
#sdc_new_severe_recurrent_bacterial_pneumonia/
#sdc_new_TB_lymphodenopathy/
#sdc_new_unexp_severe_wasting_stunting_or_malnutrition/
#sdc_new_uwl_gt_10_percent/
#sdc_new_WHO_stage_1_unspecified/
#sdc_new_WHO_stage_2_unspecified/
#sdc_new_WHO_stage_3_unspecified/
#sdc_new_WHO_stage_4_unspecified/
#sdc_oral_candidiasis/
#sdc_oral_hairy_leukoplakia/
#sdc_pneumocystis_carinii_pneumonia/
#sdc_prolonged_fever/
#sdc_ptb_within_past_year/
#sdc_severe_bacterial_inf/
#sdc_toxoplasmosis_of_brain/
#sdc_uwl_gt_10_percent/
#sdc_uwl_lt_10_percent/
#sdc_vulvo_vaginal_candidiasis/
#sdc_WHO_stage_2_unspecified/
#sdc_WHO_stage_3_unspecified/
#sdc_WHO_stage_4_unspecified/
#sex
#side_effects
#start
#stop
#sub
#switch
#temperature
#transfer_in
#transfer_out
#weight
#wrk_sch_no
#wrk_sch_yes
#year


