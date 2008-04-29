class ComplexOb < OpenMRS
  set_table_name "complex_obs"
  belongs_to :ob, :foreign_key => :obs_id
  belongs_to :mime_type, :foreign_key => :mime_type_id
#obs_id
  set_primary_key "obs_id"
end


### Original SQL Definition for complex_obs #### 
#   `obs_id` int(11) NOT NULL default '0',
#   `mime_type_id` int(11) NOT NULL default '0',
#   `urn` text,
#   `complex_value` longtext,
#   PRIMARY KEY  (`obs_id`),
#   KEY `mime_type_of_content` (`mime_type_id`),
#   CONSTRAINT `complex_obs_ibfk_1` FOREIGN KEY (`mime_type_id`) REFERENCES `mime_type` (`mime_type_id`),
#   CONSTRAINT `obs_pointing_to_complex_content` FOREIGN KEY (`obs_id`) REFERENCES `obs` (`obs_id`)
