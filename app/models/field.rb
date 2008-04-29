class Field < OpenMRS
  set_table_name "field"
  has_many :form_fields, :foreign_key => :field_id, :dependent => :delete_all
  has_many :forms, :through => :form_fields
  has_many :field_answers, :foreign_key => :field_id
  belongs_to :concept, :foreign_key => :concept_id
  belongs_to :user, :foreign_key => :user_id
  belongs_to :type, :class_name=> "FieldType", :foreign_key => :field_type
#field_id
  set_primary_key "field_id"


  @@field_hash_by_name = Hash.new
  @@field_hash_by_id = Hash.new
  self.find(:all).each{|field|
    @@field_hash_by_name[field.name.downcase] = field
    @@field_hash_by_id[field.id] = field
  }

# Use the cache hash to get these fast
  def self.find_from_ids(args, options)
    super if args.length > 1 and return
    return @@field_hash_by_id[args.first] || super
  end
  
  def self.find_by_name(field_name)
    return @@field_hash_by_name[field_name.downcase] || super
  end

  def infer_field_type
    puts "Inferring field type for field: " + self.name

    unless self.type.nil?
      puts self.name + " current type:" + self.type.name
    end

    if self.concept.concept_answers.length == 0 and self.type.nil?
      puts "Set field type as alpha (a), number (n), date (d) or enter to skip?"
      $stdin.gets
      self.field_type = FieldType.find_or_create_by_name("alpha") if $_.match(/a/i)
      self.field_type = FieldType.find_or_create_by_name("number") if $_.match(/n/i)
      self.field_type = FieldType.find_or_create_by_name("date") if $_.match(/d/i)
      self.save
    else
#      puts "Currently has answers: " + self.concept.concept_answers.collect{|ans| ans.answer_option.name}.join(", ")
#      puts "Make field type select box?"
#      $stdin.gets
#      self.type = FieldType.find_or_create_by_name("select") if $_.match(/y/i)
#      self.save
    end

  end
  
  def Field.create_fields_from_concepts
    puts "Who are you?"
    puts User.find_all.collect{|user| user.id.to_s + ": " + user.username + "\n"}
    $stdin.gets
    user = User.find($_)

    puts "Which form would you like to add the fields to?"
    puts Form.find_all.collect{|form| form.id.to_s + ": " + form.name + "\n"}
    $stdin.gets
    form = Form.find($_)
    
    Concept.find_all_by_is_set("false").each{ |concept|
      puts "Create field for #{concept.name}?"
      $stdin.gets
      if $_ =~ /y/i
        field = Field.new
        field.name = concept.name
        field.concept = concept
        form_field = FormField.new
        form_field.form = form
        form_field.field = field
        form_field.min_occurs = 1
        form_field.max_occurs = 1
        form_field.required = true
        form_field.save
        field.save
      end
    }
  end

  # Insert this field in the specified form at the specified position
  def insert_in_form_at(form, position=1)
    form_field = FormField.find(:first, :conditions => ['form_id = ? and field_number = ?', form.id, position])
    if form_field
      # desired position already taken. Push everyone at and after my position down
      form_fields = FormField.find(:all, :conditions => ['form_id = ? and field_number >= ?', form.id, position]).collect{|ff| ff}
      form_fields.each{|form_field|
        form_field.field_number += 1
        form_field.save
      }
    end
    # assign position to self in this form
    new_form_field = FormField.new(:form_id => form.id, :field_id => self.id, 
                                   :field_number => position, 
                                   :creator => User.current_user.id,
                                   :date_created => Time.now)
    new_form_field.save
  end

end



### Original SQL Definition for field #### 
#   `field_id` int(11) NOT NULL auto_increment,
#   `name` varchar(255) NOT NULL default '',
#   `description` text,
#   `field_type` int(11) default NULL,
#   `concept_id` int(11) default NULL,
#   `table_name` varchar(50) default NULL,
#   `attribute_name` varchar(50) default NULL,
#   `default_value` text,
#   `select_multiple` tinyint(1) NOT NULL default '0',
#   `creator` int(11) NOT NULL default '0',
#   `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
#   `changed_by` int(11) default NULL,
#   `date_changed` datetime default NULL,
#   PRIMARY KEY  (`field_id`),
#   KEY `concept_for_field` (`concept_id`),
#   KEY `user_who_changed_field` (`changed_by`),
#   KEY `user_who_created_field` (`creator`),
#   KEY `type_of_field` (`field_type`),
#   CONSTRAINT `concept_for_field` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
#   CONSTRAINT `type_of_field` FOREIGN KEY (`field_type`) REFERENCES `field_type` (`field_type_id`),
#   CONSTRAINT `user_who_changed_field` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`),
#   CONSTRAINT `user_who_created_field` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
