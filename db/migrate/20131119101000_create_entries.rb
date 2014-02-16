class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
        t.column :host, :string
        t.column :timestamp, :datetime

        t.column :major_os_version, :string
        t.column :os_version, :string
        t.column :cputype, :integer
        t.column :cpu64bit, :boolean
        t.column :cpusubtype, :integer
        t.column :model, :string
        t.column :ncpu, :integer
        t.column :lang, :string
        t.column :app_version, :string
        t.column :cpu_freq_m_hz, :integer
        t.column :ram_mb, :integer
        
        t.column :city_id, :integer
    end
  end
end