module Sprouter
  class PF
    def tables
      @tables ||= read_tables
    end

    def table_entries(table)
      @table_entries ||= Hash.new { |h, table| h[table] = read_table(table) }
    end

    private

    def read_tables
      lines "pfctl", "-s", "Tables"
    end

    def read_table(table)
      lines "pfctl", "-t", table, "-T", "show"
    end

    def lines(*cmd)
      IO.popen(cmd) { |pf| pf.each_line.map(&:strip) }
    end
  end
end
