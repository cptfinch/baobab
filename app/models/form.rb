class Form < OpenMRS
  set_table_name "form"
  has_many :form_fields, :foreign_key => :form_id, :dependent => :delete_all
  has_many :fields, :through => :form_fields
  has_many :encounters, :foreign_key => :form_id
  belongs_to :type_of_encounter, :class_name => "EncounterType",  :foreign_key => :encounter_type
  belongs_to :user, :foreign_key => :user_id
#form_id
  set_primary_key "form_id"

  def self.copy_staging_stuff
    adult_form = Form.find_by_name("ART adult staging")
    child_form = Form.find_by_name("ART child staging")
    
    adult_other = Form.find_by_name("ART adult staging other").form_fields.sort{|a,b|a.field_number<=>b.field_number}.collect{|ff|ff.field}
    child_other = Form.find_by_name("ART child staging other").form_fields.sort{|a,b|a.field_number<=>b.field_number}.collect{|ff|ff.field}
    
    adult_other.each{|field|
      form_field = FormField.new
      form_field.form_id = adult_form.id
      form_field.field_id = field.id
      form_field.field_number = adult_form.form_fields.collect{|ff|ff.field_number}.max + 1
      form_field.save
    }

    child_other.each{|field|
      form_field = FormField.new
      form_field.form_id = child_form.id
      form_field.field_id = field.id
      form_field.field_number = child_form.form_fields.collect{|ff|ff.field_number}.max + 1
      form_field.save
    }
  end
end


### Original SQL Definition for form #### 
#   `form_id` int(11) NOT NULL auto_increment,
#   `name` varchar(255) NOT NULL default '',
#   `version` varchar(50) NOT NULL default '',
#   `build` int(11) default NULL,
#   `published` tinyint(4) NOT NULL default '0',
#   `description` text,
#   `encounter_type` int(11) default NULL,
#   `schema_namespace` varchar(255) default NULL,
#   `template` mediumtext default NULL,
#   `infopath_solution_version` varchar(50) default NULL,
#   `uri` varchar(255) default NULL,
#   `xslt` mediumtext,
#   `creator` int(11) NOT NULL default '0',
#   `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
#   `changed_by` int(11) default NULL,
#   `date_changed` datetime default NULL,
#   `retired` tinyint(1) NOT NULL default '0',
#   `retired_by` int(11) default NULL,
#   `date_retired` datetime default NULL,
#   `retired_reason` varchar(255) default NULL,
#   PRIMARY KEY  (`form_id`),
#   KEY `user_who_created_form` (`creator`),
#   KEY `user_who_last_changed_form` (`changed_by`),
#   KEY `user_who_retired_form` (`retired_by`),
#   KEY `encounter_type` (`encounter_type`),
#   CONSTRAINT `form_encounter_type` FOREIGN KEY (`encounter_type`) REFERENCES `encounter_type` (`encounter_type_id`),
#   CONSTRAINT `user_who_created_form` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
#   CONSTRAINT `user_who_last_changed_form` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`),
#   CONSTRAINT `user_who_retired_form` FOREIGN KEY (`retired_by`) REFERENCES `users` (`user_id`)
