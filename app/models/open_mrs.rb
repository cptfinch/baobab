# CachedModel uses memcached to speed things up 
# crazy is not convinced it helps much
# It only caches very simply one row queries

#class OpenMRS < CachedModel
class OpenMRS < ActiveRecord::Base
  def before_save
    super
    self.changed_by = User.current_user.id if self.attributes.has_key? "changed_by" unless User.current_user.nil?
    self.date_changed = Time.now  if self.attributes.has_key? "date_changed"
  end

  def before_create
    super
    self.creator = User.current_user.id if self.attributes.has_key? "creator" unless User.current_user.nil?
    self.date_created = Time.now if self.attributes.has_key? "date_created"
    self.location_id = Location.current_location.id if self.attributes.has_key? "location_id" and self.location_id == 0 unless Location.current_location.nil?
  end
  
  def void!(reason)
    void(reason)
    save!
  end

  def void(reason)
    # TODO right now we are not allowing voiding to work on patient_identifiers
    # because of the composite key problem. Eventually this needs to be replaced
    # with better logic (like person_attributes)

#   TODO: this needs testing before turning on. For now, don't void Patient Identifiers
#    if composite?
#      destroy
#      return
#    end
    unless voided?
      #puts "---- Voided!!"
      self.date_voided = Time.now
      self.voided = true
      self.void_reason = reason
      self.voided_by = User.current_user.id unless User.current_user.nil?
    end    
  end
  
  def voided?
    self.attributes.has_key?("voided") ? voided : raise("Model does not support voiding")
  end  
  
  # cloning when there are composite primary keys
  # will delete all of the key attributes, we don't want that
  def composite_clone
    if composite? 
      attrs = self.attributes_before_type_cast
      self.class.new do |record|
        record.send :instance_variable_set, '@attributes', attrs
      end    
    else
      clone
    end  
  end

  def self.find_like_name(name)
    self.find(:all, :conditions => ["name LIKE ?","%#{name}%"])
  end

  # This can be used on models that have special identifier sets that should be
  # pre-loaded
  #
  #  cache_identifiers :name 
  #  
  
end

