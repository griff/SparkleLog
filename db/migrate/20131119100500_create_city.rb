class CreateCity < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.column :country_code2, :string
      t.column :country_code2, :string
      t.column :country_code3, :string
      t.column :country_name, :string
      t.column :continent_code, :string
      t.column :region_name, :string
      t.column :city_name, :string
      t.column :postal_code, :string
      t.column :latitude, :double
      t.column :longitude, :double
      t.column :dma_code, :integer
      t.column :area_code, :integer
      t.column :timezone, :string
    end
  end
end