class Collection < ActiveRecord::Base
  usesguid

  has_many_polymorphs :items, :from => [:text_items, :images], :through => :ownerships
  belongs_to :owner, :class_name => "Person"
  belongs_to :client
  serialize :metadata, Hash

  validates_presence_of :client

  def to_json(*a)
    {
      'id' => id,
      'entry' => items,
      'metadata' => metadata
    }.to_json(*a)
  end

  def metadata=(data)
    old = read_attribute(:metadata) || Hash.new
    write_attribute(:metadata, old.merge(data))
  end

  # Returns true if the given person, using the given client, has permission to view this collection.
  def read?(person, client)
    if owner == nil
      return self.client == client
    end
    return (self.client == nil || self.client == client) && (owner == person || owner.contacts.include?(person))
  end

  # Returns true if the given person, using the given client, has permission to change this collection.
  def write?(person, client)
    return read?(person, client) && (owner == person || ! read_only)
  end

  # Returns true if the given person, using the given client, has permission to delete this collection.
  def delete?(person, client)
    return write?(person, client) && (owner == nil || owner == person)
  end

  # Attempts to create an item and add it to this collection.
  def create_item(options)
    if options[:file] && options[:file].content_type.start_with?("image")
      image = Image.new
      if (image.save_to_db?(options))
        items << image
        return true
      else 
        return false
      end
      # image = Image.new(:content_type => options[:file].content_type,
      #                         :filename => options[:file].original_filename, 
      #                         :data => options[:file].read)
      #       image.full_image_size = options[:full_image_size]
      #       image.thumbnail_size = options[:thumbnail_size]                  
      #       if image.valid_file? and image.successful_conversion?
      #         image.save
      #         items << image
      #         return true
      #       else 
      #         return false
      #       end    
    elsif options[:content_type].start_with?("text")
      text_item = TextItem.new(:text => options[:body])
      text_item.save
      items << text_item
      return true
    end
    return false
  end
end
