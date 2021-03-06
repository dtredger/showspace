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
#  slug         :string(255)      not null
#

class Item < ActiveRecord::Base

  include PriceCheckable

  include FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  enum state: {incomplete: 0, pending: 1, live: 2, retired: 3,
               banned: 4, deleted: 5}

  has_and_belongs_to_many :closets
  has_many :users, through: :closets
	has_many :likes, as: :likeable, dependent: :destroy
  has_many :matches, through: :duplicate_warnings, source: :existing_item
  has_many :duplicate_warnings, foreign_key: "pending_item_id"
  # TODO does not allow bidirectional foreign_key, if uncommented will override above
  # has_many :duplicate_warnings, foreign_key: "existing_item_id"
  # TODO image files should be removed from s3: if they're just deleted, we lose
  # any way of finding them (calling destroy on image alone does remove...)
  has_many :images, dependent: :destroy

  # Virtual attribute
  attr_accessor :old_item_update

  # For the money-rails gem
  monetize :price_cents,
           allow_nil: true,
           with_model_currency: :currency

  default_scope -> { order('created_at DESC') }
  scope :search_min_price, -> (min_price) { where("price_cents >= ?", min_price) }
  scope :search_max_price, -> (max_price) { where("price_cents <= ?", max_price) }
  scope :search_designer, -> (designer) { where("designer LIKE ?", "#{designer}%") }
  scope :search_category1, -> (category1) { where("category1 LIKE ?", "#{category1}%") }


  validates_uniqueness_of :product_link

  after_update :check_for_duplicate

  after_destroy :delete_duplicate_warnings


  def slug_candidates
    [
        [:designer, :product_name ],
        [:designer, :product_name, :store_name ],
        [:designer, :product_name, :store_name, :category1 ]
    ]
  end


  # TODO - delete warning once one of matches is deleted
  # deletes matches where item is existing or pending item
  def delete_duplicate_warnings
    if self.duplicate_warnings.any?
      warnings = self.duplicate_warnings
      if self.duplicate_warnings.respond_to? :each
        warnings.each { |warn| warn.destroy }
      else !warnings.nil?
        warnings.destroy
      end
    end
    warnings = DuplicateWarning.find_by(existing_item_id: self.id)
    if warnings.respond_to? :each
      warnings.each { |warn| warn.destroy }
    elsif !warnings.nil?
      warnings.destroy
    end
  end

  def check_for_duplicate
    if self.store_name
      check_items = Item.where(store_name: self.store_name).where.not(id: self.id)
      score = 0
      notes = ""
      check_items.each do |check_item|
        if self.sku == check_item.sku
          score += 100
          notes += "sku, "
        end
        if self.product_name == check_item.product_name
          score += 70
          notes += "product_name, "
        end
        if self.price_cents == check_item.price_cents
          score += 35
          notes += "price, "
        end
        if self.designer == check_item.designer
          score += 20
          notes += "designer, "
        end
        if self.category1 == check_item.category1
          score += 15
          notes += "category, "
        end
        if score >= 70
          notes = notes[0..-3] if notes.last(2) == ", "
          self.duplicate_warnings.create(existing_item_id: check_item.id,
              match_score: score,
              warning_notes: notes)
        end
      end
    end
  end


end
