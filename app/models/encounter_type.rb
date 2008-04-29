class EncounterType < OpenMRS
  set_table_name "encounter_type"
  has_many :forms, :foreign_key => :encounter_type
  has_many :encounters, :foreign_key => :encounter_type
  belongs_to :user, :foreign_key => :user_id
  set_primary_key "encounter_type_id"
  
  @@encounter_type_hash_by_name = Hash.new
  @@encounter_type_hash_by_id = Hash.new
  self.find(:all).each{|encounter_type|
    @@encounter_type_hash_by_name[encounter_type.name.downcase] = encounter_type
    @@encounter_type_hash_by_id[encounter_type.id] = encounter_type
  }

# Use the cache hash to get these fast
  def self.find_from_ids(args, options)
    super if args.length > 1 and return
    return @@encounter_type_hash_by_id[args.first] || super
  end
  
  def self.find_by_name(encounter_type_name)
    return @@encounter_type_hash_by_name[encounter_type_name.downcase] || super
  end

  def url
    forms = self.forms
    return "/form/show/" + forms.first.id.to_s unless forms.blank?

    return "/drug_order/dispense" if self.name == "Give drugs"
    return "/patient/update_outcome" if self.name == "Update outcome"
  end

end


### Original SQL Definition for encounter_type #### 
#   `encounter_type_id` int(11) NOT NULL auto_increment,
#   `name` varchar(50) NOT NULL default '',
#   `description` varchar(50) NOT NULL default '',
#   `creator` int(11) NOT NULL default '0',
#   `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
#   PRIMARY KEY  (`encounter_type_id`),
#   KEY `user_who_created_type` (`creator`),
#   CONSTRAINT `user_who_created_type` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
