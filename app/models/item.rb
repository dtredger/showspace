# == Schema Information
#
# Table name: items
#
#  id           :integer          not null, primary key
#  product_name :text
#  description  :text
#  designer     :text
#  price_cents  :integer
#  currency     :string(255)
#  store_name   :string(255)
#  product_link :text
#  category1    :string(255)
#  category2    :string(255)
#  category3    :string(255)
#  state        :integer
#  created_at   :datetime
#  updated_at   :datetime
#  sku          :string(255)
#

class Item < ActiveRecord::Base

  has_and_belongs_to_many :closets
  has_many :users, through: :closets
	has_many :likes, as: :likeable, dependent: :destroy
  has_many :matches, through: :duplicate_warnings, source: :existing_item
  has_many :duplicate_warnings, foreign_key: "pending_item_id", dependent: :destroy
  #TODO does not allow bidirectional foreign_key, if uncommented will override above
  # has_many :duplicate_warnings, foreign_key: "pending_item_id", dependent: :destroy
  has_many :images, dependent: :destroy

  # Virtual attribute
  attr_accessor :old_item_update

  # For the money-rails gem
  monetize :price_cents, :allow_nil => true
  monetize :price_cents, with_model_currency: :currency

  default_scope -> { order('created_at DESC') }
  scope :search_min_price, -> (min_price) { where("price_cents >= ?", min_price) }
  scope :search_max_price, -> (max_price) { where("price_cents <= ?", max_price) }
  scope :search_designer, -> (designer) { where("designer LIKE ?", "#{designer}%") }
  scope :search_category1, -> (category1) { where("category1 LIKE ?", "#{category1}%") }


  # TODO - "In Rails 4.1 delete_all on associations would not fire callbacks. It means if the
  # :dependent option is :destroy then the associated records would be deleted without loading and invoking callbacks."
  after_create :check_for_duplicate
  before_destroy :delete_duplicate_warnings
  after_save :perform_item_management_operation, :handle_state

  # either delete doesn't work properly or problem with image transfer?
  def perform_item_management_operation
    if old_item_update.present?

      # update the older item with the attributes of the newer item (duplicate)
      other_item = Item.find(old_item_update)
      other_item_image_path = 'public' + other_item.image_source


      # http://stackoverflow.com/questions/10112946/nice-way-to-merge-copy-attributes-between-two-activerecord-classes
      # no :without_protection => true in rails 4 for assign?
      # http://stackoverflow.com/questions/6770350/rails-update-attributes-without-save
      # update_attributes = assign_attributes + save
      # SIMPLY UPDATE EACH ATTRIBUTE DIRECTLY
      # a.attrib = b.attrib
      # a.save
      forbidden_attributes = ["id", "state", "created_at", "category1", "category2", "category3", "image_source"]

      self.attributes.select do |attrib, val|
        if !forbidden_attributes.include?(attrib) && Item.column_names.include?(attrib)
          # http://www.davidverhasselt.com/set-attributes-in-activerecord/
          other_item.update_attribute(attrib, val)
        end
      end


      # copy the image too
      newer_item_image_path = 'public' + self.image_source
      FileUtils.move newer_item_image_path, other_item_image_path if File.exist?(newer_item_image_path)
      self.destroy
    end
  end

  def handle_state
    self.destroy if state == 4
  end

  def add_duplicate_warning!(other_item, match_score, warning_notes)
    self.duplicate_warnings.create!(existing_item_id: other_item.id, match_score: match_score, warning_notes: warning_notes)
  end

  # TODO - how would this be used?
  # def remove_duplicate_warning!(other_item)
  #   self.duplicate_warnings.find_by(existing_item_id: other_item.id).destroy
  # end

  # TODO - delete warning once one of matches is deleted
  # deletes matches where item is existing or pending item
  def delete_duplicate_warnings
    if self.duplicate_warnings
      self.duplicate_warnings.delete_all
    else
      warnings = DuplicateWarning.find_by(existing_item_id: self.id)
      warnings.delete_all unless warnings.nil?
    end
  end

  def check_for_duplicate
    if self.store_name
      check_items = Item.where(store_name: self.store_name).where.not(id: self.id)
      check_items.each do |check_item|
        if self.designer == check_item.designer && self.product_name == check_item.product_name
          self.add_duplicate_warning!(check_item, 0, "match: designer & product_name")
        end
      end
    end
  end

end
