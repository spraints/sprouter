require_relative "pf"
module Sprouter
  class Status
    def self.run!(*)
      pf = PF.new
      pf.tables.each do |table|
        puts table
        pf.table_entries(table).each do |ip|
          puts "  #{ip}"
        end
      end
    end
  end
end
