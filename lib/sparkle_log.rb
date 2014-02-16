require 'entry'
module SparkleLog
	Data = Struct.new(:time, :os_version, :count) do
  	def as_json(options={})
    	{ time: self.time, count: self.count }.as_json(options)
  	end
	end

	def self.percent
  	all = Entry.by_week.count_major_os_version.count_all
  
	  all = all.map do |d| 
	    t = d.timestamp.to_date
	    c = d.count_all+5
	    range = (5..9).map{|i| d.send("count_#{i}").to_f }.reverse
	    range.each_with_index.map do |count, i| 
	      Data.new(t, "10.#{9-i}", count*100/c)
	    end
	  end
	  all.flatten.group_by(&:os_version).to_json
	end

	def self.support
		all = Entry.by_week.count_major_os_version.count_all

		all = all.map do |d| 
		  t = d.timestamp.to_date
		  c = d.count_all+5
		  range = (6..9).map{|i| d.send("count_#{i}").to_f }.reverse
		  range.size.times.map { |i|  range[0..i].reduce(:+) }
		  	.each_with_index.map do |count, i| 
		    	Data.new(t, "10.#{9-i}", count*100/c)
		  	end
		end
		all.flatten.group_by(&:os_version).to_json
	end

	def self.all
		all = Entry.by_week.by_major_os_version.count_all
		all = all.map do |d|
			Data.new(d.timestamp.to_date, d.major_os_version, d.count_all)
		end
		all = all.group_by(&:os_version)
		all['total'] = Entry.by_week.count_all.map do |d| 
			Data.new(d.timestamp.to_date, nil, d.count_all)
		end
		all.to_json
	end

	def self.version(version)
	  all = Entry.with_major_os_version(version).by_week.by_os_version.count_all
	  all = all.map{|d| Data.new(d.timestamp.to_date, d.os_version, d.count_all) }
	  all = all.group_by(&:os_version)
	  all['total'] = Entry.with_major_os_version(version)
	  	.by_week.count_all.map do |d| 
	    	Data.new(d.timestamp.to_date, nil, d.count_all)
	  	end
	  all.to_json
	end
end