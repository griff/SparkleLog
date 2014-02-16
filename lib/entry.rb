require 'city'

class Entry < ActiveRecord::Base
  belongs_to :city
  validates_uniqueness_of :timestamp, scope: :host
  
  def self.week
    select("date(timestamp, 'weekday '||strftime('%w', 'now')) AS timestamp")
  end
  
  def self.actual
    where.not(major_os_version:nil)
  end
  
  def self.by_week
    actual.week.group(:timestamp).order(:timestamp)
  end
  
  def self.by_major_os_version
    select(:major_os_version).group(:major_os_version).order(:major_os_version)
  end

  def self.by_os_version
    select(:os_version).group(:os_version).order(:os_version)
  end
  
  def self.count_all
    select('count(*) AS count_all')
  end
  
  def self.count_major_os_version
    (5..9).reduce(self.all) {|e, i| 
      e.select("sum(CASE WHEN major_os_version = '10.#{i}' THEN 1 ELSE 0 END)+1 AS count_#{i}")
    }
  end

  def self.with_major_os_version(version)
    where(major_os_version: version)
  end
end